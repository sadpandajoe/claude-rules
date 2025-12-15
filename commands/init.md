# /init - Initialize Session

Start a new work session. Run this first.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles (always)
2. `rules/orchestration.md` - Claude + Codex workflows

Do not proceed until rules are read and understood.

---

## Steps

1. **Check for PROJECT.md**
   ```bash
   ls -la PROJECT.md
   ```
   
   - If exists: Read completely
   - If not: Ask if user wants to create one using `PROJECT_TEMPLATE.md`

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
