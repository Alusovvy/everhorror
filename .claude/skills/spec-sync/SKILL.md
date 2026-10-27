---
name: spec-sync
description: On a person's request, report spec/game status or finalize a merged spec task — markers, existing WDROZENIA tables, task report and tickets. Finalize records implementation, not a human playtest. The poller reports status only and never invokes finalize.
---

# spec-sync

Modes (the argument after `/spec-sync`): **`status`** (default), **`finalize`**. A legacy `unattended` argument requires an explicitly authorized noninteractive invocation; the poller no longer starts this skill. Read `C:/dev/gamedev/everhorror/specification/WORKFLOW.md` for current source precedence and solo ownership.

**Current flow (2026-10-26):** accepted spec changes → manually started `/spec-tasks` (`task_NN.md` + "W zadaniach") → `/ai-task implement NN` (`spec/<date>-task<NN>` in the worktree, "Na gałęziach" 🧪) → automated checks and review → Roland's merge decision → manually started `/spec-sync finalize`. Human playtest results remain separate and may still be pending after integration. The old `sync` mode (implementing straight from the diff) is gone. If someone asks for `sync`, run `/spec-tasks` instead.

**Clarification, 2026-10-26:** Roland owns all active sections. A merge proves integration, not a human playtest. Finalize never fills human `wynik`/`uwagi`, moves an unfilled factcheck to done/, or calls it verified. Keep the person's evidence/explicit waiver separate from implementation markers. Pure editorial/process changes never advance the game's baseline.

**Dashboard lock (every mode).** Before you change anything, read `reports/dashboard-runs/lock.json` in the game main copy. If it exists, its `pid` is a live process (PowerShell: `Get-Process -Id <pid>`; `null` means the run is just starting) and you are not that run (your run id is named in the dashboard contract; a terminal session has none), stop and report who holds it (`kind`, `task`, `startedBy`): a dashboard run owns the repos. Never delete the lock. A lock whose process is gone is stale; ignore it.

## Places
| What | Path |
|---|---|
| Game repo (main copy, other sessions work here — never switch its branch, never touch its uncommitted files) | `C:/dev/gamedev/everhorror/everhorror` |
| Deployment worktree (spec tasks are built here) | `C:/dev/gamedev/everhorror/everhorror-wdrozenie` |
| Spec repo (remote `everhorror-spec`, branch `master`) | `C:/dev/gamedev/everhorror/specification` |
| Spec CLI (run from the spec root) | `node dashboard/cli.ts status --json`, `diff <from> <to> --json`, `lint`, `baseline` |
| Poller state and logs | `reports/spec-sync/` in the game repo |
| Dashboard run records and lock | `reports/dashboard-runs/` in the game main copy (git-ignored) |

Read the spec's `README.md` (markers, IDs, rules) and the game's `CLAUDE.md` before changing anything. Standing permissions (user decision 2026-09-26): commits on `spec/*` branches in the game repo, `[agent]` commits **and pushes** to the spec `master`, short tests. **Not** allowed without the user: the full test suite, merging into the game `master`, force pushes, deleting anything the agent did not create.

## status
Run `node dashboard/cli.ts status` in the spec repo and `git -C <worktree> status -sb`. Report:
- the baseline and the spec HEAD;
- pending actionable changes;
- branches waiting;
- the "W zadaniach" table (task, spec commit, status);
- open tickets.

Change nothing.

## finalize
Take each "Na gałęziach" row whose branch is merged into the game `master` (`git -C <game> branch --merged master --list "spec/*"`), or that the user says was merged:
1. **Spec** (on `master`, after `git pull --ff-only`):
   - Flip the task's rule IDs ⬜→✅ (🟡 where the task report says partial).
   - Set the task's "W zadaniach" row to ✅.
   - Remove its items from "Czeka na wdrożenie".
   - Close the tickets it answered: status ✅, then move them to `zgloszenia/zamkniete/`. Move the ✅ decision cards (`Rodzaj: decyzja`) that have `Zadanie: task_NN` for this task there too; a card that is not ✅ stays where it is (mention it in the report). Fix the relative links of every moved file (they gain one `../`). In a dashboard run only set the status: the files stay in `zgloszenia/` (see **Dashboard runs**).
   - Move the branch row to "Wpisy": `| <date> | <commit cell> | <IDs> (task_NN) | <game version or branch> | <notes, skipped items> |`.
   - **Baseline rule.** The parser takes the baseline from the last hash in the "Wpisy" commit column. So write the task's spec `<sha7>` in the commit column **only if** every "W zadaniach" row with that commit or an earlier one is ✅ or ❌. Otherwise write `częściowo` in the commit column and put `spec <sha7>` in "Uwagi". Once the last open task of a commit is finalized, the new row carries the newest fully deployed commit. A tool or documentation task (`Rodzaj: narzędzia` / `dokumentacja`) has no spec commit: its row has `—` there and never moves the baseline.
   - `node dashboard/cli.ts lint` must report 0 errors. Commit `[agent] finalize spec/<…> (task_NN)`, push.
