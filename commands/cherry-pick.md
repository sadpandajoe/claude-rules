# /cherry-pick - Cherry-Pick One or More Changes

@/Users/joeli/opt/code/ai-toolkit/rules/cherry-picking.md
@/Users/joeli/opt/code/ai-toolkit/skills/release-engineer/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md

> **When**: Moving one or more changes (bug fixes, isolated features) to another branch.
> **Produces**: Ordered plan, clean cherry-picks with conflicts resolved where safe, and a per-change report documented in PROJECT.md.

## Contract

### Goal
Safely move one or more isolated changes onto the target branch.

### In Scope
- reorder requested cherries when needed
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
/cherry-pick <pr-url>                   # Cherry-pick from a PR
/cherry-pick <sha>                      # Cherry-pick a specific commit
/cherry-pick <sha> --target <branch>    # Cherry-pick to specific branch
/cherry-pick <sha-1> <sha-2> <sha-3>    # Plan and execute multiple changes
/cherry-pick <sha-1> <sha-2> --plan-only # Plan only, do not apply
```

## Steps

1. **Plan Order if Needed** (`release-engineer`)

   If multiple PRs or SHAs are provided, or if `--plan-only` is set:

   This phase owns dependency analysis, ordering, and the initial execution table.

   If `--plan-only` is set, stop after producing the plan report.

2. **Investigate Each Change in Order** (`release-engineer`)

   For a single input, investigate that change directly.
   For multiple inputs, process the planned sequence one change at a time.

   When the change is intended to resolve a bug, run `check-existing-fix.md` and produce its formal output block (the `## Existing Fix Status` summary with status, confidence, and evidence). The check itself is not enough — the normalized output is required so the calling workflow can branch on it.

   **Bug classification**: if the PR is tagged `fix`/`bugfix` or the commit message indicates corrective behavior, treat it as a bug fix. When ambiguous (e.g., `refactor` that also fixes a defect), run the check — a false positive (checking unnecessarily) costs less than a false negative (skipping and cherry-picking a fix that's already on the target). **Exception**: skip the check for dependency upgrades, version bumps, or mixed PRs where the primary change is not an isolated defect — see `check-existing-fix.md` skip rules. When skipping, still emit the output block with `Status: SKIPPED`.

   This phase produces the risk assessment for each change.
   Auto-proceed only when the helper rates the change low-risk, high-confidence, and not decision-bound.
   Otherwise record the status in the execution table and stop for user input only where required.

   **Fast path for single LOW-risk changes**: When there is only one change and investigation rates it `Risk: LOW` / `Confidence >= 8/10` / `Decision: NO`, combine investigate and apply into a single phase — emit the action gate block and proceed directly to apply without a separate presentation step.

3. **Apply Each Auto-Approved Cherry-Pick Sequentially** (`release-engineer`)

   ```bash
   git checkout <target-branch>
   git cherry-pick -x <commit-hash>
   ```

   Always apply on the target branch sequentially, never in parallel.

4. **Adapt Conflicts if Needed** (`developer`)

   This phase owns conflict classification and code-level adaptation.
   If the cherry-pick state is lost, do not continue blindly; return to the apply phase.
   If a prerequisite or behavior decision is required, stop and ask the user.

5. **Validate Each Applied Change** (`developer`)

   This phase owns validation depth, including stronger checks for dependency-manifest changes.
   If stronger validation would require rebuilding or refreshing the environment, stop for intervention instead of doing it automatically.

6. **Document the Plan and Outcome**

   **Planning phase** uses the full execution table (12 columns) defined in `cherry-pick-plan.md`. That table is the working artifact during investigation and apply.

   **Final report** uses a condensed format. Lead with the ticket outcome (what the user cares about), then the execution table, then actionable residuals:

   ```markdown
   ## Cherry-Pick Summary

   [1-2 lines answering the user's original question — e.g., "The StructuredContentStripperMiddleware (the encoding fix) is now active on this branch." or "The fix from #38837 is applied; CI re-run needed to confirm."]

   [X of N applied, Y rejected, Z partial] → <target branch>

   ### Results
   | SHA | PR | Status | Validation | Notes |
   |-----|----|--------|------------|-------|
   | `<sha>` | #123 | Applied | Tested | Clean apply |
   | `<sha>` | #124 | Partial | Checked | 5 of 7 sub-fixes applied; encoding fix dropped — see below |
   | `<sha>` | #125 | Rejected | — | Missing decorator infrastructure on target |

   ### Detailed Notes
   #### `<sha>` — <summary>
   - **Why non-trivial**: [conflict, rejection reason, or intervention point]
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

   ```markdown
   ## Continuation Checkpoint — [timestamp]
   ### Workflow
   - Top-level command: /cherry-pick <arguments>
   - Phase: plan / investigate / apply / adapt / validate / document
   - Resume target: PR #123 / `<sha>` / current conflict file
   - Completed items: [already applied, skipped, blocked, or rejected changes]
   ### State
   - Target branch: <branch>
   - Current execution table snapshot: [latest status summary]
   - Pending intervention points: [any user decisions still needed]
   ```

## Sequential Cherry-Pick Safety

When cherry-picking multiple commits in sequence:
- Verify each cherry-pick completes before starting the next
- If one fails mid-chain, do NOT continue with subsequent picks
- Clean up the failed state (`git cherry-pick --abort`) before deciding next steps
- Document which picks succeeded and which didn't

## PROJECT.md Update Discipline

Cherry-picks are branch-movement operations, not project-state changes. PROJECT.md updates are **not required** for cherry-pick workflows. The execution table and final report in the conversation are sufficient documentation.

Exception: if the cherry-pick is part of a larger workflow (e.g., `/fix-bug` routing to `/cherry-pick`), the parent workflow owns the PROJECT.md update.

## Notes
- Always use `cherry-pick -x` to preserve source reference
- Default to low-intervention flow when the investigation rates the move low-risk and no decision is required
- Prefer functional over structural changes
- When in doubt, reject
- Use `--plan-only` when you want dependency ordering and risk classification without applying anything
