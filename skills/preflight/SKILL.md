---
name: preflight
description: Use before work that needs a ready worktree or runnable app: dependency/env checks, build artifacts, Docker/service readiness, seed data, and feature flags. Do NOT use for writing tests, implementing code, or validating product behavior after the environment is ready.
user-invocable: false
disable-model-invocation: true
---

# Preflight

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

Umbrella for pre-work environment-readiness checks. Two distinct layers, both called before real work begins.

## Phases

| Phase | When | Reference |
|-------|------|-----------|
| Worktree preflight | Entering a fresh git worktree (infra-level: deps, env files, build artifacts) | [references/worktree-preflight.md](references/worktree-preflight.md) |
| Environment prep | Before QA validation / implementation that needs a runnable app (service-level: services, seed data, flags) | [references/prepare-environment.md](references/prepare-environment.md) |

## Layer Distinction

Both are "pre-work" but answer different questions:

- **Worktree preflight** — *Is my git worktree runnable?* Dependencies installed, env files present, build artifacts current. One-time per worktree entry.
- **Environment prep** — *Is the app runnable for me to validate behavior?* Services started, seed data, feature flags. Per-workflow when user-visible validation matters.

Use worktree-preflight on first entry into any worktree. Use prepare-environment when a workflow is about to validate runtime behavior (UI repro, Playwright, integration testing).

## Notes

- Worktree preflight is generic (applies to any project). Project-specific stack skills live separately (e.g., `superset-local/`).
- Neither auto-starts Docker — both surface what's needed and let the user or a concrete stack skill do the actual startup.
