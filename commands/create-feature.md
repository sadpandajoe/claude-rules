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
/create-feature sc-epic-456                              # epic — decomposes into waves
/create-feature https://github.com/owner/repo/milestone/5 # milestone — treated as epic
```

## Steps

### 1. Normalize Input + Complexity Gate

Accept:
- plain-language feature request
- Shortcut story ID or URL
- GitHub issue or PR reference / URL

When a ticket URL or issue reference is provided, **fetch and parse it FIRST** before any planning or code investigation. Extract scope, acceptance criteria, and constraints from the source. These are authoritative — don't re-derive scope from scratch.

**Detect scope** — after fetching, determine if this is a single story or an epic:

| Signal | Single story | Epic |
|--------|-------------|------|
| Input type | One ticket, one issue, one feature description | Shortcut epic, GitHub milestone, multiple linked stories |
| Sub-tasks | None or implementation sub-tasks of one feature | Multiple independent features/stories |
| Scope | One PR worth of work | Multiple PRs across different areas |

**If epic → use the Epic Path section below.** Each story within the epic runs the single-story flow independently.

**If single story** → continue with the complexity gate below.

Then assess complexity:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files touched | 1–2 | 3+ or unclear |
| Design decisions | None | Any |
| New APIs / migrations | No | Yes |
| Behavioral risk | Mechanical / cosmetic | Functional change |

Examples — TRIVIAL: add a tooltip to an existing button (1 component, no state change). STANDARD: add bulk edit for dashboard filters (new API endpoint, state management, UI components).

Emit the Complexity Gate block per `rules/complexity-gate.md`.

Record lifecycle: `gate`

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

Revise the plan until all applicable reviewers are at 8/10 or better. Run iterations automatically — do not ask the user whether to continue or which reviewers to use. Only stop for a blocking decision that requires user input. After each round, record lifecycle: `review-round` { command: "create-feature", round: `<N>`, status: `<iterating/converged>`, finding_counts: `{major: N, minor: N}` }

**Convergence criteria**: Maximum 3 rounds per reviewer. If a reviewer has not reached 8/10 after 3 rounds, stop and surface the persistent issues to the user. If any reviewer is stuck below 6/10 after 2 rounds, stop immediately — further iteration is unlikely to help without user input on scope or approach.

**c. Cold read**: Use `finalize-plan` as a fresh-eyes final check. If it finds a blocking issue, revise and re-run.

**d. Action gate**: Run `action-gate.md`. Auto-proceed when Risk is LOW, Confidence ≥ 8/10, and no decision is required.

Update PROJECT.md with final review scores after this step.

Record lifecycle: `plan-complete`

### 4½. Checkpoint Before Implementation

The plan→implement transition is the deepest context point in this workflow — planning rationale, review scores, and QA test plans are all in memory. Check context depth per `rules/context-management.md`. If at or above ~70%, run `/checkpoint --commit --clear` before proceeding. After `/clear`, `/start` reloads PROJECT.md (which has the full plan from step 3) and resumes at step 5.

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

**5b. Sync and merge worktrees:**

Use `sync-workstreams.md` to collect subagent results, update the slice status table in PROJECT.md, and merge worktree branches. Pass the list of subagent results (Implementation Handoff blocks) and the dependency graph from the plan.

The skill handles: result collection, status table updates (`queued` → `in-flight` → `complete` / `failed` / `blocked`), failure gating, dependency-ordered merges, conflict detection, and integration checks.

Branch on the skill's recommendation:
- `proceed-to-review` → continue to step 5c
- `stop-for-failure` → surface the failure to the user before proceeding
- `stop-for-conflict` → the plan's scope boundaries were wrong; surface for user decision
- `stop-for-integration-failure` → merged code doesn't build; investigate before continuing

Record lifecycle: `impl-complete`

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

Launch `/review-code` as a **subagent** (`model: "opus"`) with context isolation per `rules/orchestration.md`. Pass the merged diff, acceptance criteria from the PM brief, and QA test results from step 5c.

For multi-slice implementations: review the full merged diff. Per-slice exit criteria already verified each slice individually — this review checks the integrated result and cross-slice interactions.

**Classify review findings before looping:** Use `feedback-classify.md` to classify each finding as code-level or plan-level.
- **Code-level**: fix in the review loop as normal
- **Plan-level**: route back to step 4 for re-planning rather than trying to fix it in the review loop. Re-planning may invalidate implementation work, but it's cheaper than shipping a flawed design.

Keep iterating until only nitpicks remain or a real blocker/user decision appears.

The developer emits a Review Gate block per `rules/review-gate.md`. Callers branch on Status: `clean`, `blocked`, `user decision`, `skipped`.

Record lifecycle: `review-gate`

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

Record lifecycle: `command-complete`

## Epic Path

When step 1 detects an epic, use this path instead of steps 2–7. Each story runs the single-story flow independently in its own worktree.

### E1. Decompose Epic

Use `decompose-epic.md` to produce a wave plan — stories grouped into dependency-ordered waves. The skill analyzes what each story produces/consumes and sorts them topologically.

If resuming an epic (wave plan already in PROJECT.md), skip to E3.

### E2. Write Wave Plan to PROJECT.md

```markdown
## Epic: [title]
**Reference**: [epic URL/ID]

