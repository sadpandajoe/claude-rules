# /create-feature - End-to-End Feature Workflow

@{{TOOLKIT_DIR}}/rules/planning.md
@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/orchestration.md
@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: You have a feature request or other planned non-bug work and want the repo-standard workflow to scope it, review it, implement it, and keep going until a real decision matters.
> **Produces**: Feature brief, milestones, implementation plan, reviewed plan, implemented local changes, review and QA results, and a handoff before the final commit or PR action.

## Plan Mode Boundary

Plan mode is for **exploration and design only** — step 2 below. Review iterations (step 4) happen in **normal mode** after plan mode exit, where agents can be launched freely and PROJECT.md can be written.

**Why reviews live outside plan mode**: Plan mode constrains turn-ending behavior ("end turns with AskUserQuestion or ExitPlanMode") and is read-only except for the plan file. Review iterations need to launch multiple reviewer agents, auto-loop to 8/10, and write to PROJECT.md — all of which conflict with plan mode constraints. Separating them eliminates the ambiguity.

**Standard path**:
1. Complexity gate in normal mode (must be visible in conversation).
2. Enter plan mode for exploration + design (PM brief, tech plan draft).
3. Exit plan mode → write draft plan to PROJECT.md (hard gate).
4. Review iterations in normal mode (agents, auto-loop, cold read).
5. Implement, review, summarize.

**Moderate path**: Skip plan mode. Orchestrator designs inline, spawns one reviewer subagent. See step 1 for details.

**Trivial path**: Skip plan mode entirely. Implement → `/review-code` → summary.

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

Accept:
- plain-language feature request
- Shortcut story ID or URL
- GitHub issue or PR reference / URL

When a ticket URL or issue reference is provided, **fetch and parse it FIRST** before any planning or code investigation. Extract scope, acceptance criteria, and constraints from the source. These are authoritative — don't re-derive scope from scratch.

Then assess complexity:

| Signal | Trivial | Moderate | Standard |
|--------|---------|----------|----------|
| Files touched | 1–2 | 2–4, single subsystem | 3+ or unclear scope |
| Design decisions | None | None, known pattern | Any real trade-offs |
| New APIs / migrations | No | Minor (add endpoint, extend model) | Yes, cross-system |
| Behavioral risk | Mechanical / cosmetic | Contained functional change | Cross-cutting functional change |

Emit the Complexity Gate block per `rules/complexity-gate.md`.

**Trivial + confidence 8/10+**: Skip to the trivial path — step 5.

**Moderate + confidence 8/10+**: Skip plan mode and full reviewer army. Orchestrator designs inline:
1. Explore and design in the main thread (no plan mode, no investigation subagents)
2. Write plan to PROJECT.md (same hard gate as step 3)
3. Spawn **one** reviewer subagent (`review-implementation`, `model: "sonnet"`) + cold read (`finalize-plan`) — 2 spawns instead of 5–6
4. Implement, `/review-code`, summary (same as standard steps 5–7)

If design reveals the feature is more complex than expected, escalate to STANDARD and enter plan mode.

**Standard**: Continue to step 2. Make this decision yourself and continue automatically — do not ask the user whether to run review iterations, which reviewers to use, or whether the plan is "good enough." End-to-end commands own their internal loops.

### 2. Plan Mode → Exploration + Design

Enter plan mode. Inside plan mode, do all of the following:

**a. Decide PM scope**: Use the PM layer when scope, milestones, acceptance criteria, or rollout framing are non-trivial. Skip when the work is already tightly scoped. State the decision explicitly.

**b. Create the feature brief**: If PM planning is needed, use `pm-create-feature-brief.md` with milestones via `pm-plan-milestones.md`. If skipped, synthesize a minimal brief from the request.

**c. Create the technical plan**: Use `plan-feature.md` to define technical approach, PR slices, migrations/API implications, test strategy, and implementation sequencing.

Exit plan mode when you have a draft feature brief and technical plan. These do not need to be polished — review iterations in step 4 will refine them.

### 3. Write PROJECT.md (hard gate)

After exiting plan mode, read the plan file. Write its content into PROJECT.md sections:
- `Feature Brief`
- `Milestones` (if PM planning was used)
- `Implementation Plan`
- `Test Strategy`

**Do not proceed to step 4 until this confirmation block is emitted:**

```markdown
## PROJECT.md Updated
Sections written: [list of sections written]
```

This gate ensures the plan is durable before review iterations begin. If the plan is only in conversation or a plan file, it can be lost on context refresh.

### 4. Review Iterations + Action Gate

Now in normal mode, iterate the plan using reviewer agents. This is the main quality gate.

**a. PM brief review** (if PM planning was used): Spawn a `review-feature-brief` reviewer subagent with `model: "sonnet"` per `rules/orchestration.md` — PM briefs are scoped reviews. Use `model: "opus"` only if the brief covers multi-system rollout or material business risk. Revise until 8/10.

**b. Technical plan review**: Always run these reviewers in parallel:
- `review-architecture`
- `review-implementation`
- `review-testplan`

