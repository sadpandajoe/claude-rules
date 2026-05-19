---
name: workstreams
description: "Fan-in for parallel implementation subagents: collect handoffs, track slice status, merge branches in dependency order, surface failures."
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
