# /run-test-plan - Standalone QA Validation

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/skills/core/review-testplan/SKILL.md

> **When**: You want to validate a feature area, story, PR, or existing test-plan doc without fixing code in the same workflow.
> **Produces**: A reviewed runnable test plan, execution results, evidence for material failures, and a local findings summary.

## Usage
```
/run-test-plan ./docs/test-plan.md
/run-test-plan sql-lab
/run-test-plan sc-12345
/run-test-plan apache/superset#28456
/run-test-plan https://github.com/owner/repo/pull/123
```

## Steps

1. **Resolve the Starting Point**

   Accept:
   - an existing test-plan doc or matrix
   - a feature or product area
   - a Shortcut story ID or URL
   - a GitHub issue or PR reference / URL

   Pull in external context when references are provided.

2. **Create or Resolve the Test Plan**

   If a plan is provided:
   - read it and normalize it into a compact runnable matrix

   If no plan is provided:
   - derive a compact use-case matrix from the target area or external context

3. **Iterate the Plan to 8/10**

   Review the matrix with the shared test-plan reviewer.
   Revise the plan until it reaches `8/10`, or stop early only if blockers or unresolved ambiguities make execution unsafe or misleading.

4. **Execute the Plan**

   Run only the scenarios that are actually testable in the current environment.

   Execution defaults:
   - Playwright MCP for UI and workflow checks
   - API or CLI calls for non-UI validation
   - clear `BLOCKED` or `SKIP` outcomes when prerequisites are missing

5. **Capture Evidence**

   Capture only the artifacts that materially improve confidence or explain failures.

6. **Display Findings**

   Summarize the results locally.
   Do not:
   - auto-file bugs
   - auto-route into `/fix-bug`
   - auto-report to Shortcut

   External reporting remains a separate manual follow-up.

7. **Summary**
   ```markdown
   ## Run-Test-Plan Complete

   ### Outcome
   - [Executed plan / stopped on blocker before execution]

   ### Source
   - [Plan doc, area, story, or PR]

   ### Plan Quality
   - [Final review score or blocker]

   ### Results
   - [PASS / FAIL / BLOCKED / SKIP by scenario]

   ### Evidence
   - [Best proof for failures or high-value passes]

   ### Risks / Blockers
   - [What could not be executed or remains unclear]

   ### Follow-Up
   - [Manual next steps only]
   ```

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:
- after the starting point and target environment are resolved
- after the test plan reaches `8/10` or stops on blockers
- after execution and evidence capture complete
- at final completion with the findings summary

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /run-test-plan <arguments>
- Phase: resolve-plan / review-plan / execute / capture-evidence / summarize
- Resume target: <plan doc, area, story, PR, or current scenario>
- Completed items: <finished phases or scenarios already run>
### State
- Plan score: <score or blocked>
- Execution status: <not started / partial / complete>
- Evidence status: <captured / none / pending>
- Blockers or unclear items: <if any>
```

## Notes
- `/run-test-plan` is validation-only in v1
- Prefer a small runnable matrix over a broad exploratory sweep
- Keep findings factual and local-first
- The command should keep tightening and executing the plan automatically until the matrix reaches threshold or a real blocker stops it
