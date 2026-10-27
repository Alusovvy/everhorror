---
name: spec-sync
description: On a person's request, report spec/game status or finalize a merged spec task — markers, existing WDROZENIA tables, task report and tickets. Finalize records implementation, not a human playtest. The poller reports status only and never invokes finalize.
---

# spec-sync

Modes (the argument after `/spec-sync`): **`status`** (default), **`finalize`**. A legacy `unattended` argument requires an explicitly authorized noninteractive invocation; the poller no longer starts this skill. Read `C:/dev/gamedev/everhorror/specification/WORKFLOW.md` for current source precedence and solo ownership.

**Current flow (2026-10-26):** accepted spec changes → manually started `/spec-tasks` (`task_NN.md` + "W zadaniach") → `/ai-task implement NN` (`spec/<date>-task<NN>` in the worktree, "Na gałęziach" 🧪) → automated checks and review → Roland's merge decision → manually started `/spec-sync finalize`. Human playtest results remain separate and may still be pending after integration. The old `sync` mode (implementing straight from the diff) is gone. If someone asks for `sync`, run `/spec-tasks` instead.

**Clarification, 2026-10-26:** Roland owns all active sections. A merge proves integration, not a human playtest. Finalize never fills human `wynik`/`uwagi`, moves an unfilled factcheck to done/, or calls it verified. Keep the person's evidence/explicit waiver separate from implementation markers. Pure editorial/process changes never advance the game's baseline.

