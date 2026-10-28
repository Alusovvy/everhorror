'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const bash = process.env.EVERHORROR_BASH || (process.platform === 'win32' ? 'C:/Program Files/Git/bin/bash.exe' : 'bash');
const fake = `#!/usr/bin/env bash
if [[ " $* " == *" --export-pack "* ]]; then
  printf pack > "\${!#}"
  [ "$SMOKE_MODE" = export-error ] && echo 'SCRIPT ERROR: export failed'
  [ "$SMOKE_MODE" = export-nonzero ] && exit 9
  exit 0
fi
[ "$SMOKE_MODE" = no-result ] && exit 0
[ "$SMOKE_MODE" = conflicting-result ] && echo 'RESULT: 1 FAILED'
echo 'RESULT: ALL PASSED (fake scenario)'
[ "$SMOKE_MODE" = run-error ] && echo 'SCRIPT ERROR: missing resource'
[ "$SMOKE_MODE" = run-nonzero ] && exit 7
exit 0
`;

for (const mode of ['ok', 'export-error', 'export-nonzero', 'run-error', 'run-nonzero', 'no-result', 'conflicting-result']) {
  test(`export smoke: ${mode}`, () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'everhorror-smoke-'));
    try {
      fs.mkdirSync(path.join(root, 'tools'));
      fs.copyFileSync(path.join(__dirname, 'export_smoke.sh'), path.join(root, 'tools/export_smoke.sh'));
      const godot = path.join(root, 'fake-godot.sh');
      fs.writeFileSync(godot, fake, { mode: 0o755 });
      const result = spawnSync(bash, ['tools/export_smoke.sh', 'unit'], { cwd: root, encoding: 'utf8', timeout: 20_000, env: { ...process.env, GODOT: godot.replaceAll('\\', '/'), SMOKE_MODE: mode } });
      assert.ifError(result.error);
      assert.equal(result.status, mode === 'ok' ? 0 : 1, `${result.stdout}\n${result.stderr}`);
      assert.match(result.stdout, mode === 'ok' ? /^RESULT: ALL PASSED/m : /^RESULT: 1 FAILED/m);
    } finally { fs.rmSync(root, { recursive: true, force: true }); }
  });
}

test('manual release packaging stops when the exported-pack smoke test fails', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'everhorror-zip-gate-'));
  try {
    fs.mkdirSync(path.join(root, 'tools/release'), { recursive: true });
    fs.mkdirSync(path.join(root, 'build/windows'), { recursive: true });
    fs.copyFileSync(path.join(__dirname, 'release/make_zip.sh'), path.join(root, 'tools/release/make_zip.sh'));
    fs.writeFileSync(path.join(root, 'tools/release/stamp_build.js'), 'process.exit(0);\n');
    fs.writeFileSync(path.join(root, 'tools/export_smoke.sh'), 'echo "RESULT: 1 FAILED"; exit 1\n');
    fs.writeFileSync(path.join(root, 'project.godot'), 'config/version="1.2.3"\n');
    for (const file of ['build/windows/Everhorror.exe', 'tools/release/CZYTAJ_MNIE.txt', 'CHANGELOG.md']) fs.writeFileSync(path.join(root, file), 'fixture');
    const result = spawnSync(bash, ['tools/release/make_zip.sh'], { cwd: root, encoding: 'utf8', timeout: 20_000 });
    assert.ifError(result.error);
    assert.equal(result.status, 1, result.stderr);
    assert.match(result.stdout, /RESULT: 1 FAILED/);
    assert.equal(fs.existsSync(path.join(root, 'build/Everhorror-demo-1.2.3-windows.zip')), false);
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
