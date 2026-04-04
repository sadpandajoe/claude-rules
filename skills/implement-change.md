---
model: opus
---

# Implement Change

Use this phase when the workflow is ready to apply a code change after investigation and any needed planning are complete.

## Required Context
Read before starting: `rules/implementation.md`, `rules/testing.md`

## Goal

Implement one slice from the plan — the narrowest change that satisfies the slice's exit criteria. Add regression protection, verify against the slice's acceptance criteria, and hand the result back.

## Slice Awareness

When the plan defines structured slices (with scope, entrance/exit criteria, acceptance), implement exactly one slice per invocation:
- Verify **entrance criteria** are met before starting — if not, stop and report what's missing
- Stay within the slice's **scope** — do not touch files outside the boundary
- Stop when **exit criteria** are met — the slice is done, hand it back
- Run the slice's **acceptance** check to verify

When no structured slices exist (simple fix, trivial path), implement the full change as a single unit.

## Core Steps

1. Check entrance criteria (if slice is defined). Stop if unmet.
2. Write or update the smallest high-signal failing test before the code change when feasible.
3. If test-first is blocked by repro, env, or harness constraints, record why before continuing.
4. Implement the minimum code change that satisfies the slice's exit criteria (or the validated RCA for non-sliced work).
5. Run the slice's acceptance check or targeted verification for changed files.
6. Note anything that could not be verified locally.
7. Hand changed files back to the calling workflow for `/review-code`.

## Output

```markdown
## Implementation Handoff

- Slice: <name, or "single change" if no slices>
- Entrance criteria: <met / N/A>
- Exit criteria: <met — evidence>
- Files changed:
  - <file>
- Tests added or updated:
  - <test>
- Acceptance: <passed / failed / not runnable — reason>
- Unverified areas:
  - <gap or none>
```
