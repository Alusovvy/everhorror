'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { balanceRow, validateBalance, specificationDir } = require('./check_spec_data.js');
const root = path.resolve(__dirname, '..');
const markdown = fs.readFileSync(path.join(specificationDir(root), '07_balans.md'), 'utf8');
const sources = Object.fromEntries(['script/game_state.gd', 'script/vn.gd', 'script/expeditions.gd'].map((file) => [file, fs.readFileSync(path.join(root, file), 'utf8')]));

test('the balance tables agree with the game constants', () => {
  const result = validateBalance(markdown, sources);
  assert.deepEqual(result.errors, []);
  assert.ok(result.checked >= 15);
});

test('a spec value change fails even when the game and its generators are unchanged', () => {
  assert.ok(validateBalance(markdown.replace('| Norma | 12 żył |', '| Norma | 13 żył |'), sources).errors.some((error) => error.includes('QUOTA')));
});

test('a game-only change fails against the Markdown source', () => {
  const changed = { ...sources, 'script/game_state.gd': sources['script/game_state.gd'].replace('const QUOTA := 12', 'const QUOTA := 13') };
  assert.ok(validateBalance(markdown, changed).errors.some((error) => error.includes('QUOTA')));
});

test('missing or ambiguous rows and unsupported syntax fail closed', () => {
  assert.throws(() => balanceRow(markdown + '\n## Żyły i norma\n| Norma | 12 żył |\n', 'Żyły i norma', 'Norma'), /found 2/);
  assert.ok(validateBalance(markdown.replace('| Norma | 12 żył |', '| Norma | kilkanaście żył |'), sources).errors.length > 0);
  assert.ok(validateBalance(markdown.replace('| Norma | 12 żył |', ''), sources).errors.length > 0);
});
