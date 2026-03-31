# /review-pr - Review GitHub Pull Request

@{{TOOLKIT_DIR}}/rules/complexity-gate.md
@{{TOOLKIT_DIR}}/rules/code-review.md

> **When**: Asked to review someone else's GitHub PR.
> **Produces**: Scored review with actionable feedback, posted to GitHub.

Use `--draft` to show the review locally without posting.

## Usage

```
/review-pr <pr-number-or-url>
/review-pr <pr-number-or-url> --draft
```

## Steps

### 1. Gather PR Context

```bash
# Metadata
gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,files,additions,deletions

# Diff
gh pr diff $ARGUMENTS

# Changed file paths
gh pr view $ARGUMENTS --json files -q '.files[].path'
```

Read the full content of changed files — review comments target changed lines, but the review must understand surrounding context.

### 2. Complexity Gate

Classify the PR scope:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files changed | 1–5 | 6+ |
| Lines changed | < 100 | 100+ |
| Behavioral change | None / cosmetic | Functional |
| Cross-cutting | No | Yes |

Emit the Complexity Gate block per `rules/complexity-gate.md`.

**Trivial + confidence 8/10+**: Streamlined review — score, post, summary. Skip deep investigation.

### 3. Deep Review

Read full files for context around each changed section. For standard complexity, investigate:
- Purpose: What problem does this solve?
- Correctness: Could this break existing behavior?
- Test coverage: Are new paths tested?
- Consistency: Does it follow codebase patterns?

Score using the framework from `rules/code-review.md`:

| Component | Score | Notes |
|-----------|-------|-------|
| Root Cause | /10 | Why was this change needed? |
| Solution | /10 | Efficient, maintainable? |
| Tests | /10 | Realistic, covering? |
| Code | /10 | Readable, consistent? |
| Docs | /10 | Clear, complete? |

Tag issues by severity:
- `[major]` — Must fix before merge (bugs, security, missing tests)
- `[minor]` — Should fix (naming, DRY, partial docs)
- `[nitpick]` — Optional (style, micro-optimizations)

Use `gh api repos/{owner}/{repo}/pulls/{number}/files --paginate` for accurate diff positions when mapping issues to lines.

### 4. Review Gate

Determine recommendation based on scores:
- **Approve**: Overall 8/10+, zero `[major]` issues
- **Request Changes**: Any `[major]` issue, or overall below 6/10
- **Comment**: Overall 6-7/10, no `[major]` but notable `[minor]` issues

### 5. Post to GitHub

**Default**: Post the review to GitHub automatically.
- If recommendation is `Approve` or `Comment`: post with inline comments
- If recommendation is `Request Changes`: post with inline comments

```bash
# Submit review with inline comments
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  -f event="REQUEST_CHANGES" \
  -f body="Review summary" \
  -f 'comments[]={ "path": "file.py", "line": 42, "body": "[major] description" }'
```

**`--draft` flag**: Show the review in conversation only. Do not post to GitHub.

### 6. Summary

```markdown
## Review-PR Complete
PR #[number]: [title] — [Approve / Request Changes / Comment]

### Scores
| Component | Score |
|-----------|-------|
| Root Cause | X/10 |
| Solution | X/10 |
| Tests | X/10 |
| Code | X/10 |
| Docs | X/10 |
| **Overall** | **X/10** |

### Issues Found
- [N] major, [N] minor, [N] nitpick

### Posted
[Yes — link to review / No — draft mode]
```

## Non-Negotiable Gates

- [ ] Full file context read (not just diff)
- [ ] Complexity Gate block emitted
- [ ] All issues tagged by severity
- [ ] Review Gate recommendation determined
- [ ] Summary emitted

## PROJECT.md Update Discipline

If a PROJECT.md exists, update after posting with PR number, recommendation, and key findings. Skip if no PROJECT.md exists and review completes without issues.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /review-pr <pr-reference>
- Phase: gather / complexity-gate / review / gate / post / summarize
- Resume target: PR #[number]
- Completed items: [phases finished]
### State
- PR: [number] — [title]
- Complexity: [trivial / standard]
- Scores: [component: score, ...]
- Recommendation: [approve / request-changes / comment / pending]
- Posted: [yes / no / pending]
```

## Notes
- Read full files for context, only comment on changed lines
- Use diff positions (not file line numbers) when posting inline comments
- Default is auto-post; use `--draft` for local-only review
- Score >= 8/10 with zero `[major]` needed for approval
