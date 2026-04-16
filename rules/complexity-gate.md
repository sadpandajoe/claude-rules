# Complexity Gate

Classification protocol for commands that branch on trivial, moderate, or standard paths. This defines the output block format and path rules. Signal tables are command-specific and stay in commands.

## Block Format

Always emit this block in conversation before branching:

```markdown
## Complexity Gate
Classification: TRIVIAL / MODERATE / STANDARD
Confidence: X/10
Reason: [one line]
```

## Trivial Fast-Path

When classification is `TRIVIAL` and confidence is `8/10` or higher:
- Skip plan mode, investigation lanes, RCA validation, and reviewer subagents
- Go directly to implementation, verify, review, summary
- Zero subagent spawns — orchestrator does all work inline

## Moderate Path

When classification is `MODERATE` and confidence is `8/10` or higher:
- Skip plan mode and parallel investigation-lane subagents
- Orchestrator investigates and plans inline (no investigation subagent spawns)
- Still spawn **one** reviewer subagent for code/plan review — never review your own work
- Still run tests and emit a Review Gate block
- Spawn additional subagents only when parallelism provides a clear wall-clock win

**When to classify MODERATE** (any of these signals):
- 2–4 files touched, but within a single subsystem
- Non-mechanical change, but well-understood pattern (add endpoint, extend model, new test file)
- No architectural decisions or cross-system trade-offs
- Clear fix or implementation approach — investigation confirms rather than discovers

MODERATE is the **default classification** — most real work lands here. Use TRIVIAL only for truly mechanical changes, STANDARD only when genuine multi-system complexity or ambiguity exists.

## Standard Path

When classification is `STANDARD` (or confidence is below `8/10` for any classification):
- Full workflow: plan mode, investigation lanes, reviewer subagents, RCA validation
- Spawn subagents per command-specific steps and `rules/orchestration.md` model tiers

## Never Silently Decide

Always emit the gate block above. Do not silently choose a path — the block must be visible in conversation so the user and any continuation checkpoint can see the classification.

## Worked Examples

### TRIVIAL

- **Typo in error message**: 1 file, no logic change, no regression risk. Confidence 10/10.
- **Config value change**: 1-2 files, mechanical substitution, testable in isolation. Confidence 9/10.
- **Missing import after rename**: 1 file, fix is deterministic from the error, no design decision. Confidence 9/10.

### STANDARD

- **API endpoint returns wrong status code for edge case**: 3+ files (handler, test, maybe middleware), requires understanding request flow, behavioral change with regression potential. Confidence 6/10 until investigated.
- **Feature flag logic inverted**: Cross-cutting impact across multiple components, needs investigation to confirm scope. Confidence 5/10.
- **New validation rule on existing form**: Multiple files (frontend component, backend validator, test suite), design decision about error UX, potential for regression in adjacent flows. Confidence 7/10.

## Scope

This rule defines an output contract. It does not define the signal tables (those are command-specific) or the path-specific steps (those are command-owned).
