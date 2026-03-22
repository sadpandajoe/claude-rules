# /review-code - Auto-Fix Local Code Review

@/Users/joeli/opt/code/ai-toolkit/rules/code-review.md

> **When**: You have local uncommitted changes and want a quality pass before committing.
> **Produces**: Fixed code with only nitpicks remaining, plus a summary of changes made.

## Usage
```
/review-code                    # Review all uncommitted changes
/review-code src/api/           # Review changes in specific path
/review-code --files a.ts b.ts  # Review specific files
```

## Steps

1. **Gather Changes**
   ```bash
   git diff --name-only          # Unstaged changes
   git diff --cached --name-only # Staged changes
   ```
   If a path or files are specified, filter to those. Read each changed file.

2. **Review**

   For each changed file, evaluate against code-review.md principles:

   **Code quality**:
   - Logic errors, off-by-ones, null safety
   - Missing error handling at system boundaries
   - DRY violations, unnecessary complexity
   - Pattern violations (doesn't match existing codebase conventions)
   - Naming clarity

   **Test gap detection** (scoped to changed code only):
   - Does the changed code introduce new behavior that lacks tests?
   - Does it modify existing behavior without updating tests?
   - If yes → that's a `[major]` finding. Write the missing test as part of the fix.
   - (Broader coverage analysis is `/analyze-tests`' job, not this command's.)

   Tag each finding: `[major]`, `[minor]`, or `[nitpick]` per code-review.md severity tags.

3. **Fix**

   Fix all `[major]` and `[minor]` issues directly:
   - For code quality issues: edit the files
   - For test gaps: write the missing test (RED → verify it fails → GREEN → verify it passes)
   - Run existing tests after each fix to verify no regressions
   - If a fix causes a test regression, revert it and flag for user input

4. **Re-Review (Loop)**

   After fixing, review the changed files again (including the fixes themselves).
   Fixes can introduce new issues — catch them.

   **Continue looping** as long as `[major]` or `[minor]` items exist.

   **Stop when**:
   - Only `[nitpick]` items remain
   - Ambiguity that needs user input (present the question)
   - Same issue persists across 2 consecutive rounds (flag it — may need user decision)

5. **Summary**
   ```markdown
   ## Review-Code Complete

   ### Rounds: [N]

   ### Fixed
   - [List of issues fixed, grouped by file]

   ### Tests Added
   - [Any tests written to cover gaps]

   ### Remaining Nitpicks
   - [Items noted but not fixed — optional improvements]

   ### Needs User Input
   - [Any ambiguities or trade-offs that couldn't be resolved automatically]
   ```

## Notes
- This command is used standalone (`/review-code`) and also invoked by `/implement` during TDD
- Does NOT shadow the built-in `/review` command
- Only reviews changed code — not the entire codebase
- Test gap detection is scoped to changed code; use `/analyze-tests` for broader coverage analysis
- Reverts fixes that cause test regressions rather than shipping broken code
