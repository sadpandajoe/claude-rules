# /create-feature - End-to-End Feature Workflow

@/Users/joeli/opt/code/ai-toolkit/rules/planning.md
@/Users/joeli/opt/code/ai-toolkit/rules/implementation.md
@/Users/joeli/opt/code/ai-toolkit/rules/input-detection.md
@/Users/joeli/opt/code/ai-toolkit/rules/testing.md
@/Users/joeli/opt/code/ai-toolkit/rules/orchestration.md
@/Users/joeli/opt/code/ai-toolkit/skills/pm/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/qa/SKILL.md

> **When**: You have a feature request or other planned non-bug work and want the repo-standard workflow to scope it, review it, implement it, and keep going until a real decision matters.
> **Produces**: Feature brief, milestones, implementation plan, reviewed plan, implemented local changes, review and QA results, and a handoff before the final commit or PR action.

## Plan Mode Usage

Steps 1–2 (normalize input, complexity gate) happen **before** plan mode in normal mode. The complexity gate must be visible in conversation so the user can react, and a TRIVIAL result skips plan mode entirely.

**Standard path**: After the complexity gate, enter plan mode for planning (steps 3–8). Let plan mode's natural phases (Explore→Design→Review→Final Plan) drive the work, seeded with this command's requirements:

| Plan mode phase | `/create-feature` work |
|-----------------|----------------------|
| **Explore** | Decide PM scope, codebase exploration (step 3) |
| **Design** | Feature brief + milestones (if PM needed), technical plan (steps 4–6) |
| **Review** | PM brief to 8/10, tech plan to 8/10, cold read (steps 5, 7–8) |
| **Final Plan** | Produce the plan file with: feature brief, milestones, tech plan, review scores, implementation slices |

On exit, plan mode produces a plan file. The execution phases (steps 9–12) read that plan file as their input.

**Trivial path**: Do not enter plan mode. Go straight to implementation.

**After exiting plan mode** (step 9 onward):
1. Read the plan file
2. Write the plan content into PROJECT.md sections (Feature Brief, Milestones, Implementation Plan, Review Summary)
3. Hit the action gate — decide whether to proceed, stop, or surface a decision
4. Implement, review, summarize

## Usage
```
/create-feature "add bulk edit for dashboard filters"
/create-feature sc-12345
/create-feature apache/superset#28456
/create-feature https://github.com/owner/repo/issues/123
/create-feature https://app.shortcut.com/.../story/123
```

## Steps

1. **Normalize Input**

   Accept:
   - plain-language feature request
   - Shortcut story ID or URL
   - GitHub issue or PR reference / URL

   When a ticket URL or issue reference is provided, **fetch and parse it FIRST** before any planning or code investigation. Extract scope, acceptance criteria, and constraints from the source. These are authoritative — don't re-derive scope from scratch.

   Pull in external context when references are provided.

2. **Complexity Gate**

   Assess the change before entering planning phases:

   | Signal | Trivial | Standard |
   |--------|---------|----------|
   | Files touched | 1–2 | 3+ or unclear |
   | Design decisions | None | Any |
   | New APIs / migrations | No | Yes |
   | Behavioral risk | Mechanical / cosmetic | Functional change |

   State the classification explicitly **in the conversation** (not just in a plan file) using the action-gate format. The user must see this block and be able to react before the workflow continues.

   ```markdown
   ## Complexity Gate
   Classification: TRIVIAL / STANDARD
   Confidence: X/10
   Reason: [one line]
   ```

   **Trivial + confidence 8/10+**: Execute the trivial path directly — do not enter standard-path steps 3–10:
   1. Implement the change
   2. Run the actual test suite covering the changed files (`pytest -k ...`, `jest --testPathPattern ...`) — pre-commit alone is not sufficient
   3. `/review-code` — must produce Review Gate block (this is not optional)
   4. Update PROJECT.md (single update)
   5. Emit summary (step 12)

   **Standard**: Continue to step 3. Make this decision yourself and continue automatically — do not ask the user whether to run review iterations, which reviewers to use, or whether the plan is "good enough." End-to-end commands own their internal loops.

   Do not silently decide — always emit the gate block above.

3. **Decide Whether PM Planning Is Needed**

   Use the PM layer when scope, milestones, acceptance criteria, or rollout framing are non-trivial.
   Skip it when the work is already tightly scoped and just needs technical planning.

4. **Create the Feature Brief**

   If PM planning is needed:
   - use `pm/create-feature-brief.md`
   - include goals, non-goals, acceptance criteria, assumptions, and rollout framing
   - add milestones with `pm/plan-milestones.md`

   If PM planning is skipped:
   - synthesize a minimal feature brief from the request before technical planning starts

   @/Users/joeli/opt/code/ai-toolkit/skills/pm/create-feature-brief.md
   @/Users/joeli/opt/code/ai-toolkit/skills/pm/plan-milestones.md

5. **Iterate the PM Brief to 8/10**

   Review the feature brief with the shared PM brief reviewer and revise until it reaches `8/10`.

   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-feature-brief/SKILL.md

