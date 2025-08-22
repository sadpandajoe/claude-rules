# Universal Investigation & Problem-Solving Workflow

## 🎯 Investigation Golden Rules
- [ ] **Document findings in PROJECT.md before proposing solutions**
- [ ] **Always use git history first** - blame, log, bisect, cross-branch comparison
- [ ] **Find root cause, not symptoms** - Including introducing commit/PR when possible
- [ ] **Prefer existing tested solutions** - Check other branches/commits first
- [ ] **Gather concrete evidence** - Logs, stack traces, reproduction steps
- [ ] **Verify all assumptions** - Dependencies, imports, file existence
- [ ] **Test incrementally** - Small verified changes
- [ ] **Check related repositories** - Root cause may be external
- [ ] **Never use silent error handling** - Always log or propagate

## Investigation Process

### 1. Document in PROJECT.md First
All investigation follows the PROJECT_TEMPLATE.md structure:

```markdown
## Investigation: [Issue Name]

### The Problem
- **What's broken**: [Exact symptoms/error]
- **When it occurs**: [Trigger conditions]
- **Impact**: [What functionality affected]
- **Environment**: [Branch, version, setup]

### Investigation Timeline
- [Time]: Initial discovery - [what found]
- [Time]: Tested hypothesis - [result]
- [Time]: Root cause identified - [finding]
- [Time]: Found introducing commit/PR - [hash/number]

### Root Cause
- **Introducing change**: [commit/PR if found]
- **Why it broke**: [explanation]

### Solutions
[Document options as per planning workflow]
```

### 2. Systematic Investigation Steps

#### Step 1: Reproduce and Understand
```bash
# Verify issue exists
[Run failing command/test]

# Check current state
git status
git branch
git log --oneline -5

# See recent changes
git diff HEAD~1
git diff HEAD~5 --stat
```

#### Step 2: Find When It Broke (Root Cause Analysis)
```bash
# Find introducing commit - Method 1: Blame
git blame -- <file> | grep <relevant-line>

# Method 2: Search history
git log -S "problematic-code" --oneline
git log --grep="related-keyword" --oneline

# Method 3: Binary search
git bisect start
git bisect bad                    # Current is broken
git bisect good <known-good-commit>
# Test each commit git suggests

# Deep commit investigation
git show --stat <commit-hash>     # See all changes
git show <commit-hash>            # Full diff
git log --oneline <commit>~5..<commit>+5  # Context

# Find associated PR (if exists)
git log --grep="Merge pull request.*#" --oneline
```

#### Step 3: Understand Why (Including External Repos)
```bash
# Examine introducing commit
git show <commit-hash>
git show <commit-hash> --stat

# Compare branches
git diff branch1..branch2 -- <file>
git show branch1:<file> | grep <pattern>
git show branch2:<file> | grep <pattern>

# Check related repositories
cd ../related-repo
git log --since="<date-of-issue>" --oneline
git blame -- <related-file>

# Check dependencies changed
git log -p -- [dependency-file]
```

#### Step 4: Find Existing Solutions
```bash
# Check if fixed in other branches
git branch -a --contains <fix-keyword>
git log --all --grep="fix.*<issue>"

# Search for similar fixes
git log --all -S "similar-code-pattern"
grep -r "workaround\|fix\|patch" . | grep -i <issue>
```

### 3. Solution Analysis

#### Document Multiple Options
```markdown
### Solutions

#### Option 1: Quick Fix
- **Approach**: [Description]
- **Risk**: Low - [why safe]
- **Effort**: 5 minutes
- **Pros**: Fast, minimal change
- **Cons**: Doesn't address root cause

#### Option 2: Proper Fix  
- **Approach**: [Description]
- **Risk**: Medium - [what could break]
- **Effort**: 1 hour
- **Pros**: Fixes root cause
- **Cons**: More testing needed

#### Recommendation
[Choose based on context, timeline, risk tolerance]
```