**Dashboard lock (every mode).** Before you change anything, check it as described in [CLAUDE.md#dashboard-lock](../../../CLAUDE.md#dashboard-lock). If another live run holds it, stop and report who; never delete it.

## Places
Paths (game main copy, worktree, spec repo, run records): [CLAUDE.md#places](../../../CLAUDE.md#places). Never switch the main copy's branch and never touch its uncommitted files. Spec CLI (run from the spec root): `node dashboard/cli.ts status --json`, `diff <from> <to> --json`, `lint`, `baseline`. Poller state and logs: `reports/spec-sync/` in the game repo.

Read the spec's `README.md` (markers, IDs, rules) and the game's `CLAUDE.md` before changing anything. Standing permissions (plan §9, 2026-10-26, `docs/analizy/final-plan-human-readable.md`): commits on `spec/*` branches in the game repo, `[agent]` commits **and pushes** to the spec `master`, short tests. **Not** allowed without the user: the full test suite, merging into the game `master`, force pushes, deleting anything the agent did not create.

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
   - Ledger (`WDROZENIA.md`), only with the `ledger` command, never by hand: `node <spec>/dashboard/cli.ts ledger finalize --task task_NN --branch spec/<…> --date <YYYY-MM-DD> --commit <sha7|częściowo|—> --ids "<IDs> (task_NN)" --game "<game version or branch>" [--notes "…"]`. It sets the task's "W zadaniach" row to ✅, removes the branch row from "Na gałęziach" and adds the "Wpisy" row (see the baseline rule below, which the command enforces).
   - Remove the task's items from "Czeka na wdrożenie" with `ledger queue-remove --task task_NN` (rows noted `zadanie: task_NN`), or `ledger queue-remove --rows 3,5` for rows by their `#`.
   - Close the tickets it answered: status ✅, then move them to `zgloszenia/zamkniete/`. Move the ✅ decision cards (`Rodzaj: decyzja`) that have `Zadanie: task_NN` for this task there too; a card that is not ✅ stays where it is (mention it in the report). Fix the relative links of every moved file (they gain one `../`). In a dashboard run only set the status: the files stay in `zgloszenia/` (see **Dashboard runs**).
   - The "Wpisy" row is `| <date> | <commit cell> | <IDs> (task_NN) | <game version or branch> | <notes, skipped items> |`; `ledger finalize` writes it.
   - **Baseline rule** (`ledger finalize` enforces it: a real sha7 is accepted only when no other open task has that commit, otherwise use `częściowo` with `spec <sha7>` in `--notes`). The parser takes the baseline from the last hash in the "Wpisy" commit column. So write the task's spec `<sha7>` in the commit column **only if** every "W zadaniach" row with that commit or an earlier one is ✅ or ❌. Otherwise write `częściowo` in the commit column and put `spec <sha7>` in "Uwagi". Once the last open task of a commit is finalized, the new row carries the newest fully deployed commit. A tool or documentation task (`Rodzaj: narzędzia` / `dokumentacja`) has no spec commit: its row has `—` there and never moves the baseline (`--commit —`).
   - `node dashboard/cli.ts lint` must report 0 errors. Commit `[agent] finalize spec/<…> (task_NN)`, push.
2. **Game repo:**
   - The dashboard removes the branch's own worktree at the merge. `git -C <worktree> switch --detach` only when the worktree named in the contract is the old shared one (`everhorror-wdrozenie`) and still stands on the branch. Then `git -C <game> branch -d spec/<…>`. Only `-d`: it refuses unmerged branches, and when it refuses because a worktree still holds the branch (it had uncommitted changes), do not force it: report it in `ZROBIONE`.
   - In the main copy, first `git ls-files --error-unmatch docs/ai-tasks/task_NN.md`: a task file outside the git history is saved first (Roland's "Zapisz dokumenty w historii gry", or an `[agent] proces` commit with his consent), then `git mv docs/ai-tasks/task_NN.md docs/ai-tasks/done/`. Do **not** touch the links inside the quoted requirements (like `done/task_13.md`); other relative links of the file gain one `../`. Fix incoming links, which are the agent part of a sheet: the task link in the header of its sheet (`docs/human-tasks/factcheck-test-NN.md`, line 3) → `../ai-tasks/done/task_NN.md`. Never the human zones, never a sheet already in `done/`.
   - Check the release tag: `git -C <game> rev-list -n 1 v<version>` must print the commit the zip was built from (the "Wpisy" row names the version). If it is missing or points elsewhere: in a terminal session place it per plan §9 "Reguła tagów i pushy"; in a dashboard run only list it in `NASTĘPNY KROK`.
   - Ask Roland whether to delete the remote branch `spec/<…>` (`git -C <game> push <remote> --delete spec/<…>`); do it only after his yes, and in a dashboard run (no network) only list it in `NASTĘPNY KROK`.
   - Leave every human sheet in `docs/human-tasks/` where it is, whatever its state: closing one is a person's act, never part of finalize.
   - Playable builds in `build/do-ogrania/` stay as they are (outside git; the dashboard keeps the two newest of a task).
   - Don't commit in the main copy unless the user asks.
3. **Rejected branch** (row status ❌, or the user says so):
   - Leave the branch.
   - Set the row and the "W zadaniach" row to ❌, with the reason: `ledger reject --task task_NN --reason "<reason>" --branch spec/<…>`.
   - The rules stay pending; `/spec-tasks` will offer a new task when the spec changes.

## Dashboard runs
Roland's "Domknij po scaleniu" click starts `/spec-sync finalize` as a dashboard run: `EVERHORROR_DASHBOARD_RUN` is set, or the appended prompt starts with `# Przebieg z dashboardu`. The rules of the `ai-task` skill, section **Dashboard runs**, apply, and the contract names the task and its branch.
- Finalize **only the branch named in the appended prompt**, even when other `spec/*` branches are merged too (mention them in `ZROBIONE`). If that branch is not merged into the game `master`, change nothing and finish with `STATUS: blad`.
- `WDROZENIA.md` changes only through `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts ledger …` (`finalize`, `queue-remove`, `reject`; never by hand); commit it with the other explicit paths.
- Commit the spec only after lint shows 0 errors (`node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts lint`), with explicit paths: `git -C <spec> add -- <paths>`, then `git -C <spec> commit -m "[agent] finalize spec/<…> (task_NN)" -- <paths>`; never `-a`, `add -A` or `add .`. Push `master`, never forced. Always `git -C <full path> …`; no `git -c`, `bash -c`, `eval` or `node -e`.
- In the game repos only these are allowed: `git -C <main> mv docs/ai-tasks/task_NN.md docs/ai-tasks/done/task_NN.md` (no commit; only for a file in the git history, see below), `git -C <worktree> switch --detach` and `git -C <main> branch -d spec/<…>`.
- You cannot edit files in the game main copy in a dashboard run (only the spec is writable), so skip the link fixes of the moved task file and say in `NASTĘPNY KROK` that `docs/ai-tasks/done/task_NN.md` needs its relative links fixed outside the quoted requirements (`node tools/check_doc_links.js docs/ai-tasks/done/task_NN.md` lists them), plus the task link in the header of its sheet. A task file that is not in the git history (`git ls-files --error-unmatch` fails) is not moved: the rest of finalize still runs, and `NASTĘPNY KROK` says that Roland first saves it with "Zapisz dokumenty w historii gry" and then moves it.
- Tickets and decision cards stay in `zgloszenia/` during a dashboard run. Set the status ✅ of a ticket the task answered (and its answer) with Edit; a decision card is already ✅ once Roland resolved it. Never `git mv`, `mv`, `cp` or `rm` a file there: the guard blocks moving, copying and deleting any file of `zgloszenia/`, and the audit counts a moved card with filled `Twój wybór` cells as a change of a human zone. List the files that should go to `zgloszenia/zamkniete/` in `NASTĘPNY KROK` (their relative links gain one `../`); Roland moves them in a terminal.
- Never move, edit or fill a human sheet in `docs/human-tasks/`: closing one is Roland's click in the dashboard.
- Finish with exactly three lines, in Polish: `STATUS: ok|czeka-na-decyzje|blad`, `ZROBIONE: <one sentence>` and `NASTĘPNY KROK: <what a person does next>`.

## Game changes from elsewhere
A chat task or a bug fix that changes the game also updates the spec first, but gets **no new row** in `WDROZENIA.md` → "Zmiany agenta poza specyfikacją" (D-23, plan §9, agent recommendation, subject to Roland's veto). An urgent fix of a bug that violates an existing rule needs no row, since it restores conformity; any other change is first a ⬜ rule in the spec and goes through `/spec-tasks`. Such a change never goes through finalize.
