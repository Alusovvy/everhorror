# everhorror — agent notes

Working title "everhorror" (the GDD calls the game "XYZ", `assets/logo.png` says "EVEROLD"). **Use "Everhorror" everywhere** until the name is chosen (D-08; "Everhorror" by user decision, 2026-09-25). Docs for people are Polish. Code, identifiers and code comments are English; menus are English, in-world text is Polish.

## Hard rules
- **Three sources of truth:** the spec says what we want, the code what the game does, a human sheet what someone really checked. A newer accepted decision beats an older instruction. Name contradictions and their sources; never silently pick one or rewrite canon. Roland owns all spec sections (solo process since 2026-10-26; `WORKFLOW.md` in the spec is the source map).
- **Every game change starts in the spec** (a ⬜ rule), then a task, a `spec/<date>-task<NN>` branch and a build; a chat request goes to the spec first (plan §3 pkt 2). Changes outside the spec add no new row to `WDROZENIA.md` → "Zmiany agenta poza specyfikacją"; an urgent fix that restores an existing rule needs no row, anything else is a ⬜ first (D-23, agent recommendation, subject to Roland's veto). Process-only edits never move the game baseline; inspect the semantic diff and explain any false "do wdrożenia" item.
- **Flow:** `/spec-tasks` plans only (`task_NN.md` + a row in "W zadaniach"). `/ai-task implement NN` builds on the branch, runs tests, writes the sheet in this main copy (human zones empty) and logs "Na gałęziach" 🧪 with an `[agent]` commit and push. After Roland's merge `/spec-sync finalize` flips ⬜→✅, moves the row to "Wpisy" (the baseline moves only when every task of that spec commit is done) and the task file to `done/`; a sheet is closed by Roland, never moved by an agent. Requests are cards in `zgloszenia/`: answer inside the file.
- **Branches:** never switch branches in this main copy (other sessions work here). Spec tasks are built in the worktree `../everhorror-wdrozenie`, at most one open `spec/*` branch (plan §3 pkt 5). Only Roland merges into the game `master`.
- **Human zones are never filled by an agent.** Definition: [docs/human-tasks/INFO.md](docs/human-tasks/INFO.md#strefy-człowieka). Read filled-in sheets before related work; [ROBOCZE], presence in the game and verification are separate facts. Own results go to the task report or `## Wyniki automatu (agent)`. A merge or a green test is not a playtest: verification needs the person's entry or Roland's explicit waiver. Attribute chat decisions: `Roland, czat <date>: …`.
- **Task files:** the "Wymagania:" / "Requierments" section stays byte-identical, typos and links included; the file ends with **Podsumowanie**. Rules: [docs/ai-tasks/INFO.md](docs/ai-tasks/INFO.md). Decisions are cards in the spec (`zgloszenia/`, D-03).
- **Permissions and commits:** standing permissions are in [plan §9](docs/analizy/final-plan-human-readable.md#9-decyzje-i-stałe-zgody) (`spec/*` commits, `[agent]` spec commits after a clean lint, push of `master` after Roland's merge, version tags, short tests); a current request can narrow them. Commits: `[agent] proces: …` for process and docs, never mixed with game work. Ask first: merging, the full test suite, force push or history rewrite, anything public, paid or security-related; never infer a release or a security change from a standing permission. The poller `tools/spec_poll.ps1` only reports; it creates no tasks, and its registration is optional.
- **Tests:** never start the full suite without approval; one short scenario (`unit`, `lint`, `dialogue`, `balance`) is fine. Never pipe a long Godot run through `grep`/`head`: write the log to a file and read the `RESULT` lines. See [tools/README.md#testy](tools/README.md#testy).
- **Generated** scenes (`camp`, `locations`, `mine_deep`) and `data/` resources: change the generator in `tools/generators/` and regenerate, never hand-edit. `assets/` packs and `addons/` are third-party: instance or inherit, do not edit.
- **Spec markers:** ✅ in the game, 🟡 partial, ⬜ decided and waiting (order of "Czeka na wdrożenie" = priority), 💡 proposal and ❓ question (do not implement), ❌ remove. Rule IDs (`CZAS-3`) and content IDs (`lina`, `miroslaw`) never change; numbers live in `07_balans.md`.
- Do not read `docs/archiwum/` (history). `docs/GDD.md` is the original design document: keep its authorship and text.

## Places
| What | Path |
|---|---|
| Game repo, main copy (never switch its branch, never touch uncommitted files that are not yours) | `C:/dev/gamedev/everhorror/everhorror` |
| Deployment worktree (spec tasks are built here) | `C:/dev/gamedev/everhorror/everhorror-wdrozenie` |
| Spec repo (remote `everhorror-spec`, branch `master`) | `C:/dev/gamedev/everhorror/specification` |
| Spec CLI (run from the spec root) | `node dashboard/cli.ts status --json`, `diff <from> <to> --json`, `lint`, `baseline` |
| Tasks and sheets | `docs/ai-tasks/` (`done/`, `task_template.md`), `docs/human-tasks/` (`done/`) |
| Deployment log | spec `WDROZENIA.md`: "Wpisy" (baseline), "Na gałęziach", "W zadaniach", "Czeka na wdrożenie" |
| Poller state and logs | `reports/spec-sync/` |
| Dashboard run records and lock | `reports/dashboard-runs/` (git-ignored) |
| The one plan (stages, decisions, permissions) | `docs/analizy/final-plan-human-readable.md` |

## Dashboard lock
Before you change anything, read `reports/dashboard-runs/lock.json` in the game main copy. If it exists, its `pid` is a live process (PowerShell: `Get-Process -Id <pid>`; `null` means the run is just starting) and you are not that run (your run id is named in the dashboard contract; a terminal session has none), stop and report who holds it (`kind`, `task`, `startedBy`): a dashboard run owns the repos. Never delete the lock. A lock whose process is gone is stale; ignore it. Roland orchestrates from the spec dashboard (view **Praca**; it loads the spec repo and also reads this main copy): each step is a click by Roland and one `claude -p` run of a skill (`ai-task` → "Dashboard runs").

## Conventions
- Static typing (`var x: Type`, `-> void`), `@onready` node references, `class_name` for reusable types. Tabs, UTF-8. Prefer data as `Resource` (`.tres`).
- New `class_name` scripts register only after an editor scan: run `--import` before a headless or MCP run. After changing a `.dialogue` file run `--import` before tests (a brand-new one needs two passes).
- Every farewell response gets `[#leave]` (free exit); a response that only hands over an item gets `[#free]` (the lint checks `take_item`/`give_to_npc`); any other response costs 5 minutes. Syntax: `- Text [if cond /] [#free]`.
- Greyed-out responses (DIA-2): a response whose condition fails only on `has_item(...)` or `rep(...) >= N` is shown greyed with the reason, so a hand-over response needs a quest/event guard too (`has_flag("took_bundle") and ... and has_item("tobolek")`).
- Miner lines (Mirosław, Bolko) have a Silesian version, on by default: the text lives in `tools/generators/write_gwara.js` (generates `dialogue/gwara_slaska.json`, keyed by the exact original line). After changing a miner line update its key and rerun the generator; `tools/dialogue_test.gd` fails on a missing version.
- `GameState.has_flag` accepts payload flags (String place, int day, Array): any non-empty payload counts as set; never call `bool()` on a flag value.
- Numbers in Polish text: use `veins_acc()`, `days_left_text()`, `GameState.plural()`, never a bare number before a noun.
- New player-facing text in a script goes through `tr()` or a `Texts` table, not a new literal (preparation for the English version, D-09).
- Write longer JS/GD patches to files with the Write tool; bash heredocs can mangle backslashes.
- Delegation (Roland, 2026-10-27): one task = one doer agent end to end (read, change, test, self-check, report or commit), so it keeps its context and cache; at most one review after it. Parallel agents only for truly independent tasks. Tests: targeted layers while working, the agreed set once at the end. Models (Roland, 2026-10-27, D-29): orchestration, review, planning and analysis on Opus 5.5 (medium unless Roland sets higher); writing, coding and fixing on Sonnet 5.5 high, simpler tasks on Haiku 5.5 max. Escalate a Haiku doer to Sonnet 5.5 high when the review finds its mistake or something breaks. Opus high only with Roland's approval.

## Tech essentials
- Godot **4.7.2** (Forward+, D3D12, Jolt): `C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe`. Scripts are **GDScript**; do not add C# unless asked.
- Main scene `scene/main_menu.tscn`, gameplay scene `scene/world.tscn`. Autoloads: `Settings`, `SaveManager`, `GameState`, `VN`, `DialogueManager` and addon autoloads. Input: WASD, `interact` E, `notebook` J, `inventory` I, `field_map` M, Esc; no jump.
- Version, release steps and the tag: [tools/README.md#wydanie](tools/README.md#wydanie); history of versions: `CHANGELOG.md`. Licences of assets: spec `06_oprawa.md#rejestr-zasobów` (some unconfirmed, D-10).

## Where to read more
- Systems, layout, level, lighting, audio, addons, MCP servers, technical glossary: [docs/agent/README.md](docs/agent/README.md).
- Tests, screenshots, generators, release: [tools/README.md](tools/README.md). Plan, decisions D-01…, stages: [docs/analizy/final-plan-human-readable.md](docs/analizy/final-plan-human-readable.md).
- Spec (`C:/dev/gamedev/everhorror/specification`): `WORKFLOW.md` (process), `README.md` (markers, IDs), `WDROZENIA.md`, `01_swiat/slowniczek.md` (words), `01_swiat/LoreDoc.md` (Ren's world bible, about 305 KB: grep, then read a small window), `dashboard/INSTRUKCJA.md`.
- Skills (`.claude/skills/`): `spec-tasks` plans, `ai-task` implements, `spec-sync` finalizes. Helpers (`.claude/agents/`): `lore-checker`, `test-runner`, `convention-reviewer`.
