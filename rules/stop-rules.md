# Stop Rules

Universal stop conditions for iterative review and fix loops.

## When to Stop

Stop the current loop when any of these are true:

- **Only nitpicks remain** — no `[major]` or `[minor]` findings left
- **A user decision is required** — a trade-off, ambiguity, or scope question that only the user can answer
- **Same issue persists across two consecutive rounds** — the fix attempt did not resolve it; further iteration will not help

## What "Stop" Means

"Stop" means surface the decision or emit the gate block — not abandon the workflow. The calling command still owns the next steps (commit, summary, handoff).

## Scope

This rule applies to review/fix loops (`review-local-changes.md`), plan review iterations, and any other iterative quality loop. It does not override command-specific stop conditions that are stricter.
