---
name: review-testplan
description: Review a plan's testing strategy for coverage approach, test layers, and edge cases.
---

# Test Plan Review

Evaluate whether the plan's testing strategy will provide meaningful regression protection.

If PROJECT.md exists, read it first.

## Focus Areas

Analyze:
- Coverage approach — what's tested and what's not?
- Test layers — appropriate mix of unit, integration, and e2e tests?
- Edge cases — are boundary conditions and error paths covered?
- Testable boundaries — does the design support clean test interfaces?
- Mock strategy — is mocking appropriate or excessive?
- Test data strategy — how is test data managed?
- CI/CD implications — will tests run reliably in CI?

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
