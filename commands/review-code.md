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

2. **Summary**
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
- This command is used standalone (`/review-code`) and also invoked by `/implement` and `/fix-ci`
- Wraps Claude's built-in `/review`; it does not replace or shadow it
- The review/fix loop lives under the `developer` persona so other workflows can reuse it without duplicating logic
