# Cherry-Pick Apply

Use this phase once investigation says the change should proceed.

## Execution

1. Switch to the target branch.
2. Run `git cherry-pick -x <commit>`.
3. Preserve author and source commit metadata.

## Conflict-State Protection

If conflicts occur:

1. Verify `.git/CHERRY_PICK_HEAD` exists before doing anything else.
2. If the file is missing, do not run `git cherry-pick --continue`.
3. Re-establish state by re-running the cherry-pick from the start of the apply phase.

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
