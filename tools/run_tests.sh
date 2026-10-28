#!/usr/bin/env bash
# Runs the headless test scenarios and prints one line per scenario; full logs go to reports/tests/.
# Usage (from the project root, or anywhere: the script moves to it):
#   tools/run_tests.sh                       # all scenarios (ask the user first!)
#   tools/run_tests.sh day1 kaplica          # only the named ones
#   tools/run_tests.sh -j 3 unit lint day1   # up to 3 scenarios at the same time (default 1)
#   EVERHORROR_TEST_DIR=<folder> tools/run_tests.sh unit lint dialogue day1
#                                            # the dashboard server's form (see below)
# Scenarios: dialogue (tools/dialogue_test.gd), balance (tools/balance_sim.gd, the balance bot: it
# also prints its BALANCE lines under its result), lint (tools/data_lint.gd, then
# `node tools/check_generated.js --scenes`, then the warning-only `node tools/rule_coverage.js`),
# check_generated and rule_coverage on their own, perf (tools/perf_probe.gd: needs a window, not
# part of the default list), export (tools/export_smoke.sh: day1 and expedition run from an exported
# pack; not in the default list) and tools/tests/test_<name>.gd.
# Each scenario has its own watchdog; the outer timeout is a last resort.
#
# Test folders (G-E1): every scenario gets its own folder `<base>/<scenario>` as
# EVERHORROR_TEST_DIR, where its saves (`saves/`) and run reports (`raporty/`) go (SaveManager
# reads the variable), and the folder is removed afterwards. <base> is the folder given in
# EVERHORROR_TEST_DIR (the dashboard gives one per branch copy), else a temporary one. The
# player's `%APPDATA%\Godot\app_userdata\Everhorror` saves and reports are never touched, so
# scenarios of several branch copies and `-j N` can run at the same time.
#
# Exit code: the number of failed scenarios. A scenario fails when its RESULT line is not
# "ALL PASSED", it has no RESULT line, or its log has an `ERROR:` / `SCRIPT ERROR:` line that is
# not on the allow-list below.

GODOT="${GODOT:-C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe}"
export GODOT
cd "$(dirname "$0")/.." || exit 99
LOGS="reports/tests"
mkdir -p "$LOGS"

# Known Godot exit noise and one known harmless line; everything else that logs `ERROR:` is red.
# Keep this list short and say why each entry is here.
ERROR_ALLOW='RID allocations of type|resources still in use at exit|Pages in use exist at exit in PagedAllocator|Parameter "material" is null'
#  RID allocations / resources still in use / PagedAllocator: leak reports of the headless engine at exit.
#  Parameter "material" is null: the dummy renderer at exit (material_get_instance_shader_parameters).

JOBS=1
tests=()
while [ $# -gt 0 ]; do
	case "$1" in
		-j) JOBS="$2"; shift 2 ;;
		-j[0-9]*) JOBS="${1#-j}"; shift ;;
		*) tests+=("$1"); shift ;;
	esac
