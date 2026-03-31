# Shortcut API Fetch

Use this helper whenever a workflow needs to make Shortcut REST API calls. It wraps the known operational gotchas so callers don't rediscover them each session.

For endpoint reference, query patterns, and field names see `rules/shortcut-api.md`.

## Before Making Calls

1. Confirm `$SHORTCUT_API_TOKEN` is set
2. Source the retry wrapper below — use it for every call in the session

## Retry Wrapper

The Shortcut API returns `organization2_missing` (or similar transient errors) on the first call of a session. This is normal. Always use this wrapper:

```bash
shortcut_call() {
  local result
  result=$(eval "$1") && echo "$result" && return 0
  # First call often fails with transient error — retry once
  result=$(eval "$1") && echo "$result" && return 0
  echo "Shortcut API failed after retry: $result" >&2 && return 1
}
# Usage: shortcut_call 'curl -s -H "Shortcut-Token: $SHORTCUT_API_TOKEN" ...'
```

If the retry also fails, surface the gap to the user — do not silently move on with missing data.

## JSON Parsing

Shortcut responses contain control characters (newlines, tabs) in text fields like `description` and `comments[].text`. Raw `jq` parsing will fail on these.

**Use Python with `strict=False`:**
```bash
python3 -c "
import json, sys
data = json.loads(sys.stdin.read(), strict=False)
# ... process data
" <<< "$result"
```

Do not attempt `jq` on fields that contain user-authored text. Use `jq` only for simple structural queries on well-typed fields (IDs, dates, booleans).

## Known Field Shape Gotchas

| Field | Gotcha |
|-------|--------|
| `labels` | Array of objects: `[{"id": ..., "name": "..."}]` — use `.labels[].name`, but **guard for null**: `(.labels // [])[] .name` |
| `comments` | Not on the story object. Fetch separately: `GET /stories/<id>/comments` |
| `external_links` | Array of strings (GitHub PR URLs). Can be empty `[]`. |
| `owner_ids` | Array of member UUIDs, not names. Cross-reference with `GET /members` to resolve. |
| `group_id` | Single UUID or `null` if unassigned. Not an array. |
| `epic_id` | Integer or `null`. |
| `estimate` | Integer or `null`. Not all story types use estimates. |
| `workflow_state_id` | Integer. Map to name via `GET /workflows`. Cache the mapping per session. |
| `custom_fields` | Array of `{"field_id": ..., "value_id": ..., "value": "..."}`. Shape varies by workspace config. |
| `description` | Markdown string. May contain control chars, emoji, and embedded images. Always parse with `strict=False`. |

## Minimal Fetch Pattern

```bash
# 1. Set up wrapper
shortcut_call() {
  local result
  result=$(eval "$1") && echo "$result" && return 0
  result=$(eval "$1") && echo "$result" && return 0
  echo "Shortcut API failed after retry: $result" >&2 && return 1
}

# 2. Fetch story
story=$(shortcut_call 'curl -s "https://api.app.shortcut.com/api/v3/stories/12345" -H "Shortcut-Token: $SHORTCUT_API_TOKEN"')

# 3. Parse safely
python3 -c "
import json, sys
s = json.loads(sys.stdin.read(), strict=False)
print(f\"Story: {s['name']}\")
print(f\"Type: {s['story_type']}\")
print(f\"Labels: {', '.join(l['name'] for l in (s.get('labels') or []))}\")
print(f\"Links: {s.get('external_links', [])}\")
" <<< "$story"
```