## Investigation Patterns by Problem Type

### Build/Dependency Issues
```bash
# Check dependencies
[Language-specific: package.json, requirements.txt, go.mod, etc.]

# Compare with working branch
git diff <working-branch> -- <dependency-file>

# Check when dependencies changed
git log -p -- <dependency-file>

# Verify installations
[Language-specific: ls node_modules, pip list, go list, etc.]
```

### Test Failures
```bash
# Run specific test with verbose output
[Language-specific test command with debug flags]

# Check when test last passed
git log -S "test-name" --oneline

# Compare test between branches
git diff <branch> -- <test-file>

# Find related test changes
git log --all -- "*test*" | grep -B5 -A5 <test-name>
```

### Import/Module Errors
```bash
# Verify file exists
ls -la <path/to/module>
find . -name "*module-name*"

# Check when moved/renamed
git log --follow -- <file>
git log --all --full-history -- "**/module-name*"

# Compare import patterns
grep -r "import.*module" .
git grep "import.*module" <other-branch>
```

### Runtime Errors
```bash
# Find error in codebase
grep -r "error-message" .

# When was error-producing code added
git log -S "error-producing-line"

# Check error handling
grep -B5 -A5 "catch\|except\|rescue" <file>
```

## Investigation Tools (Universal)

### Version Control Investigation
```bash
# Core investigation commands
git blame <file>                  # Line-by-line last change
git log -S "code"                 # When code added/removed
git log --follow <file>           # File history including renames
git bisect                        # Binary search for bad commit
git reflog                        # Local activity history

# Comparison commands
git diff <ref1>..<ref2>           # Compare commits/branches
git show <ref>:<file>             # View file at specific commit
git log <file>                    # File change history
```

### File System Investigation
```bash
# Search commands (universal)
grep -r "pattern" .               # Search in files
find . -name "pattern"            # Find files
ls -la <path>                     # Check existence/permissions

# Recent changes
find . -type f -mtime -1          # Files modified in last day
find . -newer <reference-file>    # Files newer than reference
```

## Documentation Standards

### Investigation Quality Checklist
- [ ] Problem clearly defined with reproduction steps
- [ ] Timeline shows systematic investigation
- [ ] Evidence includes concrete outputs (not just descriptions)
- [ ] Root cause identified (or explicitly marked unknown)
- [ ] Multiple solutions evaluated with trade-offs
- [ ] Recommendation includes reasoning

### What Makes Good Investigation
- **Reproducible**: Anyone can follow your steps
- **Evidence-based**: Conclusions backed by data
- **Systematic**: Logical progression of hypotheses
- **Complete**: Documents failures and successes
- **Actionable**: Clear next steps or solution

## Common Investigation Mistakes

### ❌ Avoid These
- Jumping to solutions without understanding problem
- Not checking version control history
- Assuming without verifying (file exists, import works)
- Patching symptoms instead of root cause
- Not documenting failed attempts

### ✅ Do These Instead  
- Reproduce first, fix second
- Use `git blame` and `git log` liberally
- Verify every assumption with commands
- Find and fix root cause
- Document everything in PROJECT.md

## Quick Reference Card

| Problem Type | First Command | Second Command | Third Command |
|-------------|---------------|----------------|---------------|
| Won't build | `git status` | Check dependencies | `git diff HEAD~1` |
| Test fails | Run test verbose | `git blame <test>` | Compare branches |
| Import error | `ls -la <path>` | `find . -name` | Check imports |
| Runtime error | Search error message | `git log -S` | Check recent changes |
| Unknown issue | `git bisect` | Review recent commits | Compare with working |

## Lessons Learned Using This Guide
<!-- Document cases where standard investigation wasn't enough -->
<!-- Capture patterns in root cause analysis that work -->
<!-- Note when external repos were the actual cause -->
<!-- Record investigation techniques that proved valuable -->
