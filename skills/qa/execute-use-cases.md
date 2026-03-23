# Execute Use Cases

Use this phase when a workflow already has a use-case matrix or confirmed repro steps and needs a generic QA execution pass.

## Goal

Run the relevant scenarios against a real environment, record the outcomes clearly, and hand failures back with reliable repro detail.

## Core Steps

1. Filter the matrix to scenarios that are testable in the current environment.
2. Confirm environment health, data, feature flags, and permissions.
3. Run each scenario through the right path:
   - Playwright MCP for UI workflows
   - direct HTTP or CLI calls for API-only paths
   - mark blocked scenarios clearly when prerequisites are missing
4. Record PASS, FAIL, BLOCKED, or SKIP for each scenario.
5. Hand failures to the bug-filing or reporting phase only when the evidence is strong enough.

## Output

```markdown
## QA Execution Result

- Scenario: <name>
  - Result: <pass / fail / blocked / skip>
  - Validation path: <playwright / api / manual>
  - Evidence: <screenshots, logs, video, or none>
  - Follow-up: <file bug / rerun later / no action>
```
