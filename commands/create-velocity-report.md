# /create-velocity-report — Monthly Velocity Metrics

@/Users/joeli/opt/code/ai-toolkit/rules/universal.md
@/Users/joeli/opt/code/ai-toolkit/rules/pgm.md

> **When**: End of month (or anytime you need historical velocity metrics).
> **Produces**: Full velocity report with throughput, cycle times, PR metrics, and team breakdowns.

## Pre-flight

This command is data-heavy — pipeline output and follow-up analysis need context room. Before starting, follow the **Context Management** protocol from `rules/universal.md`:
1. If context is at or above ~70%, write a **continuation checkpoint** to PROJECT.md (including the `/create-velocity-report` arguments like `--month`), commit, then `/clear` → `/start` to resume
2. If context is below ~70% but above ~50%, check whether the pipeline output + follow-up conversation will fit — if tight, checkpoint and clear
3. Then proceed with Step 1

Use this checkpoint shape:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /create-velocity-report [arguments]
- Phase: load-context / read-pipeline / collect-data / process / validate / present
- Resume target: [current pipeline step or data file]
- Completed items: [collection steps or processing steps already finished]
### State
- Month: [target month]
- Summary-only: [yes/no]
- Audience: [audience or default]
- Pending blockers: [if any]
```

## Usage

```
/create-velocity-report                       # Current month from config.json
/create-velocity-report --month 2026-03       # Specific month
/create-velocity-report --summary-only        # Exec summary from existing metrics.json
/create-velocity-report --audience executive  # Format the final output for a specific audience
```

## Steps

### 1. Load Context

- Read `/Users/joeli/opt/code/pgm/config.json` for current `month`, `date_range`, teams, members, repos
- If `--month` provided and differs from config, tell the user to update `config.json` first (the pipeline reads config directly)
- If `--summary-only`, skip to Step 5

### 2. Read Pipeline Instructions

- Read `/Users/joeli/opt/code/pgm/run.md` for the full pipeline instructions
- Follow those instructions — they are the authoritative source for how the pipeline runs

### 3. Execute Pipeline

Follow the steps in `run.md`:

**3a. Start GitHub collection in background:**
```bash
cd /Users/joeli/opt/code/pgm && python3 collect_github.py
```
This takes ~5-10 min. Continue to 3b while it runs.

**3b. Collect Shortcut data (while GitHub runs in background):**

Use the Shortcut REST API (preferred) via `curl` with `$SHORTCUT_API_TOKEN`.

**Important**: The Shortcut API returns transient errors (e.g., `organization2_missing`) on the first call of a session. This is expected. Retry the exact same request once before reporting any error. See `rules/shortcut-api.md` for the retry wrapper pattern.

Run all team queries in **parallel bash calls** — each team's queries are independent:
- **Completed stories** per team: `POST /stories/search` with `completed_at_start`/`completed_at_end` from config date range, `group_id`
- **WIP snapshot** per team: `POST /stories/search` with `workflow_state_types: ["started"]`, `group_id`

That's 6 independent curl calls (2 per team × 3 teams) — run them all in parallel in a single message. Handle pagination on each.

Also collect:
- **Iterations**: overlapping the target month
- **Epics**: for all unique `epic_id` values found in completed stories

Save to `data/{month}/`:
- `raw_stories.json` — all completed stories
- `raw_wip.json` — all WIP stories
- `raw_iterations.json` — iteration objects
- `raw_epics.json` — epic objects

**3c. Wait for GitHub collection to finish.**

**3d. Run processing pipeline sequentially:**
```bash
cd /Users/joeli/opt/code/pgm && python3 collect_shortcut.py
cd /Users/joeli/opt/code/pgm && python3 analyze.py
cd /Users/joeli/opt/code/pgm && python3 report.py
```

### 4. Validate Output

Read `data/{month}/report.md` and `data/{month}/metrics.json`.

Flag data quality issues:
- Teams with 0 completed stories (collection may have failed)
- Negative cycle time values (timestamp issues)
- Individual PR counts that seem too high or low vs team size
- Large numbers of unlinked stories/PRs (Shortcut ↔ GitHub linkage gaps)

### 5. Present Report

Read and present `data/{month}/report.md` to the user.

If `--summary-only`: read `data/{month}/metrics.json` and produce a concise executive summary using:

@/Users/joeli/opt/code/ai-toolkit/skills/pgm/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/pgm/comms.md

with `executive` audience.

If `--audience <mode>` is provided, format the final output for that audience using the same internal PGM formatting skill.

Suggest follow-up actions:
- "What trends do you see?" → analyze metrics.json for patterns
- "Compare to last month" → read prior month's `data/{prev-month}/metrics.json` if it exists
- "Summarize for leadership" → use the internal PGM formatting skill with `executive` audience
- "Who's blocked?" / "Where are the bottlenecks?" → dig into specifics from raw data
- "Break this down by team" → team-level analysis from metrics.json

## Notes

- This wraps the existing Python pipeline in `/Users/joeli/opt/code/pgm/`
- The pipeline is the authoritative source for metric calculations — don't reimplement metrics manually
- For live/current-state data, use `/create-status-report` instead
- If the pipeline fails, read the error output and diagnose — don't silently skip steps
- Raw data files can be re-analyzed without re-collecting: skip to Step 3d if `raw_*.json` files already exist for the month
- If a `/clear` is needed mid-run, write the continuation checkpoint in the format above before resuming through `/start`
