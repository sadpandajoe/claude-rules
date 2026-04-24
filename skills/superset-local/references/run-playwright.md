---
model: sonnet
---

# Run Playwright Local

Run Playwright E2E tests against a local Superset development stack. Handles the common pitfalls of local Playwright execution: base URL detection, stack health verification, auth timeouts, and correct invocation.

## When to Use

- User asks to "run playwright tests", "run e2e tests", "test locally"
- After implementing or fixing Playwright test code
- When validating that Playwright tests pass before pushing

## Prerequisites

A healthy local Superset stack with its frontend dev server responding. If not running, follow [start-stack.md](start-stack.md) first (or prompt the user to start it).

## Steps

### 1. Verify Stack is Ready

Check that Superset is running and the frontend is responding:

```bash
docker ps --format "{{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "superset"
```

Look for:
- A `superset-light` container showing `(healthy)`
- A `superset-node-light` container with a port mapping

If nothing is running, follow [start-stack.md](start-stack.md) to start the stack automatically. Only stop and ask the user if the stack start fails.

### 2. Detect Frontend Port

Parse the node container's port mapping to find the host port:

```bash
docker ps --format "{{.Names}}\t{{.Ports}}" | grep "node-light"
```

Extract the host port from mappings like `0.0.0.0:9002->9000/tcp`. This is the `PLAYWRIGHT_BASE_URL` — not `localhost:8088` (the backend port inside Docker, not exposed to the host).

Verify the port responds:

```bash
curl -sf -o /dev/null -w "%{http_code}" http://localhost:$PORT/
```

If it returns 000 or times out, warn the user that the dev server may still be compiling.

### 3. Verify Auth Endpoint

The Playwright global setup authenticates via `/login/`. This is the most common failure point locally — the webpack proxy to the Flask backend can fail on first request after startup.

```bash
curl -sf -o /dev/null -w "%{http_code}" http://localhost:$PORT/login/
```

- **200**: Ready
- **502/503/000**: Backend not ready or ZSTD proxy issue — wait 10 seconds and retry once
- Still failing after retry: warn the user about the ZSTD fix (`COMPRESS_ALGORITHM = ["gzip"]` in `docker/pythonpath_dev/superset_config_docker_light.py`)

### 4. Run the Tests

Change to the `superset-frontend` directory and run Playwright with the detected base URL.

**Find the right test file** — if the user describes the test by name or feature rather than path, search for it:
```bash
find superset-frontend -name "*.spec.ts" -o -name "*.spec.js" | grep -i "<keyword>"
```

**Specific test files** (when the user specifies what to run):
```bash
cd superset-frontend
PLAYWRIGHT_BASE_URL=http://localhost:$PORT npx playwright test $TEST_PATH --reporter=list
```

**All tests** (when the user says "run all"):
```bash
cd superset-frontend
PLAYWRIGHT_BASE_URL=http://localhost:$PORT npx playwright test --reporter=list
```

Key flags the user might want:
- `--headed` — show the browser (useful for debugging)
- `--ui` — interactive Playwright UI mode
- `--debug $TEST_PATH` — step-by-step debugger for a specific test

Local config uses `workers: 1` (sequential) and `retries: 0` (fail fast), which is correct for local development. Do not override these — per `rules/resource-management.md`, local runs should stay single-worker when a Docker stack is running.

### 5. Handle Failures

If tests fail:

- **Global setup auth timeout**: Usually transient. Retry the full run once. If it fails again, check the ZSTD fix and backend health.
- **Test failures**: Report the failure summary. Don't retry — the user needs to see what failed. Mention the trace viewer if traces were captured:
  ```bash
  npx playwright show-trace test-results/<test-name>/trace.zip
  ```
- **Browser launch errors**: Check `npx playwright install chromium` has been run in the worktree.

### 6. Output

```
## Playwright Results

- Base URL: http://localhost:$PORT
- Tests: X passed, Y failed (Z total)
- Duration: Nm Ns

### Failed (if any)
- [file] › test name — error summary

### Next
- View trace: `npx playwright show-trace test-results/<name>/trace.zip`
- View report: `npx playwright show-report`
- Debug: `PLAYWRIGHT_BASE_URL=http://localhost:$PORT npx playwright test --debug <file>`
```

## Known Local Issues

These are gotchas specific to running Playwright against a local Superset dev stack:

| Issue | Symptom | Fix |
|-------|---------|-----|
| Wrong base URL | Auth timeout on `localhost:8088` | Set `PLAYWRIGHT_BASE_URL` to the node container's host port |
| ZSTD proxy | `ZSTDDecompress is not a function` | Add `COMPRESS_ALGORITHM = ["gzip"]` to superset_config, restart |
| First-run auth timeout | Global setup fails, then works on retry | Transient — retry once |
| Stale tab state | Tab count assertions off | Tests should use relative counts, not absolute |
| Missing browser | `browserType.launch` fails | Run `npx playwright install chromium` |

## What This Skill Does NOT Do

- Start or manage the Docker stack (use [start-stack.md](start-stack.md) for that)
- Fix test code
- Modify playwright.config.ts
