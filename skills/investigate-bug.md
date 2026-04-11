---
model: opus
---

# Investigate Bug

Use this phase when a workflow needs code-level RCA for a reported bug as an internal step rather than a standalone user-facing investigation command.

## Required Context
Read before starting: `rules/investigation.md`

## Goal

Trace the likely failing path, identify the most plausible root cause with evidence, and hand back a compact RCA for validation.

## Core Steps

Follow the investigation process in `investigate-change.md` with these bug-specific additions:

1. **Restate the reported problem in code-level terms** — trace from the user-visible symptom to the code path responsible.
2. **Attempt local reproduction when practical** — if reproduction is not possible, explain why and what indirect evidence substitutes.
3. **Frame findings in terms of user impact** — connect the root cause back to the observable failure the user reported.

## Output

Use the base output from `investigate-change.md` and include the bug-specific additions (Affected area, Introducing change, Existing local safeguards) documented there.

```markdown
## Bug Investigation

- Affected area: <files, services, flows>
- Likely root cause: <most plausible cause>
- Evidence: <key proof points>
- Introducing change: <commit or unknown>
- Existing local safeguards: <present / absent / partial>
- Open questions: <remaining uncertainty>
```
