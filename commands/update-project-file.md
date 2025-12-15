# /update-project-file - Update PROJECT.md

Sync PROJECT.md with current progress.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/planning.md` - PROJECT.md structure

Do not proceed until rules are read and understood.

---

## Steps

1. **Read Current PROJECT.md**
   ```bash
   cat PROJECT.md
   ```

2. **Check Recent Activity**
   ```bash
   # Recent commits
   git log --oneline -10
   
   # Current branch status
   git status
   
   # What changed since last update
   git diff --stat HEAD~5
   ```

3. **Gather Update Information**
   
   Ask user:
   - What was accomplished?
   - Any blockers?
   - What's next?
   - Any decisions made?

4. **Update Development Log**
   ```markdown
   ### [Timestamp] - Progress Update
   
   **Completed:**
   - [What was done]
   - [Related commits: abc123, def456]
   
   **Decisions Made:**
   - [Decision and reasoning]
   
   **Discovered:**
   - [Any findings or learnings]
   ```

5. **Update Current Status**
   ```markdown
   ## Current Status
   
   **Done:**
   - [x] [Completed item 1]
   - [x] [Completed item 2]
   
   **In Progress:**
   - [ ] [Current work]
   
   **Next:**
   - [ ] [Upcoming task]
   
   **Blocked:**
   - [Blocker and details, if any]
   ```

6. **Update Solutions** (if decisions made)
   
   If a solution was chosen:
   ```markdown
   ### Accepted Solution
   - **Approach**: [What we're doing]
   - **Decided**: [Timestamp]
   - **Reasoning**: [Why this approach]
   ```
   
   If something didn't work:
   ```markdown
   ### Failed Solutions
   #### [Approach Name]
   - **What**: [What we tried]
   - **Why Failed**: [What went wrong]
   - **Learned**: [Takeaway]
   ```

7. **Update Implementation Notes** (if relevant)
   ```markdown
   ## Implementation Notes
   
   ### [Topic]
   - [Technical detail]
   - [Gotcha discovered]
   - [Pattern to follow]
   ```

8. **Write Updates**
   
   Apply all updates to PROJECT.md.

9. **Confirm**
   ```markdown
   ## PROJECT.md Updated
   
   Changes made:
   - Added Development Log entry
   - Updated Current Status
   - [Other changes]
   
   Current state:
   - In Progress: [X]
   - Next: [Y]
   - Blocked: [None / Z]
   ```

## Quick Update Mode

For fast updates:
```
/update-project-file "Completed auth module, starting tests"
```

Will:
- Add timestamped log entry
- Update status based on message
- Keep it brief

## Notes
- Run periodically to keep PROJECT.md current
- Especially after completing tasks
- Before ending a session
- After making decisions
