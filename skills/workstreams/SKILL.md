---
name: workstreams
description: "Use after parallel implementation subagents finish and their worktree results need fan-in: collect handoffs, update slice status, merge branches in dependency order, and surface failed or conflicting slices. Do NOT use for planning slices, implementing code, reviewing code, or running tests before handoff."
user-invocable: false
disable-model-invocation: true
---

# Workstreams

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

This skill owns fan-in after parallel implementation, not the implementation itself.

| Phase | When | Reference |
|-------|------|-----------|
| Sync workstreams | Subagents returned implementation handoffs from isolated branches/worktrees | [references/sync.md](references/sync.md) |

## Boundaries

- Planning decides the slice graph and dependencies.
- `implement-change/` produces per-slice implementation handoffs.
- This skill consumes those handoffs and handles status tracking plus merge sequencing.
