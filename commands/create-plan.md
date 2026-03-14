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

   ## Implementation Steps
   1. [Phase 1]
   2. [Phase 2]

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

## Notes
- Document multiple options with trade-offs
- Plan should be actionable — ready to implement
- Do NOT auto-trigger review — let user decide when to review
- Full flow: `/create-plan` → `/review-plan` → `/finalize-plan` → `/implement`
