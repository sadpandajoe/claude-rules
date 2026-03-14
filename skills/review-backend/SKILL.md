---
name: review-backend
description: Review plan from a backend, API, and data modeling perspective.
---

# Backend Review

Evaluate the plan's backend approach including API design, data modeling, and security.

If PROJECT.md exists, read it first.

## Focus Areas

Analyze:
- API design — RESTful conventions, consistent naming, versioning?
- Data modeling — schema design, relationships, constraints, indexes?
- Security — authentication, authorization, input validation, injection prevention?
- Performance — query efficiency, N+1 problems, caching strategy?
- Error handling — consistent error responses, meaningful messages, retry logic?
- Migrations — safe schema changes, backward compatibility, rollback plan?
- External integrations — third-party APIs, message queues, caching layers?
- Consistency with existing backend patterns in the codebase

## Exclude

Do NOT comment on:
- UI components or frontend state
- CSS or styling
- Frontend build tooling
- Client-side routing

## Output

```markdown
## Backend Review
### Score: X/10
### Strengths
- [What the plan does well for backend]
### Issues
- [High/Medium/Low] [Issue + why it matters]
### Suggestions
- [Specific, actionable backend improvement]
### Missing
- [What the plan should address from a backend perspective]
```
