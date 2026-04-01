# Review Code Quality

Use this phase when repo-tracked files have changed and need a code quality review/fix loop. Works for both local changes (`/review-code`) and PR reviews (`/review-pr`).

## Required Context
Read before starting: `rules/code-review.md`, `rules/review-gate.md`, `rules/stop-rules.md`

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
5. **Check test coverage for changed behavior.** For each changed file that introduces or modifies behavior, verify that a corresponding test exists. Missing tests are a `[major]` finding. This applies to the original diff **and** to any fixes made during this review loop — if you fix code in step 6, that fix also needs test coverage. Exception: if the test gap is explicitly tracked as a follow-up in PROJECT.md with a clear plan and owner, note it in the summary's Remaining section instead of classifying it as a finding.
   - **No tests found for changed logic**: After flagging as `[major]`, trigger the test suggestion reviewer (`review-testplan.md`) to recommend specific tests to write.
   - **Tests found**: Trigger the test quality reviewer (`review-tests.md`) to evaluate whether they catch regressions, plus test suggestions for additional coverage.
6. Fix all `[major]` and `[minor]` items directly — including adding tests for uncovered behavior.
7. Re-run targeted tests after each fix to catch regressions.
8. Re-run review on the changed files — including files you just fixed and tests you just added. Review your own fix as if someone else wrote it: check error paths, async ordering, state consistency, and boundary conditions. The re-review is not a formality.

## Stop Rules

Apply stop rules from `rules/stop-rules.md`.

## Notes

- Test-gap checks stay scoped to the changed files; broader scenario discovery belongs to the `qa` support workflows, not `/review-code`.
- If a fix causes a regression, revert that fix and surface the trade-off instead of shipping it.
