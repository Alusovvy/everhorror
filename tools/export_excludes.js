#!/usr/bin/env node
// Export excludes (audit G7, G-E10): finds the pack assets that nothing in the game uses and keeps
// the matching `exclude_filter` entries of export_presets.cfg current, so the exported game does not
// carry them (only 51 of 94 glTF models of the Fantasy Props pack are placed anywhere).
//
// Why a list and not `export_filter="scenes"` (tried on 2026-10-27, tools/README.md "Eksport"):
// "selected scenes and their dependencies" drops every script that is only used by its class_name
// and every resource that a script only `preload`s (the characters' base models), so the exported
// game does not start. Excluding what is provably unused is safe in the other direction.
//
// An asset counts as used when its file name appears anywhere in the game's text sources: scenes,
// resources, scripts, dialogues, project settings and the scene generators (the generators build
// paths from a folder constant and a file name). Pack scenes are followed (a used scene uses what
// it names). Matching by file name over-keeps (never drops something that only another folder's
// file of the same name uses).
//
// Usage (from the project root):
//   node tools/export_excludes.js           # print the unused assets and the exclude entries
//   node tools/export_excludes.js --write   # update export_presets.cfg
//   node tools/export_excludes.js --check   # exit 1 when export_presets.cfg is not current
//                                           # (check_generated.js runs this)
"use strict";
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const PRESETS = path.join(ROOT, "export_presets.cfg");

// Generated entries are recognised by their folder, so a hand-written entry of the preset stays.
const GENERATED_PREFIXES = ["assets/prop_pack/Exports/glTF/", "assets/LoafbrrAssets/MineAndCavesSet/"];

// Candidate groups: where unused assets are looked for and how an unused one is excluded.
const GROUPS = [
  { dir: "assets/prop_pack/Exports/glTF", ext: ".gltf", exclude: (rel) => rel.replace(/\.gltf$/, ".*") }, // also .bin and .import
  { dir: "assets/LoafbrrAssets/MineAndCavesSet/scenes", ext: ".tscn", exclude: (rel) => rel },
  { dir: "assets/LoafbrrAssets/MineAndCavesSet/gltf", ext: ".glb", exclude: (rel) => rel.replace(/\.glb$/, ".*") },
];

function tracked() {
  return execFileSync("git", ["-C", ROOT, "ls-files", "-z"], { encoding: "utf8", maxBuffer: 1 << 26 }).split("\0").filter(Boolean);
}

const files = tracked();
const TEXT = /\.(tscn|tres|gd|js|dialogue|godot|cfg|json|gdshader|material)$/;
// What can name an asset: the game itself and the generators; not the docs, the other tools or the
// pack's own files (those are followed one by one below).
const sources = files.filter(
  (f) => TEXT.test(f) && !f.startsWith("assets/") && !f.startsWith("docs/") && !f.startsWith("addons/") &&
    (!f.startsWith("tools/") || f.startsWith("tools/generators/")) && f !== "export_presets.cfg"
);
let corpus = sources.map((f) => fs.readFileSync(path.join(ROOT, f), "utf8")).join("\n");

// Pack scenes name other pack files; follow them from the used ones until nothing new is used.
const packTexts = new Map();
for (const f of files) {
  if (f.startsWith("assets/") && /\.(tscn|tres|material)$/.test(f)) packTexts.set(f, fs.readFileSync(path.join(ROOT, f), "utf8"));
}
const used = new Set();
let changed = true;
while (changed) {
  changed = false;
  for (const [f, text] of packTexts) {
    if (used.has(f)) continue;
    if (corpus.includes("/" + path.posix.basename(f)) || corpus.includes('"' + path.posix.basename(f))) {
      used.add(f);
      corpus += "\n" + text;
      changed = true;
    }
  }
}

const unused = [];
const entries = [];
for (const group of GROUPS) {
  for (const f of files) {
    if (!f.startsWith(group.dir + "/") || !f.endsWith(group.ext)) continue;
    if (used.has(f)) continue;
    const name = path.posix.basename(f);
    if (corpus.includes(name)) continue;
    unused.push(f);
    entries.push(group.exclude(f));
  }
}
entries.sort();

const text = fs.readFileSync(PRESETS, "utf8");
// Every preset (the release one and the "Test Pack" one used by tools/export_smoke.sh) carries the list.
const lines = [...text.matchAll(/^exclude_filter="([^"]*)"$/gm)];
if (!lines.length) {
  console.log("export_excludes: no exclude_filter in export_presets.cfg");
  process.exit(1);
}
const wantedFor = (list) => [...list.filter((e) => !GENERATED_PREFIXES.some((p) => e.startsWith(p))), ...entries];
const asLine = (list) => `exclude_filter="${wantedFor(list).join(", ")}"`;
const split = (line) => line.split(",").map((e) => e.trim()).filter(Boolean);

const args = process.argv.slice(2);
if (args.includes("--write")) {
  fs.writeFileSync(PRESETS, text.replace(/^exclude_filter="([^"]*)"$/gm, (_, list) => asLine(split(list))));
  console.log(`export_excludes: export_presets.cfg updated, ${entries.length} unused assets excluded`);
} else if (args.includes("--check")) {
  const same = lines.every((m) => JSON.stringify(split(m[1])) === JSON.stringify(wantedFor(split(m[1]))));
  console.log(same ? `export_excludes: export_presets.cfg is current (${entries.length} unused assets excluded)` : "export_excludes: export_presets.cfg exclude_filter is out of date; run `node tools/export_excludes.js --write`");
  process.exit(same ? 0 : 1);
} else {
  for (const f of unused) console.log("unused  " + f);
  console.log(`\n${unused.length} unused assets -> ${entries.length} exclude entries`);
}
