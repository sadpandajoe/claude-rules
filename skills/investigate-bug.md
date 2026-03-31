# Investigate Bug

Use this phase when a workflow needs code-level RCA for a reported bug as an internal step rather than a standalone user-facing investigation command.

## Required Context
Read before starting: `rules/investigation.md`

## Goal

Trace the likely failing path, identify the most plausible root cause with evidence, and hand back a compact RCA for validation.

## Core Steps

1. Restate the bug in code-level terms.
2. Identify the likely files, state transitions, or services involved.
3. Reproduce locally if practical, or explain why reproduction is still indirect.
4. Inspect recent code, git history, and introducing changes.
5. Look for partial fixes, guards, or adjacent regressions in the current codebase.
6. Return the most plausible RCA with the strongest available evidence.

## Output

```markdown
## Bug Investigation

- Affected area: <files, services, flows>
- Likely root cause: <most plausible cause>
- Evidence: <key proof points>
- Introducing change: <commit or unknown>
- Existing local safeguards: <present / absent / partial>
- Open questions: <remaining uncertainty>
```
