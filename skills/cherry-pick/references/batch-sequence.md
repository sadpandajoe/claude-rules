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
   - Run `${CLAUDE_SKILL_DIR}/scripts/batch-deps.sh <sha1> <sha2> ...` to get the mechanical signals: per-SHA file lists, SHA pairs sharing files, per-file coverage (×N count), author-date order, and a list of fully-independent SHAs eligible for parallel investigation.
   - Read the output: every "[×2]" or higher entry in per-file coverage is a dependency point. The pairs above each describe an edge in the dependency graph.
   - Detect imports, APIs, or modules introduced by one change and consumed by another — the script's per-SHA file list surfaces this; verify by inspecting hunks for any pair flagged with shared files.

3. **Existing-fix scan**
   - Quick mechanical filter first: for each source SHA, run `git log --grep="cherry picked from commit ${sha}" <target-branch>`. Any hits get classified `Skipped` immediately and never enter the execution table — this catches `-x`-attributed cherry-picks already on the branch in seconds, before any per-cherry investigation runs.
   - For SHAs that pass the mechanical filter, the deeper [check-existing-fix reference](../../debug/references/check-existing-fix.md) handles squashed equivalents, partial backports already in place, and fixes done independently on the target.
   - Exclude duplicates before planning order.

## Ordering Rules

- Build the dependency graph from `batch-deps.sh` output: nodes = SHAs, edges = pairs flagged as sharing files.
- Topologically sort. Author-date order from the script is a valid topo-sort *iff* no later commit reverts or replaces content from an earlier one — verify by inspecting any pair where the later commit is a `chore: remove`, `revert`, or `refactor` of code touched by the earlier commit. If you find a revert/replace pattern, swap those two.
- Independent SHAs (the script's "Independence Check" section) may be investigated in parallel — the orchestrator should spawn one subagent per island concurrently.
- Actual cherry-pick application on the target branch remains sequential.
- Flag circular dependencies or ambiguous prerequisite chains as requiring user decision.

**Why a real graph beats merge order:** if A modifies file F and B later removes F, applying A then B on the target requires A's adapter to integrate against the target's pre-removal F, then B's adapter to remove what's left. Applying B first (when safe by hunk inspection) lets A apply against a clean post-removal state. Merge order on master doesn't reveal this — only file-overlap analysis does.

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
[List which changes can be investigated in parallel because they're independent — copy from `batch-deps.sh` "Independence Check" section]
```

Do not populate risk, confidence, or decision fields — those belong to per-cherry investigate and gate phases.

## Full Execution Table (Batch Tracking)

The orchestrator maintains this table across all cherry-picks in a batch, updating as each per-cherry subagent completes.

See [../examples/execution-table.md](../examples/execution-table.md) for the 12-column format and field meanings.
