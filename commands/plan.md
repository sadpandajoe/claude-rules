# /plan - Planning Workflow

Create or refine an implementation plan.

## Prerequisites

**Read these rules first (in order):**
1. `rules/universal.md` - Core principles
2. `rules/planning.md` - Planning-specific rules

Do not proceed until rules are read and understood.

---

## Steps

2. **Setup PROJECT.md**
   - If new: Create from `PROJECT_TEMPLATE.md`
   - If exists: Read and understand current state

3. **Gather Requirements**
   Ask user:
   - What are we trying to accomplish?
   - What are the constraints?
   - What's the timeline/priority?

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

5. **Investigation Before Finalizing**
   - Study existing codebase patterns
   - Check related/dependent code
   - Verify dependencies exist
   - Look for similar implementations

6. **Trigger Plan Review**
   ```
   "Plan created. Running /review-plan to validate..."
   ```
   
   Automatically run `/review-plan` to iterate until 8/10.

## Notes
- Document multiple options with trade-offs
- Plan should be actionable - ready to implement
- Don't skip to implementation until plan scores 8/10
