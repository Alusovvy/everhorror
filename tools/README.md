# tools/

Dev tools run from the command line (project root). Not used by the game and excluded from the export.
`GODOT` below means `C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe`.

## Workflow and documentation checks

- Current workflow and source ownership: `../specification/WORKFLOW.md`. A person starts planning, implementation and finalization.
- `pwsh -NoProfile -File tools/spec_poll.ps1 -DryRun`: reports locally known specification state, with no fetch, model launch, files, logs or registration. A normal run fetches upstream and records only the last reported notification in `reports/spec-sync/last-notification.txt`; `-LocalOnly` skips fetch. No changes to tasks, the ledger or gameplay. Schedule registration is optional and has not been performed by the foundation task.
- `pwsh -NoProfile -File tools/test_spec_poll.ps1`: checks notifications, deduplication, CLI failure and side-effect-free DryRun in temporary Git repositories, without project remotes.
- `node tools/check_doc_links.js`: checks local Markdown file targets in the specification and `CLAUDE.md`. Optional arguments select files/directories. It does not validate remote pages or heading fragments. The dashboard has separate fragment-navigation tests.
- Dashboard validation (from `../specification/dashboard`): `npm test`, `npm run build`, `npm run lint-spec`. Browser journeys and the remaining human checks are recorded in `docs/human-tasks/factcheck-foundation-2026-10-26.md`.

## Tests

**Run the full suite only after the user approves it** (see `CLAUDE.md`). To check a change, run one short scenario.

