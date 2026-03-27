# /review-code - Wrapper Around Built-In /review

@/Users/joeli/opt/code/ai-toolkit/rules/code-review.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md

> **When**: You have local changes (uncommitted or already committed) and want a quality pass.
> **Produces**: Built-in `/review` findings translated into the repo-standard developer review/fix loop, with validation and a summary of changes made.

## Usage
```
/review-code                    # Review all uncommitted changes
/review-code src/api/           # Review changes in specific path
/review-code --files a.ts b.ts  # Review specific files
/review-code --committed        # Review committed changes (diff base..HEAD)
```

## Steps

1. **Delegate the Review/Fix Loop to `developer`**

   Use `developer/review-local-changes.md`. This helper owns:
   - changed-file discovery and scoping (uncommitted or committed mode)
   - code review against `rules/code-review.md`
   - finding normalization
   - fix + verify loops
   - stop rules

2. **Run Pre-flight Checks**

   Before declaring the review complete, run the repo's standard checks against the changed files. Discover commands from `package.json` scripts, `Makefile` targets, `pyproject.toml`, or the repo's CI config:
   - **Build**: e.g., `npm run build`, `make build`
   - **Type check**: `tsc --noEmit` (TypeScript) or equivalent
   - **Lint**: e.g., `npm run lint`, `make lint`
   - **Tests**: covering the changed files

   If any check fails, fix the issue and return to step 1 for another review round.

   If the local environment cannot run the checks (missing toolchain, requires CI-only infrastructure, etc.), record `Pre-flight: skipped` with a reason. Do not invent a pass — the caller and the summary must reflect that pre-flight was not verified locally.

3. **Emit the Review Gate**

   This block is the required output of `/review-code`. Callers branch on it — completing the review loop without emitting this block is not sufficient.

   ```markdown
   ## Review Gate
   Rounds: [N]
   Pre-flight: pass / fail / skipped — [reason]
   Status: clean / blocked / user decision
   ```

4. **Summary** (standalone runs only — skip when called from another workflow)
   ```markdown
   ## Review-Code Complete
   Rounds: [N] | Pre-flight: [pass/fail] | Status: [clean/blocked]

   ### Reviewed
   - [What was checked and why it's safe — e.g., "e.currentTarget correctness (synthetic event contract guarantees non-null)"]
   - [Edge cases explicitly verified — e.g., "page boundary after delete: clamped to last valid page" or "async ordering: setState before await checked"]

   ### Not reviewed
   - [What was deliberately out of scope — e.g., "other e.target patterns in codebase (grepped, none found)" or "ColorPicker test coverage (out of scope)"]

   ### Fixed
   - [Issues fixed, grouped by file — or "none"]

   ### Remaining
   - [Nitpicks left unfixed, or blockers requiring user decision — or "none"]
   ```

## Notes
- This command is used standalone (`/review-code`) and also invoked by `/create-feature`, `/fix-bug`, and `/fix-ci`
- The review/fix loop lives under the `developer` persona so other workflows can reuse it without duplicating logic
- When invoked from another top-level workflow, that workflow owns the next step after the review loop finishes
