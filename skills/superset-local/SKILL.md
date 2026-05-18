---
name: superset-local
description: "Superset local stack work: start Docker light stack, detect frontend port, apply Superset proxy fixes, run Playwright E2E."
user-invocable: false
disable-model-invocation: true
---

# Superset Local

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

This is a project-specific environment skill for Superset/Preset local testing.

| Phase | When | Reference |
|-------|------|-----------|
| Start stack | Need a healthy local Superset stack and frontend URL | [references/start-stack.md](references/start-stack.md) |
| Run Playwright | Need to run Superset Playwright E2E tests against the local stack | [references/run-playwright.md](references/run-playwright.md) |

## Boundaries

- Use `preflight/` for generic dependency, env, and worktree readiness.
- Use `qa/` for scenario design and user-visible validation.
- Use this skill only for Superset-specific stack and Playwright mechanics.
