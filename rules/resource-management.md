# Resource Management Principles

## Golden Rules
- [ ] **Check resources before consuming them** — Docker, test workers, builds
- [ ] **One stack at a time** — shut down before starting another
- [ ] **Scale workers to available resources** — not to CPU count

## Docker Container Management

**Before starting any Docker containers:**
1. Run `docker ps` to check running containers
2. If **2 or fewer** containers are running → proceed
3. If **more than 2** → show the running containers to the user and ask whether to stop any before starting new ones, or start anyway

**Rationale**: Each Superset stack (app + DB + extras) uses 4-6 GB RAM. Multiple stacks saturate the Docker VM and crash the host.

## Test Worker Management

**Before running test suites (Jest, pytest, Playwright):**
1. Check system resources: `sysctl -n hw.ncpu` and available memory
2. Check what else is running: `docker ps -q | wc -l` for Docker load
3. Calculate appropriate `maxWorkers`:

| Condition | maxWorkers | Flag |
|-----------|-----------|------|
| Docker stack running | 2 | `--maxWorkers=2` |
| No Docker, light usage | 4 | `--maxWorkers=4` |
| Single test file | 1-2 | `--maxWorkers=2` |
| Full suite, nothing else running | 50% of CPUs | `--maxWorkers=50%` |

**Always pass `--maxWorkers` to Jest** — the default (CPUs - 1) spawns too many workers and causes OOM crashes.

**For pytest**: Use `-n` with pytest-xdist following the same worker guidelines, or omit for sequential runs.

**For Playwright**: Workers are configured in `playwright.config.ts` — check `workers` setting before running.
