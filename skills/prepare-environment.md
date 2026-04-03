---
model: haiku
---

# Prepare Environment

Use this phase when implementation or QA validation may require a runnable local environment, rebuilt artifacts, or other setup beyond reading code.

This is especially important for UI and workflow bugs, because QA may need the local app running before reproduction can move beyond first-pass triage.

## Goal

Get the smallest useful local setup ready in the background without blocking the rest of the workflow unnecessarily.

## Core Steps

1. Determine whether the bug is likely UI, workflow, or environment-sensitive.
2. Verify dependencies, generated artifacts, and local services relevant to that path.
3. Start only the services needed for local validation.
4. Prefer a setup that allows QA to use Playwright MCP for repro and post-fix validation when the bug is user-visible.
5. Note blockers instead of widening scope when setup becomes expensive or unclear.

## Output

```markdown
## Environment Prep

- Needed: <yes / no>
- Setup performed: <commands or services started>
- Ready for validation: <yes / partial / no>
- Playwright-ready: <yes / no / not applicable>
- Blockers: <what still prevents local validation>
```
