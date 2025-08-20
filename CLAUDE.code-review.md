# Code Review Guidelines & Common Patterns

## Core Review Principles

### 1. **DRY (Don't Repeat Yourself) Principle**
Look for duplicate code patterns and suggest consolidation:

**Valid Review Comments:**
- "These test methods are very similar - consider using parameterized testing"
- "This logic is duplicated in multiple files - extract to a shared utility"
- "Multiple similar API endpoints - consider a generic handler"

**How to Address:**
- Use parameterized tests for similar test scenarios
- Extract common functionality to utility functions/classes
- Create generic handlers for similar operations

### 2. **Code Consistency & Standards**
Maintain consistent patterns across the codebase:

**Valid Review Comments:**
- "Use existing error handling patterns instead of creating new ones"
- "Follow the established naming conventions (camelCase vs snake_case)"
- "This component doesn't follow the project's architecture patterns"

**How to Address:**
- Study existing code patterns before implementing new solutions
- Follow established conventions (import order, naming, file structure)
- Use project-specific linters and formatters

### 3. **Test Quality & Coverage**
Ensure tests are production-ready and maintainable:

**Valid Review Comments:**
- "Tests should not silently pass - use explicit skips or assertions"
- "Test data should match the function's type hints and expectations"
- "Consider edge cases and error conditions in test coverage"

**How to Address:**
- Always validate test inputs match API contracts
- Use `pytest.skip()` for unavailable test scenarios
- Add tests for both success and failure paths

## Best Practices for Code Review

### As a Reviewer
1. **Focus on maintainability and correctness**
2. **Suggest specific improvements with examples**
3. **Explain the reasoning behind feedback**
4. **Distinguish between "must fix" and "nice to have"**
5. **Reference project standards and conventions**

### As a Reviewee
1. **Ask questions when feedback is unclear**
2. **Implement suggested improvements when they add value**
3. **Explain reasoning if disagreeing with feedback**

## Common Valid Review Patterns

### Testing-Related Reviews

#### Test Consolidation
```markdown
**Pattern**: "Multiple similar tests can be consolidated"
**Example**: "test_by_id() and test_by_uuid() have nearly identical logic"
**Solution**: Use parameterized testing to reduce duplication
```

#### Test Data Validation
```markdown
**Pattern**: "Test data doesn't match function expectations"
**Example**: "Function expects string but test passes UUID object"
**Solution**: Convert objects to expected types: str(uuid_obj)
```

#### Silent Test Failures
```markdown
**Pattern**: "Test can pass without testing anything"
**Example**: "if obj.attr: test_function(obj.attr)" - passes if attr is None
**Solution**: Use explicit assertions or pytest.skip()
```

### Code Structure Reviews

#### Type Safety
```markdown
**Pattern**: "Missing or incorrect type hints"
**Example**: "Function signature shows 'str' but accepts objects"
**Solution**: Update type hints to match actual usage or fix implementation
```

#### Error Handling
```markdown
**Pattern**: "Inconsistent error handling patterns"
**Example**: "Some functions return None on error, others raise exceptions"
**Solution**: Follow established project patterns for error handling
```

#### Import Organization
```markdown
**Pattern**: "Import order doesn't follow project standards"
**Example**: "Third-party imports before standard library imports"
**Solution**: Use project linters (ruff, isort) to fix import order
```

### Performance & Efficiency

#### Database Queries
```markdown
**Pattern**: "Inefficient database access patterns"
**Example**: "N+1 queries in loop - use bulk operations instead"
**Solution**: Use select_related, prefetch_related, or bulk operations
```

#### Memory Usage
```markdown
**Pattern**: "Unnecessary object creation or retention"
**Example**: "Loading entire dataset when only subset needed"
**Solution**: Use pagination, filtering, or streaming approaches
```

## Invalid or Low-Value Review Patterns

### Minor Formatting Issues
- Missing periods in comments (when not affecting functionality)
- Spacing preferences that don't affect readability
- Personal style preferences not backed by project standards

### Overly Prescriptive Changes
- Demanding specific implementation when multiple valid approaches exist
- Requiring changes that contradict established project patterns
- Asking for optimizations without performance evidence

### Scope Creep
- Requesting unrelated features or improvements
- Asking to fix issues not introduced by the current PR
- Suggesting architectural changes beyond the PR scope

## Code Review Checklist

### Functionality
- [ ] Code does what it's supposed to do
- [ ] Edge cases and error conditions are handled
- [ ] No obvious bugs or logical errors

### Testing
- [ ] Tests cover the new/changed functionality
- [ ] Tests are not duplicated unnecessarily
- [ ] Test data matches function expectations
- [ ] No silent test failures

### Code Quality
- [ ] Follows project conventions and standards
- [ ] No unnecessary code duplication
- [ ] Proper error handling and logging
- [ ] Clear and maintainable code structure

### Documentation
- [ ] Code is self-documenting or properly commented
- [ ] API changes are documented
- [ ] Breaking changes are noted

## Common Superset-Specific Review Patterns

### Backend (Python)
- Type hints on all new functions
- MyPy compliance
- Proper SQLAlchemy usage (avoid N+1 queries)
- Security considerations (SQL injection prevention)

### Frontend (TypeScript)
- No `any` types - use proper TypeScript types
- Use `@superset-ui/core` components instead of direct Ant Design
- Proper error handling and loading states
- Accessibility considerations

### Testing
- Use proper test data types (strings for UUID functions)
- Clean up test data (delete and commit)
- Use realistic fixtures, not hardcoded data
- Both unit and integration test coverage

## Lessons Learned from Recent Reviews

### Test Consolidation Example
- **Initial resistance**: "I prefer separate tests for better failure isolation"
- **Valid reviewer point**: "Tests are nearly identical - DRY principle applies"
- **Resolution**: Parameterized tests achieve both goals - no duplication AND clear failure identification
- **Learning**: Consider reviewer suggestions even if initial instinct is to resist

### Test Data Validation Example
- **Problem**: CI failures due to UUID objects passed to string-expecting functions
- **Valid reviewer insight**: Would have caught this with proper type checking
- **Resolution**: Always validate test inputs match function signatures
- **Learning**: Test data contract violations are common source of failures

These patterns help maintain code quality while fostering collaborative and constructive code reviews.