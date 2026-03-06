# /start - Initialize Session

@/Users/joeli/opt/code/claude-rules/PROJECT_TEMPLATE.md

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

2. **Verify Environment**
   ```bash
   git status
   git branch
   git log --oneline -3
   ```

3. **Add Session Entry** (if PROJECT.md exists)
   ```markdown
   ### [Timestamp] - Session Start
   - Branch: [current branch]
   - Status: [summary from Current Status]
   - Goal: [ask user]
   ```

4. **Ready Prompt**
   ```
   "Session initialized. What would you like to work on?"
   ```
   
   Suggest relevant commands based on context:
   - Debugging/issues → `/investigate`
   - New feature → `/plan`
   - Writing code → `/implement`
   - Writing tests → `/test`
   - Code review → `/review`

## Notes
- This command loads context only
- Specific workflows load their own rules as needed
- Always start here for a new session
