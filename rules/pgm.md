# Program Management Context

@/Users/joeli/opt/code/ai-toolkit/rules/api.md

## Org Structure

Joe Li is an EM running 3 teams on kanban across 3 repos. Teams use flow-based delivery — frame everything around WIP, cycle time, throughput, and blockers. Not sprints.

### Teams

| Team | Shortcut Group ID | Mention Name | Repo Focus |
|------|-------------------|--------------|------------|
| Producks | `5fc58cd7-0bce-4412-820f-26e75af61e5a` | `engineering` | apache/superset (features, UI) |
| Pladopi | `67ad4529-6cca-45f8-a516-42a2bad75f93` | `platform-devops` | preset-io/manager, preset-io/superset-shell |
| Supernauts | `696a884d-23ba-44b5-8e7f-5c7e4ba32f4d` | `supernauts` | apache/superset (onboarding, enablement) |

### Member Resolution

**Canonical source**: `/Users/joeli/opt/code/pgm/config.json`

Always read `config.json` for the full member list with GitHub handles, Shortcut IDs, team assignments, and notes (QA, PM, Designer, EM roles). Do not hardcode member lists — the config is the source of truth.

Bot accounts to filter from metrics: listed in `config.json` under `bots`.

### Repo Mapping

| Repo | Strategy | Local Path |
|------|----------|------------|
| `apache/superset` | `per_member` — query by team member GitHub handles | `/Users/joeli/opt/code/superset-release` |
| `preset-io/superset-shell` | `all_prs` — query all PRs in date range | `/Users/joeli/opt/code/superset-shell` |
| `preset-io/manager` | `all_prs` — query all PRs in date range | `/Users/joeli/opt/code/manager` |

## API Reference

See `rules/api.md` for all API patterns (Shortcut REST, GitHub CLI, Notion MCP, Shortcut MCP). For PGM commands, prefer Shortcut REST API over MCP — faster, no permission prompts, richer fields.

## Parallel Agent Pattern

When gathering data from multiple sources, spawn concurrent agents to maximize throughput:

```
Agent 1 (Shortcut REST API):
  - Completed stories per team (POST /stories/search with completed_at filters)
  - WIP stories per team (workflow_state_types: started)
  - Blocked/blocker stories
  - Epic details for referenced epics
  - Calculate: WIP per member, stalled stories (moved_at > 5 days ago), type distribution

Agent 2 (GitHub CLI):
  - Open PRs per repo (flag those > 48h without review)
  - Recently merged PRs
  - Review backlog

Agent 3 (Notion MCP, optional):
  - Prior reports or meeting notes
  - Open action items
  - Skip gracefully if nothing relevant found
```

Each agent should:
- Read `config.json` for team/member context
- Filter out bot accounts
- Return structured data for synthesis

## Audience Tiers

Used by `pgm-comms` skill for formatting. Referenced here so commands know what audience modes are available.

| Audience | Focus | Tone |
|----------|-------|------|
| **Executive** | Impact, decisions needed, timeline | Brief, outcome-oriented |
| **Cross-functional** | Dependencies, risks, team highlights | Collaborative, actionable |
| **Delivery** | Board health, blockers, what shipped/next | Direct, owner-tagged |
| **Eng+QA** | PRs, test signals, build health, tech debt | Technical, specific |
| **Broad stakeholder** | What launched, user impact, milestones | Accessible, celebratory |
| **Escalation** | What's at risk, what's been tried, the ask | Urgent, structured |

## Data Collection Rules

1. **Always paginate** — Shortcut search results may span multiple pages
2. **Filter bots** — exclude accounts listed in `config.json` `bots` array from all metrics
3. **State query date** — use today's date for "current state" queries, config dates for historical
4. **Stale threshold** — stories with `moved_at` > 5 days ago and still in progress are flagged as stalled
5. **PR age threshold** — open PRs without review activity > 48 hours are flagged
6. **Cycle time source** — use `cycle_time` field from Shortcut (seconds), convert to days for display
