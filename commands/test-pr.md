# /test-pr - Manual PR Testing via Browser

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/preset-environments.md

> **When**: You want to manually verify a PR's user-visible behavior in a running local or staging app.
> **Produces**: Scenario-by-scenario pass/fail results with screenshot and optional video evidence.

## Usage

```bash
/test-pr <pr-number>
/test-pr apache/superset#28456
/test-pr https://github.com/owner/repo/pull/123
/test-pr <pr-number> --url http://localhost:3000
/test-pr <pr-number> --checkout
/test-pr <pr-number> --smoke
/test-pr <pr-number> --post
/test-pr <pr-number> --post sc-12345
/test-pr <pr-number> --post pr
/test-pr <pr-number> --no-record
```

## Prerequisite

The app must already be running unless `--url` points to staging. This command verifies the PR against the current app; it does not start the dev server.

Use `--checkout` when you need the command to switch to the PR branch first. After checkout, pause so the user can restart the app.

## Routing

Use the `qa` skill and load only the needed references:

1. Resolve PR, checkout, URL, and auth with [skills/qa/references/test-pr/setup.md](../skills/qa/references/test-pr/setup.md).
2. Assess impact and derive smoke scenarios with [skills/qa/references/test-pr/scenarios.md](../skills/qa/references/test-pr/scenarios.md).
3. Execute browser scenarios with [skills/qa/references/test-pr/execute.md](../skills/qa/references/test-pr/execute.md).
4. Report or post results with [skills/qa/references/test-pr/report.md](../skills/qa/references/test-pr/report.md).

The main thread owns PR identity, app URL, scenario selection, evidence paths, posting decisions, and final summary. Do not load execution/reporting references until setup and scenario selection are complete.

## Gates

- Stop if the app URL cannot be resolved.
- Stop on production URLs.
- Confirm scenarios before execution unless the user explicitly asked for a quick smoke.
- Run scenarios sequentially; do not parallelize browser evidence gathering.
- Record by default; skip only with `--no-record`.
- Stop before posting unless `--post` was passed and evidence paths are available.

## Summary Contract

End with:

```markdown
## Test-PR Complete

PR: #<number> - <title>
Branch: <head-branch>
App: <url>
Impact: CORE / STANDARD / PERIPHERAL

### Results
| # | Scenario | Tag | Result | Notes |
|---|----------|-----|--------|-------|

### Evidence
- Recording: ...
- Screenshots: ...

### Next Steps
- ...
```

## Notes

- For full curated validation, use `/run-test-plan`.
- For existing automated Playwright specs, route to [skills/superset-local/references/run-playwright.md](../skills/superset-local/references/run-playwright.md) when this is a Superset repo.
- This command does not modify code or file bugs.
