# API Boundary Defense

## Golden Rule
- **When fixing a frontend→backend performance or correctness bug, close the gap at the API boundary too** — fixing only the caller leaves the endpoint exposed to future regressions.

## When This Applies

Any fix where the client was doing something unsafe (unbounded, unvalidated, unpaginated) and the endpoint permitted it:
- Missing pagination params → endpoint should enforce a default or max page size
- Missing filters → endpoint should validate required scoping
- Unbounded batch size → endpoint should cap it

## Why This Matters

Fixing the UI caller is necessary but not sufficient. Other callers (internal scripts, tests, future integrations) and future regressions can reopen the same issue if the endpoint still allows the dangerous path.

## How to Apply

1. After identifying the client-side fix, ask: "Does the endpoint still allow this dangerous behavior?"
2. If yes, enforce a safe default or validation server-side in the same PR when low-risk.
3. If not done in the same PR, record it as a follow-up item in PROJECT.md.

## Example

Fixing a pagination-less frontend call for a perf bug: the endpoint should also default to a safe page size when called without params, not just rely on the fixed caller.
