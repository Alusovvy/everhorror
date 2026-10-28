#!/usr/bin/env node
// Stamps the spec commit into script/build_info.gd just before an export (TECH-1) and checks that
// the version agrees in project.godot, CHANGELOG.md and tools/release/CZYTAJ_MNIE.txt (TECH-2).
//
// Usage, from anywhere (paths come from this file's location):
//   node tools/release/stamp_build.js                  stamp the recorded implementation baseline
//   node tools/release/stamp_build.js --spec <rev>     stamp that spec commit instead (a commit is
//                                                      a commit: no "+"), e.g. the one the
//                                                      CHANGELOG names as "Zgodność ze spec"
//   node tools/release/stamp_build.js --check          only check the versions, change nothing
// The spec repository is ../specification, or the folder named in the SPEC_DIR environment variable.
// Exit code 0 = fine, 1 = refused (the versions disagree, no such spec commit, git missing).
//
// Release order (CLAUDE.md "Build"): stamp -> godot --headless --import -> export -> make_zip.sh
// -> commit the stamp, CHANGELOG.md and CZYTAJ_MNIE.txt -> tag.

'use strict';
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.resolve(__dirname, '..', '..');
const specDir = require('../check_spec_data.js').specificationDir(root);

function fail(message) {
	console.error('stamp_build: ' + message);
	process.exit(1);
}

function read(relative) {
	return fs.readFileSync(path.join(root, relative), 'utf8');
}

function argument(name) {
	const index = process.argv.indexOf(name);
	if (index < 0) return null;
	const value = process.argv[index + 1];
	if (!value || value.startsWith('--')) fail(`${name} needs a value`);
	return value;
}

// The three places that name the version.
const found = {
	'project.godot (application/config/version)': (/^config\/version="([^"]+)"/m.exec(read('project.godot')) || [])[1],
	'CHANGELOG.md (newest "## [x.y.z]" heading)': (/^## \[([\d.]+)\]/m.exec(read('CHANGELOG.md')) || [])[1],
	'tools/release/CZYTAJ_MNIE.txt (first line, "demo x.y.z")': (/\(demo ([\d.]+)\)/.exec(read('tools/release/CZYTAJ_MNIE.txt').split(/\r?\n/)[0]) || [])[1],
};
const versions = new Set(Object.values(found));
if (versions.size !== 1 || versions.has(undefined)) {
	const lines = Object.entries(found).map(([where, version]) => `  ${version === undefined ? '(none)' : version}  ${where}`);
	fail('the version is not the same everywhere:\n' + lines.join('\n'));
}
const version = [...versions][0];

if (process.argv.includes('--check')) {
	console.log(`stamp_build: version ${version} agrees in project.godot, CHANGELOG.md and CZYTAJ_MNIE.txt`);
	process.exit(0);
}

function git(args) {
	try {
		return execFileSync('git', ['-C', specDir, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
	} catch (error) {
		return null;
	}
}

const wanted = argument('--spec');
let revision = wanted;
if (!wanted) {
	try {
		revision = execFileSync(process.execPath, [path.join(specDir, 'dashboard', 'cli.ts'), 'baseline', '--required', '--rev', 'HEAD'], { cwd: specDir, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
	} catch { fail(`could not resolve the recorded implementation baseline in ${specDir}`); }
	if (!/^[0-9a-f]{7,40}$/.test(revision)) fail('WDROZENIA.md has no valid implementation baseline');
}
const stamp = git(['rev-parse', '--short=7', '--verify', `${revision}^{commit}`]);
if (!stamp) fail(`no commit "${revision}" in ${specDir} (set SPEC_DIR if the specification lives elsewhere)`);

const target = path.join(root, 'script', 'build_info.gd');
const source = fs.readFileSync(target, 'utf8');
const pattern = /^const SPEC_SHA := "[^"]*"/m;
if (!pattern.test(source)) fail('script/build_info.gd has no SPEC_SHA constant to stamp');
fs.writeFileSync(target, source.replace(pattern, `const SPEC_SHA := "${stamp}"`));
console.log(`stamp_build: script/build_info.gd -> "${version} · spec ${stamp}"`);

// A hint, not a refusal: the CHANGELOG says which spec commit the newest version matches.
const entry = (/^## \[[\d.]+\][^\n]*\n([\s\S]*?)(?=^## \[|$(?![\s\S]))/m.exec(read('CHANGELOG.md')) || [])[1] || '';
const declared = (/Zgodność ze spec: `([0-9a-f]{7,40})`/.exec(entry) || [])[1];
if (!declared) {
	console.warn('stamp_build: warning: the newest CHANGELOG entry has no "Zgodność ze spec: `<sha>`" line');
} else if (!stamp.startsWith(declared.slice(0, 7))) {
	console.warn(`stamp_build: warning: the newest CHANGELOG entry says spec ${declared.slice(0, 7)}, the stamp is ${stamp}`);
}
