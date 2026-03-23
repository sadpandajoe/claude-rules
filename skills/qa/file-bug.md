# File Bug

Use this phase when QA execution has produced a strong failure signal and the workflow needs a clean bug handoff.

## Goal

Turn a failed scenario into a crisp bug report with reliable repro steps, expected versus actual behavior, and evidence.

## Core Steps

1. Confirm the failure is reproducible or well-supported by evidence.
2. Write clean repro steps from a known starting state.
3. Record expected versus actual behavior without speculation.
4. Attach the strongest evidence and environment details.
5. Link the failure back to the originating scenario or parent work item when relevant.

## Output

```markdown
## Bug Filing Handoff

- Title: <specific failure>
- Environment: <url, branch, flags, browser, account>
- Repro steps:
  1. <step>
- Expected: <what should happen>
- Actual: <what happened>
- Evidence: <artifact links or paths>
- Severity: <high / medium / low>
```
