# Troubleshooting & Emergency Recovery

## 🎯 Recovery Golden Rules
- [ ] **Stop and assess** before recovery attempts
- [ ] **Safe options first** - stash, checkout, reset --soft
- [ ] **Document what broke** in PROJECT.md
- [ ] **Create rollback points** before major changes
- [ ] **Verify recovery success**
- [ ] **Never make it worse** - If unsure, stop

## Emergency Response

### 1. STOP - Assess
```bash
git status
git log --oneline -5
git diff
git reflog | head -10
git branch
git stash list
```

### 2. DOCUMENT in PROJECT.md
```markdown
## Recovery: [Issue]
- **What broke**: [Symptoms]
- **Last working**: [Commit/time]
- **Timeline**: [What tried, results]
```

### 3. RECOVER - Safe → Dangerous

#### Level 1: Safe (No Data Loss)
```bash
git stash save "emergency-backup"
git checkout -- <file>            # Single file
git checkout -- .                 # All files
git reset --soft HEAD~1           # Undo commit, keep changes
git checkout main && git pull     # Known good branch
```

#### Level 2: Moderate (Selective Loss)
```bash
git reset --hard <good-commit>
git checkout <hash> -- <file>     # Recover deleted file
git merge --abort
git rebase --abort
git cherry-pick --abort
```

#### Level 3: Nuclear (Data Loss)
```bash
git fetch origin
git reset --hard origin/<branch>
git clean -fd
```

## Common Problems

### Merge Conflicts
```bash
git status
grep -r "<<<\|===\|>>>" .
git checkout --ours <file>        # Keep yours
git checkout --theirs <file>      # Keep theirs
git merge --abort                 # Cancel
```

### Accidental Commits
```bash
git reset --soft HEAD~1           # Undo, keep changes
git reset --hard HEAD~1           # Undo, discard changes
git revert <hash>                 # New commit that undoes
```

### Wrong Branch
```bash
git stash
git checkout correct-branch
git stash pop
```

### Lost Work
```bash
git reflog                        # Find lost commits
git checkout <reflog-hash>
git stash list
git fsck --lost-found             # Dangling commits
```

### Build Issues
```bash
# Clean reinstall (language-specific)
rm -rf node_modules && npm install
rm -rf venv && python -m venv venv
go clean -cache && go mod download
git clean -xfd                    # Remove all untracked
```

## Prevention

### Before Changes
- [ ] Commit/stash current work
- [ ] Verify correct branch
- [ ] Create backup branch if risky

### Before Major Operations
```bash
git branch backup-$(date +%Y%m%d-%H%M%S)
git status
```

## Validation After Recovery

```bash
git status                        # Clean state
grep -r "<<<\|===\|>>>" .        # No conflict markers
[run tests]                       # Tests pass
[run app]                         # App works
```

## When to Escalate

- Recovery attempts making worse
- Data loss beyond acceptable
- Production affected
- Security implications
- Multiple cascading failures

## Quick Reference

| Situation | Safe | Nuclear |
|-----------|------|---------|
| Bad uncommitted changes | `git checkout -- .` | `git reset --hard HEAD` |
| Wrong branch | `git stash && checkout` | `git reset --hard origin/main` |
| Bad commit | `git reset --soft HEAD~1` | `git reset --hard HEAD~1` |
| Merge conflict | `git merge --abort` | `git reset --hard origin/branch` |
| Lost work | `git reflog` | `git fsck --lost-found` |
