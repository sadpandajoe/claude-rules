# /start - Initialize Session

@/Users/joeli/opt/code/ai-toolkit/PROJECT_TEMPLATE.md

> **When**: Beginning any work session.
> **Produces**: Loaded PROJECT.md context and session entry.

This command is the only supported entrypoint for resuming work after `/clear`.
It restores workflow state from PROJECT.md rather than relying on chat memory.

## Steps

1. **Find PROJECT.md**

   Search these locations in order (stop at first match):
   1. Current working directory: `PROJECT.md`
   2. Git repo root: `$(git rev-parse --show-toplevel)/PROJECT.md`
   3. Additional working directories from the environment

   The file may be a real file or a **symlink** — both are valid. Read it normally either way.

   - If found: Read completely
   - If not found anywhere: Ask if user wants to create one using `PROJECT_TEMPLATE.md`

2. **Check for Continuation Checkpoint**

   If PROJECT.md contains a `## Continuation Checkpoint` section:
   - Read the checkpoint state:
     - top-level command
     - phase
     - resume target
     - completed items
     - key workflow state
   - Add a session entry noting this is a continuation:
     ```markdown
     ### [Timestamp] - Session Resumed
     - Branch: [current branch]
     - Resuming from: [checkpoint timestamp]
     - Command: [top-level command from checkpoint]
     - Phase: [saved phase]
     - Resume target: [saved item or iteration]
     ```
   - **Automatically resume the saved top-level command** from the checkpoint. Do not prompt the user.
   - The resumed command loads its own rules, skills, and supporting files on demand.
   - After the resume succeeds, clear or replace the stale checkpoint so the same state is not resumed twice unintentionally.

3. **Normal Session** (no checkpoint)

   Add session entry:
   ```markdown
   ### [Timestamp] - Session Start
   - Branch: [current branch]
   - Status: [summary from Current Status]
   - Goal: [ask user]
   ```

   ```
   "Session initialized. What would you like to work on?"
   ```

   Suggest relevant commands based on context:
   - New feature → `/create-plan`
   - Debugging/issues → `/investigate`
   - Writing tests → `/create-tests`
   - Writing code → `/implement`
   - Cherry-picking → `/cherry-pick`
   - Completed phases cluttering PROJECT.md → `/archive-project-file`

4. **Recommend Archiving When Useful**

   If PROJECT.md appears cluttered with completed-phase material, recommend `/archive-project-file` before the next major phase.

   Common signals:
   - long Development Log sections for work that is already complete
   - resolved blockers still taking space in active sections
   - completed investigations, implementations, or milestones that are no longer active
   - active work becoming hard to find quickly

   Recommend archiving, but do not auto-run it.

## Notes
- This command initializes or resumes workflow state
- Specific workflows load their own rules, skills, and supporting files as needed
- If a continuation checkpoint exists, resumes automatically — no prompt
- After `/clear`, use `/start` as the only supported resume path
- Do not try to resume from chat history alone
- Recommends archiving when PROJECT.md is bloated, but archiving remains an explicit user action
- Always start here for a new session
