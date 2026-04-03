---
name: review-architecture
description: Review plan from a system design and architecture perspective.
model: opus
---

# Architecture Review

Evaluate the plan's architectural decisions, component boundaries, and system design.

Read before scoring: `rules/scoring.md`, `rules/severity.md`

If PROJECT.md exists, read it first. If it does not exist, use the in-conversation context, plan, or diff as primary source.

## Focus Areas

Analyze:
- System design and component boundaries
- Coupling between components — are dependencies clean?
- Scalability — will the design handle growth?
- Consistency with existing codebase patterns and conventions
- API contracts and interface design
- Data flow and state management approach
- Separation of concerns

## Exclude

Do NOT comment on:
- Code style or formatting
- Test implementation details
- UI/UX specifics
- Implementation sequencing

## Output

```markdown
## Architecture Review
### Score: X/10
### Strengths
- [What the plan does well architecturally]
### Issues
- [High/Medium/Low] [Issue + why it matters]
### Suggestions
- [Specific, actionable architectural improvement]
### Missing
- [What the plan should address from an architecture perspective]
```
