---
name: ai-task
description: Work a task from docs/ai-tasks/ (task_NN.md) end to end — "status" (what each open task waits for), "analyze NN" (analysis, plan, questions for Roland), "implement NN" (code, lore check, tests, convention review, human sheet, docs/spec sync, move to done/), "fix NN" (corrections on the existing branch), "review NN" (read-only review with a JSON verdict) and "close NN" (read the filled-in sheet, move it to done/). Also holds the rules for runs started from the spec dashboard. Use whenever the user asks to do, analyse, continue, implement, fix, review or close a task_NN, or asks which tasks are open.
---

# ai-task

Modes (the argument after `/ai-task`): **`status`** (default), **`analyze NN`**, **`implement NN`**, **`fix NN`**, **`review NN`**, **`close NN`**. A bare request like "zrób task_12" means `analyze` if the task has no resolved plan yet, otherwise `implement`.

## Places
| What | Path |
|---|---|
| Game main copy (task reports, human sheets and reading; never switch its branch) | `C:/dev/gamedev/everhorror/everhorror` |
| Tasks: open / done | `docs/ai-tasks/task_NN.md` / `docs/ai-tasks/done/` |
| Human sheets (factchecks, play sessions) and legacy decision files: open / done | `docs/human-tasks/` / `docs/human-tasks/done/` |
| Decision cards (D-03, every new decision): open / closed | `C:/dev/gamedev/everhorror/specification/zgloszenia/` / `zgloszenia/zamkniete/` |
| Workflow rules (the user's) | `docs/ai-tasks/INFO.md`, template `docs/ai-tasks/task_template.md` |
| Sheet conventions (human zones, templates) | `docs/human-tasks/INFO.md`, `factcheck_template.md`, `playtest_template.md` |
| Dashboard run records and lock | `reports/dashboard-runs/` (main copy, git-ignored; `lock.json` is the run that owns the repos) |
| Spec (design source of truth) | `C:/dev/gamedev/everhorror/specification` (`README.md`, `WDROZENIA.md`, `07_balans.md`, "Dla agenta" sections) |
| Test map (system → scenario) | `tools/README.md` |

Read `CLAUDE.md` first; it holds the conventions every step relies on. Hard rules from `INFO.md`:
- Never edit the task's requirements section ("Wymagania:" / "Requierments"), typos included.
- The task file always ends with **Podsumowanie** (Summary).
- Write in the task's language (task_02+ are Polish). Report in the task file, and briefly in chat.

**Dashboard lock (every mode).** Before you change anything, read `reports/dashboard-runs/lock.json` in the main copy. If it exists, its `pid` is a live process (PowerShell: `Get-Process -Id <pid>`; `null` means the run is just starting) and you are not that run (your run id, `EVERHORROR_DASHBOARD_RUN`, is named in your contract; a terminal session has none), stop and report who holds it (`kind`, `task`, `startedBy`, `startedAt`): a dashboard run owns the repos until it ends. Never delete the lock. A lock whose process is gone is stale: ignore it, the dashboard clears it.

Current process and source precedence: `C:/dev/gamedev/everhorror/specification/WORKFLOW.md` (accepted solo mode, 2026-10-26). Roland owns all active sections. Keep original authorship. Never fill a human zone (the `wynik`/`uwagi`/`ocena`/`wybór` cells, the answer sections and the `Wyniki człowieka`/`Zwolnienie`/`Zamknięcie` lines; rules in `docs/human-tasks/INFO.md`); your automated checks go only in the task report or under `## Wyniki automatu (agent)` in the sheet. Attribute any chat decision. A merge or green automated check is not human verification; retain pending playtests until a person's result or Roland's explicit waiver.

Before new gameplay implementation, a chat request becomes accepted spec text and then a task with its spec SHA (accepted WF-1). Use the designated implementation worktree and the Spec tasks rules below; do not implement a new gameplay request directly on main. Historical task requirements stay unchanged. A bounded documentation/tooling request follows its explicitly authorized scope, without starting gameplay waves.

## Subagents
Three helpers live in `.claude/agents/`. Spawn them at the steps below. Each gets the working directory, the files involved and one concrete question, and returns only conclusions. They never edit files, so apply their findings yourself.
- `lore-checker`: new Polish lines or world facts against the canon.
- `test-runner`: runs named scenarios and returns the RESULT table plus failure excerpts.
- `convention-reviewer`: checks the diff against `CLAUDE.md` before the factcheck.

`lore-checker` and `convention-reviewer` are read-only, so they can run in the background while you do something else. Wait for `test-runner` before judging a change.

## Dashboard runs
You are in a dashboard run when the environment variable `EVERHORROR_DASHBOARD_RUN` is set, or the appended system prompt starts with `# Przebieg z dashboardu`. Roland started you with one click in the spec dashboard (Praca): the skill call (`/ai-task <mode> NN`, `/spec-tasks unattended` or `/spec-sync finalize`) is the whole job. The appended contract (Polish) names the task, the branch, the paths and the limits, and ends with Roland's note, verbatim; the note refines the goal but never lifts a rule. Where the contract is stricter than this file, the contract wins. A PreToolUse guard hook blocks forbidden commands and writes: a blocked command is a rule, not an obstacle, so do not look for a workaround. An audit compares the repos before and after the run and flags violations; nothing is reverted automatically.
- **Non-interactive.** Nobody answers a question, so never ask and never wait. When Roland has to decide, write one decision card (D-03) as `C:/dev/gamedev/everhorror/specification/zgloszenia/<YYYY-MM-DD>_task<NN>-<topic>.md` (ASCII name), from `szablony/decyzja.md`: `Rodzaj: decyzja`, `Zadanie: task_NN`, all the run's questions in one choice table `| # | Pytanie | Opcje | Rekomendacja | Twój wybór |` (options as `**a)** … **b)** …`, your recommendation first, the `Twój wybór` cells empty), and `## Decyzja` left as "Do rozstrzygnięcia." At most five cards may be open at once (plan §3). Run `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts lint` (0 errors), commit the card as `[agent] …` naming only its path, link the card from the task file, and stop with `STATUS: czeka-na-decyzje`. Do not guess the answer and do not go on past the question. A `review` run is read-only and writes no card: it states the open decision in `podsumowanie` and gives the verdict `blokada`.
- **Main copy.** Never switch its branch, commit, merge, push or tag in it. Docs you create or change there (the task report, the human sheet) stay uncommitted: Roland saves them with "Zapisz dokumenty w historii gry". You do not `git mv` task files or sheets (`/spec-sync finalize` moves the task file after the merge; a sheet is closed by Roland's click).
- **Code** only in the worktree `C:/dev/gamedev/everhorror/everhorror-wdrozenie`, on the task branch; Godot only with `--path` set to the worktree. Tests by name through `test-runner`; the full suite only when the contract says "user approved full suite".
- **Spec commits** only after lint shows 0 errors (the full path form above), and only with explicit paths: `git -C <spec> add -- <file>`, then `git -C <spec> commit -m "[agent] …" -- <file>`; never `-a`, `add -A` or `add .`. Pushing the spec `master` is allowed (standing permission), never forced. Tickets and decision cards stay in `zgloszenia/`: edit them with Edit and Write, never `git mv`, `mv`, `cp` or `rm` them (the guard blocks it; a finished one is moved to `zgloszenia/zamkniete/` outside a dashboard run).
- **Commands.** Always `git -C <full path> …`. No `git -c`, `bash -c`, `eval` or `node -e`, and no variables or `$(…)` inside paths. Merge, rebase, reset, checkout, stash, clean, tag and force push are blocked. Network, MCP and PowerShell (also npm and npx) are disabled.
- **Human zones and requirements.** You never write a human zone, and the requirements section of the task stays byte-identical. The hook blocks both and the audit checks them. The audit also checks what a sheet says about itself: never add or change the header notes `zastąpione …` and `niesprawdzone przez człowieka` or a `Zwolnienie:` line, rename a human column (`wynik` to `Wynik automatu`) or put `(agent)` in the heading of a human table, and do not delete the empty rows of a sheet. The hook cannot tell these from prose, but the audit reports them as a violation (`SHEET_STATE`).
- **Finish** with exactly three lines, in Polish: `STATUS: ok|czeka-na-decyzje|blad`, `ZROBIONE: <what was done, one sentence>` and `NASTĘPNY KROK: <what a person or the next run does>`. `blad` also covers a failed precondition. `review` ends with its JSON verdict instead, and no STATUS lines.

## status
List every `docs/ai-tasks/task_*.md` (not `done/`). For each, give one line: the title or first requirement, and what it waits for:
- analysis;
- a decision (an open decision card with `Zadanie: task_NN` in `../specification/zgloszenia/`, or a legacy `docs/human-tasks/decision-task-NN.md` still open);
- another task (its "Kolejność" line);
- implementation;
- a review or fixes of its branch;
- the user's sheet (`docs/human-tasks/factcheck-test-NN.md` not filled in);
- closing.

Also list sheets in `docs/human-tasks/` whose `wynik` column is filled in (ready for `close`). Change nothing.

## analyze NN
1. Read the task, `INFO.md`, and any factcheck or decision of a task it depends on (done or open).
2. Read the code and the spec parts it touches (the "Dla agenta" sections point to the code). Check the "Kolejność" dependency: if an earlier task is still open, say so.
3. Below the requirements (after the `---` / agent marker), write **Analiza** (how it works today, gaps, risks) and **Plan** (numbered steps, files, tests, spec/docs updates).
4. Open questions: interactive session → AskUserQuestion; otherwise (a dashboard run, or any unattended one) → a decision card (D-03) in the spec, as described in **Dashboard runs**, linked from the task. The legacy `docs/human-tasks/decision-task-NN.md` files are read-only history: do not create or edit them.
5. Report in chat: what the task needs, what you ask.

## implement NN
A task whose header has the line `Źródło: specyfikacja` was written by `/spec-tasks`. Follow the steps below together with the differences in **Spec tasks**.

1. **Preconditions.** Every decision is resolved: the decision cards with `Zadanie: task_NN` are ✅ (or closed), a legacy decision file is in `human-tasks/done/`, or the user answered in chat. Tasks it depends on are implemented. A filled-in sheet of a related task has been read and its bugs are either fixed or explicitly out of scope. If something is missing, stop and say what (in a dashboard run: `STATUS: czeka-na-decyzje` for a decision, otherwise `STATUS: blad`).
2. **Implement** following `CLAUDE.md`:
   - generated scenes and data change through their generators, never by hand;
   - miner lines get Silesian keys (`tools/generators/write_gwara.js`, rerun it);
   - dialogue tags: `[#leave]` on farewells, `[#free]` only on item hand-overs;
   - greyed-response guards (DIA-2);
   - Polish number helpers;
   - `has_flag` never through `bool()`;
   - `--import` after `.dialogue` changes (twice for a new file).
3. **Lore.** If the change adds or changes Polish lines, or facts about people, places, magic or factions, spawn `lore-checker`. Give it the new lines with their `file:line` and the facts they assert. Fix real contradictions. Route unresolved canon to Roland with sources and a recommendation; preserve deliberate unknowns and `[ROBOCZE]` rather than inventing answers.
4. **Tests.** Spawn `test-runner` with `unit lint dialogue` plus the scenarios that cover the touched systems (see `tools/README.md`). Also tell it whether `.dialogue` files or new `class_name` scripts changed (it must `--import` first). Never ask it for the full suite unless the user approved that in this conversation; then pass the words "user approved full suite". Fix failures caused by the change. Report failures outside the change instead of widening the change.
5. **Review.** Spawn `convention-reviewer` on the uncommitted diff, naming the task number. Fix what it finds, then re-run `test-runner` on the scenarios the fixes touch.
6. **Docs.**
   - The human sheet `docs/human-tasks/factcheck-test-NN.md` (Polish) lives in the **main copy**, never on the branch. Start from `docs/human-tasks/factcheck_template.md`, or from `playtest_template.md` when the build needs a play session (rules: `docs/human-tasks/INFO.md`): what was added, then a table `# | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi`. Every human zone stays empty (the `wynik`/`uwagi`/`ocena`/`wybór` cells, answer sections, the `Wyniki człowieka`/`Zwolnienie`/`Zamknięcie` lines). Your own results go only in the task report or in a table under `## Wyniki automatu (agent)` in the sheet. If the sheet already exists, add rows and prose only; a filled cell is never touched.
   - Current design belongs to the spec; duplicated docs_v2/MECHANICS descriptions are reference-only and have no ongoing sync duty. Preserve their unique LoreDoc/asset evidence pending verified migration; follow the WORKFLOW source map.
   - Spec: update the rules; mark details you decided yourself as **[ROBOCZE]**; add code pointers under "Dla agenta"; add a row for game changes in `WDROZENIA.md` → "Zmiany agenta poza specyfikacją". Numbers go in `07_balans.md`. Run `node dashboard/cli.ts lint` in the spec repo (0 errors). Commits/pushes follow current authorization and the accepted plan's exact scope; a local-only documentation task does not commit or push.
   - `CLAUDE.md`: update it if a system, a convention or a test layer changed.
7. **Task file.** Fill in these sections:
   - "Co zostało zrobione" (one subsection per requirement);
   - "Decyzje i założenia";
   - "Czego potrzebuję od Ciebie";
   - "Test" (link to the sheet, the RESULT lines);
   - "Podsumowanie" last.

   Then `git mv` the task to `docs/ai-tasks/done/` and fix its relative links (they gain one `../`). Also fix links that point at it from other files. (A spec task stays in `docs/ai-tasks/` until its branch is merged, see **Spec tasks**; a dashboard run never moves a task file, see **Dashboard runs**.)
8. **Report** in chat, briefly: what changed, the tests and their results, what the user should check in the sheet, open questions.

## Spec tasks
These are tasks with the line `Źródło: specyfikacja <sha7>`, created by `/spec-tasks` from the spec, which is the source of truth. They differ from chat tasks as follows:
- **Where.**
  - All work happens in the worktree `C:/dev/gamedev/everhorror/everhorror-wdrozenie`, on the branch `spec/<YYYY-MM-DD>-task<NN>`. Never switch branches in the main copy.
  - First time: `git -C <game> worktree add <worktree> -b spec/<date>-task<NN> master`, then `cp -r <game>/.godot <worktree>/`.
  - Later: `git -C <worktree> switch -c spec/<date>-task<NN> master`. The worktree must be clean; if it isn't, stop and report.
  - At most one open `spec/*` branch at a time: if "Na gałęziach" in `WDROZENIA.md` has a 🔧/🧪 row, stop and say which branch waits for review.
  - Pass the worktree path to `test-runner` and `convention-reviewer`.
- **Requirements** are rule quotes. The spec text of those IDs (and their "Dla agenta" sections) is binding. A detail you decide yourself goes into the spec marked **[ROBOCZE]**. If the spec contradicts itself, ask (interactive) or write a ❔ ticket (unattended; in a dashboard run a decision card instead, see **Dashboard runs**); don't guess.
- **Commit.** The code and the relevant current docs go on the branch, committed as `task_NN: <short Polish summary>` with the IDs in the body. The human sheet is **not** committed there: it stays in the main copy and the dashboard commits it. If an older sheet already exists on the branch (committed before this rule, like task_14's PT0), leave it where it is and report it. Link automated rule checks separately; human rows focus on what a person must judge. Standing permission covers `spec/*` commits. Never commit to or merge into `master`.
- **Task file.** The report goes into the task file in the main copy. It stays in `docs/ai-tasks/` until the branch is merged; `/spec-sync finalize` moves it to `done/`.
- **Spec.**
  - Add a row to `WDROZENIA.md` → "Na gałęziach": `| \`spec/<date>-task<NN>\` | \`<sha7>\` | <IDs>, task_NN | \`docs/human-tasks/factcheck-test-NN.md\` | 🧪 do sprawdzenia |`.
  - Set the task's row in "W zadaniach" to 🧪.
  - Don't flip ⬜→✅, and don't add a row to "Zmiany agenta poza specyfikacją". Finalize does the markers.
  - Run `node dashboard/cli.ts lint` (0 errors), commit `[agent] spec/<date>-task<NN>: wdrożone na gałęzi, do sprawdzenia` with explicit paths, and push.
- **Tool and documentation tasks** (`Rodzaj: narzędzia` / `dokumentacja`, usually created by the dashboard form) have no spec rules and no spec commit. They go through the same branch, worktree, report and sheet. In their ledger rows write `—` instead of a spec sha7 (a real hash would move the start point of `/spec-tasks` and the baseline) and `task_NN` as the ID; add the "W zadaniach" row yourself when the task has none. They never start gameplay.
- **Report** in chat. Add how to try the change: open the worktree in Godot, or merge it from the dashboard ("Scal do master gry") or with `git merge spec/…` when happy.

In `status`, mark each task's source (spec or chat), and for spec tasks, its branch and "W zadaniach" status.

## review NN
A read-only review of a built branch. In the dashboard this is the "Przegląd" click; it writes nothing and commits nothing. You may run it in a terminal session too.
1. Find the branch (`spec/<date>-task<NN>`; a dashboard contract names it) and the worktree `C:/dev/gamedev/everhorror/everhorror-wdrozenie`. Read `git -C C:/dev/gamedev/everhorror/everhorror-wdrozenie diff master...<branch>` (also `--stat`; `git -C <worktree> show <branch>:<path>` for whole files), the task's requirements and report in the main copy, and the sheet. Do not switch the worktree, and never the main copy. If the worktree is not on the branch (`git -C <worktree> branch --show-current`), skip the tests and say so.
2. Judge the diff against:
   - every requirement of the task, one by one;
   - the spec rules of its IDs and their "Dla agenta" sections (code pointers still right, `[ROBOCZE]` on self-decided details, numbers in `07_balans.md`, both ledger rows at 🧪);
   - the decisions it relies on (resolved decision cards, legacy decision files, attributed chat decisions);
   - the `CLAUDE.md` conventions;
   - the process rules: the sheet is in the main copy and not on the branch, its human zones are empty, the requirements are byte-identical, the report ends with "Podsumowanie".
3. You may spawn `convention-reviewer` (name the worktree and the range `master...<branch>`) and `lore-checker` (new Polish lines with `file:line`), and run named short tests through `test-runner` (`unit lint dialogue` plus the scenarios that cover the touched systems; its logs go to the worktree's `reports/`, which is git-ignored). Never the full suite: a review never carries that approval.
4. Final answer, nothing after it: one JSON object `{werdykt, wymagania, ustalenia, podsumowanie}`.
   - `werdykt`: `gotowe` (can be merged: no `błąd`, every requirement `spełnione`, the named tests pass), `poprawki` (needs fixes first) or `blokada` (must not be merged, e.g. a human zone was filled, the requirements were edited, a decision is missing or a test fails for a reason in the change).
   - `wymagania`: one entry per requirement of the task file: `{nr, stan: spełnione|częściowo|brak, dowod}`, where `dowod` is a file, line or test.
   - `ustalenia`: the problems, most serious first: `{waga: błąd|uwaga, plik?, linia?, opis}`. `błąd` must be fixed before the merge; `uwaga` is worth knowing and may wait.
   - `podsumowanie`: two or three Polish sentences for Roland.

   A dashboard run passes the schema (`--json-schema`): return the object through the structured-output call and add no STATUS lines. In a terminal session print the same object as a JSON block.

## fix NN
Corrections on a branch that is already built (a 🧪 row in "Na gałęziach"). Inputs: the run note (in a dashboard contract, Roland's note verbatim: the review findings and/or the ❌/💬 rows of the sheet), the task report, and the sheet itself, read only.
1. **Preconditions.** The branch `spec/<date>-task<NN>` exists and is not merged. Work in the worktree: if it is detached and clean, `git -C <worktree> switch <branch>`; if it is on another branch or dirty, stop and report.
2. **Fix** minimally, only what the findings name, following `CLAUDE.md` as in **implement** step 2. A finding that needs a design decision, or a ❌/💬 row that asks for something new, is not a fix: in a dashboard run write a decision card (`STATUS: czeka-na-decyzje`), in a terminal session ask. New gameplay goes through the spec first (WF-1).
3. **Tests.** `test-runner` on the named scenarios the fix touches (plus `unit lint dialogue` when lines or ids changed); never the full suite without approval. `convention-reviewer` on the fix diff when it is more than trivial.
4. **Report.** Append `## Poprawki (<RRRR-MM-DD>)` to the task report in the main copy: what each finding got (fixed, or why not) and the tests with their actual results. Touch the spec only if a rule, a `[ROBOCZE]` detail or a "Dla agenta" pointer changed (lint 0 errors, `[agent]` commit with explicit paths, push).
5. **Commit** on the branch as `task_NN: poprawki …` (the findings in the body). Keep the ledger at 🧪 in "Na gałęziach" and "W zadaniach". Never fill, clear or re-mark a human zone: the ❌/💬 rows of the sheet stay as the person wrote them, and the person re-checks.

## close NN
The normal path is the dashboard (Praca → the sheet): a person fills it in ("Wypełnij arkusz"), then "Przenieś arkusz do done/", or waives it ("Zwolnij z testu"). Each is a click by a person and one signed commit naming only the files it touches. This mode is for a terminal session when Roland asks; it is never part of a dashboard run.
1. Read `docs/human-tasks/factcheck-test-NN.md`: every `wynik`/`uwagi` cell.
2. For each bug or change proposal, ask the user whether it becomes a new task (next free `task_NN.md` from the template, with the user's words quoted as the requirements) or a fix now. Don't fix silently.
3. When nothing is left open for that factcheck, `git mv` it to `docs/human-tasks/done/` and fix its relative links.

Never move an unfilled sheet without Roland's waiver: the `Zwolnienie:` line that the dashboard writes on his click. If Roland waives it in chat, quote him in the task report (`Roland, czat <date>: …`), ask him to press "Zwolnij z testu", and move the sheet only after the line exists. You never write the `Wyniki człowieka`, `Zwolnienie` or `Zamknięcie` lines yourself.

## Parallel tasks (only when the user asks)
Two independent tasks at once, each with resolved decisions and no dependency between them:
- run the second one in a worktree: `git worktree add ../everhorror-task-NN -b task/NN master`, then `cp -r .godot ../everhorror-task-NN/`;
- do all edits, generators and tests there (`--path .`);
- never run two Godot imports on the same folder at the same time;
- merge back only with the user's approval.
