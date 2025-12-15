# /refactor - Refactoring Workflow

Improve code structure without changing behavior.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/refactor.md` - Refactoring-specific rules

Do not proceed until rules are read and understood.

---

## Steps

1. **Pre-Refactor Checklist**
   - [ ] Tests exist for affected code?
   - [ ] All tests passing?
   - [ ] Clear goal for refactoring?
   - [ ] NOT under deadline pressure?

2. **Document Goal**
   ```markdown
   ## Refactoring: [What]
   
   ### Goal
   - **Why**: [Reason for refactoring]
   - **What improves**: [Specific improvements]
   - **Success criteria**: [How we know it's better]
   
   ### Affected Code
   - [File/module 1]
   - [File/module 2]
   ```

3. **Create Safety Point**
   ```bash
   # Verify tests pass
   [run tests]
   
   # Commit current state
   git add <files>
   git commit -m "chore: pre-refactor snapshot"
   ```

4. **Refactor Loop**
   
   For each atomic change:
   ```
   1. Plan single change
   2. Make the change
   3. Run tests
      └─ FAIL? → git checkout -- . (revert, try smaller)
      └─ PASS? → Continue
   4. Commit: "refactor: [specific change]"
   5. Repeat
   ```

5. **Safe Techniques**
   | Technique | Risk | Notes |
   |-----------|------|-------|
   | Rename | Low | Use IDE refactor |
   | Extract function | Low | Keep same behavior |
   | Extract class | Medium | Watch dependencies |
   | Move | Medium | Update all imports |
   | Inline | Medium | May lose abstraction |
   | Change signature | High | Affects callers |

6. **Validation**
   ```bash
   # All tests pass
   [run tests]
   
   # No behavior change
   # Same inputs → same outputs
   
   # Code review
   git diff <pre-refactor-commit>..HEAD
   ```

7. **Trigger Review**
   ```
   "Refactoring complete. Running /review to validate..."
   ```

## Anti-Patterns
- ❌ Refactor + new feature together
- ❌ Big bang (all at once)
- ❌ Without tests
- ❌ Changing behavior
- ❌ Skipping commits between changes

## Notes
- Tests MUST pass before starting
- One change at a time
- Commit after each change
- No new functionality