[Wave plan table from decompose-epic.md]

### Wave Status
| Wave | Stories | Status |
|------|---------|--------|
| 1 | [N] | pending |
| 2 | [N] | blocked — waiting on Wave 1 |
```

### E3. Execute Current Wave

Find the next wave with status `pending`. For each story in that wave, dispatch a subagent:

```
Agent(
  isolation: "worktree",
  model: "opus",
  prompt: "Read and follow {{TOOLKIT_DIR}}/commands/create-feature.md for story [ref].
    This is a single story — use the single-story path (steps 1–7).
    You are the orchestrator for this story: create your own PROJECT.md, plan, implement, review, and commit.
    Create branch: [branch from wave plan].
    Return: branch name, commit SHAs, summary of what was built, and any blockers."
)
```

Each subagent:
- Is a **full orchestrator** for its story (nested orchestration per `rules/orchestration.md`)
- Gets its own worktree → its own PROJECT.md, branch, and full planning/review cycle
- Installs dependencies in the worktree per `rules/resource-management.md` (Worktree Management)
- Runs the complete single-story flow autonomously — planning, implementation, review, commit
- Returns results to the epic orchestrator

**Concurrency**: Check resources per `rules/resource-management.md`. Typical limits: 2–3 parallel stories with Docker running, 3–4 without.

After all stories in the wave complete:
- Collect results (success/failure per story)
- For each successful story, run `/create-pr` against the worktree branch
- Update wave status in PROJECT.md: `pending` → `complete` or `partial (N of M)`
- If any story failed, note it but continue with successful ones

### E4. Wave Transition

After creating PRs for the current wave, check if more waves remain.

**If more waves AND user said "auto" or PRs are already approved**: Merge PRs via `gh pr merge --squash`, pull updated base branch, and continue to the next wave automatically. Only auto-merge if CI passes and the PR is approved — never force-merge.

**Otherwise**: Report and pause for the user to merge:

```markdown
## Wave [N] Complete

### PRs Created
| Story | PR | Status |
|-------|-----|--------|
| [ref] | #[N] | ready for review |

### Next
Wave [N+1] has [N] stories. Merge the Wave [N] PRs, then run:
`/create-feature [epic-ref]`
```

Update PROJECT.md wave status. The next invocation detects the wave plan, finds the next pending wave, pulls the updated base branch, and resumes from E3.

If all waves are complete → emit epic summary:

```markdown
## Epic Complete — [title]

### All PRs
| Wave | Story | PR |
|------|-------|----|
| [N] | [ref] | #[N] |

### Remaining
- [Failed/blocked stories, or "None"]
```

Record lifecycle: `command-complete`

## Non-Negotiable Gates

Use this checklist to verify you haven't skipped a gate:

- [ ] Complexity Gate block emitted (step 1)
- [ ] PROJECT.md written with plan content (step 3) — standard path only
- [ ] All applicable reviewers at 8/10 (step 4b) — standard path only
- [ ] Cold read passed (step 4c) — standard path only
- [ ] `/review-code` Review Gate block emitted (step 6)
- [ ] PROJECT.md updated with final status
- [ ] Summary emitted (step 7)
- [ ] Lifecycle events recorded at phase boundaries

## Continuation Checkpoint

**Single-story phases**: input / complexity-gate / plan-mode / project-md-write / review-iterations / action-gate / checkpoint / implement / review-code / summarize

**Epic phases**: input / decompose / write-wave-plan / execute-wave / wave-transition / epic-summary

State (single story):
- Complexity: <trivial / standard>
- PM required: <yes / no / skipped — trivial>
- PM brief score: <score or skipped>
- Technical plan scores: <reviewer: score, ... or pending>
- Cold read: <go / no-go / pending>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>

State (epic):
- Epic: <reference>
- Mode: epic
- Current wave: <N of N>
- Wave status: <wave: status, ...>
- Stories in current wave: <N total, N complete, N failed>
- PRs created: <list or none>

## Notes
- `/create-feature` is the public entrypoint for planned non-bug work, including refactors where the PM layer can be skipped
- Accepts both single stories and epics — epic detection is automatic based on input type
- Epic path: each story runs the full single-story flow in its own worktree. The orchestrator manages wave ordering and PR creation.
- Epic re-invocation is stateful — the wave plan in PROJECT.md persists across conversations. Run the same command after merging a wave's PRs to continue.
- Only pause when a real decision matters
- Use test-first implementation by default for each slice; document why when it is blocked
- `/review-code` is an internal phase here, not the expected next top-level user step
- Stop before the final commit or PR action
- When resuming from a pre-built plan, enter at the implementation phase but still run review, QA, and pre-flight checks before declaring done
