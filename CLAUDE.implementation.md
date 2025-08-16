# Implementation & Code Development Workflow

## Pre-Implementation Planning

### Before Starting Any Work
- [ ] Review all project documentation (PRDs, README, architecture docs, existing tasks)
- [ ] Clarify any unclear requirements before proceeding  
- [ ] Define goals, success criteria, and definition of done
- [ ] Document the plan in PROJECT.md before starting implementation
- [ ] Study existing codebase patterns and conventions

## Code Quality Standards

### Code Architecture Guidelines
- **File Organization**: Keep files ≤ 300 lines for maintainability
- **Function Design**: Keep functions ≤ 20 lines when practical  
- **Control Flow**: Use early returns, avoid deep nesting (≤2 levels)
- **Error Handling**: Handle errors gracefully, never use silent catches
- **DRY Principle**: Consolidate similar components, don't duplicate logic
- **Separation of Concerns**: Don't mix UI and business logic
- **Modular Design**: Design components for testability and reusability

### Code Quality DO/DON'T Reference

| ✅ DO | ❌ DON'T |
|-------|---------|
| Use DRY and consolidate similar components | Duplicate logic across files |
| Follow modular design principles | Mix UI and business logic |
| Use early returns (≤2 nesting levels) | Create deeply nested blocks |
| Handle errors gracefully with context | Use silent catches or generic errors |
| Refactor with clear purpose and reasoning | Refactor without clear objectives |
| Design for testability from the start | Hard-code dependencies |
| Modify existing code directly when possible | Create temporary or duplicate versions |
| Use descriptive variable and function names | Use unclear abbreviations or names |

### Following Existing Patterns

#### Before Making Any Changes
```bash
# Study existing codebase patterns
grep -r "similar-pattern" src/
find . -name "*SimilarComponent*" -type f

# Check component interfaces and conventions
grep -A 10 "interface\|type\|class" src/components/ComponentName/
cat src/components/SimilarComponent/index.* | head -20

# Examine file organization patterns
ls -la src/components/ src/utils/ src/services/
```

#### Pattern Matching Guidelines
- **Match existing indentation** and formatting exactly
- **Follow existing import styles** and organization patterns
- **Use existing utility functions** over creating new ones
- **Prefer editing existing files** over creating new ones when possible
- **Use consistent naming conventions** with the rest of the codebase
- **Follow established architectural patterns** in the project

### Dependency Management

#### Validate Before Using
```bash
# Verify imports/modules exist before using them
ls -la path/to/expected/module
find . -name "*ModuleName*" -type f

# Check if packages/dependencies are available
grep "package-name" package.json         # Node.js projects
import module_name                       # Python (test in REPL)
go list -m module-name                   # Go projects

# Verify component/API availability
grep -A 5 "propName\|methodName" src/components/*/types.*
```

#### Dependency Protection Rules
- **NEVER modify read-only dependencies** (submodules, vendor directories)
- **Check if file path is within protected directory** before suggesting changes
- **Treat external dependencies as immutable** 
- **For protected code changes**, recommend upstream modifications
- **Never stage or commit changes** to protected/generated content

## Implementation Workflow

### Working Solution First Rule

**Critical**: Always complete and commit a working solution before suggesting any refactors or optimizations

```bash
# Complete the working solution
git add .
git commit -m "feat: implement [feature] - working solution

- Core functionality implemented  
- Tests passing
- Basic requirements met

Ready for optimization/refactoring if needed"
```

**Why this matters**:
- Creates a safe rollback point if optimizations break things
- Ensures functional requirements are met first
- Provides working baseline for comparison
- Reduces risk when making improvements

#### After Working Solution is Committed

Only then consider:
- Code optimizations and performance improvements
- Refactoring for cleaner code structure
- Additional features or enhancements
- Architectural improvements

Each optimization should also be committed separately for easy rollback.

### During Implementation

#### Incremental Development
- [ ] Make small, testable changes
- [ ] Validate each significant change before proceeding
- [ ] Commit working states frequently with clear messages
- [ ] Update PROJECT.md Development Log with progress and discoveries

#### Code Integration
- [ ] Follow existing architectural patterns consistently
- [ ] Use established utility functions and helpers
- [ ] Maintain consistent error handling approaches
- [ ] Preserve existing component interfaces when possible
- [ ] Test integration points between new and existing code

### File Organization Standards

