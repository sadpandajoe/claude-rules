---
model: opus
---

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

## Evidence Capture

After execution, capture video evidence for every UI scenario:

1. **Default to video**: When testing via Playwright, always record video (`recordVideo: { dir: 'qa-evidence/videos/', size: { width: 1280, height: 720 } }`). One video per logical flow — not one giant recording.
2. Name files descriptively: `sc-<id>-<what-was-tested>.webm` or `<scenario-name>.webm`.
3. Save artifacts under `qa-evidence/<scenario>/`.
4. Supplement with console logs or API output when they explain a failure that video alone doesn't capture.
5. Identify the single best proof artifact for each scenario.

## Output

```markdown
## QA Execution Result

- Scenario: <name>
  - Result: <pass / fail / blocked / skip>
  - Validation path: <playwright / api / manual>
  - Evidence: <screenshots, logs, video, or none>
  - Best proof: <single artifact or log line to reference first>
  - Follow-up: <summarize / rerun later / file bug / no action>
```
