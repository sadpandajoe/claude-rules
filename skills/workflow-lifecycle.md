---
name: workflow-lifecycle
description: Record phase-boundary events for metrics and auto-create postmortems on command failure.
model: haiku
---

# Workflow Lifecycle

Single integration point for phase-boundary events. Commands call this skill at key transitions to record metrics and detect failures automatically.

## How Commands Call This

One line per phase boundary:

```
Record lifecycle: <phase> { key: value, key: value }
```

This is an in-thread call (same agent, same context). The skill appends a JSONL event and, at `command-complete` with a failure status, auto-creates a postmortem memory.

## Phase Events

| Phase | When | Required Fields |
|-------|------|-----------------|
| `gate` | After complexity gate | `command`, `complexity`, `confidence` |
| `plan-complete` | Planning phase done | `command`, `reviewer_scores`, `round_count` |
| `review-round` | Each review iteration | `command`, `round`, `status`, `finding_counts` |
| `impl-complete` | Implementation done | `command`, `slices_complete`, `slices_failed`, `slices_blocked` |
| `review-gate` | Final review outcome | `command`, `status`, `total_rounds`, `preflight` |
| `command-complete` | Summary step (end of command) | `command`, `status`, `complexity`, `rounds`, `models_used` |

All fields are best-effort. Omit unknown fields rather than guessing.

## Steps

### 1. Construct and Append Event

Build a JSONL object:
```json
{
  "timestamp": "<ISO 8601>",
  "phase": "<phase-name>",
  "<field>": "<value>",
  ...
}
```

Append as a single line to `.claude/metrics.jsonl`. Create the file if it does not exist.

If the append fails (permissions, disk, path), note the failure in conversation but **do not block the calling command**. Metrics are advisory.

### 2. Auto-Failure Check (command-complete only)

Skip this step for all phases except `command-complete`.

If `status` is `blocked`, `failed`, or indicates a non-clean terminal state:

**a.** Gather failure context from the conversation:
- Which command ran and with what inputs
- What the expected outcome was
- What actually happened (gate decisions, review findings, error messages)
- Which step or gate made the wrong call

**b.** Write a postmortem memory file:

Path: the project memory directory (same as Claude Code auto-memory: `~/.claude/projects/<project-path>/memory/`)

Filename: `feedback_failure_{command}_{YYYY-MM-DD}.md`

If a file with that name already exists (multiple failures same day), append a counter: `feedback_failure_{command}_{YYYY-MM-DD}_2.md`

```markdown
---
name: {command} failure - {one-line summary}
description: {one-line summary of what went wrong}
type: feedback
---

## What happened
{Command, inputs, expected vs actual outcome}

## What the system decided
{Which gate, skill, or step made the wrong call — with evidence from conversation}

## What it should have decided
{The correct action and why}

## Prevention
**Why:** {Root cause — process gap, missing signal, wrong threshold}
**How to apply:** {Specific rule, gate, or skill to adjust — reference by file path}
```

**c.** Update `MEMORY.md` index with a new entry linking to the file.

**d.** Emit a visible block in the command's summary:

```markdown
### Auto-Postmortem Recorded
File: `{filename}`
Summary: {one-line description}
Review with: `/learn review` | Promote with: `/learn promote {filename}`
```

### 3. Quiet Confirmation (non-failure phases)

For phases other than `command-complete`, or for `command-complete` with a clean status: no visible output. The event is recorded silently. Lifecycle events should not clutter the command output.

## Notes
- This skill subsumes `metrics-emit.md` for commands that adopt lifecycle calls. The `command-complete` event contains equivalent data. `metrics-emit.md` remains available for standalone use.
- When `/review-code` is invoked as an internal phase by another command, skip lifecycle recording — the calling command owns lifecycle events.
- One line per event, strict JSON in `.claude/metrics.jsonl` — no trailing commas, no multi-line formatting.
- The auto-postmortem runs without user prompting. The user sees it in the summary and manages it later via `/learn review` or `/learn prune`.
- Memory path follows Claude Code's auto-memory convention. If the path cannot be resolved, fall back to the project root's `.claude/` directory.
