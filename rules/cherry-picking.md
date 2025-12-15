# Cherry-Pick & Cross-Branch Patterns

## 🎯 Cherry-Pick Golden Rules
- [ ] **Understand before changing** - Analyze full scope
- [ ] **Preserve working functionality**
- [ ] **Adapt rather than force** - Work with target architecture
- [ ] **Verify imports/modules exist** in target branch
- [ ] **Prefer functional over structural** - Extract value, not architecture
- [ ] **Document decisions** - What accepted, rejected, why

## Pre-Analysis

### 1. Understand the Commit
```bash
git show <hash>
git show --stat <hash>
git log --oneline <hash>~5..<hash>+5
```

### 2. Check Compatibility
```bash
# Compare dependencies
git diff <target>..<source> -- <dependency-file>

# Module exists in target?
git ls-tree <target> -- <path/to/module>
find . -name "*module*"

# Compare imports
git show <source>:<file> | grep "import"
git show <target>:<file> | grep "import"
```

### 3. Risk Assessment
```markdown
### Classification
- [ ] Functional (logic, algorithms)
- [ ] Structural (architecture, APIs)
- [ ] Dependencies (libraries)

### Compatibility
- [ ] Dependencies exist in target
- [ ] Import paths valid
- [ ] APIs compatible

### Risk: [Low/Medium/High]
```

## Execution

### Safe Process
```bash
# 1. Safety branch
git checkout <target>
git checkout -b cherry-pick-backup

# 2. Attempt
git cherry-pick <hash>

# 3. If conflicts
git status
git diff
```

### Conflict Resolution

#### Import Conflicts
```bash
ls -la <import-path>              # Exists?
git checkout --ours <file>        # Keep target (usually safer)
```

#### Structural Conflicts
```bash
# Compare versions
git show <source>:<file> > /tmp/source
git show <target>:<file> > /tmp/target
diff /tmp/source /tmp/target

# Extract functional changes only
# Keep target structure, add source logic
```

### Decision Framework
```
Can I extract just functional improvement?
  YES → Extract and adapt
  NO  → Consider if needed

Does target have equivalent?
  YES → Enhance existing
  NO  → Add without breaking

Will forcing this break existing?
  YES → Reject or find alternative
  NO  → Proceed with caution
```

### Accept vs Reject

| ✅ Accept | ❌ Reject |
|-----------|----------|
| Bug fixes | Architecture changes |
| Isolated features | Unverified imports |
| Algorithm improvements | Breaking API changes |
| Test additions | Build system changes |
| Documentation | File restructuring |

## Validation

```bash
grep -E "<<<\|===\|>>>" . -R      # No conflict markers
[compile/lint]                     # Builds
[run tests]                        # Tests pass
[manual test]                      # Feature works
```

## Documentation

```markdown
## Cherry-Pick: [Name]

### Source
- Commit: `<hash>`
- Branch: <source>

### Accepted
- [What was cherry-picked]

### Adapted  
- [What was modified for target]

### Rejected
- [What was excluded and why]
```

## Advanced

### Partial Cherry-Pick
```bash
git cherry-pick -n <hash>         # No commit
git reset HEAD                    # Unstage all
git add <specific-files>          # Stage wanted
git commit
```

### Cherry-Pick Range
```bash
git cherry-pick <start>..<end>
git cherry-pick --continue        # After resolving
git cherry-pick --abort           # Cancel
```

## Quick Reference

| Conflict | Check | Safe | Risky |
|----------|-------|------|-------|
| Import | Module exists? | Keep target | Accept source |
| API | Compatible? | Adapt to target | Force source |
| Test fails | What expected? | Meet expectations | Change tests |
| Structure | Can extract logic? | Functional only | Force structure |
