# Universal Troubleshooting & Emergency Recovery

## 🎯 Recovery Golden Rules
- [ ] **Stop and assess before making any recovery attempts** - Understand current state
- [ ] **Use safe recovery options first** - stash, checkout, reset --soft
- [ ] **Document what broke and how it was fixed** - In PROJECT.md
- [ ] **Create rollback points before major changes** - Commit working states
- [ ] **Document everything in PROJECT.md using investigation format** - Full context
- [ ] **Check current state before any recovery attempt** - git status, git log
- [ ] **Distinguish infrastructure vs code issues** - Environmental vs actual bugs
- [ ] **More conservative changes when tooling unavailable** - Reduce risk
- [ ] **Verify recovery success** - Confirm system is in good state
- [ ] **Never make recovery worse** - If unsure, stop and ask

## Emergency Response Process

### 1. STOP - Assess the Situation
```bash
# What's the current state?
git status
git log --oneline -5
git diff

# What was working?
git reflog | head -10

# Are we on the right branch?
git branch

# Any uncommitted work to save?
git stash list
```

### 2. DOCUMENT - In PROJECT.md
Use investigation format from PROJECT_TEMPLATE.md:

```markdown
## Investigation: [Recovery Issue]

### The Problem
- **What broke**: [Exact symptoms]
- **When discovered**: [Timestamp]
- **Last working state**: [Commit/time]
- **Impact**: [What's affected]

### Investigation Timeline
- [Time]: Initial state - [what found]
- [Time]: Tried [recovery approach] - [result]
- [Time]: Tried [alternative] - [result]

### Accepted Solution
- **What worked**: [Successful recovery method]
- **Why it worked**: [How it addressed the issue]

### Failed Solutions
- **[Approach 1]**: [Why it didn't work]
- **[Approach 2]**: [Why it failed]
```

### 3. RECOVER - Safe to Dangerous

#### Level 1: Safe Recovery (No Data Loss)
```bash
# Save current work
git stash save "emergency-backup-[timestamp]"

# Return to last commit
git checkout -- <specific-file>    # Single file
git checkout -- .                  # All files

# Undo last commit but keep changes
git reset --soft HEAD~1

# Switch to known good branch
git checkout main
git pull
```

#### Level 2: Moderate Recovery (Selective Loss)
```bash
# Reset to specific commit
git reset --hard <known-good-commit>

# Recover deleted file
git log --all --full-history -- <deleted-file>
git checkout <commit-hash> -- <deleted-file>

# Abort merge/rebase/cherry-pick
git merge --abort
git rebase --abort
git cherry-pick --abort
```

#### Level 3: Nuclear Options (Data Loss)
```bash
# WARNING: These destroy work

# Reset to remote state
git fetch origin
git reset --hard origin/<branch>

# Clean everything
git reset --hard HEAD
git clean -fd

# Complete reset
rm -rf .git
git init
git remote add origin <url>
git fetch
git checkout <branch>
```

## Common Problems & Solutions

### Merge Conflicts
```bash
# Check conflict status
git status
grep -r "<<<\|===\|>>>" .

# Option 1: Keep your changes
git checkout --ours <file>

# Option 2: Keep their changes
git checkout --theirs <file>

# Option 3: Abort entirely
git merge --abort

# After resolution
git add <resolved-files>
git commit
```

### Accidental Commits
```bash
# Undo last commit, keep changes
git reset --soft HEAD~1

# Undo last commit, discard changes
git reset --hard HEAD~1

# Undo specific commit (creates new commit)
git revert <commit-hash>

# Remove file from commit
git reset HEAD~1 <file>
git commit --amend
```

### Wrong Branch Work
```bash
# Save work and switch
git stash
git checkout correct-branch
git stash pop

# Move commits to another branch
git log --oneline -n 3              # Note commits
git checkout correct-branch
git cherry-pick <commit-hash>
git checkout wrong-branch
git reset --hard HEAD~3             # Remove from wrong branch
```

