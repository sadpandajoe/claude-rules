# /review-plan - One-Off Plan Review

@{{TOOLKIT_DIR}}/rules/orchestration.md
@{{TOOLKIT_DIR}}/rules/stop-rules.md

> **When**: You have a plan in PROJECT.md and want a quality review without the full `/create-feature` workflow.
> **Produces**: Reviewed plan with all applicable reviewers at 8/10, cold read passed, and final scores in PROJECT.md.

## Usage

```
/review-plan
/review-plan --pm
```

`--pm`: Include PM brief review (`pm/references/review-feature-brief.md`) in addition to technical reviewers.

## Steps

### 1. Read the Plan

Read PROJECT.md. Verify it contains a plan with at least one of:
- `Implementation Plan` or `Accepted Solution` section
- `Test Strategy` section
- `Feature Brief` section

If no plan content found, stop: `"No plan found in PROJECT.md. Write a plan first, then run /review-plan."`

### 2. Assess Plan Scope and Select Reviewers

Assess the plan's complexity to determine reviewer depth:

| Plan scope | Reviewers | Cold read |
|------------|-----------|-----------|
| **Moderate** — single subsystem, well-understood pattern, no architectural decisions | 1 reviewer: `review-implementation` | `finalize-plan` |
| **Substantial** — multi-system, real trade-offs, novel design, or ambiguous constraints | 3+ reviewers: `review-architecture` + `review-implementation` + `testing/references/review-testplan.md` | `finalize-plan` |

**Conditional reviewers** (add to substantial plans when applicable):
- `review-frontend` — if plan touches frontend (React, CSS, UI components)
- `review-backend` — if plan touches backend (API, database, migrations)
- `pm/references/review-feature-brief.md` — if `--pm` flag or plan has a `Feature Brief` section with scope/milestones

State the scope assessment, which reviewers are selected, and why before launching.

### 3. Review Iterations

Launch selected reviewer subagents in parallel. **Choose the reviewer model based on the actual plan complexity**, per `rules/orchestration.md`:
- **Moderate plan**: use `model: "sonnet"`.
- **Substantial plan** (multi-system, real trade-offs, novel design, ambiguous constraints): use `model: "opus"`.

When mixed, default to Sonnet and escalate the specific failing reviewer to Opus on re-run if the Sonnet pass scored low for shallow analysis (not for legitimate plan issues). Each reviewer:
- Reads PROJECT.md for the plan content
- Loads its own skill file (subagents load their own domain rules)
- Produces a scored review block (X/10 with strengths, issues, suggestions)

After collecting scores:
- If all reviewers are at 8/10 or better → proceed to step 4
- If any reviewer is below 8/10 → revise the plan in PROJECT.md based on their feedback, then re-run **only the failing reviewers**
- Auto-iterate — do not ask the user whether to continue or which reviewers to re-run
- Only stop for a blocking decision that requires user input, or if stop rules trigger

### 4. Cold Read

Run `finalize-plan` as a fresh-eyes final check:
- If **Go** → proceed to step 5
- If **No-Go** with blocking issues → revise the plan and re-run finalize-plan
- If **No-Go** after two revisions → stop and surface the blocking issues to the user

### 5. Update PROJECT.md

Write final review scores to PROJECT.md:

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

### 6. Summary

```markdown
## Review-Plan Complete
[1-2 lines: plan quality assessment and whether it's ready for implementation]

### Review Scores
| Reviewer | Score |
|----------|-------|
| [reviewer] | [score] |

### Key Revisions
- [What changed based on review feedback — omit if no revisions needed]

### What to do next
- [Implement via /create-feature or start implementation directly]
```

## Non-Negotiable Gates

- [ ] All applicable reviewers at 8/10
- [ ] Cold read passed (Go)
- [ ] PROJECT.md updated with final scores
- [ ] Summary emitted

## PROJECT.md Update Discipline

- After review iterations complete: write final scores
- If revisions were made: the plan sections in PROJECT.md are updated as part of each revision

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /review-plan [flags]
- Phase: read-plan / detect-reviewers / review-iterations / cold-read / update / summarize
- Resume target: [current reviewer or iteration round]
- Completed items: [reviewers already at 8/10]
### State
- Reviewers selected: [list]
- Current scores: [reviewer: score, ...]
- Cold read: [go / no-go / pending]
- Revisions made: [count]
```

## Notes
- Standalone command — `/create-feature` step 4 does the same work inline, but this is for one-off use
- Does not create or implement the plan — only reviews an existing one
- Subagents load their own skill files; this command references skill paths but does not `@`-import them
