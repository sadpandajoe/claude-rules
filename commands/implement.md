# /implement - Manual Implementation Workflow

@/Users/joeli/opt/code/ai-toolkit/rules/implementation.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md

> **When**: You already know what to build and want the expert/manual implementation entrypoint without the full `/fix-bug` orchestration.
> **Produces**: Tested local changes, review results, and a summary of what is ready to commit.

## Steps

1. **Prepare the Environment**

   Read `PROJECT.md` or the provided task context, then use:

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/prepare-environment.md

2. **Implement Through `developer`**

   Use:

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/implement-change.md

   Follow the approved plan when one exists.

3. **Review Changed Files**

   Invoke `/review-code` on the changed repo-tracked files.

4. **Summary**
   ```markdown
   ## Implementation Complete

   ### Code Changes
   - [Files changed and what they now do]

   ### Verification
   - [Checks run locally]

   ### Review-Code
   - [Rounds run or skipped]

   ### Ready to Commit?
   - [Yes / No - what still blocks it]
   ```

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:
- after environment prep if it changes the expected validation path
- after the main implementation pass
- after `/review-code` and targeted verification
- at final completion with the resulting file set and readiness-to-commit status

## Continuation Checkpoint

If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /implement <arguments>
- Phase: prepare-environment / implement / review / summarize
- Resume target: <plan section, file set, or current failing check>
- Completed items: <finished implementation or validation steps>
### State
- Files changed so far: <files or none>
- Verification status: <passed / partial / blocked>
- Pending blockers or decisions: <if any>
```

After writing the checkpoint:
- run `/clear`
- run `/start`
- resume `/implement` at the saved phase and target

Use `/update-project-file --checkpoint ...` only when you need a manual checkpoint outside the normal flow.

## Review-Code Loop Termination Rules
- **Stop** when only `[nitpick]` items remain
- **Stop** when there's ambiguity that needs user input (present the question)
- **Continue** as long as `[major]` or `[minor]` items exist

## Implementation Standards
- Functions ≤20 lines (guideline)
- Files ≤300 lines
- Nesting ≤2 levels
- Match existing patterns
- YAGNI - only what's needed now

## Commit Message Format
```
type: brief description

- Specific change 1
- Specific change 2

[Fixes #issue]
```
Types: feat, fix, docs, style, refactor, test, chore

## Notes
- `/implement` is the manual expert entrypoint; use `/fix-bug` for end-to-end bug work
- Working solution first, then optimize
- Test as you go, not only at the end
