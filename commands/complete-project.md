# /complete-project - Project Capstone

@{{TOOLKIT_DIR}}/rules/planning.md

> **When**: A project or major body of work is complete and you want to summarize, promote learnings, archive, and hand off.
> **Produces**: Project-level metrics summary, promoted/pruned memories, archived PROJECT.md, and a recommended final action.

## Usage

```
/complete-project                    # Full capstone for current project
/complete-project --skip-promote     # Skip the memory promotion step
```

## Steps

### 1. Read PROJECT.md — Determine What Was Accomplished

Read PROJECT.md completely. Extract:
- Project goal/overview
- What was built or fixed (from Current Status, completed items)
- Key decisions made (from Accepted Solution, Key Design Decisions)
- Open risks or residual items
- Branch state: `git log --oneline -20`, `git status`, current branch

If no PROJECT.md exists, stop:
```
No PROJECT.md found. This command requires an active project file.
```

### 2. Read Metrics — Project-Level Summary

Read `.claude/metrics.jsonl`. Filter to events relevant to this project (by timestamp range or command names referenced in PROJECT.md).

Compute and emit:

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

If no metrics file exists or no events found, note "No metrics recorded for this project" and continue.

### 3. Scan Memories — Surface Promotion Candidates

Skip this step if `--skip-promote` was passed.

Read all memory files in the project memory directory. Identify promotion candidates:

- **Feedback memories** that describe patterns applicable across all projects (not project-specific context)
- **Postmortem memories** (`feedback_failure_*`) where the prevention recommendation points to a rule or skill change that would help universally
- **Recurring themes** — multiple memories pointing to the same underlying pattern

For each candidate, present:

```markdown
### Promotion Candidate: {filename}
**Pattern**: {one-line summary}
**Why promote**: {reasoning — universality, recurrence, structural value}
**Suggested action**: Promote to rule / Keep as memory / Prune (outdated)
```

Wait for user confirmation on each candidate:
- **Promote**: Follow the `/learn promote` flow (step 8 of `learn.md`) — draft the rule, present for confirmation, write if approved, delete source memory, update MEMORY.md
- **Prune**: Delete the memory file and remove from MEMORY.md
- **Keep**: No action

### 4. Archive Completed Phases

Run `/archive-project-file` as an internal phase. This moves completed development log entries, resolved blockers, and finished implementation details into PROJECT_ARCHIVE.md while keeping active state in PROJECT.md.

Pass the hint that this is a full-project archive: all completed phases should be archived, not just the most recent one.

### 5. Write Final PROJECT.md Status

After archiving, write the final project state:

```markdown
## Project Complete — [date]

{One-paragraph summary of what was accomplished, key decisions, and outcome}

### Final Stats
- Commands run: [N] | Pass rate: [N%]
- Review rounds (avg): [N.N]
- Memories created: [N] | Promoted to rules: [N]

### Residual Items
- {Open risks, untested areas, or follow-up work}
- {Or "None — project is fully validated"}

See PROJECT_ARCHIVE.md for full history.
```

### 6. Suggest Final Action

Based on the current project and branch state, recommend the concrete next step:

```markdown
### Suggested Final Action
```

Pick one:
- **Uncommitted changes exist**: Commit remaining work, then `/create-pr`
- **Changes committed, no PR**: `/create-pr` to open the pull request
- **PR already open**: Merge PR #[N], then deploy
- **Everything merged**: Deploy to staging/production
- **No code changes (process/learning project)**: Archive complete. No further action needed.

### 7. Summary

```markdown
## Complete-Project Done
[One line: project name/goal and final status]

### Accomplished
- [Key deliverables — 3-5 bullets]

### Metrics
- Commands: [N] | Pass rate: [N%] | Avg rounds: [N.N]

### Memories
- Promoted: [N] | Kept: [N] | Pruned: [N]

### Archived
- [Sections moved to PROJECT_ARCHIVE.md]

### Final Action
- [The specific recommended next step]
```

Record lifecycle: `command-complete` { command: "complete-project", status: "clean", complexity: "standard", rounds: 0 }

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /complete-project
- Phase: read-project / metrics-summary / promote-memories / archive / write-final / suggest-action / summarize
- Resume target: [current phase]
- Completed items: [finished phases]
### State
- Metrics computed: yes/no
- Memories reviewed: [N of N]
- Promoted: [N] | Pruned: [N] | Kept: [N]
- Archived: yes/no
- Final status written: yes/no
```

## Notes
- This is the bookend to `/start` — it closes what `/start` opens
- `/archive-project-file` is called as an internal phase, following the composition pattern from `rules/orchestration.md`
- Memory promotion uses the same flow as `/learn promote` — draft rule, confirm, write, delete source
- Auto-postmortems created by `workflow-lifecycle.md` during the project appear as promotion candidates here
- The final PROJECT.md status is intentionally brief — full history lives in PROJECT_ARCHIVE.md
