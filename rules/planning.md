# Planning Principles

## Core Principles
- **Document once, reference many** — PROJECT.md as single source of truth
- **Timestamp everything** — chronological clarity
- **Include context** — why matters as much as what
- **Define success** — clear completion criteria

## Stay in Planning When
- Root cause unclear (multiple plausible causes, insufficient evidence)
- Multiple approaches possible (design decision needed)
- Risk assessment incomplete (cross-cutting changes, migration concerns)
- Dependencies unverified (external APIs, library compatibility)

## Move to Implementation When
- Problem understood (can state root cause in one sentence)
- Approach validated (reviewers at 8/10+ per `rules/scoring.md`)
- Risks assessed (each identified with mitigation)
- Dependencies confirmed (verified locally or documented)

Note: trivial work (per `rules/complexity-gate.md`) skips planning entirely — go straight to implementation.

## PROJECT.md Update Defaults

These defaults apply to all commands unless the command specifies otherwise:

- **Trivial path**: single update after implementation and validation complete
- **No PROJECT.md**: if no `PROJECT.md` exists and the workflow completes in a single pass without blockers, creating one is not required — note the skip in the summary