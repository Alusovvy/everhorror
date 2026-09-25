# everhorror — agent notes

Working title "everhorror" (the GDD still calls the game "XYZ"). A first-person horror mystery / adventure game with visual-novel (VN) sequences, set in a mine that leads down into caves and finally to the Temple of the Ones ("Świątynia Onych"). The player is a member of a mining expedition and follows their missing grandfather's trail. There are time limits, NPCs to manage (sanity, health, reputation) and multiple endings.

## Docs (in Polish)
- [docs/GDD.md](docs/GDD.md) — the game design document, owned by the team. Sections and owners: concept, start and ending (Vitav), main plot (Ren), mechanics (Roland), NPC stories. Don't rewrite it unless asked.
- [docs/MECHANICS.md](docs/MECHANICS.md) — mechanics spec derived from GDD §4 and expanded for implementation. **This is the current focus.** Keep it in sync when mechanics change.
- Docs for the team are written in Polish. Code, identifiers and code comments are in English.

### Glossary (PL → meaning)
- **błękitne żelazo** — "blue iron": the ore being mined. It is ordinary metal improved by centuries of radiation from an artifact.
- **Pierwsi / Pierwszy** — "the First (ones)": a hostile ancient force. *Pierwszy* is the final threat.
- **Drudzy** — "the Second (ones)": a faction. One ending questline takes them to the bottom of the mine to defeat Pierwszy.
- **Oni / Świątynia Onych** — "the Ones" / their temple, at the deepest level.
- **Ekspedycja** — the mining expedition (the player's group). Factions: Drudzy / Ekspedycja / Inna ("other"). No more factions are planned.
- **Kniaź Jaksaru, Wąwóz Pierwszych, Mirosil** — the ruler, the region and a town in the setting.
- **obóz** — the camp (hub). **szychta** — a mining shift. **poczytalność / sanity** — an NPC's sanity meter.

## Tech
- Godot **4.7.2** (Forward+, D3D12, Jolt Physics). Executable: `C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe`.
- Scripts are **GDScript**. `project.godot` has a `[dotnet]` assembly name, but there's no C# code, so don't add C# unless asked.
- The project isn't a git repository.
- Main scene: `scene/world.tscn` (uid `cr3kk787rbwr8`).

## Layout
- `scene/` — scenes (`world.tscn`, `player.tscn`, `visual_interaction/visual_interaction.tscn`).
- `script/` — one script per scene, with the same name (`world.gd`, `player.gd`, `visual_interaction.gd`).
- `assets/` — third-party packs (`LoafbrrAssets/MineAndCavesSet` for the modular mine and caves, `prop_pack`, `Sewer`), plus `sounds/` and `pics/`. Don't edit the pack contents. Instance or inherit from them instead.
- `docs/` — design docs.

## Current state (2026-09-25)
- `world.tscn`: the sample level from the Mine & Caves pack, a few props, cave ambience. The mouse is locked to the window at start, and `ui_cancel` quits.
- `player.gd`: an FPS `CharacterBody3D` (Head → EyeCamera). It moves with the built-in `ui_*` actions and plays a footstep sound. It still has debug `print`s that run every physics frame, and its movement direction uses the pitched camera basis instead of `head`.
- `visual_interaction.tscn`: an early VN / dialogue UI prototype (picture, text box, a list of option buttons with placeholder text). Nothing in the game uses it yet.
- There are no custom input actions yet.

## Conventions
- Static typing (`var x: Type`, `-> void`), `@onready` node references, `class_name` for reusable types.
- Tabs for indentation (Godot default). UTF-8 (`.editorconfig`).
- Prefer data as `Resource` (`.tres`) for NPCs, items, quests and dialogues, so designers can edit it in the inspector.

## Godot MCP (`godot` server, `@coding-solo/godot-mcp`)
- Configured in [.mcp.json](.mcp.json) with `GODOT_PATH` set. The project path for tools is `C:/dev/gamedev/everhorror/everhorror`.
- Useful tools: `run_project` → `get_debug_output` → `stop_project` for a smoke test after changes. There are also `create_scene`, `add_node`, `save_scene`, `load_sprite`, `get_uid` and `update_project_uids`.
- Limits: no screenshots, no input simulation, no live scene-tree inspection. Check behaviour through console output, and ask the user to playtest anything visual or about game feel.
- Always call `stop_project` after `run_project`, because the game window stays open otherwise.
