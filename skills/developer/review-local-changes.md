# Review Local Changes

Use this phase when local repo-tracked files have changed and need a review/fix loop before commit.

## Goal

Wrap Claude's built-in `/review` in a repo-standard loop:

- scope the review to the changed files or requested path
- normalize findings against `rules/code-review.md`
- fix actionable issues
- verify the fixes
- re-run review until only nitpicks or user decisions remain

## Process

1. Gather the changed files from unstaged and staged diffs, then apply any explicit path filtering.
2. Run the built-in `/review` on that scope.
3. Classify findings as `[major]`, `[minor]`, or `[nitpick]`.
4. Fix all `[major]` and `[minor]` items directly.
5. Re-run targeted tests after each fix to catch regressions.
6. Re-run `/review` on the changed files.

## Stop Rules

Stop when:

- only `[nitpick]` items remain
- a user decision is required
- the same issue persists across two consecutive rounds

## Notes

- If the changed code introduces or modifies behavior without tests, that is a `[major]` issue.
- Test-gap checks stay scoped to the changed files; broader analysis belongs to `/analyze-tests`.
- If a fix causes a regression, revert that fix and surface the trade-off instead of shipping it.
