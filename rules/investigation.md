# Investigation & Problem-Solving Workflow

## 🎯 Investigation Golden Rules
- [ ] **Document in PROJECT.md before proposing solutions**
- [ ] **Use git history first** - blame, log, bisect
- [ ] **Find root cause, not symptoms**
- [ ] **Prefer existing solutions** - Check other branches first
- [ ] **Gather evidence** - Logs, stack traces, reproduction steps
- [ ] **Verify assumptions** - Dependencies, imports, file existence

## Investigation Process

### 1. Document First
```markdown
## Investigation: [Issue]

### The Problem
- **What's broken**: [Symptoms]
- **When it occurs**: [Trigger]
- **Environment**: [Branch, version]

### Timeline
- [Time]: [Finding]

### Root Cause
- **Introducing commit**: [hash]
- **Why it broke**: [explanation]
```

### 2. Reproduce and Understand
```bash
# Verify issue exists
[Run failing command/test]

# Check current state
git status && git branch && git log --oneline -5
```

### 3. Find When It Broke
```bash
# Method 1: Blame
git blame -- <file> | grep <relevant-line>

# Method 2: Search history
git log -S "problematic-code" --oneline
git log --grep="keyword" --oneline

# Method 3: Binary search
git bisect start
git bisect bad
git bisect good <known-good>
# Test each commit
```

### 4. Understand Why
```bash
# Examine introducing commit
git show <commit-hash>
git show --stat <commit-hash>

# Compare branches
git diff branch1..branch2 -- <file>

# Check related repos
cd ../related-repo && git log --since="<date>" --oneline
```

### 5. Find Existing Solutions
```bash
# Fixed in other branches?
git log --all --grep="fix.*<issue>"

# Similar fixes?
git log --all -S "similar-pattern"
```

## Problem-Specific Patterns

### Build/Dependency
```bash
git diff <working-branch> -- <dependency-file>
git log -p -- <dependency-file>
```

### Test Failures
```bash
git log -S "test-name" --oneline
git diff <branch> -- <test-file>
```

### Import Errors
```bash
ls -la <path/to/module>
find . -name "*module-name*"
git log --follow -- <file>
```

### Runtime Errors
```bash
grep -r "error-message" .
git log -S "error-line"
```

## Solution Analysis

Document multiple options:
```markdown
#### Option 1: Quick Fix
- **Risk**: Low
- **Effort**: 5 min
- **Trade-off**: Doesn't fix root cause

#### Option 2: Proper Fix
- **Risk**: Medium  
- **Effort**: 1 hour
- **Trade-off**: More testing needed
```

## Quality Checklist
- [ ] Problem clearly defined with reproduction steps
- [ ] Evidence includes concrete outputs
- [ ] Root cause identified (or marked unknown)
- [ ] Multiple solutions evaluated
- [ ] Recommendation includes reasoning

## Common Mistakes

| ❌ Avoid | ✅ Do Instead |
|----------|---------------|
| Jump to solutions | Understand problem first |
| Skip git history | Use blame/log liberally |
| Assume | Verify with commands |
| Patch symptoms | Fix root cause |
| Skip documentation | Document in PROJECT.md |

## Quick Reference

| Problem | First | Second | Third |
|---------|-------|--------|-------|
| Won't build | `git status` | Check deps | `git diff HEAD~1` |
| Test fails | Verbose run | `git blame` | Compare branches |
| Import error | `ls -la` | `find . -name` | Check imports |
| Unknown | `git bisect` | Recent commits | Compare working |
