---
name: iterate-plan-review
description: Iterate a written plan through parallel reviewer subagents until it meets the quality threshold (default 8/10), then run a cold-read finalization. Internal helper called by /create-feature, /review-plan, and any workflow that produces a plan and needs structured review before proceeding.
user-invocable: false
disable-model-invocation: true
---

# Iterate Plan Review

Shared procedure for running parallel reviewer subagents against a written plan, iterating until threshold, then finalizing with a cold read.

This skill iterates **reviews of a plan**, not iterations of code review. It is an internal helper — callers reference it explicitly; users do not invoke it.

## Inputs

The caller provides:

- **Plan location**: where the plan lives (usually PROJECT.md sections, sometimes a plan file)
- **Reviewer set**: which reviewers to run. Always + conditional:
  - Always: whichever reviewers the caller designates as mandatory
  - Conditional: add based on what the plan actually touches
- **Scope**: `trivial` / `moderate` / `substantial` — determines model tier
- **Optional PM brief review**: when the plan has a feature brief that needs `review-feature-brief`
- **Optional action gate**: when the caller wants an action gate block after cold read

## Threshold

Default: **8/10 or better** on every applicable reviewer, plus a **Go** from cold read.

## Procedure

### 1. PM Brief Review (optional)

When the caller provides PM context:

- Spawn `review-feature-brief` as a subagent
- Model: `sonnet` by default; escalate to `opus` only when the brief covers multi-system rollout or material business risk
- Revise the brief until 8/10
- If the brief reaches 8/10 after the first pass, proceed to technical plan review

### 2. Technical Plan Review

Launch all applicable technical reviewers **in parallel** as subagents. Always-on reviewers:

- `review-architecture`
- `review-implementation`
- `review-testplan`

Add conditional reviewers when the plan touches their area:

- `review-frontend` — React, CSS, UI components
- `review-backend` — API, database, migrations

**Model selection** per the scope input (see `rules/orchestration.md`):

- `trivial` / `moderate` — `model: "sonnet"`
- `substantial` — `model: "opus"` (multi-system, real trade-offs, novel design, ambiguous constraints)

Each reviewer:
- Reads the plan from the location provided by the caller
- Loads its own skill file (subagents load their own domain rules)
- Produces a scored review block (X/10 with strengths, issues, suggestions)

### 3. Iterate Until Threshold

After collecting scores:

- **All reviewers ≥ 8/10** → proceed to cold read
- **Any reviewer below 8/10** → revise the plan based on feedback, then re-run **only the failing reviewers** (not all of them)
- Auto-iterate — do not ask the user whether to continue or which reviewers to re-run
- Only stop for a blocking decision that requires user input, or if stop rules in `rules/stop-rules.md` trigger

**Shallow-analysis escalation**: If a Sonnet reviewer scored low because their analysis was shallow (not because the plan has real issues), re-run that specific reviewer on `model: "opus"` rather than revising a plan that doesn't need revising.

### 4. Cold Read

Spawn `finalize-plan` as a fresh-eyes final check. Match the model to the plan's reasoning load (same rule as step 2).

- **Go** → proceed to step 5
- **No-Go** with blocking issues → revise and re-run `finalize-plan`
- **No-Go** after two revisions → stop and surface the blocking issues to the user

### 5. Write Final Scores

Append or update the scores in the plan location (usually PROJECT.md):

```markdown
## Plan Review Scores
| Reviewer | Score |
|----------|-------|
| Architecture | X/10 |
| Implementation | X/10 |
| Test Plan | X/10 |
| [conditional reviewers] | X/10 |
| Cold Read | Go / No-Go |
```

### 6. Action Gate (optional)

When the caller requested an action gate, run the `action-gate` skill after cold read passes. Auto-proceed when Risk is LOW, Confidence ≥ 8/10, and no decision is required.

## Output

Return to the caller:

- Final scores per reviewer
- Cold read verdict (Go / No-Go)
- Action gate verdict (if run)
- Count of iteration rounds
- Any user-blocking decisions that surfaced

## Notes

- This procedure replaces inline "review iteration" logic previously duplicated in `/create-feature` step 4 and `/review-plan` body. Both commands call this helper.
- Subagents load their own skill files — the caller references skill paths but does not `@`-import them into this helper.
