# Shortcut REST API

## NEVER Skip the Retry

The Shortcut API returns transient errors (`organization2_missing`, empty responses, 500s) on the first call of a session. This is **expected behavior**, not a real failure.

**Before reporting any Shortcut API failure**:
1. Retry the exact same request once
2. If the retry succeeds, use the result — do not mention the first failure
3. If the retry also fails, THEN fall back to MCP or surface the gap

**NEVER**:
- Report "API token/org issue" or "can't fetch" after a single failure
- Switch to MCP without retrying REST first
- Silently move on without the data after a retry failure
- Debug or troubleshoot a single transient error

**Auth**: `Shortcut-Token: $SHORTCUT_API_TOKEN` header
**Base URL**: `https://api.app.shortcut.com/api/v3`

**Retry pattern** — wrap every Shortcut curl call:
```bash
shortcut_call() {
  local result
  result=$(eval "$1") && echo "$result" && return 0
  # First call often fails with transient error — retry once
  result=$(eval "$1") && echo "$result" && return 0
  echo "Shortcut API failed after retry: $result" >&2 && return 1
}
# Usage: shortcut_call 'curl -s ...'
```

## Endpoints

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

## Common Query Patterns

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

## Key Story Fields

`name`, `id`, `app_url`, `story_type` (feature/bug/chore), `workflow_state_id`, `group_id`, `epic_id`, `estimate`, `owner_ids`, `labels`, `completed_at`, `started_at`, `moved_at`, `cycle_time`, `lead_time`, `blocked`, `blocker`, `external_links` (GitHub PR URLs), `custom_fields`

## Pagination

Search responses include a `next` token when more results exist. Pass it as `"next": "<token>"` in subsequent POST body. Loop until no `next` token is returned.

## Workflow States

Fetch from `/workflows` to map `workflow_state_id` → human-readable names. The "Engineering Kanban" workflow is primary. Typical flow: Unstarted → Ready for Dev → In Development → Ready for Review → In Review → Ready for Deploy → Deployed/Done.

## Story ID Formats

Stories can be referenced as:
- `sc-12345` or `SC-12345` — extract the number, query `/stories/12345`
- Shortcut URL — extract the story ID from the path
- Numeric ID — query directly

## MCP Fallback

When REST API is unavailable or for interactive one-off lookups, use the Shortcut MCP tools:

| Tool | Use |
|------|-----|
| `stories-search` | Search with team, date, state filters |
| `stories-get-by-id` | Single story details |
| `epics-get-by-id` | Epic details |
| `epics-search` | Find epics by query |
| `iterations-search` | Find iterations by date range |
| `iterations-get-stories` | Stories in an iteration |
