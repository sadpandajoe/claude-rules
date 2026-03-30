# /update-project-file - Update PROJECT.md

@/Users/joeli/opt/code/ai-toolkit/rules/planning.md

> **When**: PROJECT.md needs a manual sync, checkpoint, or quick status refresh outside a command's normal workflow.
> **Produces**: Updated PROJECT.md state with minimal ceremony.

## Steps

1. **Read Current PROJECT.md**

   Read the current file and identify the sections that actually need updating.

2. **Inspect Current State**
   ```bash
   # Recent commits
   git log --oneline -10
   
   # Current branch status
   git status
   
   # What changed since last update
   git diff --stat HEAD~5
   ```

3. **Choose the Smallest Useful Update**

   Default to the lightest update that keeps PROJECT.md accurate.
   Use one of these modes:

   - **Quick sync**: refresh Current Status and add a short Development Log entry
   - **Checkpoint**: write a continuation checkpoint before `/clear`
   - **Decision update**: record an accepted or failed approach
   - **Manual note**: append a short user-supplied progress note

4. **Update Only the Relevant Sections**

   Do not rewrite unrelated sections.

   **Quick sync**:
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

   **Current Status**:
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

   **Decision update**:
   ```markdown
   ### Accepted Solution
   - **Approach**: [What we're doing]
   - **Decided**: [Timestamp]
   - **Reasoning**: [Why this approach]
   ```

   **Failed approach**:
   ```markdown
   ### Failed Solutions
   #### [Approach Name]
   - **What**: [What we tried]
   - **Why Failed**: [What went wrong]
   - **Learned**: [Takeaway]
   ```

   **Checkpoint**:
   ```markdown
   ## Continuation Checkpoint — [timestamp]
   ### Workflow
   - Top-level command: [command to resume]
   - Phase: [current internal phase]
   - Resume target: [current item or iteration]
   - Completed items: [items already finished]
   ### State
   - [Key decisions made]
   - [Current status snapshot]
   - [Pending blockers or intervention points]
   ```

5. **Write Updates**

   Apply only the chosen updates to PROJECT.md.

6. **Confirm**

   Summarize what changed and what the file now says is next.

## Quick Modes

For fast updates:
```
/update-project-file "Completed auth module, starting tests"
```

Will:
- Add timestamped log entry
- Update status based on message
- Keep it brief

For checkpointing:
```
/update-project-file --checkpoint "/cherry-pick ..." "validate" "PR #123"
```

Will:
- Write the continuation checkpoint in the standard format
- Keep the rest of PROJECT.md untouched unless a status refresh is also needed

7. **Session Learning** (optional)

   When doing a checkpoint or end-of-session sync, also update the `usage_patterns` memory file with commands and skills used during the session. See "Session Learning" in `rules/universal.md`.

## Notes
- Most commands should update PROJECT.md themselves before finishing
- Use this command when manual cleanup or checkpoint writing is needed
- Especially useful before `/clear` or after work done outside a structured command
