# Universal Cherry-Pick Safety & Cross-Branch Patterns

## 🎯 Cherry-Picking Golden Rules
- [ ] **Understand before changing** - Always analyze the full scope first
- [ ] **Preserve working functionality** - Don't break existing features
- [ ] **Adapt rather than force** - Work with target branch architecture
- [ ] **Document decisions** - Future maintainers need context
- [ ] **Test incrementally** - Validate changes step by step
- [ ] **Be conservative** - When in doubt, choose lower-risk options
- [ ] **Use tests as specifications** - Failing tests reveal exact requirements
- [ ] **Never accept import changes without verifying modules exist** - Check first
- [ ] **Document all rejected changes with clear reasoning** - Explain why
- [ ] **Prefer functional changes over structural** - Extract value, not architecture
- [ ] **Check import alias patterns** - Same module might use different aliases
- [ ] **Verify in target branch context** - What works in source may not in target

## Pre-Cherry-Pick Analysis

### 1. Understand the Full Scope
```bash
# What does this commit change?
git show <commit-hash>
git show --stat <commit-hash>
git show <commit-hash> -- <specific-file>

# What's the commit history context?
git log --oneline <commit>~5..<commit>+5

# Who made it and why?
git show -s --format='%an <%ae>' <commit>
git log --grep="<related-issue>"
```

### 2. Dependency and Architecture Gap Analysis
```bash
# Compare dependencies between branches
git diff <target-branch>..<source-branch> -- [dependency-file]
# Examples: package.json, requirements.txt, go.mod, pom.xml

# Check if modules/components exist in target
git ls-tree <target-branch> -- <path/to/module>
find . -name "*module-name*"

# Compare import patterns
git show <source-branch>:<file> | grep "import\|require"
git show <target-branch>:<file> | grep "import\|require"

# Check API differences
git diff <target-branch>..<source-branch> -- "*api*" "*interface*"
```

### 3. Risk Assessment
```markdown
## Cherry-Pick Risk Assessment: [Commit]

### Change Classification
- [ ] Functional (business logic, algorithms)
- [ ] Structural (architecture, APIs, patterns)
- [ ] Dependencies (new libraries, versions)
- [ ] Mixed (both functional and structural)

### Compatibility Check
- [ ] Dependencies exist in target branch
- [ ] Import paths valid in target
- [ ] APIs compatible
- [ ] File structure matches
- [ ] Test coverage exists

### Risk Level: [Low/Medium/High]
```

## Cherry-Pick Execution

### Safe Cherry-Pick Process
```bash
# 1. Create safety branch
git checkout <target-branch>
git checkout -b cherry-pick-<feature>-backup

# 2. Attempt cherry-pick
git cherry-pick <commit-hash>

# 3. If conflicts, analyze carefully
git status
git diff
```

### Conflict Resolution Strategy

#### Type 1: Import/Dependency Conflicts
```bash
# Check if import exists in target
ls -la <import-path>
find . -name "*module-name*"

# If not found, options:
# 1. Keep target branch imports (usually safest)
git checkout --ours <file>

# 2. Find equivalent in target branch
grep -r "similar-functionality" .

# 3. Reject this part of cherry-pick
git reset HEAD <file>
git checkout -- <file>
```

#### Type 2: Structural/API Conflicts
```bash
# Compare structures
git show <source-branch>:<file> > /tmp/source-version
git show <target-branch>:<file> > /tmp/target-version
diff /tmp/source-version /tmp/target-version

# Extract functional changes only
# Manual process: keep target structure, add source logic
```

#### Type 3: Test Conflicts
```bash
# Run tests to understand requirements
[Language-specific test command]

# Use test expectations as specification
# Adapt implementation to pass tests
```

### Conservative Resolution Rules

#### Decision Framework
```markdown
When facing conflicts, ask:

1. **Can I extract just the functional improvement?**
   → YES: Extract and adapt
   → NO: Consider if really needed

2. **Does target branch have equivalent functionality?**
   → YES: Enhance existing instead of replacing
   → NO: Can we add without breaking?

3. **Will forcing this break existing features?**
   → YES: Reject or find alternative
   → NO: Proceed with caution

4. **Is there a fix in another branch?**
   → YES: Use that instead
   → NO: Create minimal adaptation
```

#### What to Accept vs Reject

| ✅ Generally Accept | ❌ Generally Reject |
|--------------------|-------------------|
| Bug fixes in logic | Architecture changes |
| New features (isolated) | Import path changes (unverified) |
| Algorithm improvements | API breaking changes |
| Data additions | Dependency updates (unverified) |
| Test additions | File restructuring |
| Documentation updates | Build system changes |

