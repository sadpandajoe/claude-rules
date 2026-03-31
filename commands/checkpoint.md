# /checkpoint - Save Workflow State

> **When**: Context depth is at or above ~70%, or before running `/clear` mid-workflow.
> **Produces**: Continuation checkpoint in PROJECT.md, optional commit, then `/clear`.

No `@`-imports — lightweight utility that must work in any context state.

## Usage

```
/checkpoint
/checkpoint "review-iterations" "PR #42"
```

Arguments are optional hints to override autodetection:
- First argument: current phase
- Second argument: resume target

## Steps

### 1. Identify Current State

Read the conversation context and PROJECT.md (if it exists) to determine:
- **Top-level command**: the user-facing command in progress (e.g., `/create-feature`, `/fix-bug`)
- **Phase**: current internal phase (e.g., `plan-mode`, `implement`, `review-code`)
- **Resume target**: current item being worked on (story, PR, file set, blocker)
- **Completed items**: phases or decisions already finished
- **Key state**: scores, files changed, pending blockers

If arguments were provided, use them for phase and resume target instead of autodetecting.

### 2. Write Checkpoint to PROJECT.md

Write or replace the `## Continuation Checkpoint` section in PROJECT.md using this canonical format:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: [the user-facing command to resume]
- Phase: [current internal phase]
- Resume target: [current item, PR, SHA, file, or blocker]
- Completed items: [items already finished]
### State
- [Key decisions made]
- [Current scores/results if in review loop]
- [Files modified so far]
- [Any pending issues or blockers]
```

If no PROJECT.md exists, create one with just the checkpoint section.

Also update the `## Current Status` section if it exists — refresh **In Progress** and **Next** to reflect the checkpoint state.

### 3. Commit Uncommitted Work

If there are uncommitted changes relevant to the current workflow:
- Stage the changed files
- Commit with message: `chore: checkpoint [top-level command] at [phase]`
- If nothing to commit, skip

Do not commit PROJECT.md (it must never be committed to git).

### 4. Clear Context

Run `/clear` to reset conversation context.

The user resumes by running `/start`, which reads the checkpoint from PROJECT.md and automatically continues the saved workflow.

## Notes
- This command saves state and clears — it does NOT resume. `/start` handles resume.
- The checkpoint format above is the canonical definition. Other commands reference it but should not duplicate it.
- Only one checkpoint exists at a time — writing a new one replaces the previous.
- PROJECT.md must never be committed to git.
