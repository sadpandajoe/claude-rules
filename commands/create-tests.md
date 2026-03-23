# /create-tests - Create Automated Tests

@/Users/joeli/opt/code/ai-toolkit/rules/testing.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/review-tests/SKILL.md

> **When**: You want the manual/transitional test-writing workflow outside a larger action such as `/fix-bug`.
> **Produces**: Focused automated tests, validation results, and a summary of remaining test gaps.

## Usage
```
/create-tests                         # Tests for uncommitted changes
/create-tests <file>                  # Tests for specific file
/create-tests --function <name>       # Tests for specific function
```

## Steps

1. **Determine Scope**

   Identify the code to test:
   - Uncommitted changes: `git diff --name-only`
   - Specific file or function: as provided
   - Read the code thoroughly before writing any tests

2. **Delegate Test Creation to `developer`**

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/create-tests.md

   This helper owns:
   - running `review-tests` before writing tests
   - choosing the right test layer
   - writing or replacing tests
   - targeted verification

3. **Summary**
   ```markdown
   ## Create-Tests Complete

   ### Scope
   - [What behavior or files were covered]

   ### Tests Added or Updated
   - [Files changed]

   ### Verification
   - [Checks run]

   ### Remaining Gaps
   - [Anything still not covered]
   ```

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:
- after the target scope is locked
- after the main test-writing pass
- at final completion with the validation result and remaining gaps

## Continuation Checkpoint

If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /create-tests <arguments>
- Phase: scope / review-tests / write-tests / verify / summarize
- Resume target: <files, function, or behavior under test>
- Completed items: <finished steps>
### State
- Current scope: <what is being tested>
- Tests added so far: <files or none>
- Verification status: <passed / partial / blocked>
```

After writing the checkpoint:
- run `/clear`
- run `/start`
- resume `/create-tests` at the saved phase and target

Use `/update-project-file --checkpoint ...` only when you need a manual checkpoint outside the normal flow.

## Related Commands
- `/review-plan` — Reviews test strategy during plan phase via review-testplan skill
- `/fix-bug` — Handles test creation internally for bug-fix workflows

## Notes
- `/create-tests` is a manual/transitional command; larger workflows should absorb this over time
- Favor the smallest set of high-signal tests over broad test quantity
