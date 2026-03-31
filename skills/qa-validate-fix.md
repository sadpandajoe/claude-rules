# Validate Fix

Use this phase after a bug fix has been implemented and code-level verification has already run.

## Goal

Confirm the fix holds up in the user-visible workflow and identify any remaining behavioral regressions.

For UI and workflow bugs, use Playwright MCP as the default validation path when the app is runnable.
If Playwright MCP is unavailable or the app cannot be started, record the blocker explicitly instead of implying the bug was fully validated.

## Core Steps

1. Re-run the confirmed repro steps in the validated environment.
2. For UI paths, drive the repro and confirmation flow through Playwright MCP when available.
3. Check the primary success path and the most important adjacent scenarios.
4. Record whether the bug is resolved, partially resolved, or still present.
5. Call out any gaps caused by missing environment access, Playwright access, or incomplete setup.

## Output

```markdown
## QA Validation

- Result: <pass / partial / fail / blocked>
- Validation path: <Playwright MCP / manual / mixed / blocked>
- Primary repro: <resolved or still broken>
- Additional scenarios checked: <what was exercised>
- Remaining risks: <what still needs attention>
- Blockers: <env or setup gaps, if any>
```