## Validation After Cherry-Pick

### Validation Checklist
```bash
# 1. No conflict markers remain
grep -E "<<<\|===\|>>>" . -R

# 2. Code compiles/interprets
[Language-specific: compile/syntax check]

# 3. Tests pass
[Language-specific: test command]

# 4. Imports resolve
[Language-specific: verify imports]

# 5. Manual functionality test
[Run application, test feature]
```

### Using Tests as Specification
```bash
# When tests fail after cherry-pick
# 1. Read test to understand expectation
cat <test-file> | grep -A 10 -B 10 "failing-test-name"

# 2. Understand what test wants
# - Input data structure
# - Expected output
# - Side effects expected

# 3. Adapt cherry-picked code to meet test expectations
# Not: Change test to match cherry-picked code
```

## Documentation Requirements

### Document in PROJECT.md
```markdown
## Cherry-Pick: [Feature/Fix Name]

### Source
- **Commit**: `<hash>` - "commit message"
- **From Branch**: <source-branch>
- **Author**: <original-author>
- **Date**: <commit-date>

### What Was Cherry-Picked
- [Functional improvement 1]
- [Bug fix 2]
- [Feature 3]

### What Was Adapted
- [Change 1]: Adapted to use target branch patterns
- [Change 2]: Used existing helper instead of new one

### What Was Rejected
- [Structural change 1]: Incompatible with target architecture
- [Import change 2]: Module doesn't exist in target
- [Dependency 3]: Version not available in target

### Validation
- [ ] Tests pass
- [ ] Manual testing complete
- [ ] No regressions identified

### Risk Assessment
- **Risk Level**: [Low/Medium/High]
- **Confidence**: [High/Medium/Low]
- **Follow-up Needed**: [Yes/No - what?]
```

## Common Cherry-Pick Patterns

### Pattern 1: Feature Backport
```bash
# Backporting new feature to older branch
# Usually higher risk due to missing dependencies

# 1. Check feature dependencies
git diff <old-branch>..<new-branch> -- <feature-files>

# 2. Often need to adapt to older patterns
# - Older API versions
# - Different component structure
# - Missing helper functions
```

### Pattern 2: Hotfix Forward-Port
```bash
# Bringing hotfix from production to development
# Usually lower risk

# 1. Check if already fixed differently
git log --grep="<issue>" <target-branch>

# 2. Verify fix still applies
# Development may have refactored the code
```

### Pattern 3: Cross-Feature Cherry-Pick
```bash
# Taking specific improvement from one feature to another
# Medium risk - different contexts

# 1. Understand feature boundaries
git log --oneline -- <feature-directory>

# 2. Extract only the relevant improvement
# Avoid bringing feature-specific logic
```

## Advanced Techniques

### Partial Cherry-Pick
```bash
# Cherry-pick specific files only
git cherry-pick -n <commit>          # No commit
git reset HEAD                       # Unstage all
git add <specific-files>             # Stage only wanted files
git commit

# Cherry-pick with edits
git cherry-pick -n <commit>
# Edit files as needed
git add -p                           # Stage selectively
git commit
```

### Cherry-Pick Ranges
```bash
# Multiple commits
git cherry-pick <commit1>..<commit2>

# If conflicts in range
git cherry-pick --continue          # After resolving
git cherry-pick --abort             # To cancel
```

### Finding What to Cherry-Pick
```bash
# Find commits not in target branch
git log <target>..<source> --oneline

# Find commits touching specific file
git log <source> -- <file> --oneline

# Find fixes for specific issue
git log --all --grep="<issue-id>"
```

## Quick Reference Card

| Scenario | First Check | Safe Approach | Risky Approach |
|----------|-------------|---------------|----------------|
| Import conflict | Module exists? | Keep target imports | Accept source imports |
| API change | Compatible? | Adapt to target API | Force source API |
| Test failure | What's expected? | Meet test expectations | Change tests |
| Structure differs | Can extract logic? | Extract functional only | Force structure |
| Dependency missing | Available in target? | Find alternative | Add dependency |

## Lessons Learned Using This Guide
<!-- Document when forcing structural changes was actually right -->
<!-- Capture patterns in successful cross-version adaptations -->
<!-- Note when conservative approach was too conservative -->
<!-- Record cherry-pick strategies that work for specific scenarios -->
