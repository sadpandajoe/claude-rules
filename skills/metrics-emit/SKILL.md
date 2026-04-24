---
name: metrics-emit
description: Append a structured workflow event to .claude/metrics.jsonl for observability. Called at the end of an end-to-end command's summary step so /metrics and /complete-project can aggregate later.
user-invocable: false
disable-model-invocation: true
model: haiku
---

# Metrics Emit

Append a single structured event to `.claude/metrics.jsonl` at the end of any command's summary step. This is observability infrastructure — it records what happened so `/metrics` can analyze trends.

## Required Context

The calling command provides these values in its prompt:

- `command` — the slash command name (e.g., `create-feature`, `fix-bug`)
- `complexity` — `trivial` or `standard`
- `status` — the final outcome: `clean`, `blocked`, `user-decision`, `skipped`, `micro-fix`, or command-specific
- `rounds` — number of review iterations (0 if no review loop)
- `gate_decisions` — object with gate outcomes (e.g., `{complexity: "standard", action: "proceed", review: "clean"}`)
- `models_used` — object counting subagent model usage (e.g., `{opus: 3, sonnet: 1, haiku: 0}`)

All fields are best-effort. If a value is unknown or not applicable, omit it rather than guessing.

## Steps

1. Construct the JSONL event:

```json
{
  "timestamp": "<ISO 8601>",
  "command": "<command-name>",
  "complexity": "<trivial|standard>",
  "status": "<outcome>",
  "rounds": <number>,
  "gate_decisions": {},
  "models_used": {}
}
```

2. Append the event as a single line to `.claude/metrics.jsonl` (create the file if it does not exist).

3. If the append fails for any reason (file permissions, disk space, path issue), log the failure in conversation but do **not** block or fail the calling command. Metrics are advisory — never gate workflow progress on them.

## Output

```markdown
## Metrics Recorded
Event: <command-name>
Status: <outcome>
File: .claude/metrics.jsonl
```

## Notes
- One line per event, strict JSON — no trailing commas, no multi-line formatting
- The `.claude/` directory is user-local, not checked into git
- Commands should call this skill at the very end of their summary step, after all gates have resolved
- `/metrics` command reads this file and produces aggregate summaries
- Commands using `workflow-lifecycle.md` emit phase events that include `command-complete` — equivalent to this skill's output. Those commands do not need to call `metrics-emit` separately.
