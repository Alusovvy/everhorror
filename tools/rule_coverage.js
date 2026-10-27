#!/usr/bin/env node
// Rule coverage (audit P10): for every rule ID defined in the specification (the lines
// "- **CZAS-3** ✅ …" of the rule files) it lists where the game mentions it: files and lines in
// script/, tools/ (generators, bots, lint) and dialogue/, and the test files (tools/unit_test.gd,
// tools/tests/, tools/dialogue_test.gd, tools/balance_sim.gd, tools/data_lint.gd) that name it.
// Writes reports/rule-coverage.json and prints one summary line. Rules already marked ✅ in the
// spec but never mentioned anywhere are listed as warnings; the exit code is always 0 (the lint
// scenario treats this tool as warning-only).
//
// Usage (from the project root):  node tools/rule_coverage.js [--spec <dir>] [--out <file>] [--quiet]
//   --spec   the specification folder (default ../specification, or the SPEC_DIR variable)
//   --out    the JSON file (default reports/rule-coverage.json)
//   --quiet  only the summary line, no list of ✅ rules without a reference
"use strict";
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const args = process.argv.slice(2);
const opt = (name, fallback) => {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const SPEC = path.resolve(opt("--spec", process.env.SPEC_DIR || path.join(ROOT, "..", "specification")));
const OUT = path.resolve(ROOT, opt("--out", path.join("reports", "rule-coverage.json")));
const QUIET = args.includes("--quiet");

const MARKERS = ["✅", "🟡", "⬜", "💡", "❓", "❌"];
const DEF = /^\s*[-*]?\s*\*\*([A-Z]{2,6}-\d+)\*\*\s*(✅|🟡|⬜|💡|❓|❌)?/;
const SKIP_DIRS = new Set(["node_modules", "dashboard", "zgloszenia", "szablony", ".git"]);

function walk(dir, accept, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || SKIP_DIRS.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, accept, out);
    else if (accept(full)) out.push(full);
  }
  return out;
}

if (!fs.existsSync(SPEC)) {
  console.log(`RULES: skipped, the specification folder ${SPEC} does not exist`);
  process.exit(0);
}

// 1. Rule definitions from the specification.
const rules = new Map();
for (const file of walk(SPEC, (f) => f.endsWith(".md") && path.basename(f) !== "README.md")) {
  const rel = path.relative(SPEC, file).replace(/\\/g, "/");
  fs.readFileSync(file, "utf8").split(/\r?\n/).forEach((line, i) => {
    const m = DEF.exec(line);
    if (m && !rules.has(m[1])) {
      rules.set(m[1], { id: m[1], status: m[2] || "", spec: `${rel}:${i + 1}`, refs: { code: [], tools: [], dialogue: [], tests: [] } });
    }
  });
}

// 2. Mentions in the game.
const isTest = (rel) =>
  rel.startsWith("tools/tests/") || ["tools/unit_test.gd", "tools/dialogue_test.gd", "tools/balance_sim.gd", "tools/data_lint.gd"].includes(rel);
const scanned = [
  ...walk(path.join(ROOT, "script"), (f) => /\.(gd|tscn)$/.test(f)),
  ...walk(path.join(ROOT, "tools"), (f) => /\.(gd|js|sh|ps1)$/.test(f)),
  ...walk(path.join(ROOT, "dialogue"), (f) => f.endsWith(".dialogue")),
];
const idPattern = /(?<![A-Za-z0-9-])([A-Z]{2,6}-\d+)(?![0-9])/g;
for (const file of scanned) {
  const rel = path.relative(ROOT, file).replace(/\\/g, "/");
  if (rel === "tools/rule_coverage.js") continue;
  const bucket = isTest(rel) ? "tests" : rel.startsWith("script/") ? "code" : rel.startsWith("dialogue/") ? "dialogue" : "tools";
  const lines = new Map(); // id -> line numbers
  fs.readFileSync(file, "utf8").split(/\r?\n/).forEach((line, i) => {
    for (const m of line.matchAll(idPattern)) {
      if (!rules.has(m[1])) continue;
      if (!lines.has(m[1])) lines.set(m[1], []);
      const list = lines.get(m[1]);
      if (list[list.length - 1] !== i + 1) list.push(i + 1);
    }
  });
  for (const [id, list] of lines) rules.get(id).refs[bucket].push({ file: rel, lines: list });
}

// 3. Report.
const referenced = (r) => Object.values(r.refs).some((list) => list.length > 0);
const all = [...rules.values()];
const done = all.filter((r) => r.status === "✅");
const doneWithout = done.filter((r) => !referenced(r));
const byStatus = {};
for (const r of all) byStatus[r.status || "(none)"] = (byStatus[r.status || "(none)"] || 0) + 1;
const summary = {
  total: all.length,
  referenced: all.filter(referenced).length,
  inCode: all.filter((r) => r.refs.code.length || r.refs.tools.length || r.refs.dialogue.length).length,
  withTest: all.filter((r) => r.refs.tests.length).length,
  done: done.length,
  doneReferenced: done.length - doneWithout.length,
  doneWithoutReference: doneWithout.map((r) => r.id),
  byStatus,
};
fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(
  OUT,
  JSON.stringify({ generated: new Date().toISOString(), spec: SPEC, summary, rules: Object.fromEntries(all.map((r) => [r.id, r])) }, null, "\t") + "\n"
);

if (!QUIET) for (const r of doneWithout) console.log(`   WARN ${r.id} is marked ✅ (${r.spec}) but no file in script/, tools/ or dialogue/ names it`);
console.log(
  `RULES: ${summary.total} rule IDs in the specification, ${summary.inCode} named in script/tools/dialogue, ${summary.withTest} named by a test file; ` +
    `${summary.done} are ✅ and ${summary.doneWithoutReference.length} of those have no reference (warning) -> ${path.relative(ROOT, OUT).replace(/\\/g, "/")}`
);
