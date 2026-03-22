# External API Reference

Single source of truth for all external tool integrations. Commands reference this via `@` instead of duplicating patterns.

## GitHub CLI (`gh`)

**Auth**: `$GITHUB_TOKEN` (used by `gh` CLI automatically)

### PR Operations

```bash
# List open PRs (default limit is 30 — raise for reports)
gh pr list -R <owner>/<repo> --state open --limit 100 --json number,title,author,createdAt,reviewDecision,url,labels

# List merged PRs (by date — raise limit for monthly reports)
gh pr list -R <owner>/<repo> --state merged --limit 200 --json number,title,author,mergedAt,url --search "merged:>YYYY-MM-DD"

# View PR metadata
gh pr view <number-or-url> --json title,body,author,baseRefName,headRefName,files,additions,deletions

# Get the diff
gh pr diff <number-or-url>

# List changed file paths
gh pr view <number-or-url> --json files -q '.files[].path'

# Get diff hunks with positions (for inline review comments)
gh api repos/<owner>/<repo>/pulls/<number>/files --paginate
```

### PR Review & Comments

```bash
# View PR comments
gh pr view <number> --comments

# List code-level review comments
gh api repos/<owner>/<repo>/pulls/<number>/comments

# List general PR comments (issue-level)
gh api repos/<owner>/<repo>/issues/<number>/comments

# Submit a review with inline comments
gh api repos/<owner>/<repo>/pulls/<number>/reviews \
  -f event="REQUEST_CHANGES" \
  -f body="Review summary" \
  -f 'comments[]={ "path": "file.py", "line": 42, "body": "[major] description" }'

# Submit a simple review (approve / request changes / comment)
gh pr review <number> --approve --body "LGTM"
gh pr review <number> --request-changes --body "See comments"
gh pr review <number> --comment --body "Some thoughts"

# Reply to a specific review comment
gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies \
  -f body="<response>"

# Post a general PR comment
gh pr comment <number> --body "<response>"
```

### CI Operations

```bash
# List recent failed runs on a branch
gh run list --branch <branch> --status failure --limit 1

# View failed run logs
gh run view <run-id> --log-failed

# Check PR CI status
gh pr checks <number>
```

### Issue Operations

```bash
# View an issue
gh issue view <number-or-url> -R <owner>/<repo> --json title,body,author,labels,state,comments

# Search issues
gh api search/issues -X GET -f q="repo:<owner>/<repo> is:issue <query>"

# Search PRs waiting for review
gh api search/issues -X GET -f q="repo:<owner>/<repo> is:pr is:open review:required"
```

### Cherry-Pick Support

```bash
# Get merge commit and files from a PR
gh pr view <number-or-url> --json mergeCommit,files

# View commit context
git show --stat <commit-hash>
```

## Shortcut REST API

**Auth**: `Shortcut-Token: $SHORTCUT_API_TOKEN` header
**Base URL**: `https://api.app.shortcut.com/api/v3`

**When to use**: Bulk data gathering, automated pipelines, parallel collection. Faster than MCP, no permission prompts, richer fields.

### Endpoints

| Endpoint | Method | Use |
|----------|--------|-----|
| `/stories/search` | POST | Find stories by team, state, dates. Supports pagination. |
| `/stories/<id>` | GET | Single story details |
| `/epics/<id>` | GET | Epic details — progress, state, stories |
| `/groups` | GET | All teams (groups) — verify UUIDs |
| `/groups/<id>/stories` | GET | Stories assigned to a team |
| `/iterations` | GET | All iterations |
| `/workflows` | GET | Workflow states — map state IDs to names |
| `/members` | GET | All workspace members |

### Common Query Patterns

**Completed stories by team in a date range:**
```bash
curl -s -X POST "https://api.app.shortcut.com/api/v3/stories/search" \
  -H "Content-Type: application/json" \
  -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
  -d '{"completed_at_start":"2026-03-01T00:00:00Z","completed_at_end":"2026-03-21T23:59:59Z","group_id":"<team-uuid>"}'
```

**WIP stories (in progress) by team:**
```bash
curl -s -X POST "https://api.app.shortcut.com/api/v3/stories/search" \
  -H "Content-Type: application/json" \
  -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
  -d '{"workflow_state_types":["started"],"group_id":"<team-uuid>"}'
```

**Blocked stories (filter from WIP results):**
```bash
# Query WIP, then filter client-side:
| jq '[.data[] | select(.blocked == true or .blocker == true)]'
```

**Single story by ID:**
```bash
curl -s "https://api.app.shortcut.com/api/v3/stories/<story-id>" \
  -H "Shortcut-Token: $SHORTCUT_API_TOKEN"
```

**Epic details:**
```bash
curl -s "https://api.app.shortcut.com/api/v3/epics/<epic-id>" \
  -H "Shortcut-Token: $SHORTCUT_API_TOKEN"
```

### Key Story Fields

`name`, `id`, `app_url`, `story_type` (feature/bug/chore), `workflow_state_id`, `group_id`, `epic_id`, `estimate`, `owner_ids`, `labels`, `completed_at`, `started_at`, `moved_at`, `cycle_time`, `lead_time`, `blocked`, `blocker`, `external_links` (GitHub PR URLs), `custom_fields`

### Pagination

Search responses include a `next` token when more results exist. Pass it as `"next": "<token>"` in subsequent POST body. Loop until no `next` token is returned.

### Workflow States

Fetch from `/workflows` to map `workflow_state_id` → human-readable names. The "Engineering Kanban" workflow is primary. Typical flow: Unstarted → Ready for Dev → In Development → Ready for Review → In Review → Ready for Deploy → Deployed/Done.

### Story ID Formats

Stories can be referenced as:
- `sc-12345` or `SC-12345` — extract the number, query `/stories/12345`
- Shortcut URL — extract the story ID from the path
- Numeric ID — query directly

## Shortcut MCP

**When to use**: Interactive queries, one-off lookups, when REST API is unavailable. Slower than REST, triggers permission prompts.

| Tool | Use |
|------|-----|
| `stories-search` | Search with team, date, state filters |
| `stories-get-by-id` | Single story details |
| `epics-get-by-id` | Epic details |
| `epics-search` | Find epics by query |
| `iterations-search` | Find iterations by date range |
| `iterations-get-stories` | Stories in an iteration |

## Notion MCP

**When to use**: Interactive only — docs, meeting notes, databases. Not for bulk data.

| Tool | Use |
|------|-----|
| `notion-search` | Find pages by title/content |
| `notion-fetch` | Read a specific page or database |

## Input Detection

When a command receives an argument, detect the source type:

| Input Pattern | Source | Action |
|---------------|--------|--------|
| `sc-12345` or `SC-12345` | Shortcut story | Query Shortcut REST API `/stories/12345` |
| `https://app.shortcut.com/...` | Shortcut URL | Extract story/epic ID, query REST API |
| `#12345` or `12345` (with repo context) | GitHub issue/PR | `gh issue view` or `gh pr view` |
| `owner/repo#12345` | GitHub issue/PR | `gh issue view 12345 -R owner/repo` |
| `https://github.com/...` | GitHub URL | `gh issue view <url>` or `gh pr view <url>` |
