# /create-pr - Generate Pull Request

> **When**: You have committed changes on a feature branch and want a well-written PR with a human-readable title and description.
> **Produces**: A GitHub PR with title and body derived from commits, diff, and PROJECT.md context.

## Usage

```
/create-pr                    # Create PR from current branch
/create-pr --base develop     # Target a specific base branch
/create-pr --draft            # Create as draft PR
```

## Steps

### 1. Validate Branch State

- Verify current branch is not `main` (or the repo's default branch)
- Determine base branch: `--base` argument, or infer from `git config` / repo default
- Check if branch is pushed to remote; push with `-u` if not
- Count commits ahead of base: `git log base..HEAD --oneline`

### 2. Gather Context

Collect all available context for generating the PR:

**From git:**
- `git log base..HEAD --oneline` — commit titles
- `git log base..HEAD --format="%B"` — full commit messages
- `git diff base..HEAD --stat` — changed files summary
- `git diff base..HEAD` — full diff for understanding scope

**From PROJECT.md** (if it exists):
- Feature Brief or Overview — for the "why"
- Implementation Notes — for technical details
- Key decisions — for the "what we chose and why"

**From repo PR template** (check in order):
- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `docs/pull_request_template.md`

### 3. Generate PR Title

Rules:
- Under 70 characters
- Follow the repo's commit prefix convention (detect from recent merged PRs via `gh pr list --state merged --limit 5 --json title`)
- Human-readable — describe the user-facing "what", not the implementation detail
- Examples: "feat: Add bulk filter editing for dashboards", "fix: Prevent chart crash on empty datasets"

### 4. Generate PR Body

If a PR template exists, fill in each section from the gathered context.

If no template, use this default structure:

```markdown
## Summary
[1-3 bullet points: what changed and why, written for someone who doesn't know the codebase]

## Changes
[Grouped by area — not a file list, but a logical description of what each group of changes does]

## Test plan
[How to verify: automated tests, manual steps, or both]

## Related
[Link to ticket, issue, or prior PR if referenced in commits or PROJECT.md]
```

### 5. Present for Review

Show the generated title and body to the user. Wait for confirmation or edits.

### 6. Create PR

```bash
gh pr create --title "..." --body "..." [--draft] [--base ...]
```

Return the PR URL.

### 7. Summary

```markdown
## Create-PR Complete
PR #[number]: [title]
URL: [link]
Base: [base branch] ← [head branch]
Commits: [N]
```

**Record metrics**: call the `metrics-emit` skill with:
- `command`: `create-pr`
- `complexity`: `standard`
- `status`: `clean` if the PR was created, `blocked` otherwise
- `rounds`: 0
- `gate_decisions`: `{ pr_created: <yes | no>, draft: <yes | no> }`
- `models_used`: subagent model invocation counts

Record lifecycle: `command-complete`

## Notes
- This command generates and creates the PR — it does not review the code
- For code review before PR, use `/review-code` first
- For reviewing someone else's PR, use `/review-pr`
- The title and body are always shown for user approval before creating
