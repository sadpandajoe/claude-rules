# /update-tests - Improve an Existing Test Suite

@/Users/joeli/opt/code/ai-toolkit/rules/testing.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/qa/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/core/review-tests/SKILL.md

> **When**: You want to improve an existing test suite in a specific area, path, or function and have the workflow analyze gaps, update tests, verify, review, and auto-commit when confidence is strong.
> **Produces**: Scoped test updates, verification results, remaining follow-up gaps, and either an automatic `test:` commit or a clear handoff.

## Usage
```
/update-tests sql-lab
/update-tests src/features/sql-lab
/update-tests tests/unit/sql_lab/
/update-tests --function normalize_query
```

## Steps

1. **Normalize the Target**

   Accept:
   - a product area such as `sql-lab`
   - a repo path
   - a test file or test directory
   - `--function <name>`

   Resolve the target by searching matching product-area names, code paths, and test paths.
   If multiple plausible targets remain, stop and surface the ambiguity.

2. **Discover the Existing Suite**

   Identify the meaningful existing tests for the target area before planning any updates.

   If no meaningful suite exists:
   - stop and recommend `/create-tests`
   - do not create the first suite inside `/update-tests`

3. **Analyze the Current Suite**

   Run the shared test reviewer to identify:
   - weak or low-signal tests
   - missing behavioral coverage
   - production blind spots
   - simplification opportunities

   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-tests/SKILL.md

4. **Expand Use Cases When Needed**

   For workflow-heavy, integration-heavy, or user-visible targets:
   - run QA use-case analysis to produce a compact must-cover scenario matrix

   @/Users/joeli/opt/code/ai-toolkit/skills/qa/analyze-use-cases.md

5. **Scope the Smallest Useful Update**

   Collapse the findings into:
   - must-update now
   - suggested follow-up tests
   - out-of-scope risks

   Keep the current change focused on the smallest set of high-signal suite improvements.

6. **Update the Tests Through `developer`**

   Use the dedicated helper:

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/update-tests.md

   This helper owns:
   - updating existing tests first
   - adding tests only where they fit the current suite naturally
   - replacing low-signal tests when the replacement is clearly better
   - writing failing tests first when feasible
   - targeted verification

7. **Review Changed Test Files**

   Run `/review-code` on the changed repo-tracked files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

8. **Auto-Commit When Ready**

   If verification is strong and `/review-code` leaves no unresolved `[major]` or `[minor]` issues:
   - create a `test:` commit

   Commit message format:
   - `test: update <scope> coverage`
   - fallback: `test: update targeted coverage`

   Stop instead of committing when:
   - verification is partial or blocked
   - meaningful ambiguity remains
   - the workflow handed off to `/create-tests`

9. **Summary**
   ```markdown
   ## Update-Tests Complete

   ### Outcome
   - [Updated suite / handed off to create-tests / stopped on blocker]

   ### Scope
   - [Target area, path, or function]

   ### Suite Outcome
   - [Updated existing suite / handed off to create-tests]

   ### Behavioral Coverage
   - [What regressions or behaviors are now covered]

   ### Review / Quality
   - [Review rounds and final review outcome]

   ### Verification
   - [Checks run]

   ### Risks / Blockers
   - [Anything still weak, blocked, or intentionally left for follow-up]

   ### Remaining Gaps
   - [Suggested follow-up tests or none]

   ### Commit Result
   - [Created `test:` commit / no commit and why]
   ```

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:
- after the target scope is locked
- after gap analysis is synthesized
- after the main test-update pass
- at final completion with verification, remaining gaps, and commit result

## Continuation Checkpoint

If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /update-tests <arguments>
- Phase: scope / gap-analysis / update-tests / verify / review / commit / summarize
- Resume target: <area, path, function, or current failing test>
- Completed items: <finished phases or accepted decisions>
### State
- Existing suite status: <found / insufficient / none>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Verification status: <passed / partial / blocked>
- Pending blockers or follow-up gaps: <if any>
```

After writing the checkpoint:
- run `/clear`
- run `/start`
- resume `/update-tests` at the saved phase and target

Use `/update-project-file --checkpoint ...` only when you need a manual checkpoint outside the normal flow.

## Related Commands
- `/create-tests` — Create the first meaningful suite when there is nothing real to update
- `/fix-bug` — Handles regression tests internally for bug-fix workflows
- `/create-feature` — Handles test-first implementation internally for planned work

## Notes
- `/update-tests` is the public workflow for existing-suite maintenance
- Favor replacing low-signal tests over adding redundant ones
- Write the failing test first when feasible; if blocked, document why before changing the suite
- `/review-code` is an internal phase here, not the expected next top-level user step
