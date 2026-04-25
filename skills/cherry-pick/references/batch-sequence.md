---
model: sonnet
---

# Cherry-Pick Batch Sequence

Use when the user provides multiple commits or PRs. Determines execution order only — per-cherry planning is handled by [plan.md](plan.md).

## Goal

Build a safe execution order for a batch of cherry-picks. Stay lightweight — ordering and deduplication, not deep per-change analysis.

## Parallel Work

For each candidate change, run these analyses in parallel when possible:

1. **Source analysis**
   - Resolve the PR or SHA to actual commit(s)
   - Inspect changed files, intent, and nearby history just enough to order and triage

2. **Dependency and overlap analysis**
   - Check which changes touch the same files or modules
   - Detect imports, APIs, or modules introduced by one change and consumed by another

3. **Existing-fix scan**
   - Check whether the target branch already contains an equivalent fix
   - Exclude duplicates before planning order

## Ordering Rules

- Build a dependency graph across all requested changes
- Topologically sort the graph
- Independent changes may be investigated in parallel (orchestrator spawning subagents)
- Actual cherry-pick application on the target branch remains sequential
- Flag circular dependencies or ambiguous prerequisite chains as requiring user decision

## Dry-Run Rule

For `--plan-only`, the orchestrator also runs investigate + gate for each cherry after sequencing. This phase only handles the ordering.

## Output

```markdown
## Batch Sequence Plan

### Target Branch
<branch>

### Dependency Graph
| Change | Depends On | Independent |
|--------|------------|-------------|
| PR #123 | — | Yes |
| PR #124 | PR #123 | No |

<short summary of inter-change dependencies>

### Execution Order
| # | SHA | PR | Description | Depends On | Notes |
|---|-----|----|-------------|------------|-------|
| 1 | `<sha>` | #123 | <summary> | — | Independent |
| 2 | `<sha>` | #124 | <summary> | #123 | Must follow #123 |

### Parallelizable Groups
[List which changes can be investigated in parallel because they're independent]
```

Do not populate risk, confidence, or decision fields — those belong to per-cherry investigate and gate phases.

## Full Execution Table (Batch Tracking)

The orchestrator maintains this table across all cherry-picks in a batch, updating as each per-cherry subagent completes.

See [../examples/execution-table.md](../examples/execution-table.md) for the 12-column format and field meanings.
