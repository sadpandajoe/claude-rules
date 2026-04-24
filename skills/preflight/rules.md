# Preflight Rules

Read this when a workflow is preparing a local app, Docker stack, or git worktree.

## Docker Container Management

Before starting any Docker containers:
1. Run `docker ps` to check running containers.
2. If two or fewer containers are running, proceed.
3. If more than two containers are running, show the running containers to the user and ask whether to stop any before starting new ones, or start anyway.

Each Superset stack can use 4-6 GB RAM. Multiple stacks can saturate the Docker VM and crash the host.

## Worktree Management

When working in git worktrees, remember that worktrees share `.git` but not:
- `node_modules/` or equivalent dependency folders
- build outputs such as `dist/`, `.next/`, or `__pycache__/`
- `.env` files

Before running tests or builds in a worktree:
1. Check whether dependencies exist; install if needed.
2. Check whether build outputs are required; rebuild if needed.
3. Copy `.env` or `.env.local` from the main worktree if needed.

Worktrees created by agents may be auto-cleaned if no changes were made. If changes exist, return the worktree path and branch for merge or manual cleanup.
