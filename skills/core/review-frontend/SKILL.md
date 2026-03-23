---
name: review-frontend
description: Review plan from a frontend and UI/UX perspective.
---

# Frontend Review

Evaluate the plan's frontend approach including component design, state management, and user experience.

If PROJECT.md exists, read it first.

## Focus Areas

Analyze:
- Component design — reusable, composable, appropriately sized?
- State management — where does state live, how does it flow?
- UX flows — are user interactions well-defined?
- Accessibility — keyboard navigation, screen readers, ARIA, contrast?
- Performance — rendering, bundle size, lazy loading?
- Error and loading states — what does the user see when things go wrong or are loading?
- Responsive design — does it work across screen sizes?
- Consistency with existing frontend patterns in the codebase

## Exclude

Do NOT comment on:
- Backend API internals
- Database design
- Deployment infrastructure
- Server-side implementation details

## Output

```markdown
## Frontend Review
### Score: X/10
### Strengths
- [What the plan does well for frontend]
### Issues
- [High/Medium/Low] [Issue + why it matters]
### Suggestions
- [Specific, actionable frontend improvement]
### Missing
- [What the plan should address from a frontend perspective]
```
