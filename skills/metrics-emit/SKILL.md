---
name: metrics-emit
description: Use at the end of an end-to-end workflow summary to append one structured event to .claude/metrics.jsonl for later /metrics or /complete-project aggregation. Do NOT use as a progress log, checkpoint mechanism, or blocker for workflow completion.
user-invocable: false
disable-model-invocation: true
model: haiku
---

# Metrics Emit

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

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
- End-to-end command prompts should reference this skill context at the very end of their summary step, after all gates have resolved
- `/metrics` command reads this file and produces aggregate summaries
