# /metrics - Workflow Metrics Summary

> **When**: You want to understand how your workflows are performing — pass rates, review round counts, model usage, and trends.
> **Produces**: Aggregate summary from `.claude/metrics.jsonl`.

## Usage

```
/metrics                    # Summary of all recorded workflows
/metrics --period 7d        # Last 7 days only (also: 30d, all)
/metrics --command fix-bug  # Filter to a specific command
```

## Steps

### 1. Read Metrics File

Read `.claude/metrics.jsonl`. If the file does not exist or is empty:
```markdown
No metrics recorded yet. Metrics are emitted automatically when commands complete.
Run a workflow command (e.g., `/create-feature`, `/fix-bug`) to start collecting data.
```
Stop.

### 2. Filter Events

Apply filters from arguments:
- `--period <duration>`: filter to events within the specified window (default: `all`)
  - `7d` = last 7 days, `30d` = last 30 days, `all` = no filter
- `--command <name>`: filter to events matching the command name

### 3. Compute Aggregates

From the filtered events, compute:

**Pass rates**: percentage of workflows ending in each status (`clean`, `blocked`, `user-decision`, `skipped`, `micro-fix`)

**Round counts**: average and max review rounds per command

**Model distribution**: total subagent invocations by model (`opus`, `sonnet`, `haiku`)

**Complexity gate accuracy**: ratio of TRIVIAL classifications that ended `clean` without re-classification (indicates the gate is correctly identifying easy work)

**Command frequency**: how often each command is used

### 4. Emit Summary

```markdown
## Metrics Summary

Period: [7d / 30d / all]
Events: [total count]

### Command Usage
| Command | Runs | Clean | Blocked | Other |
|---------|------|-------|---------|-------|
| [name] | [N] | [N] | [N] | [N] |

### Review Rounds
| Command | Avg Rounds | Max Rounds |
|---------|------------|------------|
| [name] | [N.N] | [N] |

### Model Distribution
| Model | Invocations | % |
|-------|-------------|---|
| opus | [N] | [%] |
| sonnet | [N] | [%] |
| haiku | [N] | [%] |

### Complexity Gate
- Trivial workflows: [N] ([%] of total)
- Trivial → clean: [N] ([accuracy %])

### Trends
- [Notable patterns: improving/declining pass rate, command with high blocked rate, etc.]
- [If insufficient data for trends: "Not enough data for trend analysis (need 10+ events)"]
```

## Notes
- This is a read-only command — it never modifies the metrics file
- Metrics are best-effort: not every command emits metrics yet (initial adoption covers `/create-feature`, `/fix-bug`, `/fix-ci`)
- The `.claude/metrics.jsonl` file is user-local and not committed to git
- Events are appended by `metrics-emit.md` at each command's summary step
- Trend analysis requires at least 10 events to be meaningful
