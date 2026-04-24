---
name: plan-implementation
description: Produce a slice-based implementation plan after RCA (bug fix) or after the feature brief is approved (feature). Defines slices with scope, entrance/exit/acceptance, and the test-first mode the implementer will use. Internal helper.
user-invocable: false
disable-model-invocation: true
model: opus
---

# Plan Implementation

Use this phase when a workflow needs a concrete implementation plan — either for a bug fix (after RCA is validated) or for a feature (after the brief is approved). Produces slices, acceptance criteria, and sequencing.

## Goal

Create a tight, slice-based plan that an implementer (human or subagent) can execute without guessing — boundaries clear enough that "done" is unambiguous per slice.

## Core Steps

1. State the input context: validated RCA for a bug fix, or the approved brief for a feature.
2. Choose the narrowest workable technical approach. Narrower approaches have smaller review surfaces, lower regression risk, and faster iteration cycles. A broader approach can always follow in a later slice.
3. Break the work into implementation **slices**:
   - Each slice is independently implementable and reviewable.
   - Each has clear boundaries so the implementer knows exactly when it's done.
   - Well-scoped slices enable parallel execution when slices are independent.
4. For each slice, define:
   - **Scope**: files and boundaries — what this slice touches and what it does NOT touch
   - **Depends on**: none, or which slice must complete first
   - **Entrance criteria**: what must be true before starting
   - **Exit criteria**: specific, verifiable conditions for "done"
   - **Acceptance**: test command, assertion, or manual check that proves the slice works
5. Identify dependencies: which slices can run in parallel, which must be sequential.
6. Call out risks, edge cases, and anything that still requires approval.

## For Bug Fixes

Add these to the standard slice pattern:

- **TDD entry point** at the top of the plan: the failing test or verification step that proves you are verifying the actual bug, not just running the suite. Apply **RED/GREEN per slice** (see `rules/implementation.md` Test-First Modes) — write the failing test, watch it fail, implement, watch it pass. If the test passes before the fix, it does not capture the bug.
- **Decision points** section at the end: anything that needs user approval before coding.

Bug fixes usually skip the "Technical approach" line and the "Data or API implications" section — the RCA already constrains the approach.

## For Features

Add these to the standard slice pattern:

- **Technical approach**: one-line summary of the approach you chose and why it's the narrowest viable option.
- **TDD entry point**: identify the slice's full acceptance test set. Apply **test set as specification** (see `rules/implementation.md` Test-First Modes) — write all the slice's tests first as the spec, implement, then reconcile failures by deciding code-vs-test (and note in the slice or PR when a test was wrong, since the spec evolved).
- **Data or API implications**: migrations, API changes, backwards-compatibility concerns. Surface these even if you think they're handled — they often aren't.
- **Parallelism**: which slices are independent vs which have sequential dependencies.

## Output

Use the appropriate header based on context:

```markdown
## Bug Fix Plan                          # for bug fixes
## Implementation Plan                   # for features

[For features:] Technical approach: <summary>
[For bugs:]     Root cause: <validated RCA>
                TDD entry point: <first failing test or verification step>

### Slices

#### Slice 1: <name>
- Scope: <files and boundaries>
- Depends on: <none, or which slice>
- Entrance criteria: <what must be true before starting>
- Exit criteria: <specific, verifiable conditions for "done">
- Acceptance: <test command or assertion>
- Files: <expected files to create or modify>  [feature plans only]

#### Slice 2: <name>
- ...

### Parallelism                          # feature plans only
- Independent slices (can run in parallel): <e.g., Slices 1 and 2>
- Sequential dependencies: <e.g., Slice 3 depends on Slice 1>

### Data or API implications             # feature plans only
- <impact or none>

### Risks
- <risk>

### Decision points                      # bug plans only
- <approval needed or none>
```
