# /test-pr - Manual PR Testing via Browser

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/preset-environments.md

> **When**: You want to manually verify a PR's changes work correctly in a running local app.
> **Produces**: Scenario-by-scenario pass/fail results with screenshot evidence.

Uses Playwright MCP to drive a real browser. Project-agnostic — works for any web app on localhost.

## Usage

```
/test-pr <pr-number>
/test-pr apache/superset#28456
/test-pr https://github.com/owner/repo/pull/123
/test-pr <pr-number> --url http://localhost:3000   # explicit app URL
/test-pr <pr-number> --checkout                    # check out PR branch first
/test-pr <pr-number> --smoke                       # 3 scenarios max, fast
```

## Prerequisite

**The app must already be running locally.** This command does not start your dev server — run that yourself first (`npm run dev`, `docker compose up`, etc.) before invoking `/test-pr`.

Use `--checkout` if you haven't switched to the PR branch yet. After checkout the command pauses so you can restart your dev server if needed.

## Steps

### 1. Resolve PR Context

Detect the input format per `rules/input-detection.md` and fetch:

```bash
gh pr view $REF --json number,title,body,author,baseRefName,headRefName,files,additions,deletions
gh pr diff $REF
```

Extract: PR number, title, description, author, changed files, and any "how to test" notes in the PR body.

### 2. Checkout Branch (only with --checkout)

```bash
gh pr checkout $PR_NUMBER
```

After switching branches, pause and tell the user:

> "Switched to PR branch `<branch>`. If your dev server needs restarting to pick up these changes, do that now — then reply to continue."

Wait for confirmation before proceeding to step 3.

### 3. Detect App URL

If `--url` was provided, use it directly and skip probing.

Otherwise probe common dev ports:

```bash
for port in 3000 4000 5000 8000 8080 8088 9000 9001; do
  code=$(curl -sf -o /dev/null -w "%{http_code}" --connect-timeout 1 http://localhost:$port/ 2>/dev/null)
  [ "$code" != "000" ] && [ -n "$code" ] && echo "localhost:$port -> HTTP $code"
done
```

Also check Docker port mappings:

```bash
docker ps --format "{{.Names}}\t{{.Ports}}" 2>/dev/null | grep -E "0\.0\.0\.0:[0-9]+->"
```

Decision:
- **One result**: use it, note in-line ("Using http://localhost:3000")
- **Multiple results**: show the list and ask which one is the app under test
- **None found**: tell the user to start the app and provide the URL — do not proceed until resolved

### 4. Assess Impact

Run the `qa` skill's [references/assess-impact.md](../skills/qa/references/assess-impact.md) on the PR diff and changed files. This classifies the touched workflows as CORE, STANDARD, or PERIPHERAL and determines how many smoke scenarios to generate.

### 5. Derive Smoke Scenarios

Run `pr-smoke-scenarios.md` with:
- PR title, description, and author notes
- List of changed files and diff
- Impact assessment from step 4

This produces 3–7 focused scenarios. With `--smoke`, cap at 3 regardless of impact.

Show the scenario list to the user before executing. If they want to adjust (add, remove, or reword scenarios), accept changes before proceeding.

### 6. Execute via Playwright MCP

For each scenario in order:

1. Navigate to the relevant page at the app URL from step 3
2. Perform the described actions using Playwright MCP
3. Take a screenshot at the primary verification point (name it `scenario-<N>-<short-name>.png`)
4. Check console for errors: `browser_console_messages`
5. Record the outcome: **PASS**, **FAIL**, or **BLOCKED**

**Auth handling**: Determine credential strategy from the app URL per `rules/preset-environments.md`:
- **Staging** (URL contains `stg.`): use `$PRESET_STG_BOT_LOGIN` / `$PRESET_STG_BOT_PASSWORD`. If either env var is unset, mark all scenarios BLOCKED and tell the user to set them before retrying.
- **Local dev**: try `admin`/`admin` then `admin`/`general`. If both fail, mark all scenarios BLOCKED and ask the user for credentials.
- **Production**: stop immediately — do not run automated tests against production.

**On FAIL**: Take an additional screenshot showing the error state. Do not retry — move to the next scenario.

**On BLOCKED**: Note what prerequisite was missing (auth, data, feature flag). Move on.

Do not run scenarios in parallel — sequential execution keeps evidence clean.

### 7. Report

```markdown
## Test-PR Complete

PR: #<number> — <title>
Branch: <head-branch>
App: <url>
Impact: CORE / STANDARD / PERIPHERAL

### Results

| # | Scenario | Tag | Result | Notes |
|---|----------|-----|--------|-------|
| 1 | <name> | [new/fix/guard] | ✅ PASS | — |
| 2 | <name> | [fix] | ❌ FAIL | <what happened> |
| 3 | <name> | [guard] | ⚠️ BLOCKED | <what was missing> |

### Summary
- <N> passed, <N> failed, <N> blocked of <N> total

### Failures
[For each FAIL — omit section if none:]
**Scenario <N> — <name>**
- Expected: <what should have happened>
- Actual: <what happened instead>
- Screenshot: scenario-<N>-fail.png
- Console errors: <if any, or "none">

### Blocked
[For each BLOCKED — omit section if none:]
**Scenario <N> — <name>**: <what was needed — auth, data, feature flag>

### Next Steps
[All pass:] PR looks good to merge.
[Failures:] Feed findings back to the PR author — specific failures listed above.
[Blocked:] Resolve blockers above and re-run `/test-pr <number>`.
```

Record lifecycle: `command-complete`

## Continuation Checkpoint

Phases: resolve-pr / detect-url / assess-impact / derive-scenarios / confirm-scenarios / execute / report

State:
- PR: <number> — <title>
- App URL: <url or pending>
- Impact: <CORE / STANDARD / PERIPHERAL>
- Scenarios: <N total, N complete, N remaining>
- Results so far: <N pass, N fail, N blocked>

## Notes
- **This command tests what is currently running** — make sure the right branch is checked out and the app is up before running
- For full QA validation with a curated test plan iterated to quality threshold, use `/run-test-plan` instead
- For running the project's existing automated Playwright test suite (`.spec.ts` files), use the `run-playwright-local.md` skill instead
- Does not modify code or file bugs — test-only output
- The `--smoke` flag is useful for a quick pre-merge sanity check; omit it for more thorough coverage on CORE-impact PRs
