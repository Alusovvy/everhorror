# tools/

Dev tools run from the command line (project root). Not used by the game and excluded from the export.
`GODOT` below means `C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe`.

## Tests

**Run the full suite only after the user approves it** (see `CLAUDE.md`). To check a change, run one short scenario.

| Tool | What it does | Command |
|---|---|---|
| `run_tests.sh` | Runs the scenarios below, one `RESULT` line each; full logs in `reports/tests/<name>.log`. | `tools/run_tests.sh` (all) or `tools/run_tests.sh day1 kaplica` |
| `unit_test.gd` | Pure logic, no world (~2 s): the expedition graph with the closed-route regression, Polish plurals (`plural`, `veins_acc`, `days_left_text`, `hours_text`), the hero's bands and the wound floor, payload flags, `fourteenth_clues`. | `tools/run_tests.sh unit` |
| `data_lint.gd` | Static cross-checks (~2 s): ids used in dialogues, generators and the StoryDirector vs the GameState registries (items, quests + entries both ways, notes, NPCs, veins), and the `[#leave]` farewell in every camp NPC dialogue. Run after adding any content id. | `tools/run_tests.sh lint` |
| `dialogue_test.gd` | Plays every dialogue without UI: dialect coverage and switch, all NPCs' branches, quests, the wall riddle, the crystal, the day-3 announcement; task_05: the new people and their item quests, the Exitium meeting, Ottokar's offer, Hieronim, Welf, Tekla's stall, Racibor's reminder and reckoning, the "left alone" ending. | `GODOT --headless --path . --script res://tools/dialogue_test.gd` |
| `tests/test_day1.gd` | Day 1 in the real world scene: intro, schedule, trip east (signpost opens the field map, the summary), blast, comforting Mirosław. | `tools/run_tests.sh day1` |
| `tests/test_expedition.gd` | The map table and WYRUSZ, scouting, [M] onwards, Wszebor at work, a vein, the pickaxe head, the way back and the summary, bandages from the inventory. | `tools/run_tests.sh expedition` |
| `tests/test_drudzy.gd` | The Exitium meeting on day 3, Sabina joins, who can turn up where, the wounded Welf saved with bandages. | `tools/run_tests.sh drudzy` |
| `tests/test_schedule.gd` | The whole week's camp schedule: 7 days × 5 hours × 5 story states resolve to real markers with no two NPCs on one; plus the miners' field posts and an encounter spot. | `tools/run_tests.sh schedule` |
| `tests/test_week.gd` | Night 3 (Nasir's fever), Racibor's reminder, the hero's death and "retry from morning", the end of the week without the quota. | `tools/run_tests.sh week` |
| `tests/test_save_load.gd` | Save in the evening, take the bundle in the sump, load: hour, items, pickup, schedule restored. | `tools/run_tests.sh save_load` |
| `tests/test_rzapie.gd` | Racibor's quest, the sump (bundle, vein, stake), return after 22:00. | `tools/run_tests.sh rzapie` |
| `tests/test_night1.gd` | First night: dream, deciphering, day-2 camp with Dobrawa. | `tools/run_tests.sh night1` |
| `tests/test_day2.gd` | Bundle to Tekla, Dobrawa's glossary, the decline, report to Racibor. | `tools/run_tests.sh day2` |
| `tests/test_kaplica.gd` | The chapel wall riddle (wrong try, answer), the niche, letter and crystal. | `tools/run_tests.sh kaplica` |
| `tests/test_day3.gd` | Second night, the announcement with a choice, the week goes on (no end on day 3). | `tools/run_tests.sh day3` |
| `interact_test.gd`, `nav_walk_test.gd` | Older checks: every interactable's highlight/prompt; a navmesh walk through the level. | `GODOT --headless --path . --script res://tools/<name>.gd` |

Writing scenarios: extend `res://tools/tests/test_base.gd`, implement `scenario()`, start with `start_world(setup)` where `setup` prepares `GameState` (set the `intro_done` flag to skip the intro). Use `step()`, `check()`, `converse()`, `travel()` (map table + WYRUSZ), `go_on(id)` (field map; `"oboz"` goes back), `use()`, `drive()`, `wait_for_vn()`, `wait_idle()` (it also closes the expedition summary and keeps its text in `last_summary`). Override `timeout_s` in `_init()` for longer scenarios. After a dialogue that asks a question, call `wait_for_vn()` and `drive([answers])`; `wait_idle()` only answers unexpected questions with the first option and records a failure. Every wait has a time limit and a watchdog ends the scenario with `RESULT: TIMEOUT in step '…'`. Don't type variables with `class_name` types (`Npc`, `Interactable`…) in test scripts: they compile before the autoloads exist and fail.

## Screenshots

| Tool | What it does | Command |
|---|---|---|
| `screenshot.gd` | Renders the scene from camera positions in a JSON file to PNGs (real GPU window, not headless). JSON may set `flags`, `day` and `hour` (the camp is laid out for that time). | `GODOT --path . --resolution 1280x720 --script res://tools/screenshot.gd -- tools/views_tour.json <out_dir>` |
| `character_preview.gd` | Character model scenes side by side (animation, camera: front, face, side, right). Good for checking outfits, masks and what the hands hold. | `GODOT --path . --resolution 1400x700 --script res://tools/character_preview.gd -- <out.png> sobek,sabina Idle_Torch front` |

## Generators (they overwrite their output: edit the generator, not the result)

| Tool | Output | Command |
|---|---|---|
| `generators/gen_camp.gd` | `scene/levels/camp.tscn`: camp areas, barricades, west/east segments, all markers (spawn, travel, NPC schedule). | `GODOT --headless --path . --script res://tools/generators/gen_camp.gd` |
| `generators/gen_locations.gd` | `scene/levels/locations.tscn`: the sump, the decline, the chapel (riddle wall) and the ten task_05 places (template `chamber()` + `stub()`), veins (also under flowstone), pickups, hazards, entry/spot/work markers. Needs the sanctin textures. | `... --script res://tools/generators/gen_locations.gd` |
| `generators/gen_sanctin_textures.gd` | `assets/textures/`: wall glyph mask, VN portrait of the wall, scratches. Run `--import` afterwards. | `... --script res://tools/generators/gen_sanctin_textures.gd` |
| `generators/gen_mine_deep.gd` | `scene/levels/mine_deep.tscn`: east corridor, slope, cave chamber (with the two east veins). | `... --script res://tools/generators/gen_mine_deep.gd` |
| `generators/build_character_head.gd` | `head_male.res`, `head_female.res`: heads cut from the base bodies (prints eye heights). | `... --script res://tools/generators/build_character_head.gd` |
| `generators/build_iron_mask.gd` | `assets/characters/iron_mask.res`: the Drudzy iron mask. | `... --script res://tools/generators/build_iron_mask.gd` |
| `generators/write_story_data.js` | `data/npc`, `data/notes`, `data/quests` (`.tres`). | `node tools/generators/write_story_data.js` |
| `generators/write_world_data.js` | `data/items`, `data/locations` (`.tres`): items and the places graph (travel hours, requirements, veins, map positions). | `node tools/generators/write_world_data.js` |
| `generators/write_gwara.js` | `dialogue/gwara_slaska.json` (original miner line → Silesian). Reports lines without a version and keys that no longer match. | `node tools/generators/write_gwara.js` |
| `generators/synth_sfx.js` | Placeholder sounds in `assets/sounds/generated/`. | `node tools/generators/synth_sfx.js` |

## Release

- `release/CZYTAJ_MNIE.txt`: instructions for testers, zipped together with the exe (see "Build" in `CLAUDE.md`).

Notes:
- Test and tool scripts load the world one frame late, because autoloads are not registered yet when a `--script` main loop starts.
- After adding a new `class_name` script or new assets, run `GODOT --headless --path . --import` once before headless runs.
- Never pipe a long Godot run through `grep`/`head` (output is buffered until the end). Write the log to a file and read the `RESULT` lines.
