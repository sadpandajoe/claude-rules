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

**Tightness check before finalizing.** Ask three questions; if any answer is no, rewrite:

1. **Does every term in the title appear in a commit message, code comment, or external doc?** — Conversation-internal jargon ("channel-3", "Tier A", "Layer 2", or any label invented during planning that didn't make it into the codebase) is opaque to readers. Replace with the concrete domain term it stood for.
2. **Does the title lead with the outcome, not the mechanism?** — "Add helper class X" / "Introduce normaliser Y" / "Refactor to pattern Z" describe what the code looks like; readers want to know what changes for users of the affected area. Lead with the problem solved or the capability gained.
3. **Could a reader grep their codebase from this title to assess relevance?** — If the PR introduces an API that callers will adopt, name 1-2 of the key entry points (function names, route paths, env vars) so readers don't have to open the diff to know whether it touches their code.

**Common anti-patterns to flag and rewrite:**

| Anti-pattern | Example | Rewrite as |
|---|---|---|
| Invented abstraction label | `feat: introduce channel-3 helpers` | `feat: helpers for browser-direct navigation` |
| Mechanism-first phrasing | `feat: add URL normaliser to API client` | `feat: strip backend URL prefixes for subdirectory deployments` |
| Generic verb + noun | `chore: refactor exports` | `chore: collapse duplicate path utility into navigation module` |
| Multi-thing list | `feat: helpers + normaliser + lint rule` | Pick the most user-visible outcome; mention secondaries in body |

For dual-purpose PRs (feature + fix), pick the framing that matches the most user-visible outcome — even if the conventional-commits prefix is `feat`, the title text can lead with the problem ("prevent X bug via helpers Y").

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

**Body tightness check.** The same anti-patterns from the title check apply to the opening summary — readers form their first impression from the first paragraph. Specifically:

- **Don't import conversation jargon into the body.** If a label was useful for organizing the planning discussion (channels, tiers, layers, phases) but never made it into commit messages or code, do not introduce it for the first time in the PR body. The reader can't follow back to where it was defined.
- **Open with the user-visible problem or capability**, not the file list or the helper inventory. The reader decides whether to keep reading based on the first 1-2 sentences.
- **Move implementation detail tables / file inventories below the rationale**, not above. Tables of "what's in this PR" are useful to maintainers but bury the answer to "why does this PR exist".
- **Strip planning artefacts** — "skeleton commit", "first set of tests", "stubs that throw" — once the PR has grown past that phase. The body should reflect the PR's *current* state, not its development history.

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

**Record metrics**: include `metrics-emit` context with:
- `command`: `create-pr`
- `complexity`: `standard`
- `status`: `clean` if the PR was created, `blocked` otherwise
- `rounds`: 0
- `gate_decisions`: `{ pr_created: <yes | no>, draft: <yes | no> }`
- `models_used`: subagent model invocation counts

## Notes
- This command generates and creates the PR — it does not review the code
- For code review before PR, use `/review-code` first
- For reviewing someone else's PR, use `/review-pr`
- The title and body are always shown for user approval before creating
