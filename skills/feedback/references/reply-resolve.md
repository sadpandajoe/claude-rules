---
model: sonnet
---

# Reply + Resolve PR Feedback

## Draft Replies

Keep replies short and evidence-based.

Fixed:

```markdown
Fixed in `<sha>` - added a null guard before reading the response payload.
```

Skipped:

```markdown
Thanks for the suggestion. Keeping the current approach because auth is enforced by the route middleware before this handler runs.
```

Discuss:

```markdown
Good question. This would change the API contract for existing callers; should we make that behavior change in this PR or open a follow-up?
```

## Posting Rules

1. Inline reply for line-anchored review comments with a path, line, and comment id:

```bash
gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies \
  -f body="<response>"
```

2. Do not reply to top-level review body summaries unless they ask a direct code question.
3. For a top-level direct code question, use a normal PR comment and quote enough context.
4. Check identity before posting:

```bash
gh auth status
```

If `gh` is authenticated as a teammate or automation account that could surprise the user, pause and confirm before posting.

## Resolve Threads

- Bot threads may be resolved when the associated fix is verified.
- Human reviewer threads stay open. Post the reply and let the reviewer resolve or re-review.
- Never resolve ambiguous or discussion threads unless the user explicitly asks.

## Push + Post Gate

Mechanical fixes may be pushed and posted automatically unless `--draft` was passed.

For substantive fixes, pause with:

```markdown
Ready to push [N] commits and reply to [N] threads:
- Fixed: [...]
- Skipped: [...]
- Discuss: [...]
Push and post?
```

`--auto` skips this pause.

## Summary

Use this terminal summary:

```markdown
## Address-Feedback Complete
PR #[number] - [N] fixed, [N] skipped, [N] discussed

### Actions Taken
- Fixed: [count] items
- Skipped: [count] items
- Discussed: [count] items

### Verification
- [commands/checks run, or skipped reason]

### Suggested Next Steps
[request re-review / resolve discussion / rerun after blockers / merge when approved]
```

Record metrics with:

- `command`: `address-feedback`
- `complexity`: `trivial` or `standard`
- `status`: `clean`, `blocked`, `user-decision`, `skipped`, or `micro-fix`
- `rounds`: review rounds if any
- `gate_decisions`: complexity, triage, review
- `worker_usage`: subagent/worker invocation counts when applicable
