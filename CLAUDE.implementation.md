# Universal Implementation & Code Development Workflow

## 🎯 Implementation Golden Rules
- [ ] **Understand codebase and related codebases thoroughly** before writing code
- [ ] **Plan all tests before implementation** - TDD approach
- [ ] **Study and follow existing patterns** - Consistency over creativity
- [ ] **Update/extend existing code before creating new** - Modify functions vs new ones
- [ ] **Complete working solution before optimization** - Functionality first
- [ ] **Use conservative, proven approaches** when possible
- [ ] **Commit working states before refactoring** - Safe rollback points
- [ ] **Keep code simple and maintainable** - Functions ≤20 lines, files ≤300 lines
- [ ] **NEVER modify protected/generated directories** - vendor, node_modules, build
- [ ] **NEVER use `git add -A` or `git add .`** - Add only files YOU modified
- [ ] **YAGNI** - Build only what's needed now, not future possibilities

## Pre-Implementation Checklist

### Before Writing Any Code
- [ ] **Deep understanding of codebase** - How components interact, data flows
- [ ] **Understand related/dependent codebases** - External services, libraries
- [ ] Read project documentation (README, docs, comments)
- [ ] Understand requirements completely (ask if unclear)
- [ ] Study existing codebase patterns
- [ ] Plan approach in PROJECT.md
- [ ] Identify dependencies and verify availability
- [ ] **Look for existing code to update/extend** before creating new

### Pattern Discovery Commands
```bash
# Study existing patterns
grep -r "similar-feature" .          # Find similar implementations
find . -name "*similar*" -type f     # Find related files
ls -la src/ lib/ app/                # Understand structure

# Check conventions
head -20 <similar-file>              # See file organization
grep -A5 "function\|class\|def" <file>  # See naming patterns

# Understand dependencies  
[Language-specific: package.json, go.mod, requirements.txt, pom.xml]
```

## Code Quality Standards (Universal)

### Structure Guidelines
- **Functions**: ≤20 lines when practical (readability > rigid rules)
- **Files**: ≤300 lines for maintainability
- **Nesting**: ≤2 levels deep (use early returns)
- **Names**: Descriptive > clever (future you will thank you)

### Universal Best Practices
| ✅ DO | ❌ DON'T |
|-------|---------|
| Follow existing patterns | Create new patterns unnecessarily |
| Use early returns | Deep nesting (>2 levels) |
| Handle errors explicitly | Silent catches or ignored errors |
| Write self-documenting code | Over-comment obvious code |
| Validate inputs | Assume inputs are valid |
| Create small, focused commits | Large, multi-purpose commits |
| Test as you go | Leave testing until end |
| Add files individually | Use `git add -A` or `git add .` |

## Implementation Workflow

### Step 1: Test-Driven Development (TDD)
```markdown
## TDD Cycle
1. **RED** - Write failing test for new functionality
2. **GREEN** - Write minimal code to make test pass
3. **REFACTOR** - Improve code while keeping tests green

## Development Log Example
[Time]: Writing test for [feature]
[Time]: Test failing as expected - implementing
[Time]: Test passing with minimal implementation
[Time]: Refactoring for clarity - tests still green
```

### Step 2: Match Existing Patterns
```bash
# Before creating new file - can we add to existing?
grep -r "similar-functionality" .
find . -name "*related*" -type f

# Before creating new function - can we extend existing?
grep -A10 "function\|def\|class" <file> | grep similar
# Consider: Can existing function be parameterized?
# Consider: Can we add to existing function?

# Before adding function
grep -A10 "function\|def\|class" <similar-file>  # See conventions
grep "export\|public\|private" <file>  # Understand visibility patterns

# Before imports/dependencies
grep "import\|require\|include\|use" <similar-file>  # Match import style
ls -la <expected-module-path>        # Verify module exists
```

### Step 3: Incremental Development

#### YAGNI Principle
- **Build only what's needed NOW** - Not what might be needed
- **No speculative features** - Wait for actual requirements
- **Simple > Complex** - Start simple, complexify only when proven necessary
- **Delete unused code** - Don't keep "just in case" code

#### The Working Solution First Rule
```markdown
## Development Log
[Time]: Starting implementation of [feature]
[Time]: Basic structure complete - testing
[Time]: Core functionality working - committing before optimization
[Time]: Committed working solution - now optimizing
```

#### Implementation Progression
1. **Scaffold** - Basic structure, interfaces, stubs
2. **Core Logic** - Main functionality, happy path
3. **Error Handling** - Edge cases, validation
4. **Testing** - Verify it works
5. **Commit** - Save working state
6. **Optimize** - Only after working + committed

### Step 4: Validation Strategy

#### Universal Validation Checks
```bash
# Code quality
grep -r "TODO\|FIXME\|XXX" .         # Find incomplete work
grep -r "console\|print\|debug" .    # Find debug code

# Structure issues  
find . -name "*.tmp" -o -name "*.bak"  # Find temporary files
grep -E "^[[:space:]]*$" <file> | wc -l  # Count blank lines

# Common problems
grep -E "<<<|===|>>>" .              # Merge conflicts
```

