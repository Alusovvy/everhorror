'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync, spawnSync } = require('node:child_process');

test('stamping defaults to implemented baseline, allows an explicit revision, and refuses missing evidence', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'everhorror-stamp-'));
  try {
    const game = path.join(root, 'game');
    const spec = path.join(root, 'specification');
    for (const dir of ['tools/release', 'script']) fs.mkdirSync(path.join(game, dir), { recursive: true });
    fs.mkdirSync(path.join(spec, 'dashboard'), { recursive: true });
    fs.copyFileSync(__filename.replace('stamp_build.test.js', 'stamp_build.js'), path.join(game, 'tools/release/stamp_build.js'));
    fs.copyFileSync(path.join(__dirname, '../check_spec_data.js'), path.join(game, 'tools/check_spec_data.js'));
    fs.writeFileSync(path.join(game, 'project.godot'), 'config/version="1.2.3"\n');
    fs.writeFileSync(path.join(game, 'CHANGELOG.md'), '## [1.2.3]\n');
    fs.writeFileSync(path.join(game, 'tools/release/CZYTAJ_MNIE.txt'), 'Everhorror (demo 1.2.3)\n');
    const target = path.join(game, 'script/build_info.gd');
    fs.writeFileSync(target, 'const SPEC_SHA := "old"\n');
    const git = (...args) => execFileSync('git', ['-c', 'user.name=Test', '-c', 'user.email=test@example.invalid', '-c', 'commit.gpgsign=false', ...args], { cwd: spec, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
    git('init');
    fs.writeFileSync(path.join(spec, 'design.md'), 'implemented\n');
    git('add', '.'); git('commit', '-qm', 'baseline');
    const baseline = git('rev-parse', '--short=7', 'HEAD');
    fs.writeFileSync(path.join(spec, 'dashboard/cli.ts'), `console.log('${baseline}');\n`);
    fs.writeFileSync(path.join(spec, 'design.md'), 'newer design\n');
    git('add', '.'); git('commit', '-qm', 'design');
    const head = git('rev-parse', '--short=7', 'HEAD');
    fs.appendFileSync(path.join(spec, 'design.md'), 'unfinished\n');
    const stamp = (...args) => spawnSync(process.execPath, [path.join(game, 'tools/release/stamp_build.js'), ...args], { encoding: 'utf8', env: { ...process.env, SPEC_DIR: spec } });
    assert.equal(stamp().status, 0);
    assert.match(fs.readFileSync(target, 'utf8'), new RegExp(`"${baseline}"`));
    assert.equal(stamp('--spec', 'HEAD').status, 0);
    assert.match(fs.readFileSync(target, 'utf8'), new RegExp(`"${head}"`));
    fs.writeFileSync(path.join(spec, 'dashboard/cli.ts'), "console.log('');\n");
    assert.equal(stamp().status, 1);
    assert.match(fs.readFileSync(target, 'utf8'), new RegExp(`"${head}"`));
    assert.equal(stamp('--check').status, 0);
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
