# tools/

Dev tools run from the command line (project root). Not used by the game.

| Tool | What it does | Command |
|---|---|---|
| `screenshot.gd` | Renders the scene from camera positions in a JSON file to PNGs (real GPU window, not headless). | `Godot_v4.7.2-stable_win64_console.exe --path . --resolution 1280x720 --script res://tools/screenshot.gd -- tools/views_tour.json <out_dir>` |
| `nav_walk_test.gd` | Bakes a player-sized navmesh, finds a path spawn → goal, walks it with physics. Checks the level is traversable. | `... --headless --path . --script res://tools/nav_walk_test.gd` |
| `interact_test.gd` | Aims at every interactable and checks highlight, prompt, description. | `... --headless --path . --script res://tools/interact_test.gd` |
| `generators/gen_mine_deep.gd` | Generates `scene/levels/mine_deep.tscn` (corridor, slope, chamber, lights, sounds). **Overwrites the scene.** | `... --headless --path . --script res://tools/generators/gen_mine_deep.gd` |
| `generators/synth_sfx.js` | Synthesizes placeholder sounds into `assets/sounds/generated/`. | `node tools/generators/synth_sfx.js` |

Notes:
- Test scripts load the world one frame late and avoid `class_name` types, because autoloads (`Settings`, `SaveManager`) are not registered yet when a `--script` main loop starts.
- After adding a new `class_name` script, run `--headless --path . --import` once before headless runs.
