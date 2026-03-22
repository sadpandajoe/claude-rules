---
name: pgm-comms
description: Format program management content for a specific audience tier — executive, cross-functional, delivery, eng+QA, broad stakeholder, or escalation.
---

# Communication Formatting

You are formatting program management content for a specific audience. Transform the input (report data, status updates, risk summaries, etc.) into audience-appropriate output.

## Usage

```
/pgm-comms executive          # Format for exec audience
/pgm-comms delivery           # Format for delivery team
/pgm-comms escalation         # Format for escalation
```

If no audience is specified, infer from context:
- "summarize for leadership" → executive
- "update the team" → delivery
- "this needs to be escalated" → escalation
- Unclear → ask

## Audience Templates

### Executive

```markdown
**TL;DR**: [One sentence — what matters most right now]

**Status**: 🟢 On Track / 🟡 At Risk / 🔴 Blocked

**Impact**: [What this means for the business/product/users]

**Decisions Needed**:
- [Decision 1 — with recommendation]

**Timeline**: [Key dates or milestones]
```

**Rules**: No task lists. No technical jargon. No individual story details. Lead with impact. If there's nothing to decide, say so — execs value knowing their attention isn't needed.

### Cross-Functional Leadership

```markdown
## Summary
[2-3 sentences — what's happening across teams]

## Team Highlights
- **[Team]**: [Key accomplishment or focus area]

## Dependencies & Risks
- [Dependency/risk with owning team and status]

## Asks
- [What you need from other teams/stakeholders]
```

**Rules**: Balance detail across teams — don't let one team dominate. Flag cross-team dependencies explicitly. Every risk needs an owner.

### Delivery Team

```markdown
## Board Health
- **WIP**: [count] items in progress ([assessment])
- **Blocked**: [count] items ([brief details])
- **Stalled**: [count] items with no movement > 5 days

## Blockers
| Item | Owner | Blocked Since | Action Needed |
|------|-------|---------------|---------------|

## What Shipped
- [Item] — [who]

## What's Next
- [Item] — [who]

## Action Items
- [ ] [Action] — @[owner] — [due]
```

**Rules**: Every blocker needs an owner and action. Every "what's next" needs a name attached. No vague summaries — be specific about who's doing what.

### Eng+QA

```markdown
## Technical Status
[What's actively being built/tested]

## PR State
- **Open**: [count] ([count] awaiting review > 48h)
- **Merged this period**: [count]
- **Review backlog**: [details]

## Test & Build Health
[CI status, flaky tests, test coverage signals]

## Tech Debt / Risks
- [Technical risk or debt item with impact]
```

**Rules**: Include PR links where relevant. Be specific about CI/test state. Technical audience — use precise language, no hand-waving.

### Broad Stakeholder

```markdown
## What Launched
- **[Feature/Fix]**: [User-facing impact in plain language]

## Coming Up
- [Milestone] — [expected timing]

## How This Helps
[Connect technical work to user/business value]
```

**Rules**: No internal jargon (no "stories", "epics", "PRs"). Translate everything to user impact. Celebrate wins — this audience needs to see momentum.

### Escalation

```markdown
## What's At Risk
[One sentence — the thing that's at risk and why it matters]

## Business Impact
[Quantify if possible — users affected, revenue impact, timeline slip]

## What We've Tried
1. [Action taken] — [result]
2. [Action taken] — [result]

## The Ask
**[Specific decision or support needed]**
[Options if applicable, with trade-offs]

## Timeline
- **If we act by [date]**: [outcome]
- **If not**: [consequence]
```

**Rules**: Never bury the ask. Lead with what's at risk, not background. "What we've tried" proves you've done your homework. Always include a timeline with consequences.

## Anti-Patterns (applies across all audiences)

- **Don't pad with filler** — if there's nothing to report for a section, omit it
- **Don't mix audiences** — exec summary + task-level details = neither audience is served
- **Don't use passive voice for risks** — "the deadline might be missed" → "we will miss the deadline unless [action]"
- **Don't list without context** — "5 stories completed" means nothing without "which means the auth migration is 80% done"
- **Don't hedge without data** — "things seem okay" → "cycle time is 3.2 days, WIP is within limits, no blockers"

## Working Rules

- Match the format exactly — audiences develop expectations
- Use real names and real numbers — vagueness erodes trust
- If the input data is incomplete, say what's missing rather than papering over gaps
- Keep it scannable — headers, bullets, tables over paragraphs
- One message, one audience — if you need multiple audiences, produce multiple outputs
