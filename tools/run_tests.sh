#!/usr/bin/env bash
# Runs the headless test scenarios and prints one line per scenario; full logs go to reports/tests/.
# Usage (from the project root):  tools/run_tests.sh              # all scenarios (ask the user first!)
#                                 tools/run_tests.sh day1 kaplica  # only the named ones
# Scenarios: dialogue (tools/dialogue_test.gd) and tools/tests/test_<name>.gd.
# Each scenario has its own watchdog; the outer timeout is a last resort.

GODOT="${GODOT:-C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe}"
LOGS="reports/tests"
mkdir -p "$LOGS"

tests=("$@")
if [ ${#tests[@]} -eq 0 ]; then
	tests=(dialogue day1 save_load rzapie night1 day2 kaplica day3 expedition drudzy week)
fi

failed=0
for name in "${tests[@]}"; do
	script="res://tools/tests/test_${name}.gd"
	[ "$name" = "dialogue" ] && script="res://tools/dialogue_test.gd"
	start=$(date +%s)
	timeout 180 "$GODOT" --headless --path . --script "$script" > "$LOGS/$name.log" 2>&1
	code=$?
	result=$(grep -m1 "^RESULT" "$LOGS/$name.log")
	[ -z "$result" ] && result="no RESULT line (exit $code), see $LOGS/$name.log"
	case "$result" in *"ALL PASSED"*) ;; *) failed=$((failed + 1)) ;; esac
	printf "%-10s %4ss  %s\n" "$name" "$(( $(date +%s) - start ))" "$result"
done
exit $failed