6. **Create the Technical Plan**

   Use `developer/plan-feature.md` to define:
   - technical approach
   - PR slices
   - migrations or API implications
   - test strategy
   - implementation sequencing

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/plan-feature.md

7. **Iterate the Technical Plan to 8/10**

   Always run these reviewers:
   - `core/review-architecture`
   - `core/review-implementation`
   - `core/review-testplan`

   Add these when the plan needs them:
   - `core/review-frontend`
   - `core/review-backend`

   Revise the plan until all applicable reviewers are at `8/10` or better. Run the iterations automatically — do not ask the user whether to continue reviewing or which reviewers to use. Only stop for a blocking decision that requires user input.

   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-architecture/SKILL.md
   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-implementation/SKILL.md
   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-testplan/SKILL.md
   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-frontend/SKILL.md
   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-backend/SKILL.md

8. **Run the Final Cold Read**

   Use the shared finalize-plan skill as an internal cold read.
   If it finds a blocking issue, revise the relevant layer and re-run it.

   @/Users/joeli/opt/code/ai-toolkit/skills/core/finalize-plan/SKILL.md

9. **Exit Plan Mode → PROJECT.md + Action Gate**

   Read the plan file produced by plan mode. Write its content into PROJECT.md sections:
   - `Feature Brief`
   - `Milestones`
   - `Implementation Plan`
   - `Review Summary`

   Then run the action gate to decide whether to proceed, stop, or surface a decision. Use `skills/shared/action-gate.md` — auto-proceed when Risk is LOW, Confidence ≥ 8/10, and no decision is required.

   @/Users/joeli/opt/code/ai-toolkit/skills/shared/action-gate.md

10. **Continue Into Implementation**

   If no meaningful decision remains:
   - prepare the environment when needed
   - for each implementation slice, define the acceptance or regression test first
   - write the failing test before the code change when feasible
   - if test-first is blocked by env, repro, or harness constraints, write the test anyway and record the verification gap — writing is separate from running
   - for mechanical changes (renames, config swaps, endpoint changes with no new logic), writing tests alongside the implementation is acceptable — record why test-first was skipped
   - implement the feature through `developer`
   - run QA validation when the work is user-visible

   If a meaningful decision remains:
   - stop and surface it clearly

11. **Review Changed Files** (gate)

   Run `/review-code` on changed repo-tracked files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

   This step is a gate — `/review-code` must produce its Review Gate block before the workflow can proceed. If the block is missing, the review has not been completed.

   For truly minimal mechanical changes (renames, config swaps), the review loop may be skipped — but the Review Gate block must still be emitted with `Status: skipped` and a reason.

   Do not skip this step when resuming from a pre-built plan.

12. **Summary**

   Lead with the outcome, not the process. If the user gave you a ticket, answer whether it's done. Keep it concise — technical details go in the collapsible section.

   ```markdown
   ## Create-Feature Complete
   [1-2 lines: what was built, whether it meets the acceptance criteria, confidence level]

   ### What to do next
   - [Specific next action — PR link, deploy step, remaining slices]

   ### Open risks
   - [Anything uncertain or untested]

   <details><summary>Technical details</summary>

   - Approach: [brief]
   - Files changed: [count or list]
   - Review: Rounds [N] | Pre-flight [pass/fail] | Status [clean/blocked]

   </details>
   ```

## PROJECT.md Update Discipline

PROJECT.md is the single source of truth for durable state.

Update `PROJECT.md` at these points:

**Standard path:**
- **step 9** — after exiting plan mode, flush the plan file content (feature brief, milestones, tech plan, review scores) into PROJECT.md sections. This is the first and primary write.
- after implementation and validation complete

**Trivial path:**
- after implementation and validation complete (single update is sufficient)

**No PROJECT.md** — if no `PROJECT.md` exists and the workflow completes in a single pass without blockers, creating one is not required. Note the skip in the summary.

## Continuation Checkpoint

If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /create-feature <arguments>
- Phase: input / complexity-gate / pm-brief / pm-review / tech-plan / tech-review / finalize / implement / review / qa-validate / summarize
- Resume target: <story, issue, milestone, PR slice, file set, or current blocker>
- Completed items: <finished phases or accepted decisions>
### State
- Complexity: <trivial / standard>
- PM required: <yes / no / skipped — trivial>
- PM brief score: <score or skipped>
- Technical plan score: <score or pending>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>
```

After writing the checkpoint:
- run `/clear`
- run `/start`
- resume `/create-feature` at the saved phase and target

Use `/update-project-file --checkpoint ...` only when you need a manual checkpoint outside the normal flow.

## Notes
- `/create-feature` is the public entrypoint for planned non-bug work, including refactors where the PM layer can be skipped
- Only pause when a real decision matters
- Use test-first implementation by default for each slice; document why when it is blocked
- `/review-code` is an internal phase here, not the expected next top-level user step
- Stop before the final commit or PR action
- When resuming from a pre-built plan, enter at the implementation phase but still run review, QA, and pre-flight checks before declaring done
