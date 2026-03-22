# /start - Initialize Session

@/Users/joeli/opt/code/ai-toolkit/PROJECT_TEMPLATE.md

> **When**: Beginning any work session.
> **Produces**: Loaded PROJECT.md context and session entry.

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
   - Read the checkpoint state (completed commands, next command, scores, context)
   - Add a session entry noting this is a continuation:
     ```markdown
     ### [Timestamp] - Session Resumed
     - Branch: [current branch]
     - Resuming from: [checkpoint timestamp]
     - Next: [next command from checkpoint]
     ```
   - **Automatically invoke the next command** from the checkpoint. Do not prompt the user.

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
   - Cherry-picking → `/cherry-plan` or `/cherry-pick`

## Notes
- This command loads context only
- Specific workflows load their own rules as needed
- If a continuation checkpoint exists, resumes automatically — no prompt
- Always start here for a new session
