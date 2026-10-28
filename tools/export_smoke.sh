#!/usr/bin/env bash
# Export smoke test (audit G7, G-E10; the missing test of the ticket "eksport gubi listy"):
# exports the game as a .pck with the "Test Pack" preset of export_presets.cfg (the release
# filters, plus tools/ so that test scripts can run) into a temporary folder, then runs
# scenarios FROM THAT PACK instead of from the project folder, so a resource the exporter
# drops or converts badly (a class_name-only script, a preloaded asset, a PackedStringArray that
# the binary conversion empties) fails a scenario the way it fails in the shipped game.
#
# Usage (from the project root):  tools/export_smoke.sh [scenario…]     # default: day1 expedition
#   scenarios: tools/tests/test_<name>.gd, or unit / lint / dialogue / balance
#   EVERHORROR_TEST_DIR=<folder>  base folder for the saves of the scenarios (default: a temporary one)
#   GODOT                         the Godot console exe
# Prints one `RESULT:` line (ALL PASSED, or n FAILED naming the scenarios) and a line per scenario;
# the exit code is the number of failed scenarios. Takes about 1 minute for the default pair.
# Needs `GODOT --headless --path . --import` to have been run (the exporter reads the import cache).

GODOT="${GODOT:-C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe}"
cd "$(dirname "$0")/.." || exit 99
scenarios=("$@")
[ ${#scenarios[@]} -eq 0 ] && scenarios=(day1 expedition)

to_native() {
	if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
}
TMP="$(mktemp -d)"
NATIVE="$(to_native "$TMP")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/run" "$TMP/saves"

start=$(date +%s)
timeout 600 "$GODOT" --headless --path . --export-pack "Test Pack" "$NATIVE/game.pck" > "$TMP/export.log" 2>&1
export_status=$?
ERROR_ALLOW='RID allocations of type|resources still in use at exit|Pages in use exist at exit in PagedAllocator|Parameter "material" is null|Capture not registered: .beehave.'
unexpected_errors() {
	grep -E '^[[:space:]]*(SCRIPT |USER )?ERROR:' "$1" | grep -Ev "$ERROR_ALLOW"
}
if [ "$export_status" -ne 0 ] || [ ! -s "$TMP/game.pck" ] || unexpected_errors "$TMP/export.log" >/dev/null; then
	mkdir -p reports/tests
	cp "$TMP/export.log" reports/tests/export_pack.log
	echo "RESULT: 1 FAILED (Test Pack export: exit $export_status; missing pack or errors; see reports/tests/export_pack.log)"
	unexpected_errors "$TMP/export.log" | head -5
	exit 1
fi
echo "export: $(( $(date +%s) - start ))s, game.pck $(( $(stat -c %s "$TMP/game.pck") / 1048576 )) MB"

failed=0
failed_names=""
for name in "${scenarios[@]}"; do
	script="res://tools/tests/test_${name}.gd"
	[ "$name" = "dialogue" ] && script="res://tools/dialogue_test.gd"
	[ "$name" = "unit" ] && script="res://tools/unit_test.gd"
	[ "$name" = "lint" ] && script="res://tools/data_lint.gd"
	[ "$name" = "balance" ] && script="res://tools/balance_sim.gd"
	base="${EVERHORROR_TEST_DIR:-$NATIVE/saves}"
	# From an empty folder, so that nothing is read from the project: only from the pack.
	( cd "$TMP/run" && EVERHORROR_TEST_DIR="$base/export-$name" timeout 240 "$GODOT" --headless --main-pack "$NATIVE/game.pck" --script "$script" > "$TMP/$name.log" 2>&1 )
	run_status=$?
	result=$(grep '^RESULT:' "$TMP/$name.log" | tail -1)
	[ -z "$result" ] && result="no RESULT line, see the log"
	if [ "$run_status" -ne 0 ] || [[ ! "$result" =~ ^RESULT:\ ALL\ PASSED([[:space:]]|$) ]] || grep '^RESULT:' "$TMP/$name.log" | grep -Ev '^RESULT: ALL PASSED([[:space:]]|$)' >/dev/null || unexpected_errors "$TMP/$name.log" >/dev/null; then
		failed=$((failed + 1)); failed_names="$failed_names $name"
		mkdir -p reports/tests; cp "$TMP/$name.log" "reports/tests/export_$name.log"
		grep -E '\[FAIL\]|^[[:space:]]*(SCRIPT |USER )?ERROR:' "$TMP/$name.log" | head -5 | sed 's/^/             /' >> "$TMP/fails.txt"
		result="FAILED (exit $run_status): $result"
	fi
	printf "%-12s %s\n" "$name" "$result"
done
[ -f "$TMP/fails.txt" ] && cat "$TMP/fails.txt"
if [ "$failed" -eq 0 ]; then
	echo "RESULT: ALL PASSED (export smoke: ${scenarios[*]} ran from the exported pack)"
else
	echo "RESULT: $failed FAILED (export smoke:$failed_names; logs in reports/tests/export_<name>.log)"
fi
exit $failed