2. **Game repo:**
   - `git -C <worktree> switch --detach`, then `git -C <game> branch -d spec/<…>`. Only `-d`: it refuses unmerged branches.
   - In the main copy, `git mv docs/ai-tasks/task_NN.md docs/ai-tasks/done/` and fix its relative links, which gain one `../`.
   - Leave every human sheet in `docs/human-tasks/` where it is, whatever its state: closing one is a person's act, never part of finalize.
   - Don't commit in the main copy unless the user asks.
3. **Rejected branch** (row status ❌, or the user says so):
   - Leave the branch.
   - Set the row and the "W zadaniach" row to ❌, with the reason.
   - The rules stay pending; `/spec-tasks` will offer a new task when the spec changes.

## Dashboard runs
Roland's "Domknij po scaleniu" click starts `/spec-sync finalize` as a dashboard run: `EVERHORROR_DASHBOARD_RUN` is set, or the appended prompt starts with `# Przebieg z dashboardu`. The rules of the `ai-task` skill, section **Dashboard runs**, apply, and the contract names the task and its branch.
- Finalize **only the branch named in the appended prompt**, even when other `spec/*` branches are merged too (mention them in `ZROBIONE`). If that branch is not merged into the game `master`, change nothing and finish with `STATUS: blad`.
- Commit the spec only after lint shows 0 errors (`node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts lint`), with explicit paths: `git -C <spec> add -- <paths>`, then `git -C <spec> commit -m "[agent] finalize spec/<…> (task_NN)" -- <paths>`; never `-a`, `add -A` or `add .`. Push `master`, never forced. Always `git -C <full path> …`; no `git -c`, `bash -c`, `eval` or `node -e`.
- In the game repos only these are allowed: `git -C <main> mv docs/ai-tasks/task_NN.md docs/ai-tasks/done/task_NN.md` (no commit), `git -C <worktree> switch --detach` and `git -C <main> branch -d spec/<…>`.
- You cannot edit files in the game main copy in a dashboard run (only the spec is writable), so skip the link fix of the moved task file and say in `NASTĘPNY KROK` that `docs/ai-tasks/done/task_NN.md` needs its relative links fixed (`node tools/check_doc_links.js docs/ai-tasks/done/task_NN.md` lists them).
- Tickets and decision cards stay in `zgloszenia/` during a dashboard run. Set the status ✅ of a ticket the task answered (and its answer) with Edit; a decision card is already ✅ once Roland resolved it. Never `git mv`, `mv`, `cp` or `rm` a file there: the guard blocks moving, copying and deleting any file of `zgloszenia/`, and the audit counts a moved card with filled `Twój wybór` cells as a change of a human zone. List the files that should go to `zgloszenia/zamkniete/` in `NASTĘPNY KROK` (their relative links gain one `../`); Roland moves them in a terminal.
- Never move, edit or fill a human sheet in `docs/human-tasks/`: closing one is Roland's click in the dashboard.
- Finish with exactly three lines, in Polish: `STATUS: ok|czeka-na-decyzje|blad`, `ZROBIONE: <one sentence>` and `NASTĘPNY KROK: <what a person does next>`.

## Game changes from elsewhere
A chat task or a bug fix that changes the game also updates the spec, and gets a row in `WDROZENIA.md` → "Zmiany agenta poza specyfikacją" (see the ai-task skill, step 6). That is not a spec task and never goes through finalize.
