---
model: sonnet
---

# /update-project-file - Manual PROJECT.md Status Refresh

@{{TOOLKIT_DIR}}/rules/planning.md

> **When**: PROJECT.md needs a manual sync or progress note outside a command's normal workflow.
> **Produces**: Updated PROJECT.md state with minimal ceremony.

For checkpointing before `/clear`, use `/checkpoint` instead.

## Usage

```
/update-project-file
/update-project-file "Completed auth module, starting tests"
```

With a quoted argument, adds a timestamped log entry and refreshes status in one step.

## Steps

### 1. Read Current PROJECT.md

Read the current file and identify which sections need updating.

### 2. Inspect Current State

Check recent activity to inform the update:
- `git log --oneline -10` — recent commits
- `git status` — current branch status
- `git diff --stat HEAD~5` — what changed recently

### 3. Choose Update Type

Default to the lightest update that keeps PROJECT.md accurate:

- **Quick sync**: Refresh Current Status and add a short Development Log entry
- **Manual note**: Append a user-supplied progress note with timestamp

### 4. Update Only the Relevant Sections

Do not rewrite unrelated sections.

**Development Log entry**:
```markdown
### [Timestamp] - Progress Update

**Completed:**
- [What was done]
- [Related commits: abc123, def456]

**Discovered:**
- [Any findings or learnings]
```

**Current Status refresh**:
```markdown
## Current Status

**Done:**
- [x] [Completed items]

**In Progress:**
- [ ] [Current work]

**Next:** [Upcoming task]
**Blocked:** [Blocker, if any]
```

### 5. Confirm

Summarize what changed and what the file now says is next.

## Notes
- Most commands update PROJECT.md themselves before finishing
- Use this for manual cleanup or after work done outside a structured command
- For checkpointing before `/clear`, use `/checkpoint`
- For recording decisions (accepted/failed approaches), update PROJECT.md inline during the command that made the decision
