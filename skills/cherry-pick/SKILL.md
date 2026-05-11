---
name: cherry-pick
description: Use when the user asks to cherry-pick, backport, port a fix, or apply commits/PRs onto another branch. Covers safety gates, scope-leak detection, adaptation, and per-change validation. Do NOT use for ordinary same-branch bug fixes, broad refactors, dependency upgrades, or behavior-changing rewrites without an explicit cross-branch move.
argument-hint: "[pr-url | sha...] [--target branch] [--force] [--plan-only] [--push]"
allowed-tools: Bash(git *) Bash(gh *) Read Grep Glob Edit
---

# Cherry-Pick

Safely move one or more isolated changes (bug fixes, isolated features) onto a target branch.

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present. Cherry-picking has a small set of recurring failure modes; do not relearn them.

## Contract

**In scope:** classify each change, plan its application, apply, adapt conflicts when source intent can be preserved, run repo-standard validation.

**Out of scope:** broad refactors, behavior-changing adaptations without approval, dependency reinstall or environment rebuild, forcing incompatible APIs onto the target.

**Success criteria:** each change is classified `Applied | Partial | Blocked | Rejected | Skipped`; applied changes preserve source intent; validation status recorded; push status recorded; batch state lives in the execution table or `CHERRY_PICK.md`; PROJECT.md is updated by the parent workflow (this command does not own it).

If the workflow would cross a contract boundary, stop and ask — do not cross first and report after.

`--push` explicitly authorizes the per-cherry push boundary. Without `--push` or explicit user authorization during the run, validate locally and stop with a push recommendation before publishing.

For non-trivial or expensive cherry-picks, follow `rules/context-management.md`: checkpoint/clear after investigate/gate/plan is recorded in the execution table, and again after apply/adapt/validate when push authorization or final reporting remains. Batch runs checkpoint/clear between waves by default.

## Usage

```
/cherry-pick <pr-url>                          # From a PR
/cherry-pick <sha>                             # Single commit
/cherry-pick <sha> --target <branch>           # Specific target branch
/cherry-pick <sha> --force                     # Override reject-category gate
/cherry-pick <sha-1> <sha-2> <sha-3>           # Batch
/cherry-pick <sha-1> <sha-2> --plan-only       # Plan without applying
/cherry-pick <sha-1> <sha-2> --push            # Validate and push each successful cherry as it completes
```

## Single Cherry-Pick Flow

Each cherry-pick runs all validation phases. No validation phase may be skipped — the diff audit in step 7 is the only defense against scope leak (see gotchas.md). Step 8 is a publish boundary: run it only when `--push` or explicit user authorization grants push permission.

### 1. Investigate (heavy effort)

Source analysis, target compatibility scan, prerequisite scan. Investigation produces raw analysis only — the gate decides go/no-go.

→ Full procedure: [references/investigate.md](references/investigate.md)
→ Output template: [assets/investigation-template.md](assets/investigation-template.md)

### 2. Gate

Decide should-we-cherry against the accept/reject matrix (see [references/gate.md](references/gate.md)), classify difficulty (TRIVIAL vs NON-TRIVIAL), pick reasoning effort for plan/validate phases.

`--force` overrides reject decisions only — it does not skip downstream phases.

→ Full decision matrix: [references/gate.md](references/gate.md)

### 3. Plan (reasoning effort from gate)

Per-cherry application strategy: file include/exclude, conflict forecast, adaptation strategy, validation approach.

For non-trivial changes, run plan as a subagent so the review in step 4 gets a fresh perspective. For a single trivial cherry-pick, inline planning on the main thread is fine — the gate already classified low risk.

→ Full procedure: [references/plan.md](references/plan.md)
→ Output template: [assets/plan-template.md](assets/plan-template.md)

### 4. Plan Review (main thread)

Review against investigation. Cycle back with feedback if needed. Repeat until approved.

### 5. Apply (heavy effort)

```bash
git checkout <target-branch>
git cherry-pick -x <commit-hash>
```