Add when the plan needs them:
- `review-frontend`
- `review-backend`

**Choose the reviewer model based on actual plan complexity**, per `rules/orchestration.md`:
- **Trivial plan** (single subsystem, mechanical change, no architectural decisions): `model: "sonnet"`
- **Substantial plan** (multi-system, real trade-offs, novel design, ambiguous constraints): `model: "opus"`

Revise the plan until all applicable reviewers are at 8/10 or better. Run iterations automatically — do not ask the user whether to continue or which reviewers to use. Only stop for a blocking decision that requires user input.

If a Sonnet reviewer scored low for *shallow analysis* (lack of depth) rather than legitimate plan issues, re-run that specific reviewer on `model: "opus"`.

**c. Cold read**: Spawn `finalize-plan` as a fresh-eyes final check. Match the model to the plan's reasoning load (same rule as 4b — `model: "sonnet"` for trivial-to-moderate plans, `model: "opus"` for substantial cross-system plans). If it finds a blocking issue, revise and re-run.

**d. Action gate**: Run `action-gate.md`. Auto-proceed when Risk is LOW, Confidence ≥ 8/10, and no decision is required.

Update PROJECT.md with final review scores after this step.

### 5. Implementation

**Standard path** (from step 4):
- For each implementation slice, define the acceptance or regression test first
- Write the failing test before the code change when feasible
- If test-first is blocked by env, repro, or harness constraints, write the test anyway and record the verification gap — writing is separate from running
- For mechanical changes (renames, config swaps, endpoint changes with no new logic), writing tests alongside the implementation is acceptable — record why test-first was skipped
- Implement the feature through `developer`
- Run QA validation when the work is user-visible

**Trivial path** (from step 1):
1. Implement the change
2. Run the actual test suite covering the changed files (`pytest -k ...`, `jest --testPathPattern ...`) — pre-commit alone is not sufficient
3. Update PROJECT.md (single update) — skip if no PROJECT.md exists and work completes without blockers

If a meaningful decision surfaces during implementation, stop and present it clearly.

### 6. Review Changed Files (gate)

Run `/review-code` on changed repo-tracked files as an internal loop. Keep iterating until only nitpicks remain or a real blocker/user decision appears.

The developer emits a Review Gate block per `rules/review-gate.md`. Callers branch on Status: `clean`, `blocked`, `user decision`, `skipped`.

For truly minimal mechanical changes (renames, config swaps), the review loop may be skipped per the skip rule in `rules/review-gate.md`.

Do not skip this step when resuming from a pre-built plan.

### 7. Summary

Lead with the outcome, not the process. If the user gave you a ticket, answer whether it's done.

```markdown
## Create-Feature Complete
[1-2 lines: what was built, whether acceptance criteria are met]

### What was built
- [Specific behavior/UX flow — what the user or system does differently now]

### Verify manually
- [Things automated tests can't cover — live integration, UI rendering, permissions]
- [Omit section if everything is covered by automated tests]

### Key decisions
- [Decisions made during planning that shaped the implementation]

### What to do next
- [Specific next action — PR, deploy step, remaining slices]

### Open risks
- [Anything uncertain or untested — omit section if none]

<details><summary>Technical details</summary>

- Files changed: [list]
- Review: Rounds [N] | Status [clean/blocked]

</details>
```

## Non-Negotiable Gates

Use this checklist to verify you haven't skipped a gate:

- [ ] Complexity Gate block emitted (step 1)
- [ ] PROJECT.md written with plan content (step 3) — standard path only
- [ ] All applicable reviewers at 8/10 (step 4b) — standard path only
- [ ] Cold read passed (step 4c) — standard path only
- [ ] `/review-code` Review Gate block emitted (step 6)
- [ ] PROJECT.md updated with final status
- [ ] Summary emitted (step 7)

## PROJECT.md Update Discipline

**Standard path:**
- **step 3** — after exiting plan mode, flush the draft plan into PROJECT.md. This is the first write and a hard gate.
- **step 4** — after review iterations complete, update with final review scores.
- after implementation and validation complete.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /create-feature <arguments>
- Phase: input / complexity-gate / plan-mode / project-md-write / review-iterations / action-gate / implement / review-code / summarize
- Resume target: <story, issue, milestone, PR slice, file set, or current blocker>
- Completed items: <finished phases or accepted decisions>
### State
- Complexity: <trivial / moderate / standard>
- PM required: <yes / no / skipped — trivial>
- PM brief score: <score or skipped>
- Technical plan scores: <reviewer: score, ... or pending>
- Cold read: <go / no-go / pending>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>
```

## Notes
- `/create-feature` is the public entrypoint for planned non-bug work, including refactors where the PM layer can be skipped
- Only pause when a real decision matters
- Use test-first implementation by default for each slice; document why when it is blocked
- `/review-code` is an internal phase here, not the expected next top-level user step
- Stop before the final commit or PR action
- When resuming from a pre-built plan, enter at the implementation phase but still run review, QA, and pre-flight checks before declaring done
