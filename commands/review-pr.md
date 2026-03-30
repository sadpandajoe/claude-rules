# /review-pr - Review GitHub Pull Request

> **When**: Asked to review someone else's GitHub PR.
> **Produces**: Scored review with actionable feedback, optionally posted to GitHub.

## Usage
```
/review-pr <pr-number-or-url>
```

## Steps

1. **Gather PR Context**
   ```bash
   # Get PR metadata
   gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,files,additions,deletions

   # Get the diff
   gh pr diff $ARGUMENTS

   # Get list of changed files with full content for context
   gh pr view $ARGUMENTS --json files -q '.files[].path'
   ```

   Read the full content of changed files — review comments on changed lines, but understand the surrounding context.

2. **Initial Assessment**

   - Purpose: What problem does this solve?
   - Scope: Is it focused or sprawling?
   - Risk: What could break?

3. **Score Using Framework**

   | Component | Score | Notes |
   |-----------|-------|-------|
   | Root Cause | /10 | Why was this change needed? |
   | Solution | /10 | Efficient, maintainable? |
   | Tests | /10 | Realistic, covering? |
   | Code | /10 | Readable, consistent? |
   | Docs | /10 | Clear, complete? |

4. **Tag Issues by Severity**

   For each issue:
   - `[major]` - Must fix before merge (bugs, security, missing tests)
   - `[minor]` - Should fix (naming, DRY, partial docs)
   - `[nitpick]` - Optional (style, micro-optimizations)

   **Line number accuracy**: Use `gh api` to get diff hunks with positions. Map each issue to the correct diff line, not the file line number. This matters for posting review comments.

   ```bash
   # Get diff with positions for accurate line commenting
   gh api repos/{owner}/{repo}/pulls/{number}/files --paginate
   ```

5. **Present Review to User**

   ```markdown
   ## PR Review: #[number] - [title]

   ### Summary
   [1-2 sentence summary of what PR does]

   ### Scores
   | Component | Score | Notes |
   |-----------|-------|-------|
   | Root Cause | X/10 | |
   | Solution | X/10 | |
   | Tests | X/10 | |
   | Code | X/10 | |
   | Docs | X/10 | |
   | **Overall** | **X/10** | |

   ### Issues

   #### [major]
   - `file.py:42` — description

   #### [minor]
   - `file.py:87` — description

   #### [nitpick]
   - `file.py:15` — description

   ### Recommendation
   **Approve** / **Request Changes** / **Comment**
   [Reasoning]
   ```

6. **Ask User: Post to GitHub?**

   Options:
   - **Post full review** — submit as GitHub review with inline comments
   - **Post summary only** — single review comment with the summary
   - **Don't post** — just show locally

   If posting inline comments:
   ```bash
   # Submit review with inline comments
   gh api repos/{owner}/{repo}/pulls/{number}/reviews \
     -f event="REQUEST_CHANGES" \
     -f body="Review summary" \
     -f 'comments[]={ "path": "file.py", "line": 42, "body": "[major] description" }'
   ```

   If posting summary only:
   ```bash
   gh pr review $ARGUMENTS --request-changes --body "review body"
   # or --approve or --comment
   ```

## Notes
- Read full files for context, only comment on changed lines
- All `[major]` issues must be addressed before recommending approval
- Score >= 8/10 needed for approval recommendation
- Always ask before posting to GitHub
- Use diff positions (not file line numbers) when posting inline comments
