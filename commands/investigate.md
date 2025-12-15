# /investigate - Investigation & Root Cause

Debug issues and find root causes.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/investigation.md` - Investigation-specific rules

Do not proceed until rules are read and understood.

---

## Steps

1. **Document the Problem**
   ```markdown
   ## Investigation: [Issue Name]
   
   ### The Problem
   - **What's broken**: [Exact symptoms/error]
   - **When it occurs**: [Trigger conditions]
   - **Impact**: [What functionality affected]
   - **Environment**: [Branch, version, setup]
   
   ### Timeline
   - [Timestamp]: Starting investigation
   ```

2. **Reproduce**
   ```bash
   # Verify issue exists
   [Run failing command/test]
   
   # Check current state
   git status
   git branch
   git log --oneline -5
   ```

3. **Git History Analysis**
   ```bash
   # Blame - who/when changed it
   git blame -- <file>
   
   # Search history
   git log -S "problematic-code" --oneline
   git log --grep="keyword" --oneline
   
   # Binary search (if needed)
   git bisect start
   git bisect bad
   git bisect good <known-good>
   ```

4. **Find Introducing Commit**
   ```bash
   git show <commit-hash>
   git show --stat <commit-hash>
   git log --oneline <commit>~5..<commit>+5
   
   # Find associated PR
   git log --grep="Merge pull request" --oneline
   ```

5. **Check for Existing Fixes**
   ```bash
   git log --all --grep="fix.*<issue>"
   git branch -a --contains <commit>
   ```

6. **Document Root Cause**
   ```markdown
   ### Root Cause
   - **Introducing commit**: `<hash>` - "<message>"
   - **Author**: [author]
   - **PR**: #[number] (if applicable)
   - **Why it broke**: [Explanation]
   
   ### Existing Fix?
   [Yes/No - details if yes]
   ```

7. **Propose Solutions**
   ```markdown
   ### Solutions
   
   #### Option 1: Quick Fix
   - **Approach**: [Description]
   - **Risk**: Low
   - **Trade-off**: Doesn't address root cause
   
   #### Option 2: Proper Fix
   - **Approach**: [Description]
   - **Risk**: Medium
   - **Trade-off**: More testing needed
   
   ### Recommendation
   [Which option and why]
   ```

8. **Update PROJECT.md**
   Add all findings to appropriate sections.

## Notes
- Always use git history first
- Find root cause, not just symptoms
- Prefer existing fixes over creating new ones
- Document with evidence (command outputs)
