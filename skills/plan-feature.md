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
3. Break the work into implementation slices with clear boundaries. Each slice should be independently implementable and reviewable — well-scoped slices enable parallel execution and reduce review iterations because each subagent knows exactly when it's done.
4. For each slice, define: scope (files/boundaries), entrance criteria (what must be true before starting), exit criteria (what must be true to call it done), and acceptance (how to verify).
5. Identify dependencies between slices — which can run in parallel, which must be sequential.
6. Call out migrations, API changes, and compatibility concerns when they exist.
7. Define the test strategy per slice.

## Output

```markdown
## Implementation Plan

Technical approach: <summary>

### Slices

#### Slice 1: <name>
- Scope: <files and boundaries — what this slice touches and what it does NOT touch>
- Depends on: <none, or which slice must complete first>
- Entrance criteria: <what must be true before starting — e.g., "migration from Slice 1 is applied">
- Exit criteria: <what must be true to call this slice done — specific, verifiable conditions>
- Acceptance: <how to verify — test command, manual check, or assertion>
- Files: <expected files to create or modify>

#### Slice 2: <name>
- ...

### Parallelism
- Independent slices (can run in parallel): <e.g., Slices 1 and 2>
- Sequential dependencies: <e.g., Slice 3 depends on Slice 1>

### Data or API implications
- <impact or none>

### Risks
- <risk>
```
