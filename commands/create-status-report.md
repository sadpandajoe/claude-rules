# /create-status-report — Live Program Health Report

@{{TOOLKIT_DIR}}/rules/pgm.md

> **When**: Before meetings, weekly check-ins, or anytime you need a current snapshot of program health.
> **Produces**: Program health report with epic progress, flow health, risks, blockers, and team state.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /create-status-report [arguments]
- Phase: load-context / gather-data / synthesize / format / present
- Resume target: [current agent batch, synthesis step, or formatting step]
- Completed items: [data sources already gathered or sections already synthesized]
### State
- Team filter: [team or all]
- Epic filter: [epic or none]
- Audience: [audience or default]
- Pending blockers: [if any]
```

## Usage

```
/create-status-report                         # All teams
/create-status-report "Producks"              # One team
/create-status-report --epic "auth migration" # One epic across teams
/create-status-report --audience executive    # Format directly for a specific audience
```

## Steps

### 1. Load Context

- Read `$PGM_DIR/config.json` for team UUIDs, member list, bot accounts, repo mapping
- Parse arguments: team filter, epic filter, or all teams
- Set date context: today's date for "current state", last 14 days for "recently shipped"

### 2. Gather Data (Parallel Agents)

Use the **Agent tool** to spawn 2-3 agents **in a single message** (this is critical — multiple Agent tool calls in one message run concurrently). Each agent prompt must include instructions to:
- Read `{{TOOLKIT_DIR}}/rules/pgm.md` for API patterns
- Read `$PGM_DIR/config.json` for team UUIDs, members, bots
- Return structured JSON or markdown that the main context can synthesize

**Agent 1 — Shortcut REST API** (via `curl` with `$SHORTCUT_API_TOKEN`):
Follow `skills/shared/shortcut-fetch.md` for the retry wrapper, JSON parsing, and field shape gotchas.

Run all team queries in **parallel bash calls** (each team's queries are independent):
- **WIP stories** per team: `POST /stories/search` with `workflow_state_types: ["started"]` and `group_id`
  - Flag stories where `moved_at` > 5 days ago as stalled
  - Flag stories where `blocked == true` or `blocker == true`
  - Calculate WIP count per team member (from `owner_ids`)
- **Recently completed** per team: `POST /stories/search` with `completed_at_start` (14 days ago) and `group_id`
  - Include `cycle_time`, `story_type`, `epic_id`, `estimate`

That's 6 independent curl calls (2 per team) — run them all in parallel.

Then, from the results:
- **Epic details**: Collect unique `epic_id` values, then fetch `GET /epics/{id}` for each — these are also independent, run in parallel
  - Track completion percentage, state, remaining story count
- **Workflow states**: `GET /workflows` once to map state IDs → readable names

Handle pagination on all search calls. Filter out bot-owned stories.

**Agent 2 — GitHub CLI** (via `gh`):

Run all repo queries in **parallel bash calls** (each repo is independent):
- For each of the 3 repos, in parallel:
  - **Open PRs**: `gh pr list -R <repo> --state open --limit 100 --json number,title,author,createdAt,reviewDecision,url,labels`
  - **Recently merged**: `gh pr list -R <repo> --state merged --limit 200 --json number,title,author,mergedAt,url --search "merged:>YYYY-MM-DD"` (14 days ago)

That's 6 independent gh calls (2 per repo) — run them all in parallel.

Then aggregate:
- Flag PRs open > 48 hours without approved review
- Filter out bot authors from `config.json` bots list
- Count review backlog: PRs where `reviewDecision` is empty or "REVIEW_REQUIRED"

**Agent 3 — Notion MCP** (optional, skip gracefully if nothing found):
- `notion-search` for recent meeting notes, prior program reports, or open action items
- Only include if results are directly relevant
- If no Notion results, return empty — don't block on this

### 3. Synthesize Report

Combine agent results into a structured report:

```markdown
# Program Health — [date]
[Team filter if applicable]

## Epic Progress
For each active epic:
- **[Epic name]** — [X/Y stories done] — [status: on track / at risk / blocked]
  - [Key recent completions]
  - [Remaining work summary]
  - [Risk if any]

## Flow Health
- **WIP**: [total] across [teams] ([per-team breakdown])
  - [Flag if any team > 2× member count]
- **Cycle Time**: [median] days (last 14 days)
- **Throughput**: [count] stories completed in last 14 days
- **Stalled**: [count] stories with no movement > 5 days
  - [List each with owner and current state]

## Risks & Blockers
Auto-detected from signals:
- Blocked stories (from Shortcut `blocked`/`blocker` fields)
- Stalled work (no state change > 5 days)
- Review backlog (PRs pending review > 48h)
- High WIP (team WIP > 2× team size)
- Epics at risk (low completion rate vs timeline)

For each risk:
- **[Risk]** — [Impact] — [Owner/Team] — [Suggested action]

## Team State
Per team:
- **[Team name]** — [WIP count] in progress, [completed count] shipped (14d)
  - [Who's working on what — from story owners]
  - [Capacity signals — anyone overloaded (>3 WIP items)?]

## PR State
- **Open**: [count] across repos ([count] awaiting review > 48h)
- **Merged (14d)**: [count]
- **Review backlog**: [list PRs needing attention]

## Recently Shipped
- [Story/PR name] — [team] — [completed date]
  (Group by team, most recent first, limit to ~10 most notable)
```

### 4. Present & Follow Up

Present the report.

If `--audience <mode>` is provided, format the final output for that audience using `pgm/comms.md`.

Otherwise, present the default detailed report and suggest follow-up actions:

- "Summarize this for execs" → use the internal PGM formatting skill with `executive` audience
- "What are the biggest risks?" → deeper analysis from report data
- "Write a status update" → use the internal PGM formatting skill with the requested audience
- "Focus on [team/epic]" → filter and expand that section

## Notes

- This is a **live snapshot** — data is current as of query time, not historical
- For historical metrics and trends, use `/create-velocity-report` instead
- The report identifies risks from signals but doesn't prescribe solutions — that's a conversation
- If Shortcut API is unavailable, fall back to Shortcut MCP tools (slower, permission prompts)
