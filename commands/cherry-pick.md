# /cherry-pick - Cherry-Pick One or More Changes

> **When**: Moving one or more changes (bug fixes, isolated features) to another branch.
> **Produces**: Ordered plan, clean cherry-picks with conflicts resolved where safe, and a per-change report documented in PROJECT.md.

## Contract

### Goal
Safely move one or more isolated changes onto the target branch.

### In Scope
- reorder requested cherries when needed (batch only)
- gate each change: should we cherry at all?
- plan each cherry-pick's application strategy
- review each plan before applying
- auto-apply low-risk changes
- adapt conflicts when source intent can be preserved on the target branch
- run repo-standard validation that does not require environment rebuild or refresh

### Out of Scope
- broad refactors or architecture rewrites
- behavior-changing adaptations without approval
- dependency reinstall, environment refresh, or rebuild-only validation paths
- forcing incompatible dependencies, APIs, or structural changes onto the target branch

### Success Criteria
- each requested change is classified as `Applied`, `Partial`, `Blocked`, `Rejected`, or `Skipped`
- applied changes preserve source intent on the target branch
- validation status is recorded for each applied change
- PROJECT.md contains the final execution table and detailed notes for non-trivial rows

### Validation Plan
- use the repo-standard validation commands for the changed area
- prefer targeted checks over broad rebuilds
- escalate instead of rebuilding or refreshing the environment automatically

This contract is the default execution boundary for `/cherry-pick`.
Never block execution to present the contract.
If the workflow would cross a contract boundary, stop and ask the user before proceeding — do not cross first and report after.

## Usage
```
/cherry-pick <pr-url>                          # Cherry-pick from a PR
/cherry-pick <sha>                             # Cherry-pick a specific commit
/cherry-pick <sha> --target <branch>           # Cherry-pick to specific branch
/cherry-pick <sha> --force                     # Override reject-category gate
/cherry-pick <sha-1> <sha-2> <sha-3>           # Batch: plan and execute multiple changes
/cherry-pick <sha-1> <sha-2> --plan-only       # Plan only, do not apply
```

## Single Cherry-Pick Flow

Each cherry-pick follows this sequence. No phase may be skipped.

### 1. Investigate (always Opus)

Run `cherry-pick-investigate.md`.

- Source analysis: resolve PR to commit(s), inspect changed files, classify as functional/structural/dependency/mixed
- Target compatibility scan: check file/module existence, API differences, detect modify/delete risk
- Prerequisite scan: identify dependencies, check for existing fixes

Investigation produces the raw analysis. It does not make the go/no-go decision — that belongs to the gate.

### 2. Gate

Run `cherry-pick-gate.md` against the investigation output.

This phase decides:
- **Should we cherry at all?** Accept/reject based on `rules/cherry-picking.md` matrix. `--force` overrides rejection with warnings.
- **Difficulty classification**: TRIVIAL vs NON-TRIVIAL, which determines model selection for plan and validate phases.
- **Adapt required?** Trivial changes skip the adapt phase.

If the gate rejects without `--force`, stop here. Record status as `Rejected` with the reason.

### 3. Plan (subagent — model set by gate)

Run `cherry-pick-plan.md` as a subagent. Model is Sonnet for trivial, Opus for non-trivial (per gate output).

The plan covers this specific cherry-pick's application strategy:
- File exclusions and why
- Expected conflicts and resolution approach
- Adaptation strategy (if non-trivial)
- Validation approach

### 4. Plan Review (main thread)

The main thread (or orchestrator in batch mode) reviews the subagent's plan.

Review criteria:
- Does the plan match the investigation findings?
- Are file exclusions justified?
- Is the conflict resolution approach sound?
- Are there risks the plan missed?

If the plan is not acceptable, send feedback to the plan subagent and cycle back to step 3. Repeat until the plan is approved.

### 5. Apply (Opus)

Run `cherry-pick-apply.md`.

```bash
git checkout <target-branch>
git cherry-pick -x <commit-hash>
```

Always apply on the target branch. Always use `-x` to preserve source reference.

### 6. Adapt (Opus — non-trivial only)

Run `cherry-pick-adapt.md`. Only when the gate classified the change as NON-TRIVIAL or when conflicts are detected during apply.

If a trivial change unexpectedly hits conflicts during apply, escalate to adapt — the gate classification was wrong, and adapt should treat it as non-trivial.

### 7. Validate (subagent — model set by gate)

Run `cherry-pick-validate.md` as a subagent. Model is Sonnet for trivial, Opus for non-trivial (per gate output).

**Always run validation as a subagent**, never inline. The thread that applied the cherry-pick must not validate its own work.

**The diff audit is mandatory for every cherry-pick, including clean applies.** Clean applies are the highest-risk vector for scope leak — when git resolves without conflicts, nobody scrutinizes the result, and changes from adjacent commits on the source branch silently enter the target. The #38809 incident (SC-104110, P1) was a clean cherry-pick that leaked the `hideTab` guard from an adjacent commit.