### Dependency/Build Issues
```bash
# Clean and reinstall
[Language-specific:]
# Node.js
rm -rf node_modules package-lock.json
npm install

# Python
rm -rf venv __pycache__
python -m venv venv
pip install -r requirements.txt

# Go
go clean -cache
go mod download

# General
git clean -xfd                      # Remove all untracked files
```

### Lost Work Recovery
```bash
# Check reflog for lost commits
git reflog

# Recover lost commit
git checkout <reflog-hash>

# Check stash
git stash list
git stash show -p stash@{0}

# Check for dangling commits
git fsck --lost-found
```

## Prevention Strategies

### Before Making Changes
- [ ] Commit or stash current work
- [ ] Note current branch and commit
- [ ] Verify on correct branch
- [ ] Pull latest changes
- [ ] Create backup branch if risky

### During Development
- [ ] Commit frequently with clear messages
- [ ] Test incrementally
- [ ] Use feature branches
- [ ] Don't force push to shared branches
- [ ] Keep PROJECT.md updated

### Before Major Operations
```bash
# Create safety backup
git branch backup-$(date +%Y%m%d-%H%M%S)

# Verify clean state
git status
git stash list

# Document in PROJECT.md
echo "[$(date)] Creating backup before [operation]" >> PROJECT.md
```

## Troubleshooting Checklist

### Quick Diagnostics
```bash
# Version control state
git status                          # Current state
git log --oneline -5               # Recent history
git diff                           # Uncommitted changes
git diff --staged                  # Staged changes

# File system state
ls -la                             # Current directory
pwd                                # Where am I?
find . -name "*.tmp" -o -name "*.bak"  # Temporary files

# Process state
[Language-specific: ps, top, lsof, netstat]
```

### Systematic Debugging
1. **Reproduce** - Can you make it happen again?
2. **Isolate** - What's the minimum to reproduce?
3. **Compare** - What's different from working state?
4. **Hypothesize** - What could cause this?
5. **Test** - Verify hypothesis
6. **Fix** - Apply minimal solution
7. **Verify** - Confirm fix works
8. **Document** - Update PROJECT.md

## When to Escalate

### Escalate When
- Recovery attempts making it worse
- Data loss risk beyond acceptable
- Production systems affected
- Security implications discovered
- Beyond time constraints
- Multiple cascading failures

### Before Escalating Document
```markdown
## Escalation: [Issue]

### Current State
- Repository: [path/url]
- Branch: [current branch]
- Last working commit: [hash]
- Changes since: [description]

### What Was Tried
- [Attempt 1]: [Result]
- [Attempt 2]: [Result]

### Risks
- [Risk 1]: [Impact]
- [Risk 2]: [Impact]

### Needed Expertise
- [What kind of help needed]
```

## Recovery Validation

### After Recovery Verify
```bash
# Clean git state
git status                         # Should be clean or expected
grep -r "<<<\|===\|>>>" .         # No conflict markers

# Code validity
[Language-specific: compile, lint, type-check]

# Tests pass
[Language-specific: run test suite]

# Application works
[Language-specific: run application]
```

### Post-Recovery Documentation
```markdown
## Recovery Complete: [Issue]

### What Broke
[Root cause analysis]

### How Fixed
[Solution applied]

### Lessons Learned
[What to do differently]

### Prevention
[How to avoid in future]
```

## Emergency Command Reference Card

| Situation | Safe Option | Nuclear Option |
|-----------|------------|----------------|
| Uncommitted changes bad | `git checkout -- .` | `git reset --hard HEAD` |
| Wrong branch | `git stash && git checkout` | `git reset --hard origin/main` |
| Bad commit | `git reset --soft HEAD~1` | `git reset --hard HEAD~1` |
| Merge conflict | `git merge --abort` | `git reset --hard origin/branch` |
| Lost work | `git reflog && git checkout` | Check `git fsck --lost-found` |
| Build broken | Clean and rebuild | Delete and reclone |

## Lessons Learned Using This Guide
<!-- Document recovery approaches that worked unexpectedly -->
<!-- Capture patterns in what causes emergencies -->
<!-- Note when safe recovery wasn't safe -->
<!-- Record prevention strategies discovered through failures -->
