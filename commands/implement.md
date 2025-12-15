# /implement - Implementation Workflow

Write code using TDD approach.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/implementation.md` - Implementation-specific rules
3. `rules/testing.md` - TDD and test rules

Do not proceed until rules are read and understood.

---

## Steps

1. **Pre-Implementation Check**
   - [ ] Plan exists and scored 8/10? (run `/plan` first if not)
   - [ ] Codebase understood?
   - [ ] Existing patterns studied?
   - [ ] Dependencies verified?

2. **Study Existing Patterns**
   ```bash
   # Find similar implementations
   grep -r "similar-feature" .
   find . -name "*related*" -type f
   
   # Check conventions
   head -30 <similar-file>
   ```

3. **TDD Cycle**
   
   **RED** - Write failing test first
   ```markdown
   ### Development Log
   [Timestamp]: Writing test for [feature]
   - Test: [what it tests]
   - Expected: [behavior]
   ```
   
   **GREEN** - Minimal code to pass
   ```markdown
   [Timestamp]: Implementing to pass test
   - Approach: [what you're doing]
   ```
   
   **REFACTOR** - Improve while green
   ```markdown
   [Timestamp]: Refactoring
   - Tests still passing: Yes
   - Changes: [what improved]
   ```

4. **Implementation Standards**
   - Functions ≤20 lines (guideline)
   - Files ≤300 lines
   - Nesting ≤2 levels
   - Match existing patterns
   - YAGNI - only what's needed now

5. **Safe Commits**
   ```bash
   # Review changes
   git diff
   git status
   
   # Check for debug code
   grep -r "TODO\|FIXME\|console\|debug\|print" .
   
   # Stage individually (NEVER git add -A)
   git add <specific-file>
   
   # Commit
   git commit -m "feat: [description]"
   ```

6. **Trigger Code Review**
   After implementation complete:
   ```
   "Implementation complete. Running /review to validate..."
   ```
   
   Automatically run `/review` to iterate until 8/10.

## Commit Message Format
```
type: brief description

- Specific change 1
- Specific change 2

[Fixes #issue]
```
Types: feat, fix, docs, style, refactor, test, chore

## Notes
- Working solution first, then optimize
- Commit working states before refactoring
- Test as you go, not at the end
- Code review must pass 8/10 before done
