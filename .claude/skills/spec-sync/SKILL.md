---
name: spec-sync
description: Sync the game with the design spec (../specification) — pull the approved spec, work out what changed since the last deployment, implement it on a spec/<date>-<sha> branch in a separate git worktree, test, write a factcheck and record the branch in the spec's WDROZENIA.md. Also "finalize" (after the user merged a spec/* branch: markers ⬜→✅, log entry) and "status". Use when asked to sync/deploy the spec, when the spec poller (tools/spec_poll.ps1) starts a run, or when someone mentions a merged spec branch.
---

# spec-sync

Modes (the argument after `/spec-sync`): **`sync`** (default), **`finalize`**, **`status`**. An argument `unattended` means the poller started this run with nobody watching: never wait for an answer — anything that needs the user goes into a spec ticket (see step 4), then stop.

## Places
| What | Path |
|---|---|
| Game repo (main copy, other sessions work here — never switch its branch, never touch its uncommitted files) | `C:/dev/gamedev/everhorror/everhorror` |
| Deployment worktree (all spec work happens here) | `C:/dev/gamedev/everhorror/everhorror-wdrozenie` |
| Spec repo (remote `everhorror-spec`, branch `master`) | `C:/dev/gamedev/everhorror/specification` |
| Spec CLI (run from the spec root) | `node dashboard/cli.ts status --json`, `diff <from> <to> --json`, `lint`, `baseline` |
| Poller state and logs | `reports/spec-sync/` in the game repo |

Read the spec's `README.md` (markers, IDs, rules) and the game's `CLAUDE.md` (conventions, tests) before changing anything. Standing permissions (user decision 2026-09-26): commits on `spec/*` branches in the game repo, `[agent]` commits **and pushes** to the spec `master`, short tests. **Not** allowed without the user: the full test suite, merging into the game `master`, force pushes, deleting anything the agent did not create.

## status
Run `node dashboard/cli.ts status` in the spec repo and `git -C <worktree> status -sb`; report: baseline, spec HEAD, pending actionable changes, branches waiting, open tickets. Change nothing.

## sync
1. **Preconditions.** Spec repo: `git status --porcelain` must be empty (someone is editing it by hand otherwise — stop and say so). `git pull --ff-only`. Then `node dashboard/cli.ts status --json`:
   - a row in `branches` with status 🔧 or 🧪 → if that game branch is already merged into the game `master` (`git -C <game> branch --merged master --list "spec/*"`), run **finalize** first, then continue; otherwise **stop**: one open deployment branch at a time. Report which branch waits for review.
   - `changes.actionable == 0` and no 📥 tickets → nothing to do; stop.
