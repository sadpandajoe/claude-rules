---
model: opus
---

# Plan Change

Use this phase when the RCA is plausible but the fix is broad enough, risky enough, or uncertain enough that the workflow should pause to define a tighter implementation approach before coding.

## Goal

Create a compact implementation plan that is specific enough for the current bug fix without expanding into a full feature-design exercise unless the workflow truly needs it.

## Core Steps

1. State the validated root cause and the narrow success condition.
2. Break the fix into the smallest implementation slices that preserve behavior. Each slice should have clear boundaries so the implementer knows exactly when it's done — this reduces review iterations and enables parallel execution when slices are independent.
3. For each slice, define: scope, entrance criteria, exit criteria, and the specific test or verification that proves the slice works.
4. Define the RED test first, then the GREEN implementation path. (The failing test proves you are verifying the actual bug, not just running the suite. If the test passes before the fix, it does not capture the bug.)
5. Call out edge cases, risk points, and dependencies between slices.
6. Note anything that still requires approval before coding.

## Output

```markdown
## Bug Fix Plan

Root cause: <validated RCA>
TDD entry point: <first failing test or verification step>

### Slices

#### Slice 1: <name>
- Scope: <files and boundaries>
- Depends on: <none, or which slice>
- Entrance criteria: <what must be true before starting>
- Exit criteria: <specific, verifiable conditions for "done">
- Acceptance: <test command or assertion>

#### Slice 2: <name>
- ...

### Risks
- <risk>

### Decision points
- <approval needed or none>
```
