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

1. Gather the changed files:
   - **Uncommitted mode** (default): unstaged and staged diffs.
   - **Committed mode** (`--committed` or when invoked on already-committed changes): `git diff <base>..HEAD`. Skip stage/commit steps in the calling workflow.
   - Apply any explicit path filtering.
2. Perform a code review using the criteria in `rules/code-review.md`. Read each changed file, examine the diff, and assess against the scoring framework and severity tags.
3. Classify findings as `[major]`, `[minor]`, or `[nitpick]`.
4. For bug-fix reviews: grep the codebase for the same pattern that caused the bug (e.g., if the fix changed `e.target` to `e.currentTarget`, search for other occurrences of the broken pattern). Report matches as findings.
5. Fix all `[major]` and `[minor]` items directly.
6. Re-run targeted tests after each fix to catch regressions.
7. Re-run review on the changed files — including files you just fixed. Review your own fix as if someone else wrote it: check error paths, async ordering, state consistency, and boundary conditions. The re-review is not a formality.

## Stop Rules

Stop when:

- only `[nitpick]` items remain
- a user decision is required
- the same issue persists across two consecutive rounds

## Notes

- If the changed code introduces or modifies behavior without tests, that is a `[major]` issue. **Exception**: if the test gap is explicitly tracked as a follow-up in PROJECT.md with a clear plan and owner, do not classify it as a finding — note it in the summary's Remaining section as an acknowledged gap instead.
- Test-gap checks stay scoped to the changed files; broader scenario discovery belongs to the `qa` support workflows, not `/review-code`.
- If a fix causes a regression, revert that fix and surface the trade-off instead of shipping it.
