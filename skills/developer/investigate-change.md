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

Do not use this file to replace the `/investigate` command when the user explicitly asked for a full standalone investigation workflow.

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
