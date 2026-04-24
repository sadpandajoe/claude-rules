# /create-feature - End-to-End Feature Workflow

@{{TOOLKIT_DIR}}/rules/planning.md
@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/orchestration.md
@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: You have a feature request or other planned non-bug work and want the repo-standard workflow to scope it, review it, implement it, and keep going until a real decision matters.
> **Produces**: Feature brief, milestones, implementation plan, reviewed plan, implemented local changes, review and QA results, and a handoff before the final commit or PR action.

## Contract

Non-negotiable guarantees this workflow maintains. If the workflow would skip any of these, stop and ask.

- [ ] Complexity Gate block emitted (step 1)
- [ ] PROJECT.md written with plan content (step 3) — standard path only
- [ ] Review iterations meet threshold and cold read passes (step 4) — standard path only
- [ ] `/review-code` Review Gate block emitted (step 5)
- [ ] PROJECT.md updated with final status
- [ ] Summary emitted (step 6)

## Plan Mode Boundary

Plan mode is for exploration and design only — step 2. Everything else (writing PROJECT.md, launching reviewer agents, looping to 8/10) happens in normal mode, because plan mode is read-only except for the plan file and turns must end with `AskUserQuestion` or `ExitPlanMode`.

Standard path flow: complexity gate → plan mode (brief + tech plan draft) → exit plan mode → PROJECT.md hard gate → review iterations → implement + review → summarize.

Moderate and trivial paths skip plan mode. See `rules/complexity-gate.md` for canonical path behavior; step 1 below lists only the feature-specific overrides.

## Usage
```
/create-feature "add bulk edit for dashboard filters"
/create-feature sc-12345
/create-feature apache/superset#28456
/create-feature https://github.com/owner/repo/issues/123
/create-feature https://app.shortcut.com/.../story/123
```

## Steps

### 1. Normalize Input + Complexity Gate

Accept plain-language feature requests, Shortcut story IDs/URLs, or GitHub issue/PR references.

When a ticket URL or reference is provided, **fetch and parse it FIRST** before any planning or code investigation. The ticket's scope, acceptance criteria, and constraints are authoritative — don't re-derive from scratch.

Run the complexity gate as one sequence: classify → emit → route.

**a. Classify** using these feature-specific signals:

| Signal | Trivial | Moderate | Standard |
|--------|---------|----------|----------|
| Files touched | 1–2 | 2–4, single subsystem | 3+ or unclear scope |
| Design decisions | None | None, known pattern | Any real trade-offs |
| New APIs / migrations | No | Minor (add endpoint, extend model) | Yes, cross-system |
| Behavioral risk | Mechanical / cosmetic | Contained functional change | Cross-cutting functional change |

**b. Emit** the Complexity Gate block using the format in `rules/complexity-gate.md`. That rule also defines auto-proceed and general routing behavior — do not re-state it here.

**c. Route** per the classification. These are the feature-specific overrides to the rule's canonical paths:

- **Trivial**: skip to step 5.
- **Moderate**: skip plan mode. Design inline, write to PROJECT.md (same hard gate as step 3), then run the `iterate-plan-review` skill with `reviewer set: [review-implementation]` and scope `moderate`. Continue from step 5. Escalate to STANDARD if complexity emerges.
- **Standard**: continue to step 2.

### 2. Plan Mode → Exploration + Design

Enter plan mode. Inside plan mode, produce a draft plan:

**a. Decide PM scope**: Use the PM layer when scope, milestones, acceptance criteria, or rollout framing are non-trivial. Skip when the work is already tightly scoped. State the decision explicitly.

**b. Create the feature brief**: If PM planning is needed, use `pm-create-feature-brief.md` with milestones via `pm-plan-milestones.md`. If skipped, synthesize a minimal brief from the request.

**c. Create the technical plan**: Use `plan-implementation.md` (follow the "For Features" guidance) to define technical approach, PR slices, migrations/API implications, test strategy, and implementation sequencing.

