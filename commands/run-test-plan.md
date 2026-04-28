# /run-test-plan - Standalone QA Validation

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/preset-environments.md
@{{TOOLKIT_DIR}}/skills/testing/references/review-testplan.md

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

   Record Playwright video for every UI scenario. One video per logical flow.
   Use `recordVideo: { dir: 'qa-evidence/videos/', size: { width: 1280, height: 720 } }` when launching the Playwright browser context.
   Name files descriptively: `sc-<id>-<scenario>.webm` or `<scenario>.webm`.
   Supplement with console logs or API output only when video alone doesn't explain a failure.

6. **Report Findings**

   Post a narrative report using the QA Verification template from [skills/shortcut/references/report.md](../skills/shortcut/references/report.md).

   **If a Shortcut story is known** (provided as input, or from PROJECT.md):
   - Upload video evidence to the story
   - Post the report as a story comment

   **If a GitHub PR is known** (provided as input):
   - Upload video evidence to the story if one is linked, otherwise note local paths
   - Post the report as a PR comment

   **Otherwise**:
   - Display the report locally using the same template, with video file paths

   Do not auto-file bugs or auto-route into `/fix-bug`.

7. **Summary**

   Always display locally, regardless of whether external reporting happened:

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
   - [Video files with paths]
   - [Best proof for failures or high-value passes]

   ### Reported To
   - [Shortcut story link / GitHub PR link / local only]

   ### Risks / Blockers
   - [What could not be executed or remains unclear]

   ### Follow-Up
   - [Manual next steps only]
   ```

## Notes
- `/run-test-plan` is validation-only in v1
- Prefer a small runnable matrix over a broad exploratory sweep
- Keep findings factual and local-first
- The command should keep tightening and executing the plan automatically until the matrix reaches threshold or a real blocker stops it
