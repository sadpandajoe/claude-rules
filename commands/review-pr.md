# /review-pr - Review GitHub Pull Request

Review a third-party PR using scoring framework and Codex verification.

> **Note**: Claude Code invokes Codex CLI via the **Bash tool**.
> Run `codex exec ...` commands through Bash, not as a native tool.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/code-review.md` - Review criteria and scoring
3. `rules/orchestration.md` - Claude + Codex workflows

Do not proceed until rules are read and understood.

---

## Usage
```
/review-pr <pr-number-or-url>
```

## Arguments
- `$ARGUMENTS` - PR number (e.g., `123`) or full URL (e.g., `https://github.com/owner/repo/pull/123`)

## Steps

1. **Gather PR Context**
   ```bash
   # Get PR metadata
   gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,files,additions,deletions

   # Get the diff
   gh pr diff $ARGUMENTS

   # Get list of changed files
   gh pr view $ARGUMENTS --json files -q '.files[].path'
   ```

2. **Initial Assessment**

   Review the PR for:
   - Purpose: What problem does this solve?
   - Scope: Is it focused or sprawling?
   - Risk: What could break?

3. **Score Using Framework**

   Evaluate per `rules/code-review.md`:

   | Component | Score | Notes |
   |-----------|-------|-------|
   | Root Cause | /10 | Why was this change needed? |
   | Solution | /10 | Efficient, maintainable? |
   | Tests | /10 | Realistic, covering? |
   | Code | /10 | Readable, consistent? |
   | Docs | /10 | Clear, complete? |

4. **Tag Issues by Severity**

   For each issue found:
   - `[major]` - Must fix before merge (bugs, security, missing tests)
   - `[minor]` - Should fix (naming, DRY, partial docs)
   - `[nitpick]` - Optional (style, micro-optimizations)

5. **Codex Independent Review** (REQUIRED per orchestration rules)

   ```bash
   codex exec --sandbox read-only "Review this PR diff for bugs, security issues, and style problems. Score 1-10 and list issues by severity [major]/[minor]/[nitpick]:

   $(gh pr diff $ARGUMENTS)"
   ```

6. **Consolidate Findings**

   Merge Claude and Codex findings:
   - Deduplicate issues
   - Reconcile scoring differences
   - Note any disagreements

7. **Final Report**
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
   - file:line - description

   #### [minor]
   - file:line - description

   #### [nitpick]
   - file:line - description

   ### Codex Review
   [Summary of Codex findings, especially any Claude missed]

   ### Recommendation
   **Approve** / **Request Changes** / **Comment**

   [Reasoning for recommendation]
   ```

## Notes
- Always get Codex independent review before finalizing
- All `[major]` issues must be addressed before approving
- Score ≥ 8/10 needed for approval recommendation
- Include file:line references for actionable feedback
