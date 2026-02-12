# /review-plan - Plan Review (Iterate to 8/10)

> **When**: A plan exists and needs quality review before implementing.
> **Produces**: Iterated plan scoring 8/10+.

## Usage
```
/review-plan                    # Review PROJECT.md (default)
/review-plan ./docs/PLAN.md     # Review specific file
```

## Steps

1. **Load Plan**

   Use the `Read` tool to load the plan file (PROJECT.md by default, or specified path).

2. **Codex Review**
   ```
   codex exec --sandbox read-only "Review this implementation plan thoroughly.

   PLAN:
   ---
   [insert plan content]
   ---

   First, list ALL findings - don't hold back:

   ## Findings
   For each issue found:
   - [High/Medium/Low] Specific issue with file/section reference
   - Include missing details, gaps, risks, inconsistencies
   - Be specific about what's wrong and why it matters

   ## Open Questions
   List any ambiguities or decisions that need clarification.

   ## Summary Score
   Rate the plan 1-10 considering:
   - Clarity, Completeness, Feasibility
   - Risk Assessment, Implementation Path
   - Testing Strategy, Actionability

   **Overall: X/10**

   ## Top 3 Priorities
   The most critical items to fix before implementation."
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
