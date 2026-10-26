---
name: spec-tasks
description: On a person's request, turn accepted changes in the design spec (../specification) into tasks — diff since the last planned commit, group actionable changes, tickets and queue by feature, write docs/ai-tasks/task_NN.md files and record them in WDROZENIA.md. Never implements gameplay. The poller reports status only and does not invoke this skill.
---

# spec-tasks

The one entry point from the spec to the game. It only **plans**: it writes task files and spec bookkeeping, never game code. Implementation goes through `/ai-task implement NN` (spec tasks are built on a `spec/*` branch in the worktree, see the ai-task skill). After the user merges that branch, `/spec-sync finalize` flips the markers.

This skill starts on a person's instruction, not from the poller. A legacy `unattended` argument is meaningful only for an explicitly authorized noninteractive invocation; unresolved questions go into a spec ticket (step 6), without inventing decisions. Current process/source map: `C:/dev/gamedev/everhorror/specification/WORKFLOW.md`; Roland owns all sections, and newer accepted decisions take precedence over older instructions.

## Places
| What | Path |
|---|---|
| Game repo, main copy (task files are written here, left uncommitted like the user's tasks) | `C:/dev/gamedev/everhorror/everhorror` |
| Tasks: open / done, template | `docs/ai-tasks/`, `docs/ai-tasks/done/`, `docs/ai-tasks/task_template.md` |
| Spec repo (remote `everhorror-spec`, branch `master`) | `C:/dev/gamedev/everhorror/specification` |
| Spec CLI (run from the spec root) | `node dashboard/cli.ts status --json`, `diff <from> <to> --json`, `lint` |
| Deployment log | spec `WDROZENIA.md`: "Wpisy" (baseline), "Na gałęziach", **"W zadaniach"**, "Czeka na wdrożenie" |

Read the spec's `README.md` (markers, IDs, rules) and the game's `CLAUDE.md` first. Standing permission (user decision 2026-09-26): `[agent]` commits **and pushes** to the spec `master`. Game-repo commits are not part of this skill.

## Steps
1. **Preconditions.**
   - In the spec repo, `git status --porcelain` must be empty. If it isn't, someone is editing by hand: stop and say so.
   - `git pull --ff-only`.
   - `node dashboard/cli.ts status --json`.
   - A branch waiting in "Na gałęziach" does **not** block this skill; it only blocks implementing.
2. **Start point.**
   - Start from the last hash in the "W zadaniach" table, if `git merge-base --is-ancestor <baseline> <that hash>` holds.
   - Otherwise start from the baseline (`status.baseline`).
   - Then run `node dashboard/cli.ts diff <start> HEAD --json`. If the start already equals HEAD, and there are no 📥 tickets and no unplanned queue items, there is nothing to do: stop.
3. **Collect work.** Read the surrounding spec text and the file's "Dla agenta" section for each item.
   - Distinguish design changes from editorial/process corrections. `actionable` is a parser classification, not proof of new gameplay requirements. Report a false positive with file/ID and reason; never move the baseline to hide it or create a gameplay task for an ownership/header/template correction.
   - Diff changes with `actionable: true`. The marker says what to do:
     - ✅ with changed text: the game must follow the new text;
     - ⬜: implement;
     - 🟡: finish, if the text says how;
     - ❌: a removal task (from the game, then from the spec text);
     - 💡 and ❓: **never** turn into tasks. An answer written under a ❓ is not a decision until an owner turns it into a rule.
   - 📥 tickets in `zgloszenia/` of the kinds *błąd* or *zmiana tekstu*. Kinds *pomysł* and *pytanie* are for the team, not for tasks.
   - Rows of "Czeka na wdrożenie" that have no `zadanie: task_NN` note yet and aren't waiting for an answer or deferred ("odłożone", "na później").
4. **Deduplicate.**
   - An ID already in an open task that **hasn't been started** (no "Co zostało zrobione" section): append `## Zmiana w specyfikacji <sha7>` to that task, below the agent marker, with the new rule text quoted. Never touch its requirements section.
   - An ID in a task in progress or in `done/`: a new task that links the earlier one.
   - An ID in a row of "Na gałęziach": a new task. Say that it follows that branch.
5. **Group by feature**, not by spec file: all the IDs of one mechanic or one story change go into one task, even across files. For each group, write `docs/ai-tasks/task_NN.md`. NN is the next free number across `docs/ai-tasks/` and `docs/ai-tasks/done/`. The file follows `task_template.md`:
   ```
   <!--
   Zadanie ze specyfikacji (spec-tasks, <YYYY-MM-DD>). Wymagania to cytat zasad ze specyfikacji w commicie <sha7>; nie edytować.
   -->

   Wymagania:
   1. <ID> (<plik.md>) <marker>: „<the rule text, quoted exactly>”
   2. …   (a ticket: its "Co" and "Było → ma być", quoted)

   Źródło: specyfikacja `<sha7>` · ID: <IDs> · Zgłoszenia: <files or —>

   Priorytet: <from the order in "Czeka na wdrożenie", else "do ustalenia"> · Kolejność: <tasks it depends on, or "—">

   ---
   <!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

   ## Analiza wstępna
   <which systems and files ("Dla agenta" pointers), risks, what is unclear. Full analysis: /ai-task analyze NN>
   ```
   Write in Polish. Quote the rules; don't paraphrase them. Don't add an agent "Podsumowanie" yet: `ai-task` ends the file when the task is done.
6. **Unclear items.** An item is unclear when it is contradictory, missing a number, or needs a design decision the spec doesn't make.
   - Interactive run: ask the user (AskUserQuestion) before writing that task.
   - Unattended run: write `zgloszenia/<YYYY-MM-DD>_pytania-agenta-<sha7>.md` from `szablony/zgloszenie.md` (Status `❔ pytanie`, Zgłasza: agent, Rodzaj: pytanie; one numbered question per item, quoting its ID and the options you see). Then either create the task for the clear part with the line "czeka na odpowiedź: <ticket>", or create no task at all.
7. **Spec bookkeeping** (spec repo, on `master`):
   - If `WDROZENIA.md` has no "W zadaniach" section yet, create it between "Na gałęziach" and "Czeka na wdrożenie":
     - intro: "Zadania w repozytorium gry (`docs/ai-tasks/`), które agent utworzył ze zmian w specyfikacji (skill `spec-tasks`). Wdraża je `/ai-task implement NN` na gałęzi `spec/*`; po scaleniu `/spec-sync finalize` zaznacza ✅.";
     - the table header `| Zadanie | Commit specyfikacji | ID | Status |`;
     - the status legend below the table.
   - `WDROZENIA.md` → "W zadaniach": one row per new task: `| task_NN | \`<sha7>\` | <IDs> | 📋 czeka |`. The sha7 is HEAD of this run. Statuses: 📋 czeka · 🔧 w pracy · 🧪 na gałęzi · ✅ scalone · ❌ odrzucone.
   - For every queue row that got a task, add `zadanie: task_NN` to its "Uwagi".
   - Tickets that became tasks: status `🔧`, plus "Odpowiedź agenta": "Zadanie `task_NN` w repo gry."
   - `node dashboard/cli.ts lint` must report 0 errors.
   - First run, interactive: show the user the task list before committing.
   - Commit `[agent] zadania z <sha7>: task_NN, …` and push.
8. **Report** in chat, or in the run log when unattended, in Polish:
   - the tasks created, with their IDs;
   - tasks that got a "Zmiana w specyfikacji" section;
   - what was skipped (💡/❓/deferred) and why;
   - the questions asked;
   - next step: `/ai-task analyze NN` or `/ai-task implement NN`.
