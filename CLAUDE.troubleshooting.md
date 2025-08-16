# Troubleshooting & Emergency Recovery

## When Things Break - Emergency Response

### 1. Stop and Assess Immediately
- [ ] What was the last working state?
- [ ] What changed since then? 
- [ ] Is this a simple revert or complex debugging needed?
- [ ] Can I safely undo the change?

**Golden Rule**: Document everything in PROJECT.md using investigation format

### 2. Check Current State
```bash
git status                    # See what's changed
git log --oneline -5          # Recent commits
git branch                    # Current branch
pwd                          # Verify location
```

### 3. Use PROJECT.md for All Documentation
All troubleshooting follows standard investigation workflow:
- Document the problem in PROJECT.md
- Track what you tried in Development Log
- Use Failed Solutions section for attempts that didn't work
- Record root cause analysis and solution

**See CLAUDE.investigation.md for complete debugging process**

## Emergency Recovery Commands

### Safe Recovery (No Data Loss)
```bash
git stash                   # Save work safely
git status                  # Check current state
git log --oneline -5        # Recent history
git reflog                  # Activity history
```

### File Recovery
```bash
# Restore deleted files
git log --oneline --follow -- deleted-file.txt
git checkout commit-hash -- deleted-file.txt

# Revert specific file to last commit
git checkout -- filename.txt

# Revert all unstaged changes
git checkout -- .
```

### Undo Changes
```bash
# Unstage files
git reset filename.txt      # Unstage specific file
git reset                   # Unstage all files

# Undo commits (local only)
git reset --soft HEAD~1     # Undo last commit, keep changes
git reset --hard HEAD~1     # Undo last commit, discard changes
```

### Branch Recovery
```bash
# If on wrong branch
git stash                   # Save current work
git checkout correct-branch # Switch to right branch
git stash pop              # Restore work

# Start fresh from known good state
git checkout main          # Go to safe branch
git pull                   # Get latest
git checkout -b new-branch # Create fresh branch
```

### Last Resort (Data Loss Possible)
```bash
git reset --hard HEAD       # Discard all changes
git clean -fd              # Remove untracked files
git reset --hard origin/main # Match remote exactly
```

### Merge Conflict Recovery
```bash
# Abort operations
git merge --abort          # Abort merge
git rebase --abort         # Abort rebase  
git cherry-pick --abort    # Abort cherry-pick

# Clean up after manual resolution
grep -r "<<<\|===\|>>>" . # Find remaining conflicts
git add .                  # Stage resolved files
git commit                 # Complete merge/rebase
```

## Verification After Recovery

### Essential Checks
```bash
# Ensure no conflict markers remain
grep -E "<<<|===|>>>" **/*

# Check project-specific validation
[run project-specific validation commands]

# Verify basic functionality
[test core features manually]
```

### Post-Recovery Documentation in PROJECT.md
Use standard investigation format:

```markdown
## Recovery from [Issue Description]

### The Problem
- **What was broken**: [Description]
- **When discovered**: [Timestamp]
- **Impact**: [What was affected]

### Investigation Timeline
- [Timestamp]: Discovered issue - [state found]
- [Timestamp]: Tried [recovery method] - [result]
- [Timestamp]: Found root cause - [what caused it]

### Failed Solutions
- **Attempt 1**: [What was tried] - [Why it didn't work]
- **Attempt 2**: [Another approach] - [Result]

### Accepted Solution
- **What worked**: [Successful recovery method]
- **Why it worked**: [Root cause and how solution addressed it]
- **Prevention**: [How to avoid this in future]
```

## When to Escalate

### Escalate When:
- Recovery attempts make situation worse
- Data loss risk or security implications
- Multiple systems affected beyond expertise
- Time-sensitive with external dependencies

### Before Escalating:
- Document current state in PROJECT.md
- List what was tried and results
- Include exact error messages
- Note current branch and working directory

## Emergency Command Reference

### Quick Recovery
```bash
git stash && git reset --hard HEAD    # Nuclear option - save work first
git status && git log --oneline -5    # Assess current state
```

### Information Gathering
```bash
git reflog                            # See recent activity
git log --oneline -10                 # Recent commits
git diff HEAD~1                       # What changed recently
```

### Prevention
- Commit working states frequently
- Use descriptive commit messages
- Test changes incrementally
- Keep PROJECT.md updated with current state

---

**Remember**: All troubleshooting is debugging. Use CLAUDE.investigation.md for systematic problem-solving and document everything in PROJECT.md.

## Lessons Learned

### Common Recovery Patterns
<!-- Add recovery strategies that have worked well -->

### Prevention Strategies
<!-- Add practices that prevent common issues -->

### Emergency Procedures
<!-- Add quick fixes for recurring problems -->

### Tool-Specific Recovery
<!-- Add recovery procedures for specific tools/frameworks -->
