#!/usr/bin/env node
// Generator = source (audit G-E5): regenerates what the generators write into a temporary folder
// and compares it with the repository. Red (exit 1) when a generated file differs, is missing, or
// when a file sits in a generated data folder that no generator writes (a hand-made file).
//
// Checked:
//   - data/npc, data/notes, data/quests   <- tools/generators/write_story_data.js
//   - data/items, data/locations           <- tools/generators/write_world_data.js
//   - dialogue/gwara_slaska.json           <- tools/generators/write_gwara.js
//   - export_presets.cfg: its generated exclude entries (unused pack assets) <- tools/export_excludes.js
//   - with --scenes (needs Godot; the `lint` scenario passes it):
//       scene/levels/camp.tscn, locations.tscn, mine_deep.tscn <- tools/generators/gen_*.gd
//     compared with the random resource ids of one run (`id="3_ab12c"`, `unique_id=`) masked out.
// Not checked (binary or one-off): synth_sfx.js, gen_sanctin_textures.gd, build_character_head.gd,
// build_iron_mask.gd.
//
// Usage (from the project root):  node tools/check_generated.js [--scenes] [--keep]
//   GODOT   path of the Godot console exe (default C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe)
//   --keep  leave the temporary folder and print its path
"use strict";
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const GODOT = process.env.GODOT || "C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe";
const withScenes = process.argv.includes("--scenes");
const keep = process.argv.includes("--keep");

const DATA_DIRS = ["data/npc", "data/notes", "data/quests", "data/items", "data/locations"];
const JS_GENERATORS = ["write_story_data.js", "write_world_data.js", "write_gwara.js"];
const SCENES = [
  ["gen_camp.gd", "scene/levels/camp.tscn"],
  ["gen_locations.gd", "scene/levels/locations.tscn"],
  ["gen_mine_deep.gd", "scene/levels/mine_deep.tscn"],
];

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "everhorror-gen-"));
const problems = [];
let compared = 0;

const text = (file) => fs.readFileSync(file, "utf8").replace(/\r\n/g, "\n");
// Godot picks a random suffix for resource ids on every save: mask them.
const maskScene = (s) =>
  s
    .replace(/"([0-9A-Za-z]+)_[a-z0-9]{5}"/g, '"$1_X"')
    .replace(/ unique_id=\d+/g, "");

function compare(rel, generated, mask) {
  compared += 1;
  const repoFile = path.join(ROOT, rel);
  if (!fs.existsSync(repoFile)) {
    problems.push(`${rel}: the generator writes it, but the repository has no such file`);
    return;
  }
  let a = text(repoFile);
  let b = text(generated);
  if (mask) {
    a = mask(a);
    b = mask(b);
  }
  if (a === b) return;
  const la = a.split("\n");
  const lb = b.split("\n");
  const shown = [];
  for (let i = 0; i < Math.max(la.length, lb.length) && shown.length < 3; i++) {
    if (la[i] !== lb[i]) shown.push(`      line ${i + 1}\n        repo:      ${(la[i] ?? "<none>").slice(0, 150)}\n        generated: ${(lb[i] ?? "<none>").slice(0, 150)}`);
  }
  problems.push(`${rel}: differs from the generator's output (hand-edited, or the generator was not rerun)\n${shown.join("\n")}`);
}

try {
  // Data generators, run from a folder that looks like the project root (they use relative paths).
  for (const dir of [...DATA_DIRS, "dialogue"]) fs.mkdirSync(path.join(tmp, dir), { recursive: true });
  for (const file of fs.readdirSync(path.join(ROOT, "dialogue"))) {
    if (file.endsWith(".dialogue")) fs.copyFileSync(path.join(ROOT, "dialogue", file), path.join(tmp, "dialogue", file));
  }
  for (const generator of JS_GENERATORS) {
    try {
      execFileSync(process.execPath, [path.join(ROOT, "tools", "generators", generator)], { cwd: tmp, stdio: "pipe" });
    } catch (err) {
      problems.push(`tools/generators/${generator} failed: ${String(err.stderr || err.message).trim().split("\n")[0]}`);
    }
  }
  const generatedFiles = new Set();
  for (const dir of DATA_DIRS) {
    for (const file of fs.readdirSync(path.join(tmp, dir))) {
      generatedFiles.add(`${dir}/${file}`);
      compare(`${dir}/${file}`, path.join(tmp, dir, file));
    }
    const repoDir = path.join(ROOT, dir);
    if (fs.existsSync(repoDir)) {
      for (const file of fs.readdirSync(repoDir)) {
        if (file.endsWith(".uid") || file.endsWith(".import")) continue;
        if (!generatedFiles.has(`${dir}/${file}`)) problems.push(`${dir}/${file}: in a generated folder, but no generator writes it`);
      }
    }
  }
  if (fs.existsSync(path.join(tmp, "dialogue", "gwara_slaska.json"))) compare("dialogue/gwara_slaska.json", path.join(tmp, "dialogue", "gwara_slaska.json"));

  // The unused-asset excludes of the export presets are generated too (tools/export_excludes.js).
  compared += 1;
  try {
    execFileSync(process.execPath, [path.join(ROOT, "tools", "export_excludes.js"), "--check"], { cwd: ROOT, stdio: "pipe" });
  } catch (err) {
    problems.push(`export_presets.cfg: ${String(err.stdout || err.message).trim()}`);
  }

  if (withScenes) {
    if (!fs.existsSync(GODOT)) {
      console.log(`check_generated: scenes skipped, Godot not found at ${GODOT} (set GODOT)`);
    } else {
      for (const [generator, rel] of SCENES) {
        const out = path.join(tmp, path.basename(rel)).replace(/\\/g, "/");
        try {
          execFileSync(GODOT, ["--headless", "--path", ROOT, "--script", `res://tools/generators/${generator}`, "--", `--out=${out}`], { stdio: "pipe", timeout: 240000 });
        } catch (err) {
          problems.push(`tools/generators/${generator} failed: ${String(err.stdout || err.message).trim().split("\n").slice(-3).join(" | ")}`);
          continue;
        }
        if (!fs.existsSync(out)) {
          problems.push(`tools/generators/${generator} wrote no scene`);
          continue;
        }
        compare(rel, out, maskScene);
      }
    }
  }
} finally {
  if (keep) console.log(`check_generated: temporary folder kept: ${tmp}`);
  else fs.rmSync(tmp, { recursive: true, force: true });
}

if (problems.length) {
  for (const p of problems) console.log(`   FAIL ${p}`);
  console.log(`\nRESULT: ${problems.length} FAILED (check_generated: ${compared} generated files compared; edit the generator, not the result, and rerun it)`);
  process.exit(1);
}
console.log(`RESULT: ALL PASSED (check_generated: ${compared} generated files identical to the repository${withScenes ? ", scenes included" : ""})`);
