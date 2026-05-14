---
tier: Standard
---

# PR Review Posting

Use after PR review synthesis has produced a recommendation.

## Posting Rules

Detail level scales with complexity and findings.

- **Trivial + clean**: return an approve recommendation; post/approve directly only with `--auto` or explicit user authorization.
- **Moderate + clean**: approve with compact summary in draft/confirmation mode; post directly only with `--auto`.
- **Standard + clean**: pause with a one-line confirmation before approving unless `--auto` was passed.
- **Any findings**: post only user-confirmed findings with adjusted severities.
- **`--draft`**: show review in conversation only. Do not post.
- **`--auto`**: skip confirmations and post/approve directly.

Reasoning, confidence, and internal evidence shown to the user are not posted to GitHub. GitHub gets clean finding descriptions only.

Use `gh api repos/{owner}/{repo}/pulls/{number}/files --paginate` for accurate diff positions.

## Security Suggestion

If `--adversarial` was not used and the diff touches security-sensitive areas (auth, input handling, API endpoints, database queries, file operations, secrets), suggest re-running with `/review-pr <ref> --adversarial` or `/review-code-adversarial`.

## Summary Shape

```markdown
## Review-PR Complete
PR #<number>: <title> — <Approve / Request Changes / Comment>

### Team Selected
| Reviewer | Why |
|----------|-----|
| Code quality | Always |

### Scores
| Component | Score |
|-----------|-------|
| Root Cause | X/10 |
| Solution | X/10 |
| Tests | X/10 |
| Code | X/10 |
| Docs | X/10 |
| Overall | X/10 |

### Issues Found
- <N> major, <N> minor, <N> nitpick

### Posted
<Yes — link / No — draft mode>

### Suggested Next Steps
- <specific next action>
```

Suggested next step examples:
- Approved: PR is ready to merge.
- Request Changes posted: wait for author to address, then re-run `/review-pr`.
- Comment posted: author should review comments; re-run when updated.
- Draft mode: post with `/review-pr <number>` without `--draft`.
- Security-sensitive: re-run with `--adversarial`.
- Author asked you to address feedback: `/address-feedback <number>`.
