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

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files touched | 1–2 | 3+ or unclear |
| Design decisions | None | Any |
| New APIs / migrations | No | Yes |
| Behavioral risk | Mechanical / cosmetic | Functional change |

Examples — TRIVIAL: add a tooltip to an existing button (1 component, no state change). STANDARD: add bulk edit for dashboard filters (new API endpoint, state management, UI components).

Emit the Complexity Gate block per `rules/complexity-gate.md`.

**Trivial + confidence 8/10+**: Skip to the trivial path — step 5.

**Standard**: Continue to step 2. Make this decision yourself and continue automatically — do not ask the user whether to run review iterations, which reviewers to use, or whether the plan is "good enough." End-to-end commands own their internal loops.

### 2. Plan Mode → Exploration + Design

Enter plan mode. Inside plan mode, do all of the following:

**a. PM brief** (product criteria): Use `pm-create-feature-brief.md` to investigate the request and produce a brief with verifiable acceptance criteria. Use `pm-plan-milestones.md` for milestone framing when the work spans multiple deliverables. Skip only when the work is already tightly scoped with clear acceptance criteria — state the decision explicitly.

**b. Architect + QA in parallel** (technical + test criteria): These are peers that both consume the PM brief — launch them together:
- **Architect**: Use `plan-feature.md` to define the technical approach, structured slices with scope/entrance/exit criteria, and implementation sequencing.
- **QA**: Use `qa-analyze-use-cases.md` to derive test scenarios from the PM brief's acceptance criteria, then `qa-expand-scenarios.md` to identify edge cases and adjacent flows. Produce a test plan that maps scenarios to slices.

The Architect defines *how to build it*. QA defines *how to prove it works*. Neither needs the other's output — both need the PM brief. Running them in parallel means the test plan is ready before implementation starts, strengthening TDD: devs know what tests to write as part of their slice, not as an afterthought.

Exit plan mode when you have: feature brief, technical plan with structured slices, and QA test plan. These do not need to be polished — review iterations in step 4 will refine them.

### 3. Write PROJECT.md (hard gate)

After exiting plan mode, read the plan file. Write its content into PROJECT.md sections:
- `Feature Brief` (PM brief with acceptance criteria)
- `Milestones` (if PM planning was used)
- `Implementation Plan` (Architect's structured slices)
- `Test Plan` (QA's test scenarios mapped to slices)

**Do not proceed to step 4 until this confirmation block is emitted:**

```markdown
## PROJECT.md Updated
Sections written: [list of sections written]
```

This gate ensures the plan is durable before review iterations begin. If the plan is only in conversation or a plan file, it can be lost on context refresh.

### 4. Review Iterations + Action Gate

Now in normal mode, iterate the plan using reviewer agents. This is the main quality gate.

**a. PM brief review** (if PM planning was used): Run `review-feature-brief` and revise until 8/10.

**b. Technical plan + test plan review**: Always run these reviewers:
- `review-architecture` — validates the Architect's slice decomposition and technical approach
- `review-implementation` — validates feasibility, sequencing, and slice boundaries
- `review-testplan` — validates the QA test plan covers the architecture and acceptance criteria. This reviewer now has both the technical plan and test plan, so it can verify alignment: does every slice have test coverage? Does the test plan catch cross-slice integration risks?

Add when the plan needs them:
- `review-frontend`
- `review-backend`

Revise the plan until all applicable reviewers are at 8/10 or better. Run iterations automatically — do not ask the user whether to continue or which reviewers to use. Only stop for a blocking decision that requires user input.

**Convergence criteria**: Maximum 3 rounds per reviewer. If a reviewer has not reached 8/10 after 3 rounds, stop and surface the persistent issues to the user. If any reviewer is stuck below 6/10 after 2 rounds, stop immediately — further iteration is unlikely to help without user input on scope or approach.

**c. Cold read**: Use `finalize-plan` as a fresh-eyes final check. If it finds a blocking issue, revise and re-run.

**d. Action gate**: Run `action-gate.md`. Auto-proceed when Risk is LOW, Confidence ≥ 8/10, and no decision is required.

Update PROJECT.md with final review scores after this step.

### 5. Implementation

**Standard path** (from step 4):

Read the plan's structured slices from PROJECT.md. For each slice, the plan defines scope, entrance/exit criteria, and acceptance — use these to drive implementation.

**5a. Dispatch implementation subagents:**

The QA test plan already exists from step 2b — devs use it to know what tests to write for their slice. Each subagent gets its slice context (scope, entrance/exit criteria, acceptance) AND the relevant test scenarios from the QA test plan.

Check the plan's Parallelism section and dispatch:
- **Independent slices**: launch as parallel subagents, each with `isolation: "worktree"` and `model: "opus"`, running `implement-change.md`. The worktree isolation ensures parallel subagents don't conflict on files.
- **Sequential slices** (depends-on chain): implement in dependency order. After each slice completes and its exit criteria are met, start the next.
- **Single slice or no structured slices**: implement as one unit through `implement-change.md` (no worktree needed).

Each subagent:
- Verifies **entrance criteria** before starting — stops if unmet
- Installs dependencies in the worktree if needed (`node_modules/`, build outputs)
- Writes the failing test from the QA test plan before the code change (TDD — the test plan tells them exactly what to test)
- Stays within the slice's **scope** boundary
- Stops when **exit criteria** are met and **acceptance** passes
- Commits changes on the worktree's temp branch with a message referencing the slice name
- Returns the Implementation Handoff block

**5b. Merge worktrees back:**

After all implementation subagents complete:
1. Collect results — check each subagent's Implementation Handoff for exit criteria status
2. If any slice failed its exit criteria, stop and surface the failure before merging
3. Merge each worktree's temp branch into the current branch, one at a time, in dependency order
4. If a merge conflict occurs, stop and surface it — the plan's scope boundaries were wrong, don't auto-resolve
5. Run a quick build/type-check after all merges to verify integration

**5c. QA validates the integrated result:**

After merge, execute the test plan from step 2b against the integrated code:
- Run `qa-execute-use-cases.md` for the test scenarios
- Use `qa-validate-fix.md` for scenarios that need live environment validation
- Dev subagents already wrote unit/integration/API tests per-slice — QA execution focuses on cross-slice integration and user-facing behavior
- In the future, QA can also own E2E test slices (Playwright tests in their own worktree) since unit/integration coverage is handled by dev subagents

**Trivial path** (from step 1):
1. Implement the change
2. Run the actual test suite covering the changed files (`pytest -k ...`, `jest --testPathPattern ...`) — pre-commit alone is not sufficient
3. Update PROJECT.md (single update) — skip if no PROJECT.md exists and work completes without blockers

If a meaningful decision surfaces during implementation, stop and present it clearly.

### 6. Review Changed Files (gate)

For multi-slice implementations: run `/review-code` on the full merged diff. The per-slice exit criteria already verified each slice individually — this review checks the integrated result and cross-slice interactions.

Keep iterating until only nitpicks remain or a real blocker/user decision appears.

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
- Complexity: <trivial / standard>
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
