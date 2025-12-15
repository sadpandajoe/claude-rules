# Code Review Guidelines

## Core Principles

### 1. DRY (Don't Repeat Yourself)
- "These tests are similar - use parameterized testing"
- "Logic duplicated - extract to shared utility"

### 2. Consistency & Standards
- "Use existing error handling patterns"
- "Follow established naming conventions"
- "Match project architecture patterns"

### 3. Test Quality
- "Tests should not silently pass"
- "Test data should match type hints"
- "Cover edge cases and errors"

## Scoring Framework

| Component | Evaluate | 1-3 | 4-7 | 8-10 |
|-----------|----------|-----|-----|------|
| **Root Cause** | Why issue occurred? | Missing/wrong | Incomplete | Thorough |
| **Solution** | Efficient, maintainable? | Hacky | Reasonable | Clean |
| **Tests** | Realistic, covering? | Missing | Partial | Comprehensive |
| **Code** | Readable, consistent? | Poor | Functional | Clean |
| **Docs** | Clear, complete? | Missing | Partial | Self-explanatory |

### Example
```markdown
| Component | Score | Notes |
|-----------|-------|-------|
| Root Cause | 8 | Traces to PR #123 |
| Solution | 7 | Could reuse utils |
| Tests | 9 | Good parameterization |
| Code | 8 | Consistent |
| Docs | 6 | Needs README |
```

## Severity Tags

| Tag | Meaning | When |
|-----|---------|------|
| **[major]** | Must fix | Logic errors, missing tests, security |
| **[minor]** | Should fix | Naming, DRY, partial docs |
| **[nitpick]** | Optional | Style, micro-optimizations |

```markdown
[major] Missing null validation in update_dataset()
[minor] Inconsistent naming; use snake_case
[nitpick] Could use comprehension
```

## Best Practices

### As Reviewer
1. Focus on maintainability and correctness
2. Suggest specific improvements with examples
3. Explain reasoning
4. Distinguish must-fix vs nice-to-have
5. Reference project standards

### As Reviewee
1. Ask when feedback unclear
2. Implement valuable suggestions
3. Explain reasoning if disagreeing

## Common Patterns

### Testing Issues
| Pattern | Example | Solution |
|---------|---------|----------|
| Consolidation | Similar tests | Parameterized tests |
| Data mismatch | Wrong types | Match signatures |
| Silent pass | Conditional asserts | Explicit skip/assert |

### Code Issues
| Pattern | Example | Solution |
|---------|---------|----------|
| Type safety | Missing hints | Add/fix types |
| Error handling | Inconsistent | Follow patterns |
| N+1 queries | Loop DB calls | Bulk operations |

## Invalid Review Patterns

### Avoid
- Minor formatting (periods, spacing)
- Personal style preferences
- Demanding specific implementation
- Scope creep (unrelated fixes)

## Checklist

### Functionality
- [ ] Does what it should
- [ ] Handles edge cases
- [ ] No obvious bugs

### Testing
- [ ] Covers new functionality
- [ ] Not duplicated
- [ ] Data matches expectations

### Quality
- [ ] Follows conventions
- [ ] No duplication
- [ ] Proper error handling

### Docs
- [ ] Self-documenting or commented
- [ ] API changes documented
- [ ] Breaking changes noted
