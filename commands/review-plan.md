# /review-plan - Plan Review (Iterate to 8/10)

Review implementation plan using Codex, iterating until score ≥ 8/10.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/planning.md` - What makes a good plan
3. `rules/orchestration.md` - Claude + Codex workflows

Do not proceed until rules are read and understood.

---

## Usage
```
/review-plan                    # Review PROJECT.md (default)
/review-plan ./docs/PLAN.md     # Review specific file
```

## Steps

1. **Load Plan**
   ```bash
   # Default: PROJECT.md
   cat PROJECT.md
   
   # Or specified file
   cat <path>
   ```

2. **Codex Review**
   ```
   codex exec --sandbox read-only "Review this implementation plan.
   
   PLAN:
   ---
   [insert plan content]
   ---
   
   Score each dimension (1-10):
   
   | Dimension | What to Evaluate |
   |-----------|------------------|
   | **Clarity** | Goal clear? Success criteria defined? |
   | **Completeness** | All sections filled? Assumptions documented? |
   | **Feasibility** | Technically sound? Dependencies identified? |
   | **Risk Assessment** | Risks identified? Mitigation strategies? |
   | **Implementation Path** | Clear steps? Sequenced? Blockers identified? |
   | **Testing Strategy** | Validation approach? Edge cases? |
   | **Trade-offs** | Multiple options? Pros/cons documented? |
   | **Actionability** | Can implementation start immediately? |
   
   For each dimension:
   - Score (1-10)
   - Specific issues
   - Concrete improvement suggestions
   
   Format:
   ## Scores
   | Dimension | Score | Issues | Suggestions |
   
   ## Top 3 Priorities
   1. [Most important fix]
   2. [Second priority]
   3. [Third priority]
   
   ## Overall
   **Score: X.X/10**"
   ```

3. **Check Score**

   - **Score ≥ 8/10**: Plan approved ✅ → Go to step 6
   - **Score < 8/10**: Continue to step 4

4. **Claude Improves Plan** (if < 8/10)

   **IMPORTANT**: Do NOT write feedback/review comments into PROJECT.md.
   Instead, directly improve the actual plan content:

   - If Clarity is low → Rewrite Goal/Overview to be clearer
   - If Completeness is low → Add missing sections
   - If Risk Assessment is low → Add Risks section with mitigations
   - If Testing Strategy is low → Add concrete test approach
   - If Implementation Path is low → Add sequenced steps

   Think through improvements, then edit the actual plan sections.

5. **Re-Review** (Loop)

   Return to step 2 with the improved plan.

   Continue until:
   - Score ≥ 8/10, OR
   - Max 5 rounds reached

6. **Write Approved Plan to PROJECT.md**

   Once score ≥ 8/10, write the final improved plan to PROJECT.md.

   The plan content should be clean - no review feedback, just the plan itself.

7. **Final Report**
   ```markdown
   ## Plan Review Complete

   ### Rounds: [N]
   | Round | Score | Key Improvements |
   |-------|-------|------------------|
   | 1 | 5.5 | Missing risk assessment |
   | 2 | 6.8 | Added testing strategy |
   | 3 | 8.2 | Clarified implementation steps |

   ### Final Score: X.X/10 ✅

   ### Plan Written To
   - PROJECT.md updated with approved plan

   ### Next Steps
   - Run `/implement` to begin implementation
   ```

## Stagnation Detection

If score unchanged for 2 rounds:
```markdown
## Review Stagnating

Score stuck at X.X/10 for 2 rounds.

Options:
1. Continue with different approach
2. Accept current plan
3. Rethink fundamentally
```

## Notes
- Defaults to PROJECT.md
- Iterates until 8/10 or max 5 rounds
- Claude improves, Codex reviews
- Plan must pass before implementation starts
