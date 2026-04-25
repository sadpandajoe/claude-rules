# Resource Management Principles

## Golden Rules
- [ ] **Check resources before consuming them** — Docker, test workers, builds
- [ ] **One stack at a time** — shut down before starting another
- [ ] **Scale workers to available resources** — not to CPU count

## Routing

Use this file as the always-on index. Load the scoped rule only when the task needs it:

| Work | Read |
|------|------|
| Starting Docker or local app stacks | `skills/preflight/rules.md` |
| Entering or preparing a git worktree | `skills/preflight/rules.md` |
| Running Jest, pytest, Playwright, or similar suites | `skills/testing/rules.md` |

## Always-On Guardrails

- Before starting containers, check what is already running.
- If more than two containers are already running, show them to the user and ask before starting another stack.
- Before heavy test runs, choose worker counts intentionally; do not blindly use CPU count.
- In worktrees, assume dependencies, build outputs, and env files may be missing until checked.

Detailed stack, worktree, and worker-count rules are skill-scoped so they only load for environment prep or testing work.
