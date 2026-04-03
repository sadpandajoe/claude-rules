---
model: opus
---

# Plan Feature

Use this phase when the feature brief is ready and the workflow needs a technical plan that a developer could implement without guessing.

## Goal

Translate the approved brief into a concrete implementation plan with PR slices, validation strategy, and sequencing.

## Core Steps

1. Identify the key code paths, interfaces, and data boundaries affected.
2. Choose the narrowest workable technical approach. (Narrower approaches have smaller review surfaces, lower regression risk, and faster iteration cycles. A broader approach can always follow in a later slice.)
3. Break the work into reviewable PR slices.
4. Call out migrations, API changes, and compatibility concerns when they exist.
5. Define the test strategy and verification path.

## Output

```markdown
## Implementation Plan

- Technical approach: <summary>
- PR slices:
  - <slice>
- Data or API implications:
  - <impact or none>
- Test strategy:
  - <checks>
- Risks:
  - <risk>
```
