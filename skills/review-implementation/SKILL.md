---
name: review-implementation
description: Review plan from an implementation feasibility and sequencing perspective.
---

# Implementation Review

Evaluate whether the plan is practically implementable with realistic effort and sequencing.

If PROJECT.md exists, read it first.

## Focus Areas

Analyze:
- Step sequencing — are dependencies between steps respected?
- Effort realism — are estimates reasonable for each step?
- Dependency availability — do required libraries/APIs exist?
- Consistency with existing codebase patterns and conventions
- Incremental delivery — can the plan be implemented in shippable increments?
- Migration concerns — backward compatibility, data migration, rollback
- Risk of each step — what could go wrong?

## Exclude

Do NOT comment on:
- High-level architecture decisions
- Test strategy details
- UI design choices
- Code style

## Output

```markdown
## Implementation Review
### Score: X/10
### Strengths
- [What the plan does well for implementability]
### Issues
- [High/Medium/Low] [Issue + why it matters]
### Suggestions
- [Specific, actionable implementation improvement]
### Missing
- [What the plan should address from an implementation perspective]
```
