---
name: spec-sync
description: Close the loop between the design spec (../specification) and the game after a spec task's branch was merged — "finalize" (markers ⬜→✅, "W zadaniach" ✅, row to "Wpisy" moving the baseline, task file to done/, tickets closed) and "status" (baseline, spec HEAD, pending changes, branches, spec tasks, tickets). New spec changes are turned into tasks by /spec-tasks and implemented by /ai-task implement NN. Use when someone mentions a merged spec/* branch, asks where the game stands against the spec, or the spec poller starts a finalize run.
---

# spec-sync

Modes (the argument after `/spec-sync`): **`status`** (default), **`finalize`**. An argument `unattended` means the poller started this run with nobody watching: never wait for an answer.

**Flow since 2026-09-26 (user decision):** spec changes → `/spec-tasks` (writes `task_NN.md` + "W zadaniach") → `/ai-task implement NN` (builds a spec task on a `spec/<date>-task<NN>` branch in the worktree, "Na gałęziach" 🧪) → the user plays, fills in the factcheck and merges the branch into the game `master` → `/spec-sync finalize`. The old `sync` mode (implementing straight from the diff) is gone. If someone asks for `sync`, run `/spec-tasks` instead.

## Places
| What | Path |
|---|---|
| Game repo (main copy, other sessions work here — never switch its branch, never touch its uncommitted files) | `C:/dev/gamedev/everhorror/everhorror` |
| Deployment worktree (spec tasks are built here) | `C:/dev/gamedev/everhorror/everhorror-wdrozenie` |
| Spec repo (remote `everhorror-spec`, branch `master`) | `C:/dev/gamedev/everhorror/specification` |
| Spec CLI (run from the spec root) | `node dashboard/cli.ts status --json`, `diff <from> <to> --json`, `lint`, `baseline` |
| Poller state and logs | `reports/spec-sync/` in the game repo |

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
   - Close the tickets it answered: status ✅, then move them to `zgloszenia/zamkniete/`.
   - Move the branch row to "Wpisy": `| <date> | <commit cell> | <IDs> (task_NN) | <game version or branch> | <notes, skipped items> |`.
   - **Baseline rule.** The parser takes the baseline from the last hash in the "Wpisy" commit column. So write the task's spec `<sha7>` in the commit column **only if** every "W zadaniach" row with that commit or an earlier one is ✅ or ❌. Otherwise write `częściowo` in the commit column and put `spec <sha7>` in "Uwagi". Once the last open task of a commit is finalized, the new row carries the newest fully deployed commit.
   - `node dashboard/cli.ts lint` must report 0 errors. Commit `[agent] finalize spec/<…> (task_NN)`, push.
2. **Game repo:**
   - `git -C <worktree> switch --detach`, then `git -C <game> branch -d spec/<…>`. Only `-d`: it refuses unmerged branches.
   - In the main copy, `git mv docs/ai-tasks/task_NN.md docs/ai-tasks/done/` and fix its relative links, which gain one `../`.
   - Don't commit in the main copy unless the user asks.
3. **Rejected branch** (row status ❌, or the user says so):
   - Leave the branch.
   - Set the row and the "W zadaniach" row to ❌, with the reason.
   - The rules stay pending; `/spec-tasks` will offer a new task when the spec changes.

## Game changes from elsewhere
A chat task or a bug fix that changes the game also updates the spec, and gets a row in `WDROZENIA.md` → "Zmiany agenta poza specyfikacją" (see the ai-task skill, step 6). That is not a spec task and never goes through finalize.
