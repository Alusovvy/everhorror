#!/usr/bin/env bash
# One script for the manual release steps (tools/README.md "Wydanie"):
#   tools/release/release.sh <version> [--spec <rev>] [--dry-run]
# version check -> stamp_build.js --check -> stamp_build.js -> --import -> --export-release ->
# make_zip.sh. It stops at the first error. At the end it PRINTS the git commit, tag and push
# commands and the reminder about the spec commit; it never runs them (the tag and the push stay
# with Roland after the merge). --dry-run prints every step and runs nothing, not even the
# version check. The Godot binary is $GODOT (default: the project's Godot 4.7.2 console exe).

set -euo pipefail
cd "$(dirname "$0")/../.."

usage() { echo "usage: tools/release/release.sh <version> [--spec <rev>] [--dry-run]" >&2; exit 2; }

version=""
spec=""
dry=0
while [ $# -gt 0 ]; do
	case "$1" in
		--dry-run) dry=1 ;;
		--spec) shift; [ $# -gt 0 ] || usage; spec="$1" ;;
		-*) usage ;;
		*) [ -z "$version" ] || usage; version="$1" ;;
	esac
	shift
done
[ -n "$version" ] || usage

godot="${GODOT:-C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe}"
stamp_args=()
[ -z "$spec" ] || stamp_args=(--spec "$spec")
export_log="reports/release-export.log"
marker="reports/.release-start"

step() { echo; echo "[$1/6] $2"; }

# Runs a command, or only prints it with --dry-run.
run() {
	echo "    \$ $*"
	[ "$dry" -eq 1 ] || "$@"
}

[ "$dry" -eq 0 ] || echo "DRY RUN: nothing is executed."

step 1 "the version $version equals application/config/version in project.godot"
if [ "$dry" -eq 1 ]; then
	echo "    (check skipped in a dry run)"
else
	current=$(sed -n 's/^config\/version="\(.*\)"/\1/p' project.godot)
	[ -n "$current" ] || { echo "release: no config/version in project.godot" >&2; exit 1; }
	[ "$current" = "$version" ] || { echo "release: project.godot says $current, not $version (bump it, CHANGELOG.md and CZYTAJ_MNIE.txt first)" >&2; exit 1; }
	echo "    ok: $current"
fi

step 2 "the version is the same in project.godot, CHANGELOG.md and CZYTAJ_MNIE.txt"
run node tools/release/stamp_build.js --check

step 3 "stamp the spec commit into script/build_info.gd"
run node tools/release/stamp_build.js ${stamp_args[@]+"${stamp_args[@]}"}

step 4 "import the assets"
run "$godot" --headless --path . --import

step 5 "export the Windows build (log: $export_log)"
if [ "$dry" -eq 1 ]; then
	echo "    \$ $godot --headless --path . --export-release \"Windows Desktop\" build/windows/Everhorror.exe > $export_log"
	echo "    (then: build/windows/Everhorror.exe must exist and be newer than the start of this script)"
else
	mkdir -p reports build/windows
	touch "$marker"
	"$godot" --headless --path . --export-release "Windows Desktop" build/windows/Everhorror.exe > "$export_log" 2>&1 || { echo "release: the export failed, see $export_log" >&2; exit 1; }
	# The console Godot can exit 0 after an error: trust the file, not the exit code.
	[ build/windows/Everhorror.exe -nt "$marker" ] || { echo "release: build/windows/Everhorror.exe was not written by this export, see $export_log" >&2; exit 1; }
	rm -f "$marker"
	echo "    ok: build/windows/Everhorror.exe"
fi

step 6 "zip: build/Everhorror-demo-$version-windows.zip"
run tools/release/make_zip.sh

echo
echo "Done. Not executed, for Roland (after the merge; the tag and the push are a standing permission, plan §9):"
echo "    git add script/build_info.gd CHANGELOG.md tools/release/CZYTAJ_MNIE.txt"
echo "    git commit -m \"Wydanie $version\""
echo "    git tag v$version"
echo "    git push origin master v$version"
echo "Put the SAME spec commit into CHANGELOG.md (\"Zgodność ze spec\"), the WDROZENIA.md entry and the tag message."
