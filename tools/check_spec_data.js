'use strict';
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

function balanceRow(markdown, section, label) {
  let heading = '';
  const matches = [];
  for (const line of markdown.split(/\r?\n/)) {
    if (line.startsWith('## ')) heading = line.slice(3).trim();
    if (heading !== section || !line.startsWith('|')) continue;
    const cells = line.split('|').slice(1, -1).map((cell) => cell.trim());
    if (cells[0] === label) matches.push(cells[1]);
  }
  if (matches.length !== 1) throw new Error(`07_balans.md / ${section} / ${label}: expected one row, found ${matches.length}`);
  return matches[0];
}

function validateBalance(markdown, sources) {
  const errors = [];
  let checked = 0;
  function check(section, label, pattern, bindings) {
    try {
      const value = balanceRow(markdown, section, label);
      const match = pattern.exec(value);
      if (!match) throw new Error(`07_balans.md / ${section} / ${label}: unsupported value: ${value}`);
      for (const [capture, file, constant] of bindings) {
        const expected = Number(match[capture].replace(',', '.'));
        const definition = new RegExp(`^const ${constant}(?:\\s*:\\s*\\w+)?\\s*:?=\\s*(-?\\d+(?:\\.\\d+)?)\\s*$`, 'm').exec(sources[file] ?? '');
        const actual = definition ? Number(definition[1]) : null;
        checked++;
        if (actual !== expected) errors.push(`${file}: ${constant} = ${actual ?? '(missing)'}, spec ${section} / ${label} = ${expected}`);
      }
    } catch (error) { errors.push(error.message); }
  }
  const state = 'script/game_state.gd';
  check('Czas', 'Dzień', /^(\d+):00[–-](\d+):00\s*\((\d+) h\)/, [[1, state, 'DAY_START_HOUR'], [3, state, 'DAY_LENGTH_HOURS']]);
  try {
    const day = /^(\d+):00[–-](\d+):00\s*\((\d+) h\)/.exec(balanceRow(markdown, 'Czas', 'Dzień'));
    if (day && Number(day[2]) - Number(day[1]) !== Number(day[3])) errors.push('07_balans.md / Czas / Dzień: hours disagree with the stated duration');
  } catch {}
  check('Czas', 'Rozmowa z NPC', /^(?:✅\s*)?(\d+) min\b/, [[1, 'script/vn.gd', 'TALK_MINUTES']]);
  check('Czas', 'Rozpoznanie nowego miejsca', /^\+(\d+(?:[.,]\d+)?) h$/, [[1, 'script/expeditions.gd', 'SCOUTING_HOURS']]);
  check('Czas', 'Ranny bohater w drodze', /^\+(\d+(?:[.,]\d+)?) h\b/, [[1, 'script/expeditions.gd', 'WOUNDED_EXTRA_HOURS']]);
  check('Czas', 'Termin normy / koniec gry', /^wieczór dnia (\d+) \/ rano dnia (\d+)$/, [[1, state, 'QUOTA_DAY'], [2, state, 'LAST_DAY']]);
  check('Żyły i norma', 'Norma', /^(\d+) żył$/, [[1, state, 'QUOTA']]);
  check('Żyły i norma', 'Termin', /^wieczór dnia (\d+)$/, [[1, state, 'QUOTA_DAY']]);
  check('Bohater', 'Zdrowie', /^start (\d+), maks\. (\d+)$/, [[2, state, 'PLAYER_MAX']]);
  check('Bohater', 'Poczytalność', /^start (\d+), maks\. (\d+)$/, [[1, state, 'PLAYER_START_SANITY'], [2, state, 'PLAYER_MAX']]);
  check('Bohater', 'Zmęczenie', /^start \d+, maks\. (\d+); \+(\d+)%\/h w tunelach.*\+(\d+)%\/h w obozie; sen −(\d+)%, ognisko −(\d+)%/, [[1, state, 'FATIGUE_MAX'], [2, state, 'FATIGUE_TUNNEL_PER_HOUR'], [3, state, 'FATIGUE_CAMP_PER_HOUR'], [4, state, 'FATIGUE_SLEEP'], [5, state, 'FATIGUE_FIRE']]);
  return { checked, errors };
}

function specificationDir(root) {
  if (process.env.SPEC_DIR) return path.resolve(process.env.SPEC_DIR);
  const common = execFileSync('git', ['rev-parse', '--git-common-dir'], { cwd: root, encoding: 'utf8' }).trim();
  return path.resolve(root, common, '..', '..', 'specification');
}

if (require.main === module) {
  try {
    const root = path.resolve(__dirname, '..');
    const spec = specificationDir(root);
    const sources = Object.fromEntries(['script/game_state.gd', 'script/vn.gd', 'script/expeditions.gd'].map((file) => [file, fs.readFileSync(path.join(root, file), 'utf8')]));
    const result = validateBalance(fs.readFileSync(path.join(spec, '07_balans.md'), 'utf8'), sources);
    for (const error of result.errors) console.error(`SPEC: ${error}`);
    console.log(`RESULT: ${result.errors.length ? `${result.errors.length} FAILED` : 'ALL PASSED'} (spec data: ${result.checked} comparisons with ${path.join(spec, '07_balans.md')})`);
    process.exitCode = result.errors.length ? 1 : 0;
  } catch (error) {
    console.error(`RESULT: 1 FAILED (spec data: ${error.message})`);
    process.exitCode = 1;
  }
}

module.exports = { balanceRow, validateBalance, specificationDir };
