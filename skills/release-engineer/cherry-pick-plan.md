# Cherry-Pick Plan

Use this phase when the user provides multiple commits or PRs, or requests a plan-only dry run.

## Goal

Build a safe execution order, identify which changes can be applied automatically, and surface only the decisions that actually need user intervention.

This is a batch-level planning phase. It should stay lightweight enough to order, dedupe, and triage the requested changes.
Do not duplicate the deeper per-change risk gate owned by `cherry-pick-investigate.md`.

## Parallel Work

For each candidate change, run these analyses in parallel when possible:

1. Source analysis
   - Resolve the PR or SHA to the actual commit(s)
   - Inspect changed files, intent, and nearby history just enough to order and triage the batch

2. Dependency and overlap analysis
   - Check which changes touch the same files or modules
   - Detect imports, APIs, or modules introduced by one change and consumed by another

3. Existing-fix scan
   - Check whether the target branch already appears to contain an equivalent fix
   - Exclude duplicates before planning order

## Ordering Rules

- Build a dependency graph across all requested changes.
- Topologically sort the graph.
- Independent changes may be investigated in parallel.
- Actual cherry-pick application on the target branch remains sequential.
- Flag circular dependencies or ambiguous prerequisite chains as `Decision Required: YES`.
- Reserve final per-change `Risk`, `Confidence`, and `Decision` ratings for the investigate phase. The plan phase may populate provisional values only.

## Dry-Run Rule

For `--plan-only`, stop after planning and reporting.

Without `--plan-only`, the plan phase should classify each change as:

- `Auto` — low risk, high confidence, no decision required
- `Needs approval` — plausible move, but requires a user decision
- `Reject` — not suitable for cherry-pick in current form

Treat these as provisional until the investigate phase confirms them.

## Output

Always produce a plan summary before execution:

```markdown
## Cherry-Pick Plan

### Target Branch
<branch>

### Dependency Graph
| Change | Depends On | Independent |
|--------|------------|-------------|
| PR #123 | — | Yes |

<short summary of whether inter-change dependencies were detected>

### Execution Table
| # | SHA | PR | Description | Depends On | Risk | Confidence | Decision | Status | Adaptation | Validation | Notes |
|---|-----|----|-------------|------------|------|------------|----------|--------|------------|------------|-------|
| 1 | `<sha>` | #123 | <summary> | — | LOW | 9/10 | Auto | Planned | None | Not run | Clean apply expected |
| 2 | `<sha>` | #124 | <summary> | #123 | MED | 7/10 | Approval | Planned | Minor | Not run | Needs prerequisite first |
```

Use these field meanings:

- `Risk`: `LOW`, `MED`, or `HIGH`
- `Confidence`: confidence in the move as `X/10`
- `Decision`: `Auto`, `Approval`, or `Escalate`
- `Status`: `Planned`, `Applied`, `Blocked`, `Rejected`, or `Skipped`
- `Adaptation`: `None`, `Minor`, `Medium`, or `High`
- `Validation`: `Not run`, `Clean`, `Tested`, `Build-only`, or a short repo-specific equivalent

Do not overload the `Risk` field with prose. Put the explanation in `Notes`.

After execution, update the same execution table rather than emitting a separate parallel format.

Below the table, include detailed sections only for non-trivial rows:

- `Needs adaptation`
- `Blocked`
- `Rejected`
- `Intervention required`
