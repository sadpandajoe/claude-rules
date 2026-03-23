# Execute Use Cases

Use this phase when a workflow already has a use-case matrix or confirmed repro steps and needs a generic QA execution pass.

## Goal

Run the relevant scenarios against a real environment, record the outcomes clearly, and hand the results back with reliable evidence and repro detail.

## Core Steps

1. Filter the matrix to scenarios that are testable in the current environment.
2. Confirm environment health, data, feature flags, and permissions.
3. Run each scenario through the right path:
   - Playwright MCP for UI workflows
   - direct HTTP or CLI calls for API-only paths
   - mark blocked scenarios clearly when prerequisites are missing
4. Record PASS, FAIL, BLOCKED, or SKIP for each scenario.
5. Hand the results back to the calling workflow with enough evidence for summary, reporting, or bug filing when needed.

## Output

```markdown
## QA Execution Result

- Scenario: <name>
  - Result: <pass / fail / blocked / skip>
  - Validation path: <playwright / api / manual>
  - Evidence: <screenshots, logs, video, or none>
  - Follow-up: <summarize / rerun later / file bug / no action>
```
