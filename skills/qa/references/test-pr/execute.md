---
model: opus
---

# Test PR Execution

## Recording

Follow [../browser-recording.md](../browser-recording.md) unless `--no-record` was passed. Start recording before the first scenario and surface the recording path at the end.

## Browser Execution

Run scenarios sequentially. Do not parallelize browser scenarios; evidence is clearer when the recording is linear.

For each scenario:

1. Navigate to the app URL.
2. Perform the scenario actions in the browser.
3. Capture a screenshot at the main verification point.
4. Check console errors.
5. Mark `PASS`, `FAIL`, or `BLOCKED`.

On `FAIL`, capture an additional screenshot of the failure state and move to the next scenario. Do not retry until after the report.

On `BLOCKED`, record the missing prerequisite: auth, data, feature flag, environment, or unclear expected behavior.

## Evidence Naming

Use stable names:

- `scenario-<N>-<short-name>.png`
- `scenario-<N>-fail.png`

Keep all generated evidence paths for the report phase.
