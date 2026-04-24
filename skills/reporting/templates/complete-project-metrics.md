# /complete-project Metrics Summary Template

Filter `.claude/metrics.jsonl` events to those relevant to this project (timestamp range or referenced commands), then aggregate.

```markdown
## Project Metrics Summary

| Metric | Value |
|--------|-------|
| Total commands run | [N] |
| Pass rate (clean/micro-fix) | [N%] |
| Blocked/failed | [N] |
| Average review rounds | [N.N] |
| Complexity distribution | [N] trivial / [N] standard |
| Model usage | opus: [N], sonnet: [N], haiku: [N] |

### Command Breakdown
| Command | Runs | Clean | Blocked |
|---------|------|-------|---------|
| [name] | [N] | [N] | [N] |
```

If no metrics file exists or no events found in range, emit `No metrics recorded for this project` and continue.
