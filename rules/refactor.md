# Refactoring Guidelines

## 🎯 Refactoring Golden Rules
- [ ] **Tests MUST pass before starting** - No refactoring without safety net
- [ ] **Commit working state first** - Rollback point required
- [ ] **One change at a time** - Atomic, verifiable refactors
- [ ] **No new functionality** - Pure structure changes only
- [ ] **Tests pass after EACH change** - Continuous validation
- [ ] **Behavior unchanged** - Same inputs → same outputs

## When to Refactor

| ✅ Good Time | ❌ Bad Time |
|--------------|-------------|
| Tests passing | Tests failing |
| Before adding feature | During bug fix |
| Pattern emerged (rule of 3) | First instance |
| Clear improvement | Speculative "might help" |
| Time allocated | Under deadline |

## Process

```
1. Document goal in PROJECT.md (why, what improves)
2. Verify test coverage exists for affected code
3. Run tests - must pass
4. Commit: "chore: pre-refactor snapshot"
5. Make ONE atomic change
6. Run tests
   └─ FAIL? Revert, try smaller change
7. Commit: "refactor: [specific change]"
8. Repeat 5-7 until complete
9. Final validation + code review
```

## Safe Techniques

| Technique | When | Risk |
|-----------|------|------|
| **Rename** | Unclear names | Low |
| **Extract function** | Long functions, duplication | Low |
| **Extract class/module** | Class doing too much | Medium |
| **Move** | Wrong location | Medium |
| **Inline** | Over-abstraction | Medium |
| **Change signature** | API improvement | High |

### Extract Function
```bash
# Before: Long function with embedded logic
# After: Smaller functions with clear names
# Validation: Same inputs → same outputs
```

### Rename
```bash
# Find all usages
grep -r "old_name" . --include="*.ext"
# Rename (IDE refactor safest)
# Verify no missed references
grep -r "old_name" . --include="*.ext"  # Should return nothing
```

### Move
```bash
# Document current imports
grep -r "import.*module" . --include="*.ext"
# Move file
# Update all imports
# Run tests
```

## Anti-Patterns

| ❌ Don't | ✅ Do Instead |
|----------|---------------|
| Refactor + add feature | Separate commits |
| Big bang refactor | Incremental changes |
| Refactor without tests | Add tests first |
| Change behavior | Pure structure only |
| Skip commits between changes | Commit each change |

## Delegation to Codex CLI

| ✅ Delegate | ❌ Keep in Claude Code |
|-------------|----------------------|
| Rename across files | Architectural decisions |
| Extract simple function | Design decisions |
| Update import paths | Decide what moves where |
| Mechanical transforms | Logic changes |

## Quick Reference

```bash
# Before starting
git status                    # Clean?
[run tests]                   # Pass?
git commit -m "chore: pre-refactor snapshot"

# After each change
[run tests]                   # Still pass?
git add <changed-files>
git commit -m "refactor: [what changed]"

# If tests fail
git checkout -- .             # Revert
# Try smaller change
```
