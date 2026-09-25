# everhorror — agent notes

Working title "everhorror" (the GDD still calls the game "XYZ"). The logo `assets/logo.png` says "EVEROLD", but the name is still under discussion. **Use "Everhorror" everywhere for now** (user decision, 2026-09-25).

## Docs (in Polish)
- [docs/GDD.md](docs/GDD.md) — the game design document, owned by the team. Sections and owners: concept, start and ending (Vitav), main plot (Ren), mechanics (Roland), NPC stories. Don't rewrite it unless asked.
- [docs/MECHANICS.md](docs/MECHANICS.md) — mechanics spec derived from GDD §4 and expanded for implementation. **This is the current focus.** Keep it in sync when mechanics change.
- [docs_v2/](docs_v2/README.md) — modular game documentation (v2, Polish): one-pager, vision, gameplay, one file per system, world (lore, `LoreDoc.md` 1.2 MB with embedded images — search it, don't read it whole; `magia.md`, `loredoc_niespojnosci.md`, NPC cards in `swiat/postacie/`), levels, UI, art and audio (asset register with licences). The TDD (`docs_v2/06_techniczne.md`) and the production, decisions, glossary and changelog files are still to be written. Keep implementation status (✅/🟡/⬜) in docs_v2 in sync with the code. User decisions answered in `docs/MECHANICS.md` §13 are marked **[decyzja 2026-09-25]** in docs_v2.
- **[docs/ai-tasks/](docs/ai-tasks/INFO.md) — tasks for the agent.** The user drops `task_NN.md` files there. Workflow (from `INFO.md`):
  - Keep the **Requierments** section exactly as the user wrote it (typos included). Never edit it.
  - Below it, add sections as needed (e.g. what was done, decisions, what I need from the user).
  - Always end the file with a **Summary** section.
  - **If the task includes implementation**, also create `docs/human-tasks/factcheck-test-XX.md` (XX = task number): what was added, plus a test table with columns # / what to check / how / expected result / result / notes, which the user fills in with bugs and change proposals. Read the user's filled-in factcheck results before related work.
  - New tasks follow `docs/ai-tasks/task_template.md`. Write reports in the language the task is written in (task_02+ are in Polish).
  - Report back in the task file itself, and in chat briefly.
- Docs for the team are written in Polish. Code, identifiers and code comments are in English.

### Glossary (PL → meaning)
- **błękitne żelazo** — "blue iron": the ore being mined. It is ordinary metal improved by centuries of radiation from an artifact.
- **Pierwsi / Pierwszy** — "the First (ones)": a hostile ancient force. *Pierwszy* is the final threat.
- **Drudzy** — "the Second (ones)": a faction. One ending questline takes them to the bottom of the mine to defeat Pierwszy.
- **Oni / Świątynia Onych** — "the Ones" / their temple, at the deepest level.
- **Ekspedycja** — the mining expedition (the player's group). Factions: Drudzy / Ekspedycja / Inna ("other"). No more factions are planned.
- **Kniaź Jaksaru, Wąwóz Pierwszych, Mirosil** — the ruler, the region and a town in the setting.
- **Demo NPCs:** Mirosław z Głuszy (explosives, GDD), Stary Bolko (old miner), Racibor (the Kniaź's steward, expedition boss), Tekla (quartermaster and cook, Konfraternia kupiecka), Dobrawa z Initium (a Druga in an iron mask, from day 2). task_05 camp people (LoreDoc flavour, nobody important): Wszebor (Hawiar hewer), Nasir (pump man from the Sultanate, fever from day 4), Hagiwara (exiled Imperial scribe, keeps the ledger), Sobek (Exarch mercenary, guard), brat Anzelm (ex-Order medic). The Exitium Drudzy (met on day 3): Ottokar von Brühl (leader, cold), Sabina von Reuss (healer, joins the camp), Hieronim (mad old mage), Welf (proud young mage, can be wounded). Only Mirosław comes from the GDD; the others are working characters for Ren to review.
- **Places:** Stara sztolnia (east), Zawalony chodnik (west), Rząpie (flooded shaft bottom), Upadowa (the steep decline the grandfather sealed), Kaplica (chapel with the Onych wall riddle); task_05: Stare wyrobisko, Komora pomp, Kuźnia, Grzybowa grota, Przekop Grabca, Zalany chodnik, Ślepy szyb, Kostnica, Parująca szczelina, Kryształowa galeria (the deepest). **sanctin** is the language of Oni (LoreDoc). **Exitium** — Initium's satellite in an old mine across the Wąwóz (LoreDoc).
- **obóz** — the camp (hub). **szychta** — a mining shift. **poczytalność / sanity** — an NPC's sanity meter.

## Tech
- Godot **4.7.2** (Forward+, D3D12, Jolt Physics). Executable: `C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe`.
- Scripts are **GDScript**. `project.godot` has a `[dotnet]` assembly name, but there's no C# code, so don't add C# unless asked.
- Git repo root is this folder (branch `master`). Commit only when the user asks.
- Main scene: `scene/main_menu.tscn`. The gameplay scene is `scene/world.tscn`.
- Autoloads: `Settings` (options + Silesian dialect, `user://settings.cfg`), `SaveManager` (3 JSON slots in `user://saves/`), `GameState` (day, hour, flags, items, notes, quests, NPC state and current places), `VN` (opens the dialogue screen), `DialogueManager` (addon), plus addon autoloads (Phantom Camera, Beehave, MCPRuntimeProbe).
- Input actions: `move_forward/back/left/right` (WASD + arrows), `jump` (Space), `interact` (E), `notebook` (J), `inventory` (I), `field_map` (M, only in the tunnels). `ui_cancel` (Esc) opens the pause menu or closes a screen.
- Physics layers: 1 = world, 2 = interactable.

## Layout
- `scene/` — scenes. `script/` — one script per scene, with the same name. `shader/`, `theme/ui_theme.tres` (shared menu theme).
- `assets/` — third-party packs, all CC0 (see `docs_v2/05_oprawa.md`): `LoafbrrAssets/MineAndCavesSet` (modular mine and caves; its `res://Assets/` paths were fixed to `res://assets/`), `prop_pack` (Quaternius Fantasy Props MegaKit; only `Exports/glTF` is used), `props/kenney_survival`, `characters/quaternius` (base bodies, outfits, hair, animation library), `Sewer` (unused). Plus `sounds/`, `textures/` (generated) and `pics/`. Don't edit the pack contents. Instance or inherit from them instead.
- `data/` — `NpcData` / `NoteData` / `QuestData` resources (generated by `tools/generators/write_story_data.js`) and `ItemData` / `LocationData` (`data/items`, `data/locations`, generated by `tools/generators/write_world_data.js`: items, the places graph with travel hours, requirements and veins). `dialogue/` — Dialogue Manager files per character + `sciana` (the wall riddle) + `system`, and `gwara_slaska.json`.
- `scene/levels/` — `mine.tscn` (our editable copy of the pack's TestLevel; the wooden platform in the east room was removed), `mine_deep.tscn`, `camp.tscn` and `locations.tscn` (the last three are **generated**). `scene/characters/` — character model scenes. `scene/ui/`, `scene/vn/`.
- `build/` — exported builds and zips (git-ignored). `reports/` — test logs (git-ignored).
- `docs/` — design docs.
- `.vscode/launch.json` — F5 "Godot: main scene" via the godot-tools extension.

## Systems (2026-09-25)
- **Player** (`player.gd`): FPS `CharacterBody3D`, **capsule r=0.35 m h=2 m** (the cave arm has ~1 m squeezes, so don't make it wider), `floor_max_angle` 55° and `floor_snap_length` 0.3 so it rides over rails and lips. Head yaws → EyeCamera pitches (40° up / 70° down) → `InteractRay` 2.5 m + `Lamp` (a warm OmniLight the player carries). Emits `focus_changed` / `interacted`. It is in the `persist` group.
- **Interactable** (`interactable.gd`, `Area3D`): add it as a child of a prop, then set `display_name` and `description`. It fits its own box shape (and, with `solid`, a StaticBody) to the prop's meshes when the scene starts, and highlights them with `shader/interact_highlight.gdshader` as `material_overlay`.
- **HUD** (`hud.tscn`): crosshair, "[E] name · cost" prompt, description panel (E closes it and never re-uses the object; texts of objects that vanish when used are pinned for 12 s), clock, toasts. `world.gd` connects it to the player.
- **GameState** (`game_state.gd`): the whole run state and its helpers for dialogues (`has_flag`, `done_today`/`mark_today`, `give_item`, `give_to_npc`, `use_item`, `quest_log`, `change_rep`, `sanity_band`, `can_afford`, `npc_place`, `veins_mapped`, `quota_text`, `veins_acc`, `days_left_text`, `vein_hint`, `mark_veins_for_player`, `request(action)`…). The week: `LAST_DAY = 8` (Racibor counts on that morning), `QUOTA = 12` veins by the end of `QUOTA_DAY = 7`. Day 06:00–22:00 (16 h). The hero: `player_health`, `player_sanity`, `player_fever` (bands in words; death only on top of earlier wounds). `expedition` holds the trip under way. Constants aren't visible in dialogues: use helper functions (`quota()`).
- **VN** (`vn.gd` + `scene/vn/vn_balloon.tscn`): Dialogue Manager balloon with a live 3D portrait of the speaking NPC (own world in a SubViewport) or a static portrait (`STATIC_PORTRAITS`, e.g. the wall). Modal while open. Dialogues request world actions (`sleep`, `blast`) that run after the dialogue closes.
- **NPCs**: `NpcData` card → `Npc` node in `world.tscn/NPCs` (model, collision, "talk" interactable, 1 h) → `CharacterModel` (Quaternius parts on one retargeted skeleton, male or female body, hidden parts, head attachments such as the iron mask, looping work poses). `CampSchedule` (`camp_schedule.gd`) says where each NPC is by day, hour and story flags; markers are in `camp.tscn/Markers`.
- **StoryDirector** (`story_director.gd`, node `Story` in `world.tscn`): intro, applying the schedules (camp and field; a short fade when someone moves in the camp), expeditions (depart, [M] onwards, return with `ExpeditionSummary`), Drudzy encounters (the day-3 meeting, then rolls on arrival kept in the `encounter_place`/`encounter_npcs` flags), Mirosław's blast, nights (sanity, Nasir's fever, departures, Mirosław's death, the tremor, the hero's rest/fever, deciphering, dreams), mornings (morning snapshot, day-3 announcement, Racibor's reminders), the hero's death (retry from the morning) and breakdown, the week end (two endings). Location id while away is the `location` flag (`GameState.current_place()`).
- **Expeditions**: `LocationData` + `Expeditions` (graph, shortest path through places that are open now, falling back to the blocked shortest one so `route_lock` can say what's in the way; known/locked places, trip cost: edges + 1 h scouting on the first visit + 1 h per leg when wounded; requirements `flag:`, `noflag:`, `item:`). `MapScreen` has two modes: TABLE (the map table in the camp, "WYRUSZ") and FIELD ([M] or a signpost: neighbours or back to the camp). `map_drawing.gd` draws the graph. 25 veins (`vein_<id>` flags), 3 of them under flowstone (need the pickaxe).
- **Items / screens**: `ItemData`; `InventoryScreen` [I] (use medicine, the hero's state in words); `ExpeditionSummary` after each return; `Notebook` [J] (quests with the quota line, notes, people: health/mind/trust in words). `Interactable` supports `required_item`/`consume_item`/`missing_text`, several items per pickup (`"bandaze:2,swieca"`), `wound`, `sanity_change`, `expedition_event`; the player checks `blocked_reason()` before using.
- **Schedules**: `CampSchedule` (camp places by day/hour/flags; `gone`/`dead` NPCs never appear) and `FieldSchedule` (miners at work in `<Place>Work` markers, Drudzy in `<Place>Spot1..4`). An NPC met in the field has place `"teren"`.
- **Locations** (`locations.tscn`, generated by `tools/generators/gen_locations.gd`, far away from the mine): Rzapie (-60, 0, 70), Upadowa (-60, 0, 110), Kaplica (60, 0, 110); task_05 places on a grid: z 150 (Wyrobisko -100, Pompy -50, Grota 0, Kostnica 50, Galeria 100) and z 200 (Kuznia -100, Przekop -50, Zalany 0, Szczelina 50, Szyb 100), each a chamber built by the `chamber()`/`stub()` template with the entry from the west. Markers in `Locations/Markers`: `<Place>Entry`, `<Place>Spot1..4`, `<Place>Work`. Signposts `*ExitUse` open the field map. The east/west places live in the main level (veins in `gen_mine_deep.gd` / `gen_camp.gd`, spots `EastSpot*`/`WestSpot*`). `RiddleWall` (`riddle_wall.gd`) animates the chapel wall when the `wall_open` flag is set (after the dialogue closes).
- **Menus**: `main_menu.tscn` (START / OPTIONS / LOAD GAME / EXIT) and `pause_menu.tscn` (a CanvasLayer that runs while the game is paused). Both reuse `options_panel.tscn` and `save_slots_panel.tscn`.
- **Save/load**: `SaveManager.save_game(slot)` saves `save_state()` from every node in the `persist` group, keyed by node path. `load_game(slot)` changes scene, and the scene calls `SaveManager.restore_pending(self)` in `_ready`. New stateful nodes: add them to the group and implement `save_state` / `load_state`. `SAVE_VERSION = 3` (v2 saves still load). `capture_morning()` keeps the dawn state in memory; `retry_morning()` restarts the day after a death.
- **Level**: `scene/levels/mine.tscn` is our copy of the pack's TestLevel (without its sky environment and lights, with the east doorway opened and the east-room platform removed). Edit this copy, never the pack. `scene/levels/mine_deep.tscn` is the east extension: corridor → 10° slope → cave chamber with blue-iron veins. `camp.tscn` holds the camp areas (west room: beds, kitchen and common table, storage, powder store; east room behind the partition at x=20: leader's map table, supply stall) and all markers. **Generated scenes** (`mine_deep`, `camp`, `locations`): change the generator and regenerate, never hand-edit the scene.
- **Level coordinates**: the player wakes at `SpawnBed` (8.4, 0, 3.3) in the hall x 0–32 / z -5–4.5 (partition with a door at x=20; hall posts at x 24/27, z -3.1 and 1.1) → east exit x≈31 → east corridor along z 1–5 → old doorway x≈43 → slope x 52–64 (floor drops to y≈-2.1) → chamber x 68–82, z -4–10. The old cave arm with the first props is at x -5..0, z -35..-5.
- **Lighting** (in `world.tscn`): WorldEnvironment (black background, low ambient, ACES, SSAO/SSIL, glow, volumetric fog). OmniLights use `light_flicker.gd` (FLICKER for flames, PULSE for veins; `housing_casts_shadow=false` for lights inside lanterns). Veins: `overlay_applier.gd` + `shader/blue_iron_vein.gdshader`.
- **Audio**: `default_bus_layout.tres` has buses Ambience and SFX, both with reverb. `random_sound_emitter.gd` (AudioStreamPlayer3D) replays a sound at random intervals. Placeholder SFX in `assets/sounds/generated/` come from `tools/generators/synth_sfx.js`. The `cave_ambient.mp3` bed is non-positional and looped.
- `visual_interaction.tscn`: an early VN prototype, unused (the VN balloon replaced it).
- **Dev tools**: see [tools/README.md](tools/README.md): screenshots (lets me SEE the game, which the MCP can't; supports `day`/`hour`/`flags`), `character_preview.gd` (character models side by side), test scenarios, generators.
- **Build**: `--export-release "Windows Desktop" build/windows/Everhorror.exe` (embedded PCK; `tools/*`, `docs*`, `build/*`, `assets/Sewer/*` excluded; `dialogue/*.json` included), then zip with `tools/release/CZYTAJ_MNIE.txt` as `build/Everhorror-demo-<version>-windows.zip`. Current: 0.2. The main menu starts a new game with the user arg `--new-game` (smoke tests).

## Conventions
- Static typing (`var x: Type`, `-> void`), `@onready` node references, `class_name` for reusable types.
- Tabs for indentation (Godot default). UTF-8 (`.editorconfig`).
- New `class_name` scripts only register after an editor scan. Run `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import` before a headless or MCP run.
- Game UI text: menus are in English (START, OPTIONS…). In-world text (descriptions, dialogue) is in Polish.
- Miner lines (Mirosław, Bolko) have a Silesian-dialect version. The option is on by default. The `.dialogue` files keep the originals. The Silesian text lives in `tools/generators/write_gwara.js`, which generates `dialogue/gwara_slaska.json`, keyed by the exact original line. `Settings` registers it as a Dialogue Manager translation. After changing a miner line, update its key and rerun the generator. `tools/dialogue_test.gd` fails if a line has no Silesian version.
- Prefer data as `Resource` (`.tres`) for NPCs, items, quests, places and dialogues, so designers can edit it in the inspector.
- After changing a `.dialogue` file run `--import` before tests: the tests read the imported version. A brand-new `.dialogue` file needs two import passes (the first one fails to load resources that point at it).
- Numbers in Polish dialogue text: use the helpers (`veins_acc()`, `days_left_text()`, `GameState.plural()`), never a bare number before a noun.
- Write longer JS/GD patches to files with the Write tool; bash heredocs can mangle backslashes (`\n`).

## MCP servers ([.mcp.json](.mcp.json))
Machine-specific paths. uv tools live in `C:/Users/grups/.local/bin`. Windows **Smart App Control is ON**: it blocks unsigned DLLs (e.g. pywin32's `win32job`) in some Python packages. Python MCP servers on the `mcp` 1.10–1.x library crash on import, so pin `mcp==1.9.4` or use `mcp>=2.2`. Never try to bypass the policy.

### `godot` — `@coding-solo/godot-mcp` (no editor needed)
- Runs the game without the editor: `run_project` → `get_debug_output` → `stop_project` for a smoke test after changes. Always call `stop_project`.
- Also `create_scene`, `add_node`, `save_scene`, `load_sprite`, `get_uid`, `update_project_uids`. The project path is `C:/dev/gamedev/everhorror/everhorror`.

### `godot-editor` — hybridindie `godot-editor-mcp` (needs the Godot editor open)
- The editor addon `addons/godot_mcp` dials `ws://127.0.0.1:9080`. The `MCPRuntimeProbe` autoload enables runtime inspection and does nothing in exports.
- Start with `godot_health_check` (`bridge_connected` must be true; if false, ask the user to open the editor) and `godot_get_server_info`.
- Only `core` and `inspection` are on by default. Enable more with `godot_enable_toolset(category=...)`, e.g. `scene_edit`, `scripts`, `runtime` (play scene, live scene tree, input simulation), `editor` (screenshots), `physics`, `scene_3d`, `navigation`. Mutations support `dry_run` and `godot_undo`.
- Known issue: `godot_editor_capture_screenshot` timed out while the editor window was idle in the background. Retry with the editor in front.
- Full docs: https://hybridindie.github.io/godot-mcp/llms-full.txt

### `blender` — `mcp-for-blender` (needs Blender 5.2 open with "Start MCP Server" clicked)
- Addon `blender_mcp.py` is installed and enabled in Blender. Press N in the 3D viewport → "MCP for Blender" tab → Start/Connect.
- Useful for simple props, Poly Haven (CC0) search and download, viewport screenshots, `export_scene` → export glTF into `assets/`. Telemetry is disabled.

### `freesound` — timjrobinson/FreesoundMCPServer (`C:/dev/tools/freesound-mcp-server`)
- Needs the user env var `FREESOUND_API_KEY` (free at https://freesound.org/apiv2/apply). Without it, calls fail.
- Search and metadata only (no OAuth). Fetch the public preview MP3 URL with curl. Always record the sound's licence in `docs_v2/05_oprawa.md`, and prefer CC0.

### Our own tools (`tools/`)
- `tools/screenshot.gd` renders views to PNG, which works without the editor. Headless tests: `nav_walk_test.gd`, `interact_test.gd`. Still ask the user to playtest game feel.
- **Tests (user rule, 2026-09-25):** the demo is tested by short scenarios in `tools/tests/` (each starts from a prepared GameState, prints its steps, has a watchdog) plus `tools/dialogue_test.gd`. `tools/run_tests.sh` runs them and prints one `RESULT` line per scenario; full logs go to `reports/tests/`. **Run the full suite only after the user approves it. Never start it automatically.** Without approval, run at most a single short scenario to check a change. Never pipe a long Godot run through `grep`/`head`; write the log to a file and read the `RESULT` lines.

## Godot addons (`addons/`, third-party: don't edit, update by replacing the folder)
| Addon | Version | Use | Autoload |
|---|---|---|---|
| Dialogue Manager | 4.1.0 | VN dialogue (`.dialogue` files) | `DialogueManager` |
| GdUnit4 | 6.2.1 | unit and scene tests (reports go to `/reports/`, git-ignored) | — |
| Beehave | 2.9.3 | behaviour trees for NPCs | `BeehaveGlobalMetrics`, `BeehaveGlobalDebugger` |
| Phantom Camera | 0.11.0.3 | camera moves / cutscenes | `PhantomCameraManager` |
| Godot MCP | 2026.09.23 | editor bridge for `godot-editor` | `MCPRuntimeProbe` |
- Plugins were enabled by editing `project.godot` (`[editor_plugins]`), and their autoloads were added by hand, because `_enable_plugin()` only runs when you toggle a plugin in the editor. Keep both in sync if you add or remove an addon.