Always `-x` to preserve source reference. For merge commits, add `-m 1`. For modify/delete conflicts, resolve with `git rm`, not by reverting.

→ Full escalation ladder, modify/delete handling, CHERRY_PICK_HEAD recovery: [references/apply.md](references/apply.md)

### 6. Adapt (heavy effort, non-trivial only)

Resolve conflicts surgically. **Never** use `git checkout --theirs` or `--ours` (see gotchas.md).

If a trivial change unexpectedly hits conflicts, escalate to adapt — the gate classification was wrong.

→ Conflict classification, scope leak detection during resolution, escalation triggers: [references/adapt.md](references/adapt.md)

### 7. Validate

Two distinct jobs, run on different threads:

**7a. Scope-leak audit — subagent, mandatory, every cherry, no exceptions.**

Post-apply, spawn a subagent (reasoning effort from gate: standard for trivial, heavy for non-trivial). Its only job is leak detection. Single rule: every cherry, every time, including clean applies — clean applies are the highest-risk vector for scope leak.

The subagent must:
1. Run `${CLAUDE_SKILL_DIR}/scripts/scope-audit.sh <source-commit>` and capture the literal output.
2. Run the LLM hunk-level audit comparing source diff vs cherry-pick result diff.
3. Return a structured report containing the literal `scope-audit.sh` output, per-hunk verdict, and a clear `LEAK / CLEAN / ESCALATE` recommendation.

The orchestrator may not mark a cherry `Applied` without this report. If the subagent finds leaks, revert leaked hunks and amend on the main thread, then re-spawn the subagent on the amended commit.

**7b. Correctness validation — main thread.**

Conflict-marker scan, **pre-commit on changed files**, build, type-check, targeted tests. Pre-commit is mandatory — conflict resolution often re-indents lines past length limits, and pre-commit is what CI runs. If pre-commit auto-fixes or you make manual fixes, `git commit --amend --no-edit` before pushing. Do not push, then amend, then force-push.

→ Full procedure (subagent contract, LLM audit, validation order, status labels, dependency manifest rule): [references/validate.md](references/validate.md)

### 8. Push Recommendation / Authorized Push

```bash
git push
```

When push is authorized, push **immediately after** step 7 passes for *this* cherry, before starting the next one. Do not batch pushes at the end of a multi-cherry run unless the user explicitly asked for batched push.

When push is not authorized, stop before publishing and record `Push: pending authorization` in the execution table or `CHERRY_PICK.md`. Continue to independent planning/investigation work only if it does not depend on the unpublished cherry being on the remote.

**Why:** CI can attribute each cherry independently only when each authorized push is per cherry. Batching defeats per-cherry attribution and forces bisection later.

The only exception is when the user explicitly asks for batched push (e.g., to reduce CI cost). In that case, confirm before deferring and record the batched-push decision.

## Batch Cherry-Pick Flow

When multiple PRs/SHAs are provided, the main agent acts as a **thin orchestrator**. It owns ordering, dependency tracking, user decisions, checkpoint boundaries, and final synthesis. It must not accumulate raw per-cherry context.

**Invariant: each cherry must start with clean context.** Subagents are the usual mechanism, but any isolation that prevents cherry #10 from inheriting cherry #1's diffs and decisions works. What matters is that the agent working on cherry N does not carry state from cherries 1..N-1.

### Durable Batch Manifest

For 10+ changes, or any run with meaningful dependencies, expected conflicts, or multiple blocked/intervention points, create or update local `CHERRY_PICK.md` from [templates/cherry-pick-manifest.md](templates/cherry-pick-manifest.md).

`PROJECT.md` should only point to the active run:
- target branch
- current phase
- next batch/wave
- manifest path: `CHERRY_PICK.md`

`CHERRY_PICK.md` owns the detailed execution table, execution waves, dependency notes, per-cherry validation, conflict notes, user decisions, and compact subagent handoffs.

Never commit `CHERRY_PICK.md`. Prefer `.git/info/exclude` for this workspace-local file unless the repo should ignore it globally.

Update `CHERRY_PICK.md` before every checkpoint/clear. After `/start`, resume from the manifest row/wave rather than from chat history.