done
case "$JOBS" in ''|*[!0-9]*) JOBS=1 ;; esac
[ "$JOBS" -lt 1 ] && JOBS=1
if [ ${#tests[@]} -eq 0 ]; then
	tests=(unit lint dialogue balance schedule places camp_walk hrapek first_meet day1 save_load rzapie night1 day2 kaplica day3 expedition drudzy week)
fi

# Godot (a Windows program) needs C:/… paths; Git Bash's /tmp/… would not open.
to_native() {
	if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
}
OWN_BASE=0
if [ -n "$EVERHORROR_TEST_DIR" ]; then
	BASE="$(to_native "$EVERHORROR_TEST_DIR")"
	mkdir -p "$BASE"
else
	BASE="$(to_native "$(mktemp -d)")"
	OWN_BASE=1
fi
OUTDIR="$(mktemp -d)"
cleanup() {
	rm -rf "$OUTDIR"
	if [ "$OWN_BASE" -eq 1 ]; then
		rm -rf "$BASE"
	else
		for name in "${tests[@]}"; do rm -rf "${BASE:?}/$name"; done
	fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM

# Runs one scenario; writes its printed lines to $OUTDIR/<name>.out and 0/1 (failed) to <name>.code.
run_scenario() {
	local name="$1"
	local out="$OUTDIR/$name.out" log="$LOGS/$name.log"
	local dir="$BASE/$name"
	local start result ok=1 errors bad code
	rm -rf "$dir"
	mkdir -p "$dir"
	start=$(date +%s)
	case "$name" in
		check_generated)
			node tools/check_generated.js --scenes > "$log" 2>&1
			code=$? ;;
		rule_coverage)
			node tools/rule_coverage.js > "$log" 2>&1
			code=0 ;;
		export)
			EVERHORROR_TEST_DIR="$dir" tools/export_smoke.sh day1 expedition > "$log" 2>&1
			code=$? ;;
		perf)
			EVERHORROR_TEST_DIR="$dir" timeout 300 "$GODOT" --path . --resolution 1280x720 --script res://tools/perf_probe.gd > "$log" 2>&1
			code=$? ;;
		*)
			local script="res://tools/tests/test_${name}.gd"
			[ "$name" = "dialogue" ] && script="res://tools/dialogue_test.gd"
			[ "$name" = "unit" ] && script="res://tools/unit_test.gd"
			[ "$name" = "lint" ] && script="res://tools/data_lint.gd"
			[ "$name" = "balance" ] && script="res://tools/balance_sim.gd"
			EVERHORROR_TEST_DIR="$dir" timeout 180 "$GODOT" --headless --path . --script "$script" > "$log" 2>&1
			code=$? ;;
	esac
	result=$(grep -m1 "^RESULT" "$log")
	if [ "$name" = "rule_coverage" ]; then
		result="RESULT: ALL PASSED  ($(grep -m1 '^RULES' "$log"))"
	fi
	[ -z "$result" ] && result="no RESULT line (exit $code), see $log"
	case "$result" in *"ALL PASSED"*) ;; *) ok=0 ;; esac

	# The lint scenario also checks that the generators are the source, and counts rule coverage.
	if [ "$name" = "lint" ]; then
		if command -v node >/dev/null 2>&1; then
			node tools/check_generated.js --scenes > "$LOGS/check_generated.log" 2>&1 || {
				ok=0
				result="$result  +check_generated FAILED, see $LOGS/check_generated.log"
			}
			node tools/rule_coverage.js --quiet > "$LOGS/rule_coverage.log" 2>&1
		else
			result="$result  (node not found: check_generated and rule_coverage skipped)"
		fi
	fi

	# A scenario that "passes" while the engine logs errors is not a pass (G-E3).
	bad=$(grep -E '^(SCRIPT |USER )?ERROR:' "$log" | grep -v -E "$ERROR_ALLOW")
	errors=0
	[ -n "$bad" ] && errors=$(printf '%s\n' "$bad" | grep -c .)
	if [ "$errors" -gt 0 ]; then
		ok=0
		result="$result  +$errors ERROR line(s), see $log"
	fi
	[ "$ok" -eq 0 ] && echo 1 > "$OUTDIR/$name.code" || echo 0 > "$OUTDIR/$name.code"
	{
		printf "%-10s %4ss  %s\n" "$name" "$(( $(date +%s) - start ))" "$result"
		[ "$errors" -gt 0 ] && printf '%s\n' "$bad" | head -3 | sed 's/^/             /'
		# The balance bot measures the pace (TECH-3): its answers are lines of their own; so does the perf probe.
		grep -E "^(BALANCE|PERF)" "$log" | sed 's/^/             /'
		if [ "$name" = "lint" ]; then
			grep -E "^WARNINGS" "$log" | sed 's/^/             /'
			grep -E "^RULES" "$LOGS/rule_coverage.log" 2>/dev/null | sed 's/^/             /'
		fi
	} > "$out"
	rm -rf "$dir"
}

failed=0
if [ "$JOBS" -le 1 ]; then
	for name in "${tests[@]}"; do
		run_scenario "$name"
		cat "$OUTDIR/$name.out"
		[ "$(cat "$OUTDIR/$name.code")" -ne 0 ] && failed=$((failed + 1))
	done
else
	for name in "${tests[@]}"; do
		while [ "$(jobs -rp | wc -l)" -ge "$JOBS" ]; do wait -n; done
		run_scenario "$name" &
	done
	wait
	for name in "${tests[@]}"; do
		cat "$OUTDIR/$name.out"
		[ "$(cat "$OUTDIR/$name.code")" -ne 0 ] && failed=$((failed + 1))
	done
fi
exit $failed
