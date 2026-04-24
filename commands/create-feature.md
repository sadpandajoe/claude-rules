# /create-feature - End-to-End Feature Workflow

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/orchestration.md
@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: You have a feature request or other planned non-bug work and want the repo-standard workflow to scope it, review it, implement it, and keep going until a real decision matters.
> **Produces**: Feature brief, milestones, implementation plan, reviewed plan, implemented local changes, review and QA results, and a handoff before the final commit or PR action.

## Contract

Non-negotiable guarantees this workflow maintains. If the workflow would skip any of these, stop and ask.

- [ ] Complexity Gate block emitted (step 1)
- [ ] PLAN.md written with plan content (step 3) — standard path only
- [ ] Review iterations meet threshold and cold read passes (step 4) — standard path only
- [ ] `/review-code` Review Gate block emitted (step 5)
- [ ] PROJECT.md updated with current state and (on completion) Completed entry
- [ ] Summary emitted (step 6)

## Plan Mode Boundary

Plan mode is for exploration and design only — step 2. Everything else (writing PLAN.md, launching reviewer agents, looping to 8/10) happens in normal mode, because plan mode is read-only except for the plan file and turns must end with `AskUserQuestion` or `ExitPlanMode`.

Standard path flow: complexity gate → plan mode (brief + tech plan draft) → exit plan mode → write PLAN.md (hard gate) → review iterations → implement + review → summarize.

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

- **Trivial**: skip to step 5. Update PROJECT.md with action items only (no PLAN.md).
- **Moderate**: skip plan mode. Design inline, write action items to PROJECT.md (no PLAN.md), then run the `iterate-plan-review` skill with `reviewer set: [plan-review/references/implementation.md]` and scope `moderate`. Continue from step 5. Escalate to STANDARD if complexity emerges.
- **Standard**: continue to step 2 — produces a formal plan in PLAN.md.

### 2. Plan Mode → Exploration + Design

Enter plan mode. Inside plan mode, produce a draft plan:

**a. Decide PM scope**: Use the PM layer when scope, milestones, acceptance criteria, or rollout framing are non-trivial. Skip when the work is already tightly scoped. State the decision explicitly.

**b. Create the feature brief**: If PM planning is needed, use the `pm` skill's [references/create-feature-brief.md](../skills/pm/references/create-feature-brief.md) with milestones via [references/plan-milestones.md](../skills/pm/references/plan-milestones.md). If skipped, synthesize a minimal brief from the request.

**c. Create the technical plan**: Use `plan-implementation.md` (follow the "For Features" guidance) to define technical approach, PR slices, migrations/API implications, test strategy, and implementation sequencing.

The deliverable from this step is a **draft plan** — a feature brief (when applicable) and a technical plan. Step 3 writes that draft to PLAN.md. Polish happens in step 4 review iterations, not here.

Exit plan mode when the draft is complete.

### 3. Write PLAN.md (hard gate)

After exiting plan mode, read the draft plan file and write its content into a new `PLAN.md` at the repo root with these sections:
- `Feature Brief`
- `Milestones` (if PM planning was used)
- `Implementation Plan`
- `Test Strategy`

Then update PROJECT.md with a pointer:
- Set current workflow + phase ("Working on: <feature>; phase: review")
- Add "Active plan: PLAN.md" pointer

**Do not proceed to step 4 until this confirmation block is emitted:**

```markdown
## PLAN.md Written
Sections: [list of sections written]
PROJECT.md updated: pointer to PLAN.md added
```

This gate ensures the plan is durable before review iterations begin. PLAN.md is loaded by the review iteration phase and again during implementation; PROJECT.md is the lightweight state pointer that subsequent sessions read first.

### 4. Review Iterations + Action Gate

Run the `iterate-plan-review` skill with these inputs:

- **Plan location**: `PLAN.md` (written in step 3)
- **PM brief review**: include when PM planning was used in step 2
- **Reviewer set**:
  - Always: `plan-review/references/architecture.md`, `plan-review/references/implementation.md`, `testing/references/review-testplan.md`
  - Conditional: `plan-review/references/frontend.md` when the plan touches UI; `plan-review/references/backend.md` when it touches API / DB / migrations
- **Scope**: same classification produced in step 1 (trivial / moderate / substantial) so the helper picks the right reviewer model
- **Action gate**: include (run the `action-gate` skill after cold read)

The helper handles parallel launch, 8/10 iteration loop, shallow-analysis escalation (Sonnet → Opus), cold read via `finalize-plan`, and appends final scores to PLAN.md. See its file for the full procedure.

After the helper returns, **print a brief summary in conversation** for approval / next step:
- What scored where (final scores per reviewer)
- Cold read verdict
- Action gate verdict
- Whether iterations introduced material plan changes (1–2 lines, not a full change log)

Auto-iterate the helper. Only stop for a user-blocking decision.

Update PROJECT.md: phase → "implementing".

### 5. Implement + Review

Implementation and review run as one tight loop.

**Standard / moderate path**: for each slice in the plan, spawn `implement-change.md` — it handles test-first execution per the mode the plan specified (test set as specification for features) and runs the slice's acceptance check. After each slice, run `/review-code` as an internal loop until only nitpicks remain, then update PROJECT.md phase to "implementing slice N of M". Run QA validation when the work is user-visible. **Stop before the final commit** — the commit boundary is a user decision for non-trivial work.

**Trivial path**: spawn `implement-change.md` for the change → run the actual test suite covering the changed files (`pytest -k ...`, `jest --testPathPattern ...` — pre-commit alone is not sufficient) → update PROJECT.md if present → commit (`feat:`) → push, but **only when verification is STRONG and review is clean**. **Stop before creating a PR** — PR creation remains a user decision even on the trivial path.

The reviewer emits a Review Gate block per `rules/review-gate.md`; branch on Status: `clean`, `blocked`, `user decision`, `skipped`. STRONG/PARTIAL/WEAK labels: per `rules/review-gate.md`. For truly minimal mechanical changes, the review loop may be skipped per the skip rule in `rules/review-gate.md`.

**Resuming from a pre-built plan**: enter at this step (skip steps 1–4), but still run the review loop and pre-flight checks before declaring done — do not skip the Review Gate because the plan was drafted in a prior session.

If a meaningful decision surfaces during implementation or review, stop and present it clearly.

### 6. Summary

Use the template at [skills/reporting/templates/create-feature-summary.md](../skills/reporting/templates/create-feature-summary.md) following the structural rules in [skills/reporting/SKILL.md](../skills/reporting/SKILL.md).

Lead with whether the feature ships and acceptance criteria are met — if the user gave you a ticket, answer whether it's done.

**Update PROJECT.md** (standard path only): on successful completion:
- Remove the "Active plan" pointer (PLAN.md is no longer driving active work)
- Append a "Completed" entry: `<date> — <feature>`

**Do not delete PLAN.md.** It persists in place after completion. Cleanup happens when the user explicitly runs `/archive-project-file` — workflows do not auto-delete files. If the workflow stopped before completion (blocker, escalation), leaving PLAN.md in place lets the next session pick up.

**Record metrics**: call the `metrics-emit` skill with:
- `command`: `create-feature`
- `complexity`: classification from step 1 (`trivial` / `moderate` / `standard`)
- `status`: outcome from step 5 Review Gate (`clean` / `blocked` / `user-decision` / `skipped` / `micro-fix`)
- `rounds`: total review iteration rounds from step 4 (0 for trivial path)
- `gate_decisions`: `{ complexity: <step 1>, action_gate: <step 4>, review: <step 5> }`
- `models_used`: subagent model invocation counts