#### Language-Specific Validation
```bash
# Add project-specific validation commands in project CLAUDE.md
# Examples:
# - JavaScript: npm run lint
# - Python: flake8, black --check
# - Go: go fmt, go vet
# - Java: mvn compile
```

## Dependency Management

### Before Using Any Dependency
```bash
# Verify it exists
ls -la <path/to/dependency>
find . -name "*dependency-name*"

# Check if already used in project
grep -r "dependency-name" . --include="*.ext"

# Verify version compatibility
[Language-specific: check dependency file]
```

### Protected Directories Check
```bash
# NEVER modify these
ls -la .git/                         # Git internals
ls -la node_modules/                 # Dependencies
ls -la vendor/                       # Third-party code
ls -la build/ dist/ out/             # Generated files

# Check before modifying
git ls-files <file>                  # Is it tracked?
git submodule status                 # Is it a submodule?
```

### Import/Module Best Practices
- **Match existing import style** (relative vs absolute)
- **Group imports** like existing files
- **Order imports** consistently
- **Avoid circular dependencies**

## Error Handling Patterns

### Universal Error Handling
```
# Pseudocode - adapt to your language

TRY operation
CATCH error
  LOG error with context
  HANDLE gracefully
  RETURN safe default OR
  PROPAGATE with context
END
```

### Error Handling Checklist
- [ ] All errors caught or propagated intentionally
- [ ] Error messages include context
- [ ] Graceful degradation where appropriate
- [ ] No silent failures
- [ ] Appropriate error types/codes

## Code Organization

### File Organization Rules
1. **Follow existing structure** - Don't reorganize without reason
2. **Related code together** - High cohesion
3. **Clear naming** - File name describes content
4. **Consistent patterns** - Similar files organized similarly

### When Creating New Files
```bash
# Study existing organization
tree -d -L 2 .                      # See directory structure
ls -la src/                          # Check naming patterns
find . -type f -name "*.ext" | head -20  # See file conventions

# Choose location
# - Near similar functionality
# - In appropriate directory
# - Following naming convention
```

## Commit Strategy

### Safe Staging Rules
- **NEVER use `git add -A` or `git add .`** - Adds unintended files
- **Add files individually** - `git add <file1> <file2>`
- **Use `git add -p` for partial staging** - Review each change
- **Check `git status` before committing** - Verify only intended files
- **If you didn't modify it, don't stage it** - Even if it appears changed

### Commit Best Practices
```bash
# Before committing
git diff                             # Review changes
git status                           # Check what's staged

# Remove debug code
git diff | grep "console\|debug\|print"

# CRITICAL: Add only files YOU modified
git add <specific-file>              # Add individual files
git add -p                           # Stage selectively with review
# NEVER use git add -A or git add .  # Can add unintended files

# Commit incrementally
git commit -m "type: description"   # Clear message
```

### Commit Message Format
```
type: brief description

- Specific change 1
- Specific change 2
- Why this approach (if not obvious)

[Fixes #issue] [References #issue]
```

Types: feat, fix, docs, style, refactor, test, chore

## Testing During Implementation

### Test-As-You-Go Strategy
1. **Unit** - Test individual functions as written
2. **Integration** - Test component interactions
3. **Manual** - Verify user-facing behavior
4. **Edge Cases** - Test boundaries and errors

### Quick Testing Patterns
```bash
# Manual testing approach
# 1. Add temporary test code
# 2. Run and verify
# 3. Remove test code before commit

# Find test files
find . -name "*test*" -o -name "*spec*"

# Run tests if available
[Language-specific test command]
```

## Refactoring Guidelines

### When to Refactor
- **After working solution committed** - Never before
- **When patterns emerge** - Rule of three
- **Before adding complexity** - Clean base
- **When understanding improves** - Better approach clear

### Safe Refactoring Process
1. Ensure tests pass (or manual verification complete)
2. Commit current working state
3. Make single refactoring change
4. Verify still works
5. Commit refactoring separately

## Documentation Standards

### Code Documentation
- **Document WHY, not WHAT** - Code shows what
- **Complex business logic** - Explain the reasoning
- **Non-obvious decisions** - Why this approach
- **External dependencies** - Why needed
- **Workarounds** - Why and temporary nature

### Documentation Locations
- **PROJECT.md** - Implementation decisions, approaches
- **Code comments** - Why, not what
- **Commit messages** - What changed and why
- **README** - How to use/build/test

## Quick Reference Card

| Task | Before Starting | During | After |
|------|----------------|---------|--------|
| New feature | Study patterns, write test | TDD cycle, incremental | Validate & commit |
| Bug fix | Understand root cause | Minimal change | Test fix thoroughly |
| Refactoring | Commit working state | Single purpose changes | Verify still works |
| New file | Check existing structure | Follow conventions | Update imports/exports |
| Dependencies | Verify availability | Match usage patterns | Document if new |
| Staging | Check what you modified | Add files individually | Verify with git status |

## Lessons Learned Using This Guide
<!-- Document when creating new was better than updating existing -->
<!-- Capture patterns in how to extend vs replace code -->
<!-- Note when YAGNI principle was violated and why -->
<!-- Record implementation patterns that proved valuable -->
