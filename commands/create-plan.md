# /create-plan - Create Implementation Plan

@/Users/joeli/opt/code/claude-rules/rules/planning.md
@/Users/joeli/opt/code/claude-rules/PROJECT_TEMPLATE.md

> **When**: Facing a non-trivial task that needs a plan before coding.
> **Produces**: Documented implementation plan in PROJECT.md.

## Usage
```
/create-plan "add caching to the API"
/create-plan                            # interactive requirements gathering
```

## Steps

1. **Setup PROJECT.md**
   - If new: Create from `PROJECT_TEMPLATE.md`
   - If exists: Read and understand current state

2. **Gather Requirements**
   Ask user:
   - What are we trying to accomplish?
   - What are the constraints?
   - What's the timeline/priority?

3. **Investigate Codebase**
   - Study existing patterns and conventions
   - Check related/dependent code
   - Verify dependencies exist
   - Look for similar implementations

4. **Document Plan**
   ```markdown
   ## Overview
   [One paragraph description]

   ## Goal
   [What success looks like]

   ## Assumptions
   - [Assumption 1]
   - [Assumption 2]

   ## Solutions

   ### Option 1: [Name]
   - **Approach**: [Description]
   - **Pros**: [Benefits]
   - **Cons**: [Drawbacks]
   - **Risk**: Low/Medium/High
   - **Effort**: [Estimate]

   ### Option 2: [Alternative]
   [Same structure]

   ## Recommended Approach
   [Which option and why]

   ## Implementation Phases

   Break work into small, independently deployable PRs.
   Each phase should be shippable on its own — no phase should
   leave the system in a broken state.

   ### Phase 1: [Name]
   - **PR scope**: [What this PR contains]
   - **Migrations**: [If needed — never a standalone migration PR]
   - **Deployable**: Yes — [why this works independently]
   - **Steps**:
     1. [Step]
     2. [Step]

   ### Phase 2: [Name]
   - **PR scope**: [What this PR contains]
   - **Depends on**: Phase 1
   - **Deployable**: Yes
   - **Steps**:
     1. [Step]
     2. [Step]

   ## Testing Strategy
   [How we'll validate]

   ## Risks & Mitigation
   | Risk | Probability | Impact | Mitigation |
   |------|-------------|--------|------------|
   | [Risk] | Low/Med/High | Low/Med/High | [Strategy] |
   ```

5. **Handoff**
   ```
   Plan written to PROJECT.md.
   Run /review-plan when ready to get domain expert feedback.
   ```

## Phase Decomposition Rules
- Every phase must be independently deployable — no "deploy phases 1-3 together"
- Migrations are never standalone PRs — bundle with the code that uses them
- If a later phase needs another migration, add to it then — don't front-load all migrations
- Prefer vertical slices (one feature end-to-end) over horizontal layers (all models, then all APIs, then all UI)
- Each phase's PR should be small enough to review in one sitting

## Auto-Chain

After the plan is written to PROJECT.md, automatically continue:

1. **Invoke `/review-plan`** — run multi-round expert review
   - Iterate until ALL reviewers score >= 8/10
   - No round limit — keep iterating until threshold is met
   - Each round: apply feedback, re-run reviewers

2. **Invoke `/finalize-plan`** — fresh-eyes final review
   - Cold-read Go/No-Go assessment
   - **Enhanced output**: Include an iteration summary showing:
     - Starting score → final score
     - What changed in each review round and why
     - Key decisions made during iteration

3. **STOP** — present the finalized plan to the user
   - User reviews and decides whether to proceed to `/implement`

## Notes
- Document multiple options with trade-offs
- Plan should be actionable — ready to implement
- Full flow: `/create-plan` → auto: `/review-plan` → `/finalize-plan` → **GATE** → `/implement`
