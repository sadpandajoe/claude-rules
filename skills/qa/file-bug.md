# File Bug

Use this phase when QA execution has produced a strong failure signal and the workflow needs a clean bug handoff.

## Goal

Turn a failed scenario into a crisp bug report with reliable repro steps, expected versus actual behavior, and evidence.

## Core Steps

1. Reuse the latest validated repro steps from QA triage, validation, or test-plan execution instead of rewriting them from memory.
2. Confirm whether the bug is:
   - reproducible with steps, or
   - not fully reproduced but strongly supported by evidence
3. Write clean repro steps from a known starting state.
4. Record expected versus actual behavior without speculation.
5. Attach the strongest evidence and environment details:
   - URL or page
   - branch, build, or commit when relevant
   - browser/device
   - account, role, flags, or seed data
6. For UI or workflow bugs, prefer Playwright video as the primary artifact when available.
7. Identify one `Best proof` artifact or log line so later readers know what to open first.
8. Link the failure back to the originating scenario or parent work item when relevant.

## Output

```markdown
## Bug Filing Handoff

- Title: <specific failure>
- Repro status: <reproduced / evidence-only>
- Environment: <url, branch/build, flags, browser/device, account/role>
- Repro steps:
  1. <step>
- Expected: <what should happen>
- Actual: <what happened>
- Evidence: <artifact links or paths>
- Best proof: <single artifact or log line to open first>
- Severity: <high / medium / low>
```
