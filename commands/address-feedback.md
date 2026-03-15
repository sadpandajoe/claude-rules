# /address-feedback - Address PR Review Feedback

@/Users/joeli/opt/code/claude-rules/rules/code-review.md

> **When**: A PR has review comments that need to be addressed.
> **Produces**: Fixes committed, responses drafted or posted.

## Usage
```
/address-feedback <pr-url>
/address-feedback <pr-number>
```

## Steps

1. **Fetch PR Comments**
   ```bash
   gh pr view <number> --comments
   gh api repos/<owner>/<repo>/pulls/<number>/comments
   ```

2. **Triage Each Comment**

   For each feedback item:
   ```markdown
   | # | Reviewer | Comment | Verdict | Reason |
   |---|----------|---------|---------|--------|
   | 1 | @alice | Missing null check | Fix | Valid — unhandled edge case |
   | 2 | @bob | Use a factory pattern | Skip | Style preference, not project convention |
   | 3 | @alice | What about auth? | Discuss | Ambiguous — need to clarify scope |
   ```

   **Fix**: actual bugs, security issues, missing error handling, project standards
   **Skip**: style preferences, out of scope, misunderstanding, incorrect assessment
   **Discuss**: architectural disagreements, ambiguous requirements, trade-offs

3. **Present Triage to User**

   Show the table. User approves, adjusts, or overrides any verdicts.

4. **Fix Approved Items**

   Address fixes by priority:
   1. Bugs and security issues
   2. Missing error handling
   3. Standards compliance

   Commit fixes: `fix: address PR feedback — [summary]`

5. **Draft Responses**

   For each skipped or discussed item, draft a reply:
   ```markdown
   ### Skipped: FB-2 (@bob — "Use a factory pattern")
   > Thanks for the suggestion. We're keeping the current approach since
   > it follows the existing patterns in this area of the codebase.

   ### Discuss: FB-3 (@alice — "What about auth?")
   > Good question — auth is handled by the middleware layer upstream.
   > The changes here operate after auth is already validated.
   ```

   **Ask user**: "Post these replies directly to the PR, or just show them for you to post?"

   If user approves direct posting:
   ```bash
   gh pr comment <number> --body "<response>"
   # Or reply to specific review comment
   gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies -f body="<response>"
   ```

6. **Summary**
   ```markdown
   ## Feedback Addressed

   **PR**: #[number]
   - **Fixed**: X items (committed)
   - **Skipped**: X items (responses drafted/posted)
   - **Discussed**: X items (responses drafted/posted)

   ### Next Steps
   - Request re-review if fixes were made
   ```

## Notes
- Always present triage to user before acting
- Ask before posting any replies to the PR
- Fix items get committed, skip/discuss items get responses
