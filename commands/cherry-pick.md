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
- each requested change is classified as `Applied`, `Blocked`, `Rejected`, or `Skipped`
- applied changes preserve source intent on the target branch
- validation status is recorded for each applied change
- PROJECT.md contains the final execution table and detailed notes for non-trivial rows

### Validation Plan
- use the repo-standard validation commands for the changed area
- prefer targeted checks over broad rebuilds
- escalate instead of rebuilding or refreshing the environment automatically

This contract is the default execution boundary for `/cherry-pick`.
Do not stop just to present it.
Surface it only if intervention is needed or summarize adherence in the final report.

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

   @/Users/joeli/opt/code/ai-toolkit/skills/release-engineer/cherry-pick-plan.md

   This phase owns dependency analysis, ordering, and the initial execution table.

   If `--plan-only` is set, stop after producing the plan report.

2. **Investigate Each Change in Order** (`release-engineer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/release-engineer/cherry-pick-investigate.md

   For a single input, investigate that change directly.
   For multiple inputs, process the planned sequence one change at a time.

   This phase produces the risk assessment for each change.
   Auto-proceed only when the helper rates the change low-risk, high-confidence, and not decision-bound.
   Otherwise record the status in the execution table and stop for user input only where required.

3. **Apply Each Auto-Approved Cherry-Pick Sequentially** (`release-engineer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/release-engineer/cherry-pick-apply.md

   ```bash
   git checkout <target-branch>
   git cherry-pick -x <commit-hash>
   ```

   Always apply on the target branch sequentially, never in parallel.

4. **Adapt Conflicts if Needed** (`developer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/cherry-pick-adapt.md

   This phase owns conflict classification and code-level adaptation.
   If the cherry-pick state is lost, do not continue blindly; return to the apply phase.
   If a prerequisite or behavior decision is required, stop and ask the user.

5. **Validate Each Applied Change** (`developer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/cherry-pick-validate.md

   This phase owns validation depth, including stronger checks for dependency-manifest changes.
   If stronger validation would require rebuilding or refreshing the environment, stop for intervention instead of doing it automatically.

6. **Document the Plan and Outcome**
   ```markdown
   ## Cherry-Pick Plan

   ### Target Branch
   <branch>

   ### Dependency Graph
   | Change | Depends On | Independent |
   |--------|------------|-------------|
   | PR #123 | — | Yes |

   <short summary of whether inter-change dependencies were detected>

   ### Execution Table
   | # | SHA | PR | Description | Depends On | Risk | Confidence | Decision | Status | Adaptation | Validation | Notes |
   |---|-----|----|-------------|------------|------|------------|----------|--------|------------|------------|-------|
   | 1 | `<sha>` | #123 | <summary> | — | LOW | 9/10 | Auto | Applied | None | Tested | Applied cleanly |
   | 2 | `<sha>` | #124 | <summary> | #123 | MED | 7/10 | Approval | Blocked | Minor | Not run | Needs user approval for prerequisite |

   ### Detailed Notes
   #### `<sha>` — <summary>
   - **Source**: <source branch or PR>
   - **Why non-trivial**: [conflict, rejection reason, or intervention point]
   - **Adaptation details**: [What was modified and why]
   - **Prerequisites**: [Any commits needed first]
   - **Residual risk**: [What remains uncertain]

   ### Contract Adherence
   - **Within contract**: Yes / No
   - **Boundary crossed**: [if any]
   - **Intervention required**: [if any]
   ```

   Keep the dependency graph.
   Use one master execution table for both planning and final outcome.
   Add detailed notes only for rows that are not straightforward.

   If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

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

   After writing the checkpoint:
   - run `/clear`
   - run `/start`
   - resume `/cherry-pick` at the saved phase and target

## Sequential Cherry-Pick Safety

When cherry-picking multiple commits in sequence:
- Verify each cherry-pick completes before starting the next
- If one fails mid-chain, do NOT continue with subsequent picks
- Clean up the failed state (`git cherry-pick --abort`) before deciding next steps
- Document which picks succeeded and which didn't

## Notes
- Always use `cherry-pick -x` to preserve source reference
- Default to low-intervention flow when the investigation rates the move low-risk and no decision is required
- Prefer functional over structural changes
- When in doubt, reject
- Use `--plan-only` when you want dependency ordering and risk classification without applying anything
