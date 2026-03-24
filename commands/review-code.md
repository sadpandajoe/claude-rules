# /review-code - Wrapper Around Built-In /review

@/Users/joeli/opt/code/ai-toolkit/rules/code-review.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md

> **When**: You have local uncommitted changes and want a quality pass before committing.
> **Produces**: Built-in `/review` findings translated into the repo-standard developer review/fix loop, with validation and a summary of changes made.

## Usage
```
/review-code                    # Review all uncommitted changes
/review-code src/api/           # Review changes in specific path
/review-code --files a.ts b.ts  # Review specific files
```

## Steps

1. **Delegate the Review/Fix Loop to `developer`**

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/review-local-changes.md

   This helper owns:
   - changed-file discovery and scoping
   - built-in `/review` usage
   - finding normalization
   - fix + verify loops
   - stop rules

2. **Run Pre-flight Checks**

   Before declaring the review complete, run the repo's standard checks against the changed files:
   - **Build**: the repo's build command
   - **Type check**: `tsc --noEmit` (TypeScript) or equivalent
   - **Lint**: the repo's lint command
   - **Tests**: covering the changed files

   If any check fails, fix the issue and return to step 1 for another review round.

3. **Emit the Review Gate**

   This block is the required output of `/review-code`. Callers branch on it — completing the review loop without emitting this block is not sufficient.

   ```markdown
   ## Review Gate
   Rounds: [N]
   Pre-flight: pass / fail
   Status: clean / blocked / user decision
   ```

4. **Summary** (standalone runs only — skip when called from another workflow)
   ```markdown
   ## Review-Code Complete
   Rounds: [N] | Pre-flight: [pass/fail] | Status: [clean/blocked]

   ### Fixed
   - [Issues fixed, grouped by file — or "none"]

   ### Remaining
   - [Nitpicks left unfixed, or blockers requiring user decision — or "none"]
   ```

## Notes
- This command is used standalone (`/review-code`) and also invoked by `/create-feature`, `/fix-bug`, and `/fix-ci`
- Wraps Claude's built-in `/review`; it does not replace or shadow it
- The review/fix loop lives under the `developer` persona so other workflows can reuse it without duplicating logic
- When invoked from another top-level workflow, that workflow owns the next step after the review loop finishes
