# Cherry-Pick Adapt

Use this phase when a cherry-pick cannot be applied mechanically.

## Goal

Preserve the source change's behavior on the target branch without widening scope.

This phase owns code-level adaptation only.
Do not redo batch ordering or final validation here.

## Conflict Classification

Classify each conflict before editing:

- import or module path mismatch
- target API mismatch
- structural drift
- logic overlap
- missing prerequisite change

## Parallel Work

When there are multiple conflicting files and they are independent, resolve them in parallel with one worker per file.

Do not parallelize if:

- multiple files participate in the same behavioral change
- a shared interface or type must be updated consistently across files
- one file's resolution depends on another's outcome

## Resolution Rules

- Prefer adapting to the target branch's APIs over pulling in structural changes
- Extract only the functional part of a mixed commit when possible
- If a prerequisite change is truly required, stop and send the decision back to the release-engineer phase
- Reject the cherry-pick if preserving source intent would require a broad refactor
- Record adaptation severity in the execution table as `None`, `Minor`, `Medium`, or `High` (see `cherry-pick-plan.md` for level definitions). When dropping significant chunks, use `High` — not `Minor`.
- **Never use `git checkout --theirs` or `git checkout --ours`** — in cherry-pick context these take the full file from one side, silently discarding the other's changes. Always resolve conflicts by reading markers and editing surgically.

## Residual Bug Surfacing

When a bug-fix cherry-pick is rejected or has significant portions dropped due to architecture mismatch:

1. Assess whether the underlying bug likely exists on the target branch via a different code path.
2. If yes, surface it as a residual risk item in the Detailed Notes — not buried in adaptation notes, but called out as an actionable item (e.g., "the encoding bug likely affects the target branch via `ExecuteSqlCore` — needs a separate fix").
3. The cherry-picking rules say "validate bug exists in target branch." That validation doesn't end when the fix is rejected — the bug's existence is still the user's problem.

## Escalation Triggers

Stop and ask for user input when:

- there are two reasonable behavior-preserving interpretations
- the adaptation changes externally visible behavior
- the target branch lacks required architectural groundwork
- dropping a bug fix leaves the underlying bug unaddressed on the target branch (surface the residual risk even if proceeding)
