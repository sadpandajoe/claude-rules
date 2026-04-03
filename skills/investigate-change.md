---
model: opus
---

# Investigate Change

Use this phase when a workflow needs investigation or root-cause analysis as an internal step rather than as a standalone user-facing command.

## Goal

Understand what is broken, identify the most plausible root cause with evidence, and hand the result back to the calling workflow.

## Scope

Use this for:

- code-level behavior investigation
- local root-cause analysis
- validating whether a suspected fix already exists
- narrowing failure scope before planning or adaptation

This file is the reusable RCA phase for larger workflows. Use it when the public action is still `/fix-bug`, `/create-feature`, or another end-to-end command.

## Core Steps

1. Define the problem precisely.
2. Reproduce if possible.
3. Inspect code, history, and recent changes.
4. Identify the most likely introducing change.
5. Check whether an equivalent fix already exists.
6. Summarize root cause, evidence, and open uncertainty.

## Output

Return a compact handoff:

```markdown
## Investigation Summary

- Problem: <what is broken>
- Root cause: <most likely cause>
- Evidence: <key proof points>
- Existing fix: <yes/no and where>
- Open questions: <remaining uncertainty>
```

### Bug-Specific Additions (Optional)

When investigating a bug, also include these fields in the summary:

- **Affected area**: files, services, or flows involved
- **Introducing change**: commit or PR that introduced the regression, or "unknown"
- **Existing local safeguards**: tests, guards, or defensive checks that should have caught this (present / absent / partial)
