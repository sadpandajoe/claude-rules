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

- Bot threads are eligible for resolution only when the associated fix is verified and resolution was authorized for this run.
- Human reviewer threads stay open. Post the reply and let the reviewer resolve or re-review.
- Never resolve ambiguous or discussion threads unless the user explicitly asks.

## Push + Post Gate

Do not push, post GitHub replies, approve/request changes, or resolve threads unless the user explicitly authorized that boundary or a command flag clearly grants it.

Boundary meanings:
- `--draft`: never post or resolve; return reply drafts and resolution recommendations only.
- `--auto`: may skip posting confirmation for already-verified replies, but does not authorize commit, amend, rebase, push, or force-push by itself.
- No flag: prepare replies and ask before posting or resolving.

Replies that claim a fix was made should only be posted after the fix is visible on the PR branch, or after the user explicitly asks to post draft wording before pushing.

When confirmation is needed, pause with:

```markdown
Ready to push [N] commits and reply to [N] threads:
- Fixed: [...]
- Skipped: [...]
- Discuss: [...]
Push and post?
```

With `--auto`, skip this pause only for posting replies or resolving eligible bot threads after verification is clean and identity checks pass.

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
- `complexity`: `trivial`, `moderate`, or `standard`
- `status`: `clean`, `blocked`, `user-decision`, `skipped`, or `micro-fix`
- `rounds`: review rounds if any
- `gate_decisions`: complexity, triage, review
- `worker_usage`: subagent/worker invocation counts when applicable
