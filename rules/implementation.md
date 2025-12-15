# Implementation & Code Development

## 🎯 Implementation Golden Rules
- [ ] **Understand codebase** before writing code
- [ ] **Plan tests before implementation** - TDD
- [ ] **Follow existing patterns** - Consistency over creativity
- [ ] **Update existing code** before creating new
- [ ] **Working solution before optimization**
- [ ] **Commit working states** - Safe rollback points
- [ ] **NEVER use `git add -A` or `git add .`** - Add only YOUR files
- [ ] **YAGNI** - Build only what's needed now

## Pre-Implementation

### Before Writing Code
- [ ] Deep codebase understanding
- [ ] Requirements clear (ask if not)
- [ ] Existing patterns studied
- [ ] Approach planned in PROJECT.md
- [ ] Dependencies verified

### Pattern Discovery
```bash
grep -r "similar-feature" .           # Find similar code
find . -name "*similar*" -type f      # Find related files
head -20 <similar-file>               # See conventions
```

## Code Standards

### Structure Guidelines
- Functions: ≤20 lines (guideline)
- Files: ≤300 lines
- Nesting: ≤2 levels (use early returns)
- Names: Descriptive > clever

### Best Practices
| ✅ Do | ❌ Don't |
|-------|---------|
| Follow existing patterns | Create new patterns |
| Early returns | Deep nesting |
| Handle errors explicitly | Silent catches |
| Small, focused commits | Large commits |
| Add files individually | `git add -A` |

## TDD Workflow

```
1. RED   - Write failing test
2. GREEN - Minimal code to pass
3. REFACTOR - Improve, keep green
```

### Development Log
```markdown
[Time]: Writing test for [feature]
[Time]: Test failing - implementing
[Time]: Test passing - committing
[Time]: Refactoring - tests still green
```

## Implementation Steps

1. **Scaffold** - Basic structure, stubs
2. **Core Logic** - Happy path
3. **Error Handling** - Edge cases
4. **Testing** - Verify
5. **Commit** - Save working state
6. **Optimize** - Only after committed

## Dependency Management

```bash
# Verify exists
ls -la <path/to/dependency>

# Already used in project?
grep -r "dependency-name" .

# NEVER modify
.git/  node_modules/  vendor/  build/  dist/
```

## Commit Strategy

### Safe Staging
```bash
# Review changes
git diff
git status

# Add individually (NEVER git add -A)
git add <specific-file>
git add -p                    # Stage selectively

# Verify
git status
```

### Message Format
```
type: brief description

- Specific change 1
- Specific change 2

[Fixes #issue]
```
Types: feat, fix, docs, style, refactor, test, chore

## Validation

```bash
# Code quality
grep -r "TODO\|FIXME" .       # Incomplete work
grep -r "console\|debug" .    # Debug code
grep -E "<<<|===|>>>" .       # Conflict markers
```

## Quick Reference

| Task | Before | During | After |
|------|--------|--------|-------|
| New feature | Study patterns, write test | TDD cycle | Validate, commit |
| Bug fix | Root cause | Minimal change | Test thoroughly |
| New file | Check structure | Follow conventions | Update imports |