The subagent runs `cherry-pick-validate.md` which includes:
1. **Diff audit** — compare source commit diff vs cherry-pick result diff, flag extra files/hunks
2. **Build/lint/type-check** — repo-standard checks
3. **Targeted tests** — covering the changed area

If the diff audit finds scope leak, the subagent reverts the leaked hunks and reports back. The orchestrator then amends the cherry-pick before pushing.

**Push after each successful cherry-pick**: After local validation passes, push immediately so CI runs against the change.
```bash
git push
```

## Batch Cherry-Pick Flow

When multiple PRs or SHAs are provided, the main agent acts as a **thin orchestrator**. It must not accumulate per-cherry context — each cherry runs in isolation.

### Orchestrator Responsibilities

1. **Sequence planning**: Run `cherry-pick-batch-sequence.md` (Sonnet subagent) to determine execution order based on dependencies and overlap.

2. **Per-cherry execution**: For each cherry in sequence, spawn a subagent that runs the full single cherry-pick flow (steps 1-7 above). Each subagent gets its own clean context.

3. **Status tracking**: After each subagent completes, record the result in the execution table. If one fails, do NOT continue with subsequent picks that depend on it. Independent subsequent picks may continue.

4. **Escalation handling**: If a subagent escalates a decision, the orchestrator surfaces it to the user, gets the answer, and relays it back.

5. **Final report**: Collect results from all subagents and produce the document phase output.

### Why Isolation Matters

With 15 cherry-picks, if the main agent processes each one inline, by cherry #10 the context is polluted with prior diffs, conflict resolutions, and adaptation decisions. Quality degrades. Each cherry in its own subagent gets a clean context window.

### `--plan-only` for Batch

If `--plan-only` is set, run only the sequence planning step and per-cherry investigate + gate (in parallel where independent). Produce the execution table without applying anything.

## Sequential Cherry-Pick Safety

When cherry-picking multiple commits in sequence:
- Verify each cherry-pick completes before starting the next
- If one fails mid-chain, do NOT continue with dependent picks
- Independent picks may continue if they don't share files/modules with the failed pick
- Clean up the failed state (`git cherry-pick --abort`) before deciding next steps
- Document which picks succeeded and which didn't

## Document the Plan and Outcome

**Per-cherry tracking** uses the execution table defined in `cherry-pick-plan.md`. Every cherry-pick (single or batch) produces one. In batch mode, the orchestrator also maintains the full batch execution table from `cherry-pick-batch-sequence.md`.

**Final report** uses a condensed format. Lead with the ticket outcome (what the user cares about), then the execution table, then actionable residuals:

```markdown
## Cherry-Pick Summary

[1-2 lines answering the user's original question — e.g., "The StructuredContentStripperMiddleware (the encoding fix) is now active on this branch." or "The fix from #38837 is applied; CI re-run needed to confirm."]

[X of N applied, Y rejected, Z partial] -> <target branch>

### Results
| SHA | PR | Status | Validation | Notes |
|-----|----|--------|------------|-------|
| `<sha>` | #123 | Applied | Tested | Clean apply |
| `<sha>` | #124 | Partial | Checked | 5 of 7 sub-fixes applied; encoding fix dropped — see below |
| `<sha>` | #125 | Rejected | — | Feature change, no --force |

### Detailed Notes
#### `<sha>` — <summary>
- **Why non-trivial**: [conflict, rejection reason, or intervention point]
- **Gate decision**: [PROCEED / REJECT / FORCE-PROCEED + criteria]
- **Adaptation details**: [What was modified and why]
- **What was dropped**: [specific functions, files, or sub-fixes omitted]
- **Residual risk**: [What remains uncertain]

### What to do next
- [Actionable residual items — e.g., "encoding bug likely affects target via different code path — needs separate fix"]
- [Validation gaps — e.g., "run pytest tests/unit_tests/mcp_service/ before merging"]
- [Pending PRs to monitor — e.g., "#38676 still open — pick when merged"]
```

Keep the dependency graph from the planning phase if inter-change dependencies were detected.
The full 12-column execution table remains in the planning output — the compact table replaces it only in the final report.
Add detailed notes for any row that is not `Applied` with `None` adaptation, plus any `Applied` row with notable adaptation.

Record lifecycle: `command-complete`

## Continuation Checkpoint

Phases: investigate / gate / plan / plan-review / apply / adapt / validate / document

State:
- Target branch: <branch>
- Current execution table snapshot: [latest status summary]
- Pending intervention points: [any user decisions still needed]

## Notes

- **PROJECT.md**: Cherry-picks are branch-movement operations — the parent workflow owns any PROJECT.md update, not this command.
- Always use `cherry-pick -x` to preserve source reference
- `--force` overrides the gate's accept/reject decision, not any downstream phase
- When in doubt, reject
- Use `--plan-only` when you want dependency ordering and risk classification without applying anything