### Wave Size Policy

Batch size means an orchestration wave, not permission to weaken per-cherry validation or to publish without authorization.

| Case | Wave size |
|------|----------:|
| Tiny independent fixes | 5 |
| Normal bug fixes | 3 |
| Cross-cutting changes | 1 |
| Expected conflicts | 1 |
| Dependency chain | 1 sequentially |
| Clean mechanical backports | 5-8 only if validation is cheap |

Investigate, gate, or plan independent changes in parallel when useful. Actual application on the target branch remains dependency-safe and sequential unless the workflow explicitly creates isolated worktrees/branches and has a fan-in plan.

### Subagent Handoff Contract

Each per-cherry or per-wave subagent returns only:
- PR/SHA
- source commit(s)
- target commit SHA after apply
- result: `Applied` / `Partial` / `Blocked` / `Rejected` / `Skipped`
- conflicts: `none` or compact summary
- scope audit: `CLEAN` / `LEAKED-REVERTED` / `ESCALATED`
- validation label: `Tested` / `Checked` / `Build-only` / `Structural` / `Not run`
- push status: `pushed` / `pending authorization` / `deferred by request`
- commands run
- residual risk
- dependency implications for later rows

No full diffs or long logs unless blocked. If a blocked handoff needs raw evidence, put file paths or the shortest decisive excerpt in the manifest.

1. **Sequence planning** — run [references/batch-sequence.md](references/batch-sequence.md) to determine execution order based on dependencies. Standard reasoning effort is sufficient.
2. **Per-cherry execution** — for each cherry in sequence, run the full single flow through validation in an isolated context. **Step 8 is a push boundary:** when authorized, it runs per cherry, not after the batch; when unauthorized, record `pending authorization` and stop before publishing dependent work.
3. **Status tracking** — record results in the execution table or `CHERRY_PICK.md`. If one fails, do NOT continue with subsequent dependent picks. Independent picks may continue.
4. **Escalation** — surface escalations to the user, relay answers back.
5. **Final report** — collect results and produce the document phase output. Include pushed cherries and any cherries waiting on push authorization; the report summarizes, it does not silently publish.

**Why isolation matters:** with 15 cherry-picks, inline processing pollutes context with prior diffs by cherry #10. Quality degrades silently — conflicts start looking alike, decisions bleed across cherries.

**`--plan-only`:** run sequence + per-cherry investigate + gate (parallel where independent). Produce execution table without applying.

## Final Report

Use the format in [examples/final-report.md](examples/final-report.md). Lead with the ticket outcome (what the user cares about), then the execution table, then actionable residuals.

The full 13-column execution table format is in [examples/execution-table.md](examples/execution-table.md). The compact table replaces it only in the final report.

**Record metrics**: include `metrics-emit` context with:
- `command`: `cherry-pick`
- `complexity`: from gate (`trivial` / `non-trivial`); use `standard` for batch
- `status`: aggregate result (`clean` if all Applied, `blocked` if any Blocked/Rejected requiring intervention, etc.)
- `rounds`: total plan-review iterations across all cherries (0 if all clean)
- `gate_decisions`: `{ verdict: PROCEED | REJECT | FORCE-PROCEED, batch_size: <N> }`
- `scope_audit`: per-cherry verdicts from the 7a subagent — `{ clean: <N>, leaked_reverted: <N>, escalated: <N> }`. Single cherry: one of `CLEAN | LEAKED-REVERTED | ESCALATED`.
- `worker_usage`: subagent/worker invocation counts when applicable

## Continuation Checkpoint

Phases: investigate / gate / plan / plan-review / apply / adapt / validate / push-authorization / document

State to checkpoint:
- Target branch
- Current execution table snapshot
- Pending intervention points

## Notes

- **PROJECT.md**: branch-movement operations — the parent workflow owns any PROJECT.md update, not this command.
- Always use `cherry-pick -x` to preserve source reference.
- `--force` overrides the gate's accept/reject only, never downstream phases.
- When in doubt, reject.
