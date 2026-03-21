# /address-feedback - Address PR Review Feedback

@/Users/joeli/opt/code/claude-rules/rules/code-review.md

> **When**: A PR has review comments that need to be addressed.
> **Produces**: Fixes committed, responses drafted or posted.

## Golden Rule
Triage is step 1, not the goal. The point is to fix things and respond, not to produce a triage table.

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

2. **Investigate Each Comment**

   For each review comment, before triaging:
   - Read the actual code referenced by the comment
   - Verify the reviewer's claim is correct (don't assume)
   - Check if the issue is already handled elsewhere (guard clause upstream, try/catch wrapper, etc.)
   - Check git blame to understand why the code is the way it is

   This is evidence-based triage, not guess-based.

3. **Triage with Evidence**

   For each feedback item:
   ```markdown
   | # | Reviewer | Comment | Verdict | Evidence |
   |---|----------|---------|---------|----------|
   | 1 | @alice | Missing null check | Fix | Confirmed — `getData()` can return null on L42 |
   | 2 | @bob | Use a factory pattern | Skip | Current approach matches existing pattern in `src/utils/` |
   | 3 | @alice | What about auth? | Discuss | Auth is handled by middleware (verified in `auth.ts:15`) |
   ```

   **Fix**: actual bugs, security issues, missing error handling, project standards
   **Skip**: style preferences, out of scope, misunderstanding, incorrect assessment
   **Discuss**: architectural disagreements, ambiguous requirements, trade-offs

4. **Fix Approved Items**

   Address fixes by priority:
   1. Bugs and security issues
   2. Missing error handling
   3. Standards compliance

   **TDD for behavioral changes**: If a fix adds code, changes a function's behavior, or introduces a new code path → write a test first (RED), then fix (GREEN).
   **Direct fix for pattern-following**: If the fix follows existing patterns or is cosmetic (naming, formatting, moving code) → fix directly, existing tests cover it.

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

   **Note**: Comments may be interpreted differently — always let user review drafts before posting.

6. **Present Everything to User**

   Show all at once:
   - Triage table with evidence
   - Fixes made (with commit hashes)
   - Draft responses for skip/discuss items
   - Ask: "Push commits and post these replies? Or adjust first?"

7. **Push + Post on Approval**

   Only after user approves:
   ```bash
   git push

   # Reply to specific review comments
   gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies \
     -f body="<response>"

   # Or post a general PR comment
   gh pr comment <number> --body "<response>"
   ```

8. **Summary**
   ```markdown
   ## Feedback Addressed

   **PR**: #[number]
   - **Fixed**: X items (committed + pushed)
   - **Skipped**: X items (responses posted)
   - **Discussed**: X items (responses posted)

   ### Next Steps
   - Request re-review if fixes were made
   ```

## GitHub API Reference

```bash
# List review comments (code-level)
gh api repos/<owner>/<repo>/pulls/<number>/comments

# List issue comments (general PR comments)
gh api repos/<owner>/<repo>/issues/<number>/comments

# Reply to a specific review comment
gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies \
  -f body="<response>"

# Post a general PR comment
gh pr comment <number> --body "<response>"
```

## Notes
- Always investigate before triaging — read the actual code
- Present triage + fixes + draft responses to user before pushing/posting
- TDD for behavioral changes, direct fix for cosmetic/pattern-following changes
- Ask before posting any replies to the PR
