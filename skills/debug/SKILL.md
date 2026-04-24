---
name: debug
description: Diagnosis toolkit — open investigation, pattern-match CI classification, RCA review, prior-work scan, CI fix verification. Internal helper for /fix-bug, /fix-ci, /cherry-pick, and any workflow that needs to find or validate a root cause.
user-invocable: false
disable-model-invocation: true
---

# Debug

Umbrella for all diagnostic work — finding root causes, validating them, and confirming fixes. References have distinct shapes (investigation / classifier / reviewer / search workflow / verification) unified by the common goal of *understanding what broke*.

## Phases

| Phase | When | Shape | Reference |
|-------|------|-------|-----------|
| Investigate change | Open-ended investigation — bug or RCA | Orchestrator inline OR subagent | [references/investigate-change.md](references/investigate-change.md) |
| Classify CI failure | CI log / artifact available, need pattern match | Fast pattern-match producer | [references/ci-classify-failure.md](references/ci-classify-failure.md) |
| Review RCA | RCA produced, needs critique before implementation | Reviewer subagent prompt | [references/review-rca.md](references/review-rca.md) |
| Check existing fix | Is this bug already fixed upstream or pending in a PR? | Parallel git+gh search | [references/check-existing-fix.md](references/check-existing-fix.md) |
| Verify CI fix | CI fix applied, determine STRONG/PARTIAL/WEAK locally | Verification strength tiering | [references/ci-verify-fix.md](references/ci-verify-fix.md) |

## Typical Composition

**Bug workflow** (`/fix-bug`):
1. `investigate-change` (with "Investigating a Bug" section) → produces RCA
2. `review-rca` → critiques the RCA
3. `check-existing-fix` → is fix already upstream?

**CI workflow** (`/fix-ci`):
1. `ci-classify-failure` → pattern-match or novel
2. Apply fix
3. `ci-verify-fix` → STRONG/PARTIAL/WEAK tier

**Cherry-pick** (`/cherry-pick`):
1. `check-existing-fix` → is the cherry still needed?

## Shape Notes

References here are intentionally diverse:
- `investigate-change` is an open investigation flow (the orchestrator reads the reference and follows steps).
- `ci-classify-failure` is a pattern-match producer (returns a classified failure block).
- `review-rca` is a reviewer subagent prompt (spawned with its content as prompt).
- `check-existing-fix` is a parallel-search workflow (runs git+gh queries in parallel).
- `ci-verify-fix` is a verification-strength tiering reference (definitions + stop conditions).

The umbrella unifies them by workflow domain (diagnosis), not by shape.

## Notes

- `investigate-change` has a "When Investigating a Bug" section with bug-specific framing fields — use it for `/fix-bug`.
- `review-rca` is a *critic* — it scores and returns findings, unlike investigate-change which *produces* the RCA.
- `check-existing-fix` can be skipped when the change is a dependency upgrade or structural refactor (not an isolated defect correction).
