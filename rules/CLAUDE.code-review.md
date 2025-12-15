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

**Common Resistance:** "I prefer separate tests for better failure isolation"  
**Counter:** Parameterized tests achieve both goals - no duplication AND clear failure identification

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

### 4. **Extend Rather Than Create New**
Reduce tech debt by building on existing code:

**Valid Review Comments:**
- "This functionality already exists in utils.ts - can we extend that instead?"
- "Consider adding a parameter to the existing function rather than creating a duplicate"
- "This pattern is similar to what's in module X - can we consolidate?"

**How to Address:**
- Search for existing similar functionality before creating new
- Parameterize existing functions to handle new cases
- Refactor common code into shared utilities
- Consolidate similar patterns to reduce maintenance burden

**Impact:** Adding optional parameters to existing functions vs creating duplicates significantly reduces maintenance burden and tech debt

---

## Review Scoring Framework

Each reviewed PR should include a **component breakdown** scored **1–10** for clarity, quality, and completeness.

| **Component** | **What to Evaluate** | **Score Meaning (1–10)** |
|----------------|----------------------|---------------------------|
| **Root Cause Analysis** | Does the PR clearly explain *why* the issue occurred? Is the reasoning sound and traceable to commits, logs, or design flaws? | **1–3**: Missing or incorrect cause<br>**4–7**: Some reasoning but incomplete<br>**8–10**: Thorough and validated RCA |
| **Solution Quality** | Is the chosen solution efficient, maintainable, and aligned with project architecture? | **1–3**: Hacky or temporary fix<br>**4–7**: Reasonable but not ideal<br>**8–10**: Clean, scalable, follows DRY & standards |
| **Test Coverage & Accuracy** | Are tests realistic, type-safe, and covering success/failure paths? | **1–3**: Missing or superficial tests<br>**4–7**: Partial coverage, edge cases missing<br>**8–10**: Comprehensive, correct, maintainable |
| **Code Implementation** | Is code readable, consistent, and performant? Follows established project conventions? | **1–3**: Poor structure or duplication<br>**4–7**: Functional but inconsistent<br>**8–10**: Clean, typed, idiomatic implementation |
| **Security** | Are there vulnerabilities? Input validation, auth checks, data exposure, injection risks? | **1–3**: Critical security issues<br>**4–7**: Minor concerns or missing validation<br>**8–10**: Security best practices followed |
| **Performance** | Are there performance impacts? N+1 queries, memory leaks, inefficient algorithms? | **1–3**: Significant performance issues<br>**4–7**: Some concerns, could be optimized<br>**8–10**: Optimized and efficient |
| **Tech Debt** | Does this introduce or reduce tech debt? Code duplication, outdated patterns, workarounds, extend vs create? | **1–3**: Increases debt significantly<br>**4–7**: Neutral or minor debt<br>**8–10**: Reduces existing debt |
| **Documentation & Clarity** | Are docstrings, PR descriptions, and change logs clear and complete? | **1–3**: Missing or unclear<br>**4–7**: Partially described<br>**8–10**: Self-explanatory, follows template |

**Example PR Scoring:**
```markdown
| Component | Score | Notes |
|------------|-------|--------|
| Root Cause | 8 | Clear, traces back to PR #123 |
| Solution | 7 | Works but could reuse shared utils |
| Tests | 9 | Excellent parameterization |
| Code | 8 | Consistent with existing modules |
| Security | 9 | Proper input validation |
| Performance | 7 | Could optimize database queries |
| Tech Debt | 8 | Extends existing rather than duplicating |
| Docs | 6 | Needs README update |
```

---

## Feedback Severity Levels

| **Tag** | **Meaning** | **When to Use** |
|----------|--------------|----------------|
| **[major]** | Must be fixed before merge | Logical errors, missing tests, type mismatches, security risks, performance regressions, critical bugs |
| **[minor]** | Should be fixed before merge unless time-critical | Inconsistent naming, DRY violations, partial documentation gaps, minor performance issues |
| **[nitpick]** | Optional improvements | Readability, style preferences, micro-optimizations |

**Examples:**
```markdown
[major] Missing validation for null inputs in `update_dataset()` - security risk
[major] N+1 query in loop will cause performance issues at scale
[minor] Inconsistent variable naming; use `snake_case` for functions
[minor] This duplicates functionality in utils.py - consider extending existing
[nitpick] Could simplify by using a comprehension instead of a loop
```

---

## Review Patterns by Category

### Security

| Pattern | Example | Solution |
|---------|---------|----------|
| Input validation missing | API endpoint accepts unsanitized HTML/SQL | Validate and sanitize all user inputs; use parameterized queries |
| Missing auth checks | Any user can delete resources | Add authorization before sensitive operations |
| Data exposure | Passwords/tokens in logs | Sanitize logs; return only necessary data |
| Injection vulnerability | String concat in SQL/shell | Use parameterized queries/safe APIs |

**Critical Learning:** Unsanitized user input in SQL queries is a common vulnerability. Always use parameterized queries with proper input validation. Never trust client-side data.

### Performance

