# Triage Bug

Use this phase at the start of a bug workflow to determine whether the report is reproducible, what evidence exists, and what setup is required.

For UI and workflow bugs, this is a two-stage process:
- first-pass triage from the report, logs, screenshots, and available context
- full reproduction after the local app or target environment is ready

## Goal

Turn a loose bug report into a concrete QA handoff with repro steps, expected behavior, actual behavior, and confidence about whether the issue is real.

## Core Steps

1. Restate the reported problem in user-facing terms.
2. Identify the environment, data, feature flags, and accounts needed to reproduce it.
3. Attempt a fast first-pass reproduction or explain why it cannot be reproduced yet.
4. Decide whether local app startup is required before reliable reproduction is possible.
5. For UI paths, prefer Playwright MCP once the app is runnable.
6. Record expected behavior versus actual behavior.
7. Capture artifacts that increase confidence: screenshots, logs, failing steps, or URLs.
8. Flag gaps that block reliable validation.

## Output

```markdown
## QA Triage

- Bug status: <confirmed / plausible / not reproduced / insufficient evidence>
- Repro phase: <first-pass only / fully reproduced / blocked on environment>
- Repro steps: <numbered steps or blockers>
- Expected behavior: <what should happen>
- Actual behavior: <what happens instead>
- Environment needs: <data, flags, accounts, browsers, services>
- Playwright MCP: <required / useful / not needed>
- Evidence: <key proof points>
- Open gaps: <what still blocks reliable validation>
```
