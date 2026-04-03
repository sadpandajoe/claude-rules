---
name: review-testplan
description: Review a plan's testing strategy for coverage approach, test layers, and edge cases.
model: opus
---

# Test Plan Review

Evaluate whether the plan's testing strategy will provide meaningful regression protection.

Read before scoring: `rules/scoring.md`, `rules/severity.md`

If PROJECT.md exists, read it first. If it does not exist, use the in-conversation context, plan, or diff as primary source.

## Focus Areas

Analyze:
- Coverage approach — identify what is tested and what is not
- Test layers — verify an appropriate mix of unit, integration, and e2e tests
- Edge cases — verify boundary conditions and error paths are covered
- Testable boundaries — verify the design supports clean test interfaces
- Mock strategy — verify mocking is appropriate and not excessive
- Test data strategy — verify test data is managed and reproducible
- CI/CD implications — verify tests will run reliably in CI

## Exclude

Do NOT comment on:
- Architecture decisions
- Code style or formatting
- UI design
- Implementation sequencing

## Output

```markdown
## Test Plan Review
### Score: X/10
### Strengths
- [What the plan does well for testing]
### Issues
- [High/Medium/Low] [Issue + why it matters]
### Suggestions
- [Specific, actionable testing improvement]
### Missing
- [What the plan should address from a testing perspective]
```
