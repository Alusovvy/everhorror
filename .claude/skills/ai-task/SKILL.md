---
name: ai-task
description: Work a task from docs/ai-tasks/ (task_NN.md) end to end — "status" (what each open task waits for), "analyze NN" (analysis, plan, decision file), "implement NN" (code, lore check, tests, convention review, factcheck, docs/spec sync, move to done/) and "close NN" (read the filled-in factcheck, move it to done/). Use whenever the user asks to do, analyse, continue, implement or close a task_NN, or asks which tasks are open.
---

# ai-task

Modes (the argument after `/ai-task`): **`status`** (default), **`analyze NN`**, **`implement NN`**, **`close NN`**. A bare request like "zrób task_12" means `analyze` if the task has no resolved plan yet, otherwise `implement`.

## Places
| What | Path |
|---|---|
| Game repo (work here, on `master`, no commits unless asked) | `C:/dev/gamedev/everhorror/everhorror` |
| Tasks: open / done | `docs/ai-tasks/task_NN.md` / `docs/ai-tasks/done/` |
| Decisions and factchecks: open / done | `docs/human-tasks/` / `docs/human-tasks/done/` |
| Workflow rules (the user's) | `docs/ai-tasks/INFO.md`, template `docs/ai-tasks/task_template.md` |
| Spec (design source of truth) | `C:/dev/gamedev/everhorror/specification` (`README.md`, `WDROZENIA.md`, `07_balans.md`, "Dla agenta" sections) |
| Test map (system → scenario) | `tools/README.md` |

Read `CLAUDE.md` first; it holds the conventions every step relies on. Hard rules from `INFO.md`:
- Never edit the task's requirements section ("Wymagania:" / "Requierments"), typos included.
- The task file always ends with **Podsumowanie** (Summary).
- Write in the task's language (task_02+ are Polish). Report in the task file, and briefly in chat.

## Subagents
Three helpers live in `.claude/agents/`. Spawn them at the steps below. Each gets the working directory, the files involved and one concrete question, and returns only conclusions. They never edit files, so apply their findings yourself.
- `lore-checker`: new Polish lines or world facts against the canon.
- `test-runner`: runs named scenarios and returns the RESULT table plus failure excerpts.
- `convention-reviewer`: checks the diff against `CLAUDE.md` before the factcheck.

`lore-checker` and `convention-reviewer` are read-only, so they can run in the background while you do something else. Wait for `test-runner` before judging a change.

## status
List every `docs/ai-tasks/task_*.md` (not `done/`). For each, give one line: the title or first requirement, and what it waits for:
- analysis;
- a decision (`docs/human-tasks/decision-task-NN.md` still open);
- another task (its "Kolejność" line);
- implementation;
- the user's factcheck (`docs/human-tasks/factcheck-test-NN.md` not filled in);
- closing.

Also list factchecks in `docs/human-tasks/` whose `wynik` column is filled in (ready for `close`). Change nothing.

## analyze NN
1. Read the task, `INFO.md`, and any factcheck or decision of a task it depends on (done or open).
2. Read the code and the spec parts it touches (the "Dla agenta" sections point to the code). Check the "Kolejność" dependency: if an earlier task is still open, say so.
3. Below the requirements (after the `---` / agent marker), write **Analiza** (how it works today, gaps, risks) and **Plan** (numbered steps, files, tests, spec/docs updates).
4. Open questions: interactive session → AskUserQuestion; otherwise → `docs/human-tasks/decision-task-NN.md` (numbered questions, options, your recommendation first), linked from the task.
5. Report in chat: what the task needs, what you ask.

## implement NN
A task whose header has the line `Źródło: specyfikacja` was written by `/spec-tasks`. Follow the steps below together with the differences in **Spec tasks**.

1. **Preconditions.** The decision file is resolved (moved to `human-tasks/done/`, or the user answered in chat). Tasks it depends on are implemented. A filled-in factcheck of a related task has been read and its bugs are either fixed or explicitly out of scope. If something is missing, stop and say what.
2. **Implement** following `CLAUDE.md`:
   - generated scenes and data change through their generators, never by hand;
   - miner lines get Silesian keys (`tools/generators/write_gwara.js`, rerun it);
   - dialogue tags: `[#leave]` on farewells, `[#free]` only on item hand-overs;
   - greyed-response guards (DIA-2);
   - Polish number helpers;
   - `has_flag` never through `bool()`;
   - `--import` after `.dialogue` changes (twice for a new file).
3. **Lore.** If the change adds or changes Polish lines, or facts about people, places, magic or factions, spawn `lore-checker`. Give it the new lines with their `file:line` and the facts they assert. Fix real contradictions. Leave a canon question for Ren as a note in "Czego potrzebuję od Ciebie".
4. **Tests.** Spawn `test-runner` with `unit lint dialogue` plus the scenarios that cover the touched systems (see `tools/README.md`). Also tell it whether `.dialogue` files or new `class_name` scripts changed (it must `--import` first). Never ask it for the full suite unless the user approved that in this conversation; then pass the words "user approved full suite". Fix failures caused by the change. Report failures outside the change instead of widening the change.
5. **Review.** Spawn `convention-reviewer` on the uncommitted diff, naming the task number. Fix what it finds, then re-run `test-runner` on the scenarios the fixes touch.
6. **Docs.**
   - `docs/human-tasks/factcheck-test-NN.md` (Polish): what was added, then a table `# | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi`, with `wynik`/`uwagi` left empty.
   - docs_v2: status markers ✅/🟡/⬜ and the changed system files.
   - Spec: update the rules; mark details you decided yourself as **[ROBOCZE]**; add code pointers under "Dla agenta"; add a row in `WDROZENIA.md` → "Zmiany agenta poza specyfikacją". Numbers go in `07_balans.md`. Run `node dashboard/cli.ts lint` in the spec repo (0 errors). Spec commits only when the user asks (outside spec-sync).
   - `CLAUDE.md`: update it if a system, a convention or a test layer changed.
7. **Task file.** Fill in these sections:
   - "Co zostało zrobione" (one subsection per requirement);
   - "Decyzje i założenia";
   - "Czego potrzebuję od Ciebie";
   - "Test" (link to the factcheck, the RESULT lines);
   - "Podsumowanie" last.

   Then `git mv` the task to `docs/ai-tasks/done/` and fix its relative links (they gain one `../`). Also fix links that point at it from other files.
8. **Report** in chat, briefly: what changed, the tests and their results, what the user should check in the factcheck, open questions.

## Spec tasks
These are tasks with the line `Źródło: specyfikacja <sha7>`, created by `/spec-tasks` from the spec, which is the source of truth. They differ from chat tasks as follows:
- **Where.**
  - All work happens in the worktree `C:/dev/gamedev/everhorror/everhorror-wdrozenie`, on the branch `spec/<YYYY-MM-DD>-task<NN>`. Never switch branches in the main copy.
  - First time: `git -C <game> worktree add <worktree> -b spec/<date>-task<NN> master`, then `cp -r <game>/.godot <worktree>/`.
  - Later: `git -C <worktree> switch -c spec/<date>-task<NN> master`. The worktree must be clean; if it isn't, stop and report.
  - At most one open `spec/*` branch at a time: if "Na gałęziach" in `WDROZENIA.md` has a 🔧/🧪 row, stop and say which branch waits for review.
  - Pass the worktree path to `test-runner` and `convention-reviewer`.
- **Requirements** are rule quotes. The spec text of those IDs (and their "Dla agenta" sections) is binding. A detail you decide yourself goes into the spec marked **[ROBOCZE]**. If the spec contradicts itself, ask (interactive) or write a ❔ ticket (unattended); don't guess.
- **Commit.** The code, docs_v2 and the factcheck (`docs/human-tasks/factcheck-test-NN.md`, one row per rule ID) go on the branch, committed as `task_NN: <short Polish summary>` with the IDs in the body. Standing permission covers `spec/*` commits. Never commit to or merge into `master`.
- **Task file.** The report goes into the task file in the main copy. It stays in `docs/ai-tasks/` until the branch is merged; `/spec-sync finalize` moves it to `done/`.
- **Spec.**
  - Add a row to `WDROZENIA.md` → "Na gałęziach": `| \`spec/<date>-task<NN>\` | \`<sha7>\` | <IDs>, task_NN | \`docs/human-tasks/factcheck-test-NN.md\` | 🧪 do sprawdzenia |`.
  - Set the task's row in "W zadaniach" to 🧪.
  - Don't flip ⬜→✅, and don't add a row to "Zmiany agenta poza specyfikacją". Finalize does the markers.
  - Run `node dashboard/cli.ts lint` (0 errors), commit `[agent] spec/<date>-task<NN>: wdrożone na gałęzi, do sprawdzenia` and push.
- **Report** in chat. Add how to try the change: open the worktree in Godot, or `git merge spec/…` when happy.

In `status`, mark each task's source (spec or chat), and for spec tasks, its branch and "W zadaniach" status.

## close NN
1. Read `docs/human-tasks/factcheck-test-NN.md`: every `wynik`/`uwagi` cell.
2. For each bug or change proposal, ask the user whether it becomes a new task (next free `task_NN.md` from the template, with the user's words quoted as the requirements) or a fix now. Don't fix silently.
3. When nothing is left open for that factcheck, `git mv` it to `docs/human-tasks/done/` and fix its relative links.

## Parallel tasks (only when the user asks)
Two independent tasks at once, each with resolved decisions and no dependency between them:
- run the second one in a worktree: `git worktree add ../everhorror-task-NN -b task/NN master`, then `cp -r .godot ../everhorror-task-NN/`;
- do all edits, generators and tests there (`--path .`);
- never run two Godot imports on the same folder at the same time;
- merge back only with the user's approval.
