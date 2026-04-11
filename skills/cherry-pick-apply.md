---
model: opus
---

# Cherry-Pick Apply

Use this phase once investigation says the change should proceed.

## Pre-Exclusion

When investigation identified files to exclude (e.g., CI configs, submodule pointers, files not relevant to the target branch):

1. Build the exclusion list before running `cherry-pick -x`.
2. For small exclusion sets where excluded files **exist on both branches**, proceed with cherry-pick and revert the excluded files after resolution.
3. For excluded files that **don't exist on the target branch**, expect modify/delete conflicts — resolve with `git rm` (see Modify/Delete Conflicts section below).
4. Only for large exclusion sets or high-adaptation changes, fall back to `git diff <commit>^..<commit> -- <files-to-include> | git apply --3way`. This is a **last resort** — it discards cherry-pick metadata (`-x` attribution, CHERRY_PICK_HEAD). Use the escalation ladder below before reaching for it.

## Execution

1. Switch to the target branch.
2. Check whether the commit is a merge commit: `git rev-list --parents -1 <commit>` — count parent SHAs.
   - 1 parent → `git cherry-pick -x <commit>`
   - 2+ parents → `git cherry-pick -x -m 1 <commit>`
3. Preserve author and source commit metadata.

## Modify/Delete Conflicts

When a cherry-pick touches files that exist on the source branch but not on the target branch, git reports modify/delete conflicts. These require a different resolution path than content conflicts:

1. `git rm <missing-files>` to resolve the modify/delete conflicts.
2. Verify `.git/CHERRY_PICK_HEAD` still exists after the `git rm`.
3. Resolve any remaining content conflicts in other files.
4. Stage all resolved files.
5. `git cherry-pick --continue`.

Do not try to "revert" these files after resolution — they never existed on the target branch. The `git rm` is the resolution.

## Conflict-State Protection

If conflicts occur:

1. Verify `.git/CHERRY_PICK_HEAD` exists before doing anything else.
2. If the file is missing, do not run `git cherry-pick --continue`.
3. Re-establish state by aborting (`git cherry-pick --abort`) and re-running the cherry-pick from the start of the apply phase.

**Why CHERRY_PICK_HEAD may be missing**: Some git versions drop it when all conflicts are of the modify/delete type (no content conflicts remain). It can also disappear after an abort that wasn't followed by a fresh cherry-pick. If re-running the cherry-pick reproduces the same modify/delete-only situation and CHERRY_PICK_HEAD is still missing, resolve with `git rm` + `git commit` (manually writing the cherry-pick message with the `-x` reference) rather than falling back to `git apply`. For `git rm` resolution details, see the Modify/Delete Conflicts section above.

**Never use `git checkout --theirs` or `git checkout --ours` to resolve cherry-pick conflicts.** In cherry-pick context, `--theirs` takes the source branch's full file (not a merge of both sides) and `--ours` takes the target's full file — both silently discard the other side's changes. Always resolve conflicts surgically by reading the conflict markers and editing the file.

## Escalation Ladder

When a cherry-pick hits conflicts, follow this order. Do not skip steps:

1. **Resolve in place** — resolve modify/delete conflicts with `git rm` (see Modify/Delete Conflicts section above), edit markers for content conflicts, then `git cherry-pick --continue`.
2. **Abort and re-run** — `git cherry-pick --abort`, then re-run `git cherry-pick -x <commit>`. This resets state cleanly. Try a different resolution approach on the second attempt.
3. **Manual commit** — if CHERRY_PICK_HEAD is unrecoverable after re-run, resolve files manually, then `git commit` with a message that includes the `-x` reference (e.g., `(cherry picked from commit <sha>)`).
4. **`git apply --3way`** — last resort only. Use when the cherry-pick is fundamentally incompatible with a clean cherry-pick flow (e.g., large exclusion sets, commit must be decomposed). This loses cherry-pick metadata and CHERRY_PICK_HEAD. Never use it for ≤5 excluded files when cherry-pick + `git rm` would work.

## When to Hand Off

Hand off to the `developer` persona only when:

- a conflict requires code-level adaptation
- source intent must be inferred from surrounding code
- target-side APIs differ enough that a pure git resolution is insufficient

Remain in the release-engineer persona when the work is only:

- branch switching
- cherry-pick execution
- state verification
- staging resolved files
- continuing the in-progress cherry-pick

## Continue Rule

After conflicts are resolved:

1. Stage resolved files.
2. Verify `.git/CHERRY_PICK_HEAD` still exists.
3. Run `git cherry-pick --continue`.
4. Hand off to validation.
