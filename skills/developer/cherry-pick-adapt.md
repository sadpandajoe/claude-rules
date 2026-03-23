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
- Record adaptation severity in the execution table as `None`, `Minor`, `Medium`, or `High`

## Escalation Triggers

Stop and ask for user input when:

- there are two reasonable behavior-preserving interpretations
- the adaptation changes externally visible behavior
- the target branch lacks required architectural groundwork