2. **What changed.** `node dashboard/cli.ts diff <baseline> HEAD --json` (baseline from `status`). Also: new or 📥 tickets in `zgloszenia/`, and the top of "Czeka na wdrożenie" in `WDROZENIA.md` (only items not waiting for an answer). For every change read the surrounding spec text and the file's "Dla agenta" section to find the code. Markers: ✅ changed text = the game must follow it; ⬜ = implement; 🟡 = finish if the text says how; 💡 and ❓ = never implement; ❌ = remove from the game, then from the spec text. Answers under ❓ are not decisions until an owner turns them into a rule — note them, don't implement them.
3. **Plan.** Group the changes; for each, decide: clear → implement; unclear, contradictory, or a design decision the spec does not make → question.
4. **Questions.** Interactive run: ask the user (AskUserQuestion) before implementing. Unattended run: write `zgloszenia/<YYYY-MM-DD>_pytania-agenta-<sha7>.md` from `szablony/zgloszenie.md` (Status `❔ pytanie`, Zgłasza: agent, Rodzaj: pytanie; one numbered question per unclear change, quoting the rule ID and the options you see), commit `[agent] pytania do <sha7>` and push. If some changes are clear, implement those and add the unclear ones to "Czeka na wdrożenie" with "czeka na odpowiedź: <ticket>"; if nothing is clear, stop here.
5. **Worktree.** First time: `git -C <game> worktree add <worktree> -b spec/<YYYY-MM-DD>-<sha7> master`, then copy the import cache (`cp -r <game>/.godot <worktree>/`), so Godot does not re-import 300 MB. Later runs: `git -C <worktree> switch -c spec/<YYYY-MM-DD>-<sha7> master` (the worktree must be clean; if it is not, stop and report). All edits, generators and tests run **inside the worktree** (`cd` there; Godot `--path .`).
6. **Implement** following `CLAUDE.md`: generated scenes and data via their generators, the Silesian dialect keys for miner lines, `[#leave]` farewells, Polish number helpers, `--import` after `.dialogue` changes (twice for a new file). New content ids must match the spec ids. Update the docs_v2 status markers (✅/🟡/⬜) on the branch too, so they land together with the code.
7. **Test** (in the worktree): `Godot_v4.7.2-stable_win64_console.exe --headless --path . --import`, then `tools/run_tests.sh unit lint dialogue` plus the scenarios that cover the touched systems (see `tools/README.md`), one or two at a time, logs to `reports/tests/`, read the RESULT lines. Never the full suite without the user's approval. Fix failures; if a failure is outside the change, report it instead of widening the change.
8. **Factcheck** `docs/human-tasks/factcheck-spec-<sha7>.md` (Polish, same format as the other factchecks: what was added, then a table `# | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi`, one row per implemented rule ID, the `wynik`/`uwagi` columns empty for the user).
9. **Commit** in the worktree on the `spec/*` branch: `spec <sha7>: <short Polish summary>` with the rule IDs in the body. Never commit to `master`.
10. **Spec update** (spec repo, on `master`):
    - `WDROZENIA.md` → "Na gałęziach": `| \`spec/<date>-<sha7>\` | \`<sha7>\` | <IDs and a few words> | \`docs/human-tasks/factcheck-spec-<sha7>.md\` | 🧪 do sprawdzenia |`.
    - Details you had to decide while implementing: write them into the spec marked **[ROBOCZE]**; code pointers into "Dla agenta".
    - Do **not** flip ⬜→✅ yet: that happens in finalize.
    - `node dashboard/cli.ts lint` must have 0 errors. Commit `[agent] spec/<date>-<sha7>: wdrożone na gałęzi, do sprawdzenia` and push.
11. **Report** (chat or run log), in Polish: branch, what was implemented per ID, tests run and their RESULT lines, questions asked, how to try it (open `<worktree>` in Godot, or `git merge spec/…` when happy).

## finalize
For each "Na gałęziach" row whose branch is merged into the game `master` (or when the user says it was merged):
1. Spec: flip the implemented rules ⬜→✅ (🟡 where partial), move the row to "Wpisy" (`| <date> | \`<sha7>\` | <IDs> | <game version or branch> | <notes, skipped items> |` — the baseline is the last hash in that table, so it must be the spec commit the branch implemented), remove finished items from "Czeka na wdrożenie", close answered tickets (status ✅, move to `zgloszenia/zamkniete/`). Lint, commit `[agent] finalize spec/<…>`, push.
2. Game repo: `git -C <worktree> switch --detach` and `git -C <game> branch -d spec/<…>` (only `-d`, it refuses unmerged branches).
3. A branch the user rejected (row status ❌ or the user says so): leave the branch, set the row to ❌ with the reason; the changes stay pending.

## The baseline must always move
The baseline is the newest commit hash in `WDROZENIA.md` → "Wpisy"; everything committed after it counts as waiting for the agent. So **every time the spec is updated to describe something that is already in the game, add a "Wpisy" row too** — not only after a spec-driven deployment:

- work given outside the spec (a task from chat, a bug fix): after updating the spec and logging the row in "Zmiany agenta poza specyfikacją", add a "Wpisy" row with the spec commit the game now matches (`| <data> | \`<sha7>\` | <IDs / krótko> | <task albo wersja> | <uwagi> |`),
- the hash is the spec commit **before** your own `[agent]` commit (you cannot know your own hash yet); your commit only adds ✅ markers and [ROBOCZE] details, which the dashboard does not count as work.

Without that row the queue keeps growing with things that are long since in the game — that is exactly what happened with task_06…task_12. The dashboard offers the same bookkeeping under *Wdrożenia → „Jeśli to już jest w grze”*.
