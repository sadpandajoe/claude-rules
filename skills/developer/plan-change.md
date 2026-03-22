# Plan Change

Use this phase when the RCA is plausible but the fix is broad enough, risky enough, or uncertain enough that the workflow should pause to define a tighter implementation approach before coding.

## Goal

Create a compact implementation plan that is specific enough for the current bug fix without expanding into a full feature-design exercise unless the workflow truly needs it.

## Core Steps

1. State the validated root cause and the narrow success condition.
2. Break the fix into the smallest implementation slices that preserve behavior.
3. Define the RED test first, then the GREEN implementation path.
4. Call out edge cases, risk points, and the validation plan.
5. Note anything that still requires approval before coding.

## Output

```markdown
## Bug Fix Plan

- Root cause: <validated RCA>
- TDD entry point: <first failing test or verification step>
- Implementation slices:
  - <slice>
- Risks:
  - <risk>
- Validation plan:
  - <check>
- Decision points:
  - <approval needed or none>
```