The deliverable from this step is a **draft plan** — a feature brief (when applicable) and a technical plan. Step 3 translates that draft into PROJECT.md sections. Polish happens in step 4 review iterations, not here.

Exit plan mode when the draft is complete.

### 3. Write PROJECT.md (hard gate)

After exiting plan mode, read the draft plan file and write its content into PROJECT.md sections:
- `Feature Brief`
- `Milestones` (if PM planning was used)
- `Implementation Plan`
- `Test Strategy`

**Do not proceed to step 4 until this confirmation block is emitted:**

```markdown
## PROJECT.md Updated
Sections written: [list of sections written]
```

This gate ensures the plan is durable before review iterations begin. If the plan is only in conversation or in a plan file, it can be lost on context refresh.

### 4. Review Iterations + Action Gate

Run the `iterate-plan-review` skill with these inputs:

- **Plan location**: PROJECT.md sections written in step 3
- **PM brief review**: include when PM planning was used in step 2
- **Reviewer set**:
  - Always: `review-architecture`, `review-implementation`, `review-testplan`
  - Conditional: `review-frontend` when the plan touches UI; `review-backend` when it touches API / DB / migrations
- **Scope**: same classification produced in step 1 (trivial / moderate / substantial) so the helper picks the right reviewer model
- **Action gate**: include (run `action-gate.md` after cold read)

The helper handles parallel launch, 8/10 iteration loop, shallow-analysis escalation (Sonnet → Opus), cold read via `finalize-plan`, and writing final scores to PROJECT.md. See its file for the full procedure.

This is the main quality gate. Auto-iterate — only stop for a user-blocking decision.

### 5. Implement + Review

Implementation and review run as one tight loop.

**Standard / moderate path**: for each slice in the plan, spawn `implement-change.md` — it handles test-first execution per the mode the plan specified (test set as specification for features) and runs the slice's acceptance check. After each slice, run `/review-code` as an internal loop until only nitpicks remain. Run QA validation when the work is user-visible. **Stop before the final commit** — the commit boundary is a user decision for non-trivial work.

**Trivial path**: spawn `implement-change.md` for the change → run the actual test suite covering the changed files (`pytest -k ...`, `jest --testPathPattern ...` — pre-commit alone is not sufficient) → update PROJECT.md if present → commit (`feat:`) → push, but **only when verification is STRONG and review is clean**. **Stop before creating a PR** — PR creation remains a user decision even on the trivial path.

The reviewer emits a Review Gate block per `rules/review-gate.md`; branch on Status: `clean`, `blocked`, `user decision`, `skipped`. STRONG/PARTIAL/WEAK labels: per `rules/review-gate.md`. For truly minimal mechanical changes, the review loop may be skipped per the skip rule in `rules/review-gate.md`.

If a meaningful decision surfaces during implementation or review, stop and present it clearly.

### 6. Summary

Use the template at [skills/reporting/templates/create-feature-summary.md](../skills/reporting/templates/create-feature-summary.md) following the structural rules in [skills/reporting/SKILL.md](../skills/reporting/SKILL.md).

Lead with whether the feature ships and acceptance criteria are met — if the user gave you a ticket, answer whether it's done.

## PROJECT.md Update Discipline

**Standard path:**
- **step 3** — after exiting plan mode, flush the draft plan into PROJECT.md. This is the first write and a hard gate.
- **step 4** — after review iterations complete, update with final review scores.
- after implementation and validation complete.

## Continuation Checkpoint

Use the template at [skills/reporting/templates/create-feature-checkpoint.md](../skills/reporting/templates/create-feature-checkpoint.md) following the structural rules in [skills/reporting/SKILL.md](../skills/reporting/SKILL.md).

**Resuming from a pre-built plan**: enter at step 5 (implement + review), but still run the review loop and pre-flight checks before declaring done — do not skip the Review Gate because the plan was drafted in a prior session.
