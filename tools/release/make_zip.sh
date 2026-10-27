#!/usr/bin/env bash
# Zips the exported game with the tester's notes (TECH-2):
#   build/Everhorror-demo-<version>-windows.zip = Everhorror.exe + CZYTAJ_MNIE.txt + CHANGELOG.md,
# all at the top level. Run it from anywhere after the export (CLAUDE.md "Build"); the version
# comes from project.godot, and the zip is refused when the version in CHANGELOG.md or the
# CZYTAJ_MNIE.txt header differs (stamp_build.js --check).

set -euo pipefail
cd "$(dirname "$0")/../.."

node tools/release/stamp_build.js --check

version=$(sed -n 's/^config\/version="\(.*\)"/\1/p' project.godot)
[ -n "$version" ] || { echo "make_zip: no config/version in project.godot" >&2; exit 1; }
for file in build/windows/Everhorror.exe tools/release/CZYTAJ_MNIE.txt CHANGELOG.md; do
	[ -f "$file" ] || { echo "make_zip: missing $file (export first)" >&2; exit 1; }
done

out="build/Everhorror-demo-${version}-windows.zip"
rm -f "$out"
if command -v zip >/dev/null 2>&1; then
	zip -j -q "$out" build/windows/Everhorror.exe tools/release/CZYTAJ_MNIE.txt CHANGELOG.md
else
	shell=pwsh
	command -v pwsh >/dev/null 2>&1 || shell=powershell
	"$shell" -NoProfile -Command "Compress-Archive -Force -DestinationPath '$out' -Path 'build/windows/Everhorror.exe','tools/release/CZYTAJ_MNIE.txt','CHANGELOG.md'"
fi
ls -l "$out"
