# Cherry-Pick Apply

Use this phase once investigation says the change should proceed.

## Pre-Exclusion

When investigation identified files to exclude (e.g., CI configs, submodule pointers, files not relevant to the target branch):

1. Build the exclusion list before running `cherry-pick -x`.
2. If the exclusion set is large or the change is high-adaptation, consider applying with `git diff <commit>^..<commit> -- <files-to-include> | git apply` instead of cherry-pick + cleanup.
3. For small exclusion sets, proceed with cherry-pick and revert the excluded files after resolution.

## Execution

1. Switch to the target branch.
2. Check whether the commit is a merge commit: `git rev-list --parents -1 <commit>` — count parent SHAs.
   - 1 parent → `git cherry-pick -x <commit>`
   - 2+ parents → `git cherry-pick -x -m 1 <commit>`
3. Preserve author and source commit metadata.

## Conflict-State Protection

If conflicts occur:

1. Verify `.git/CHERRY_PICK_HEAD` exists before doing anything else.
2. If the file is missing, do not run `git cherry-pick --continue`.
3. Re-establish state by re-running the cherry-pick from the start of the apply phase.

**Never use `git checkout --theirs` or `git checkout --ours` to resolve cherry-pick conflicts.** In cherry-pick context, `--theirs` takes the source branch's full file (not a merge of both sides) and `--ours` takes the target's full file — both silently discard the other side's changes. Always resolve conflicts surgically by reading the conflict markers and editing the file.

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