| Pattern | Example | Solution |
|---------|---------|----------|
| N+1 queries | Loop fetches related records individually | Use bulk operations, joins, prefetch |
| Inefficient algorithm | Nested loops = O(n²) for large datasets | Use hash maps, sets, better algorithms |
| Memory waste | Loading entire dataset into memory | Use pagination, streaming, generators |
| Missing caching | Same computation repeated in hot path | Cache results, memoize functions |

### Tech Debt

| Pattern | Example | Solution |
|---------|---------|----------|
| Code duplication | Same validation in 5 endpoints | Extract to shared utility/middleware |
| Create vs extend | New formatter when existing could work | Add parameter to existing function |
| Workarounds | setTimeout hack for race condition | Document tech debt; fix root cause |
| Outdated patterns | Old callback API vs promise-based | Migrate to modern patterns |

### Testing

| Pattern | Example | Solution |
|---------|---------|----------|
| Similar tests | test_by_id() and test_by_uuid() identical | Use parameterized testing |
| Wrong test data | Function expects string, test passes UUID | Convert to expected types |
| Silent failures | `if obj.attr: test()` passes if None | Use explicit assertions or skip |

### Code Structure

| Pattern | Example | Solution |
|---------|---------|----------|
| Missing type hints | Function shows 'str' but accepts objects | Update hints to match usage |
| Inconsistent errors | Some return None, others raise | Follow project error patterns |
| Import disorder | Third-party before stdlib | Use project linters |

---

## Code Review Checklist

### Functionality
- [ ] Code does what it's supposed to do
- [ ] Edge cases and error conditions handled
- [ ] No obvious bugs or logical errors

### Security
- [ ] Input validation for user-provided data
- [ ] Authentication and authorization checks
- [ ] No sensitive data exposure
- [ ] No injection vulnerabilities
- [ ] Proper error handling without info leakage

### Performance
- [ ] No N+1 query problems
- [ ] Efficient algorithms and data structures
- [ ] No unnecessary memory usage
- [ ] Caching where appropriate
- [ ] Database queries optimized

### Testing
- [ ] Tests cover new/changed functionality
- [ ] Tests not duplicated unnecessarily
- [ ] Test data matches function expectations
- [ ] No silent test failures
- [ ] Success and failure paths tested

### Code Quality
- [ ] Follows project conventions
- [ ] No unnecessary duplication
- [ ] Extends existing code when possible
- [ ] Proper error handling and logging
- [ ] Clear, maintainable structure
- [ ] Appropriate type hints

### Tech Debt
- [ ] Doesn't introduce new debt unnecessarily
- [ ] Reduces existing debt where possible
- [ ] Workarounds documented with tickets
- [ ] Uses current patterns

### Documentation
- [ ] Code self-documenting or commented
- [ ] API changes documented
- [ ] Breaking changes noted
- [ ] README/docs updated if needed

---

## Best Practices

### As a Reviewer
1. Focus on maintainability and correctness
2. Check for security vulnerabilities and performance issues
3. Suggest specific improvements with examples
4. Explain reasoning behind feedback
5. Distinguish "must fix" from "nice to have"
6. Reference project standards
7. Look for extend vs create opportunities

### As a Reviewee
1. Ask questions when feedback unclear
2. Implement valuable improvements
3. Explain reasoning if disagreeing
4. Be open to consolidation
5. Consider reviewer suggestions even if initial instinct resists

---

## Language-Specific Patterns

### Python Backend
- Type hints on all new functions
- MyPy compliance
- Proper SQLAlchemy usage (avoid N+1)
- Security (SQL injection prevention, input validation)
- Proper exception handling

### TypeScript/JavaScript Frontend
- No `any` types - use proper types
- Use framework components appropriately
- Proper error/loading states
- Accessibility (ARIA, keyboard nav)
- No XSS vulnerabilities

### Testing (All Languages)
- Proper test data types
- Clean up test data
- Realistic fixtures, not hardcoded
- Unit and integration coverage
- No flaky tests

---

## Invalid Review Patterns

### Avoid These
- Minor formatting issues (periods in comments)
- Spacing preferences without standards backing
- Personal style preferences
- Overly prescriptive when multiple valid approaches exist
- Scope creep (unrelated features/improvements)
- Asking to fix issues not introduced by PR

---

## Quick Reference: Common Review Scenarios

| Scenario | Tag | Action |
|----------|-----|--------|
| SQL injection risk | [major] | Require parameterized queries |
| Missing input validation | [major] | Require validation/sanitization |
| N+1 query in loop | [major] | Require bulk operations |
| Duplicate code (5+ instances) | [minor] | Suggest extraction to utility |
| New function duplicates existing | [minor] | Suggest extending existing |
| Missing type hints | [minor] | Request type annotations |
| Inconsistent naming | [minor] | Request following conventions |
| Could use comprehension | [nitpick] | Optional suggestion |
| Minor formatting | [nitpick] | Only if impacts readability |

---

## Lessons Learned from Recent Reviews

---

These patterns and frameworks help maintain code quality while fostering **objective, constructive, and collaborative** code reviews that catch bugs, security issues, performance problems, and tech debt before they reach production.
