---
model: sonnet
---

# Shortcut Report

Post structured reports (QA results, fix summaries, test findings) to Shortcut stories with evidence and metadata updates.

## When to Use

- After QA validation, test execution, or bug triage produces results that belong on a Shortcut story
- When a fix has been verified and the story needs a closing summary
- When evidence (screenshots, videos, logs) needs to be attached and referenced in a comment

## Prerequisites

- `$SHORTCUT_API_TOKEN` must be set
- Story ID must be known (numeric ID or `sc-NNNNN` format)
- Follow [fetch.md](fetch.md) patterns for API access and retry logic

Read `rules/shortcut-api.md` for the global Shortcut routing constraints.

## Core Steps

1. **Resolve the story**

   Extract the numeric ID from `sc-NNNNN`, URL, or raw number.
   Fetch the story to confirm it exists and get current state:
   ```bash
   shortcut_call 'curl -s "https://api.app.shortcut.com/api/v3/stories/<id>" -H "Shortcut-Token: $SHORTCUT_API_TOKEN"'
   ```

2. **Upload evidence** (if any)

   Upload files before posting the comment so the comment can reference the hosted URLs.
   Use the `/files` endpoint (not `/stories/<id>/files`), linking via `story_id`:
   ```bash
   shortcut_call 'curl -s -X POST "https://api.app.shortcut.com/api/v3/files" \
     -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
     -F "file0=@<path>" \
     -F "story_id=<id>"'
   ```
   Do not pass `description` as a form field — it causes a validation error.
   Capture the returned `url` for embedding in the comment.
   Name video files descriptively: `sc-<id>-<what-was-tested>.webm`.

3. **Post the report comment**

   Use the appropriate template from the Report Templates section below.
   ```bash
   shortcut_call 'curl -s -X POST "https://api.app.shortcut.com/api/v3/stories/<id>/comments" \
     -H "Content-Type: application/json" \
     -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
     -d "{\"text\": \"<markdown body>\"}"'
   ```
   Escape the markdown body for JSON. For long reports, build the JSON with Python to handle newlines safely.

4. **Link PR** (if applicable)

   ```bash
   shortcut_call 'curl -s -X PUT "https://api.app.shortcut.com/api/v3/stories/<id>" \
     -H "Content-Type: application/json" \
     -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
     -d "{\"external_links\": [\"<github-pr-url>\"]}"'
   ```
   Note: this replaces all external links. Fetch existing links first and merge.

5. **Update story metadata** (if needed)

   Update state, labels, custom fields, or estimate:
   ```bash
   shortcut_call 'curl -s -X PUT "https://api.app.shortcut.com/api/v3/stories/<id>" \
     -H "Content-Type: application/json" \
     -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
     -d "{\"workflow_state_id\": <state_id>}"'
   ```
   Fetch workflow states from `/workflows` to map names to IDs. Cache per session.

## Report Template

Reports should read like a human QA tester wrote them — narrative, concise, evidence-linked. No tables, no metadata headers, no PASS/FAIL grids. Just tell the story of what you did and what you found.

### Structure

```markdown
## QA Verification — PASS ✅ / FAIL ❌ / PARTIAL ⚠️

**Tested on**: <environment URL or description> (<version/branch info>)
**Date**: <YYYY-MM-DD>
**Tester**: <who or what ran the test>

### Repro steps followed:
1. <what you actually did, step by step>
2. <be specific — name the dashboard, chart, page, action>
3. <include what you looked for and how you verified>

### Result:
**<One-sentence verdict.>** <2-3 sentences of narrative explaining what you observed. Be specific about what rendered, what didn't break, what you checked.>

### Evidence:
[<descriptive-filename.webm>](<shortcut media URL>)
```

### Writing Guidelines

- **Narrative over structure**: "Opened the dashboard, scrolled through all charts, hovered over cells to check for artifacts" beats "Scenario 1: Load dashboard: PASS"
- **Specific over generic**: Name the actual dashboard, chart, page, feature flag, user role
- **One video beats ten screenshots**: Record a Playwright video of the full repro flow
- **Verdict first, then details**: Lead with whether it passed, then explain what you saw
- **Link evidence inline**: Embed the video/screenshot URL directly, don't put it in a separate section
- **Keep it short**: If the fix works, say so in 3-4 sentences. Save long reports for failures.

### Example (real — sc-98396)

```markdown
## QA Verification — PASS ✅

**Tested on**: https://example.us1a.app-stg.preset.io (staging 6.0.0.6rc1)
**Date**: 2026-02-20
**Tester**: Playwright automation

### Repro steps followed:
1. Opened the existing "Treemap" chart (slice_id=14) from the World Bank's Data dashboard in Explore view
2. Chart rendered with dimensions: region, country_code and metric: Population Total
3. Visually inspected all treemap category rectangles across all regions
4. Hovered over multiple cells (CHN, IND, JPN, RUS, BRA, NGA) to verify no white lines appear on hover

### Result:
**Bug appears fixed.** No white vertical lines visible in the middle of any treemap category cells. The category rectangles render cleanly with solid colors and proper borders between cells only (not through them).

### Evidence:
[sc-98396-treemap-no-white-lines.webm](https://media.app.shortcut.com/...)
```

## Output

After posting, confirm what was done:

```markdown
## Shortcut Report Posted

- Story: sc-<id> (<story name>)
- Comment: posted (<comment link or confirmation>)
- Evidence: <N files uploaded / none>
- PR linked: <yes / no>
- State updated: <new state / unchanged>
```

## Notes

- Always fetch the story first to confirm it exists and get current state
- Upload evidence before posting comments so URLs are available for embedding
- Use Python for JSON body construction when the report contains newlines or special characters
- When updating `external_links`, merge with existing links — don't replace
- Prefer video evidence over screenshots for complex UI flows
- Keep reports factual — no speculation about cause or impact beyond what evidence shows