#### When Creating New Files
```bash
# Study existing project structure
find . -type d -name "*" | head -20        # Directory organization
ls -la src/ lib/ app/ | head -10           # Common source directories  
find . -name "*.*" | head -20              # File naming patterns

# Identify naming conventions from existing files
ls -la */                                  # Directory naming style
find . -name "*Component*" -o -name "*Service*" -o -name "*Utils*" | head -10

# Check file extension patterns
find . -name "*.*" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
```

#### File Organization Guidelines
- **Follow existing directory structure** - don't create new top-level directories without reason
- **Match naming conventions** - study existing file names for patterns
- **Use consistent file extensions** - match what the project already uses
- **Group related functionality** - put files where similar files already exist

#### When Modifying Existing Files
- [ ] Maintain existing import order and grouping
- [ ] Follow established function organization within files
- [ ] Keep consistent indentation and spacing
- [ ] Preserve existing comment styles and documentation patterns

## Code Validation

### Standard Validation Steps
```bash
# Check if project has validation scripts
cat package.json | grep -A 10 "scripts"   # Node.js projects
cat Makefile | grep test                  # Make-based projects
ls -la tox.ini pytest.ini                # Python projects

# Run available validation commands
[lint-command]                            # Code linting (if available)
[type-check-command]                      # Type checking (if available)  
[test-command]                            # Run test suite (if available)

# Manual checks when tools unavailable
grep -E "<<<|===|>>>" **/*.* # Check for merge conflicts
find . -name "*.ext" | xargs grep "console.log\|debugger\|print\|fmt.Print"
```

#### Final Validation Checklist
- [ ] All tests pass (if test suite available)
- [ ] No linting errors (if linter available)
- [ ] Type checking passes (if type system used)
- [ ] No merge conflict markers remain
- [ ] No debug code or logging statements left in
- [ ] All imports resolve correctly
- [ ] Code follows existing patterns and conventions

### Manual Testing Guidelines

When automated tests aren't available:
- [ ] Test happy path functionality thoroughly
- [ ] Verify error conditions behave correctly
- [ ] Check edge cases and boundary conditions
- [ ] Validate user interaction flows (for UI changes)
- [ ] Test in different environments if applicable
- [ ] Document test steps for future reference

## Error Handling Strategy

### Consistent Error Handling Patterns
```javascript
// Example: Graceful error handling with context
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  console.error('Operation failed:', error.message, { context: additionalInfo });
  // Handle gracefully - don't let errors crash the application
  return fallbackValue || null;
}
```

### Error Handling Guidelines
- **Never use silent catches** - always log or handle errors
- **Provide meaningful error messages** with context
- **Use appropriate fallback strategies** for different error types
- **Log stack traces** for debugging in development
- **Handle errors at appropriate levels** - don't catch too early or too late

## Documentation and Communication

### Code Documentation Standards
- **Comments**: Only for complex business logic, never for obvious code
- **README Updates**: Keep project documentation current with changes
- **API Documentation**: Update when interfaces or contracts change
- **Migration Guides**: Document breaking changes and upgrade paths

### Implementation Communication
- **Explain reasoning** behind code suggestions and architectural decisions
- **Show multiple approaches** when relevant with pros/cons
- **Include error handling** in examples and recommendations
- **Provide full context** of changes being made
- **Focus on practical, implementable solutions**

### Commit Documentation
```markdown
## Commit Message Template

[type]: Brief description of what changed

- Specific change 1
- Specific change 2  
- Why this approach was chosen

[Include reasoning for non-obvious decisions]
```

## Advanced Implementation Patterns

### Component Integration Patterns
- **Interface Design**: Define clear, well-typed interfaces
- **State Management**: Use existing state patterns in codebase
- **Event Handling**: Follow established event naming conventions
- **Styling**: Use existing CSS/styling approaches consistently

### Performance Considerations
- **Optimize after working solution** - functionality first, performance second
- **Profile before optimizing** - measure actual bottlenecks
- **Consider maintainability** - don't sacrifice readability for minor gains
- **Document performance decisions** - explain trade-offs made

## Lessons Learned

### Implementation Patterns That Work
<!-- Add successful implementation strategies discovered through experience -->

### Common Implementation Pitfalls
<!-- Add mistakes to avoid during implementation -->

### Code Quality Improvements
<!-- Add quality practices that consistently work well -->

### Refactoring Strategies
<!-- Add effective approaches to improving existing code -->