| Tool | What it does | Command |
|---|---|---|
| `run_tests.sh` | Runs the scenarios below, one `RESULT` line each; full logs in `reports/tests/<name>.log`. | `tools/run_tests.sh` (all) or `tools/run_tests.sh day1 kaplica` |
| `unit_test.gd` | Pure logic, no world (~2 s): the expedition graph with the closed-route regression, Polish plurals (`plural`, `veins_acc`, `days_left_text`, `hours_text`), the hero's bands and the wound floor, payload flags, `fourteenth_clues`; task_09: `duration_text`, the time log (and its JSON save), `ResponseLock` (greyed-out reasons), `StoryDirector.hrapek_due()` (day 3, 25%, the certain second meeting, the body); task_14: who has not arrived loses no sanity at night or in the tremor (`has_arrived`, NPC-18; `_resolve_night()` on a bare `StoryDirector`), the band helpers, the version in `project.godot` = `CHANGELOG.md` = `CZYTAJ_MNIE.txt` and the shape of `BuildInfo.label()`, the time categories, `dawn_log` / `vein_log` and their save (also an old save), and `RunReport` (collect, Markdown, JSON, `write()` into `user://raporty`). | `tools/run_tests.sh unit` |
| `data_lint.gd` | Static cross-checks (~2 s): ids used in dialogues, generators and the StoryDirector vs the GameState registries (items, quests + entries both ways, notes, NPCs, veins), the `[#leave]` farewell in every camp NPC dialogue, and `[#free]` only on responses that hand over an item; task_14: every time label in the sources has a report category other than "inne", the bot's hidden veins match `hidden_vein()` in the generator, and every flag that is read is set somewhere (the `hieronim_gone` class of bug). Run after adding any content id or time label. | `tools/run_tests.sh lint` |
| `balance_sim.gd` | task_14 (TECH-3): the balance bot, the fifth test layer (~2 s). "Plays" the week without the world scene, on the game's own costs (`Expeditions`, `GameState.advance_time`, fatigue, `QUOTA`, `BLAST_HOURS`, `VN.TALK_MINUTES`), in two styles ("żyły": tunnels all day; "rozmowy": talks every morning and the fire in the evening) and two variants (story gates as in the table of `07_balans.md` "Pomiar", or each a day later). Prints `BALANCE[styl, wariant]: norma 12 → dzień X, HH:MM (żyły po dniu 7: N)` and the assumptions it used; `tools/run_tests.sh` shows those lines under the RESULT line. It **measures**: the pace never fails the test, only invariants do (back by 22:00, fatigue in 0–100, no vein twice, the logs agree, the same answer twice, the run report reads the bot's week). `-- --timeline` after the script prints every day's time log. | `tools/run_tests.sh balance` |
| `dialogue_test.gd` | Plays every dialogue without UI: dialect coverage and switch, all NPCs' branches, quests, the wall riddle, the crystal, the day-3 announcement; task_05: the new people and their item quests, the Exitium meeting, Ottokar's offer, Hieronim, Welf, Tekla's stall, Racibor's reminder and reckoning, the "left alone" ending. | `GODOT --headless --path . --script res://tools/dialogue_test.gd` |
| `tests/test_day1.gd` | Day 1 in the real world scene: intro (task_14: the map table is in Racibor's pen), schedule, trip east (signpost opens the field map, the summary), blast, comforting Mirosław. | `tools/run_tests.sh day1` |
| `tests/test_expedition.gd` | The map table and WYRUSZ, scouting, [M] onwards, Wszebor at work, a vein, the pickaxe head, the way back and the summary, bandages from the inventory. | `tools/run_tests.sh expedition` |
| `tests/test_drudzy.gd` | The Exitium meeting on day 3, Sabina joins (task_14: the night after, she loses 2 and the met mages lose nothing), who can turn up where, the wounded Welf saved with bandages. | `tools/run_tests.sh drudzy` |
| `tests/test_schedule.gd` | The whole week's camp schedule: 7 days × 5 hours × 5 story states resolve to real markers with no two NPCs on one; plus the miners' field posts and an encounter spot. | `tools/run_tests.sh schedule` |
| `tests/test_places.gd` | task_08: every camp marker is a sane place to stand: flat floor at its height, a person-sized capsule touches no rock or solid prop (seated/crouching markers: upper body only), not inside a rock (mesh-core check: pack rocks are hollow trimeshes), not facing the rock (except praying/sulking), inside the cave. Control probes (a body in the pillar, a ray at the wall) keep the test honest. | `tools/run_tests.sh places` |
| `tests/test_camp_walk.gd` | task_08: bakes a player-sized navmesh of the camp and walks the real player (physics + the `move_forward` action, steering the head) from the bed to the fire, the map table in the pen, Tekla's stall, Hagiwara's corner, the east barricade, the corridor to the old entrance, the west boards and back. Fails on stuck or late. | `tools/run_tests.sh camp_walk` |
| `tests/test_hrapek.gd` | task_09: Hrapek on the way back (day 3 after the blast, the certain second meeting on day 5), the fish from Tekla at 5 min an option with its time-log entry, a greyed trust lock in the VN (Bolko), no HUD clock, his death in the night after day 5, the body and the ring. | `tools/run_tests.sh hrapek` |
| `tests/test_first_meet.gd` | task_10: day 1 with only Mirosław, Bolko, Tekla and Racibor in the camp; the other five on a shift in the first-level rooms (Stara sztolnia, Rząpie, Zawalony chodnik), at most two to a room, met there with the day-1 shift greeting; from the morning of day 2 everyone is in the camp. | `tools/run_tests.sh first_meet` |
| `tests/test_week.gd` | Night 3 (Nasir's fever), Racibor's reminder, SAVE REPORT in the pause menu (task_14), the hero's death and "retry from morning" (no report of its own, the dawn log of that morning comes back), the end of the week without the quota and the run report it writes. | `tools/run_tests.sh week` |
| `tests/test_save_load.gd` | Save in the evening, take the bundle in the sump, load: hour, items, pickup, schedule restored; task_14: save version 6, the dawn and vein logs come back. | `tools/run_tests.sh save_load` |
| `tests/test_rzapie.gd` | Racibor's quest, the sump (bundle, vein, stake), return after 22:00. | `tools/run_tests.sh rzapie` |
| `tests/test_night1.gd` | First night: dream, deciphering, day-2 camp with Dobrawa; task_14: Sabina, not here yet, loses nothing; the dawn of day 2 is in the dawn log. | `tools/run_tests.sh night1` |
| `tests/test_day2.gd` | Bundle to Tekla, Dobrawa's glossary, the decline, report to Racibor. | `tools/run_tests.sh day2` |
| `tests/test_kaplica.gd` | The chapel wall riddle (wrong try, answer), the niche, letter and crystal. | `tools/run_tests.sh kaplica` |
| `tests/test_day3.gd` | Second night, the announcement with a choice, the week goes on (no end on day 3). | `tools/run_tests.sh day3` |
| `interact_test.gd`, `nav_walk_test.gd` | Older checks: every interactable's highlight/prompt; a navmesh walk through the level. | `GODOT --headless --path . --script res://tools/<name>.gd` |

Writing scenarios: extend `res://tools/tests/test_base.gd`, implement `scenario()`, start with `start_world(setup)` where `setup` prepares `GameState` (set the `intro_done` flag to skip the intro). Use `step()`, `check()`, `converse()`, `travel()` (map table + WYRUSZ), `go_on(id)` (field map; `"oboz"` goes back), `use()`, `drive()`, `wait_for_vn()`, `wait_idle()` (it also closes the expedition summary and keeps its text in `last_summary`). Override `timeout_s` in `_init()` for longer scenarios. After a dialogue that asks a question, call `wait_for_vn()` and `drive([answers])`; `wait_idle()` only answers unexpected questions with the first option and records a failure. Every wait has a time limit and a watchdog ends the scenario with `RESULT: TIMEOUT in step '…'`. Don't type variables with `class_name` types (`Npc`, `Interactable`…) in test scripts: they compile before the autoloads exist and fail.

## Screenshots

| Tool | What it does | Command |
|---|---|---|
| `screenshot.gd` | Renders the scene from camera positions in a JSON file to PNGs (real GPU window, not headless). JSON may set `flags`, `day` and `hour` (the camp is laid out for that time), `hide` (node paths to hide, e.g. `["Camp/Cave/Vault", "Camp/Cave/Backing/Vault"]` for a top view under the vault) and `bright: true` (flat light from above, no fog: layout checks). | `GODOT --path . --resolution 1280x720 --script res://tools/screenshot.gd -- tools/views_tour.json <out_dir>` |
| `level_probe.gd` | Prints every instanced piece of a level (path, source scene, global position, yaw, world AABB) as TSV, or with `measure` the local AABB of given piece scenes. For planning geometry edits. | `GODOT --headless --path . --script res://tools/level_probe.gd -- res://scene/levels/mine.tscn > probe.log` or `-- measure res://…/wall_caves_a.tscn …` |
| `character_preview.gd` | Character model scenes side by side (animation, camera: front, face, side, right). Good for checking outfits, masks and what the hands hold. | `GODOT --path . --resolution 1400x700 --script res://tools/character_preview.gd -- <out.png> sobek,sabina Idle_Torch front` |

## Generators (they overwrite their output: edit the generator, not the result)

| Tool | Output | Command |
|---|---|---|
| `generators/gen_camp.gd` | `scene/levels/camp.tscn`: the camp cave (floor, `Wall_Cave` walls, a vault of face-down wall pieces, rock backing, pillar, ledges, door frames), its areas and wooden structures (Racibor's pen, the storage scaffold, the old track with carts, lantern posts), barricades, west/east segments, all markers (spawn, travel, NPC schedule; working NPCs face what they work at via `face()`). | `GODOT --headless --path . --script res://tools/generators/gen_camp.gd` |
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

Order for a build (see "Build" in `CLAUDE.md`): `stamp_build.js` → `GODOT --headless --path . --import` → `GODOT --headless --path . --export-release "Windows Desktop" build/windows/Everhorror.exe` → `make_zip.sh` → commit the stamp, `CHANGELOG.md` and `CZYTAJ_MNIE.txt` → tag `v<version>`.

| Tool | What it does | Command |
|---|---|---|
| `release/stamp_build.js` | TECH-1 / TECH-2. Checks that the version is the same in `project.godot` (`application/config/version`), the newest `## [x.y.z]` heading of `CHANGELOG.md` and the first line of `release/CZYTAJ_MNIE.txt` (it refuses when not), then writes the spec commit into the `SPEC_SHA` constant of `script/build_info.gd` (the main menu shows `BuildInfo.label()`, "0.5.3 · spec 8e46253"). Default is the HEAD of `../specification` (a "+" is added when the spec has uncommitted changes); `--spec <rev>` stamps that commit instead (no "+"); `--check` only checks the versions. `SPEC_DIR` overrides the spec folder. Warns when the newest CHANGELOG entry names another spec commit. | `node tools/release/stamp_build.js [--spec <rev>] [--check]` |
| `release/make_zip.sh` | TECH-2. After the export: `build/Everhorror-demo-<version>-windows.zip` with `Everhorror.exe`, `CZYTAJ_MNIE.txt` and `CHANGELOG.md` at the top level (the version comes from `project.godot`; it refuses on a version mismatch). Uses `zip` when there is one, otherwise PowerShell's `Compress-Archive`. | `tools/release/make_zip.sh` |
| `release/CZYTAJ_MNIE.txt` | Instructions for testers, zipped together with the exe. Its first line carries the version. | |

Notes:
- Test and tool scripts load the world one frame late, because autoloads are not registered yet when a `--script` main loop starts.
- After adding a new `class_name` script or new assets, run `GODOT --headless --path . --import` once before headless runs.
- Never pipe a long Godot run through `grep`/`head` (output is buffered until the end). Write the log to a file and read the `RESULT` lines.
