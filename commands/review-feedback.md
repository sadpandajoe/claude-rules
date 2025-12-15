# /review-feedback - Process PR Feedback

Analyze PR feedback, determine validity, and plan fixes.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/code-review.md` - Review criteria
3. `rules/orchestration.md` - Claude + Codex workflows

Do not proceed until rules are read and understood.

---

## Usage
```
/review-feedback                    # Prompt for PR link/number
/review-feedback --pr <number>      # Specific PR
/review-feedback --file <path>      # Feedback from file
```

## Steps

1. **Gather PR Feedback**
   ```bash
   # From GitHub CLI (if available)
   gh pr view <number> --comments
   
   # Or from file
   cat <feedback-file>
   
   # Or paste directly
   ```

2. **Parse Feedback Items**
   
   Extract each distinct piece of feedback:
   ```markdown
   ## Feedback Items
   
   ### FB-1: [Summary]
   - **From**: [Reviewer name]
   - **File**: [file:line if specified]
   - **Comment**: [Full comment text]
   
   ### FB-2: [Summary]
   ...
   ```

3. **Claude Analysis**
   
   For each feedback item, Claude evaluates:
   ```markdown
   ### FB-1 Analysis (Claude)
   
   - **Valid**: Yes / No / Partially
   - **Reasoning**: [Why valid or not]
   - **Category**: Bug / Security / Performance / Style / Incorrect
   - **Effort**: Low / Medium / High
   - **Recommendation**: Fix / Skip / Discuss
   ```

4. **Codex Analysis**
   
   Send each item to Codex for independent review:
   ```
   codex exec --sandbox read-only "Analyze this PR feedback.
   
   FEEDBACK:
   ---
   [feedback text]
   ---
   
   RELEVANT CODE:
   ---
   [code being commented on]
   ---
   
   Evaluate:
   1. Is this feedback valid? (Yes/No/Partially)
   2. Why or why not?
   3. If valid, what's the fix?
   4. If invalid, what's the misunderstanding?
   
   Respond with:
   VALID: [Yes/No/Partially]
   REASONING: [explanation]
   RECOMMENDATION: [Fix/Skip/Discuss]
   FIX_APPROACH: [if valid, how to fix]"
   ```

5. **Consensus Resolution**
   
   Compare Claude and Codex assessments:
   
   | Claude | Codex | Action |
   |--------|-------|--------|
   | Fix | Fix | ✅ Fix - Add to plan |
   | Skip | Skip | ✅ Skip - Document why |
   | Fix | Skip | ⚠️ Discuss - Review together |
   | Skip | Fix | ⚠️ Discuss - Review together |
   
   **For disagreements:**
   ```markdown
   ### FB-X: Disagreement Resolution
   
   **Claude says**: [Fix/Skip] because [reason]
   **Codex says**: [Fix/Skip] because [reason]
   
   **Resolution process**:
   1. Re-examine the code context
   2. Consider reviewer's perspective
   3. Weigh risk of fixing vs not fixing
   4. Make final call with justification
   
   **Final Decision**: [Fix/Skip]
   **Reasoning**: [Why this decision]
   ```

6. **Generate Fix Plan**
   
   For all items marked "Fix":
   ```markdown
   ## Fix Plan
   
   ### High Priority
   - [ ] **FB-1**: [What to fix]
         - File: [file:line]
         - Approach: [How to fix]
         - Risk: Low/Medium/High
   
   ### Medium Priority
   - [ ] **FB-3**: [What to fix]
         ...
   
   ### Low Priority
   - [ ] **FB-5**: [What to fix]
         ...
   ```

7. **Codex Review Fix Plan**
   ```
   codex exec --sandbox read-only "Review this fix plan for PR feedback.
   
   PLAN:
   ---
   [fix plan]
   ---
   
   Evaluate:
   1. Are fixes appropriate for the feedback?
   2. Any risks or concerns?
   3. Suggested order of implementation?
   4. Anything missing?
   
   Score: X/10"
   ```
   
   If score < 8, refine plan and re-review.

8. **Document Skipped Items**
   ```markdown
   ## Skipped Feedback
   
   ### FB-2: [Summary]
   - **Reviewer**: [name]
   - **Comment**: [text]
   - **Why Skipped**: [Clear explanation]
   - **Response to Reviewer**: [Suggested reply]
   
   ### FB-4: [Summary]
   ...
   ```

9. **Generate Summary Report**
   ```markdown
   ## PR Feedback Summary
   
   **PR**: #[number]
   **Total Feedback Items**: X
   
   ### Disposition
   | Status | Count | Items |
   |--------|-------|-------|
   | Fix | X | FB-1, FB-3, FB-5 |
   | Skip | X | FB-2, FB-4 |
   | Discussed | X | FB-6 |
   
   ### Consensus
   - **Agreed (Claude + Codex)**: X items
   - **Disagreed → Resolved**: X items
   
   ### Fix Plan
   [Link to fix plan above]
   
   ### Suggested Responses
   
   **For FB-2 (skipped)**:
   > Thanks for the feedback. We're not addressing this because [reason].
   > [Additional context if needed]
   
   ### Next Steps
   1. Run `/implement` to execute fix plan
   2. Post responses to skipped items
   3. Request re-review
   ```

10. **Optional: Execute Fixes**
    ```
    "Fix plan ready. Run `/implement` to start fixing?
    Or review the plan first?"
    ```

## Validity Criteria

**Valid feedback (Fix):**
- Points out actual bugs
- Identifies security issues
- Catches incorrect behavior
- Highlights missing error handling
- Notes performance problems
- Follows project standards

**Invalid feedback (Skip):**
- Based on misunderstanding of requirements
- Suggests changes outside PR scope
- Personal style preference (not project standard)
- Already addressed elsewhere
- Incorrect technical assessment
- Nitpicks on unchanged code

**Needs Discussion:**
- Architectural disagreements
- Trade-off decisions
- Ambiguous requirements
- Both perspectives have merit

## Notes
- Both Claude and Codex analyze independently
- Disagreements are resolved explicitly
- Fix plan must score 8/10 before proceeding
- Document reasons for all skipped items
- Provide suggested responses to reviewers
