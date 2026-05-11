---
model: sonnet
---

# PR Review Batch

Use when `/review-pr` receives multiple PR numbers or `--all-open`.

## Batch Contract

The main thread is a thin orchestrator:
- resolve the PR list
- dispatch bounded single-PR reviews
- collect compact results
- post aggregate summary

The main thread must not accumulate full diffs or full review transcripts for every PR.

## Resolve PRs

- `--all-open`: run `gh pr list --json number,title --state open`
- Multiple numbers: parse provided refs

## Dispatch

For each PR, dispatch a subagent with:
- PR number/ref
- flags (`--auto` by default in batch mode unless user asked for draft)
- pointer to [pr-review.md](pr-review.md)
- pointer to [pr-posting.md](pr-posting.md)
- compact return contract

Return contract:

```markdown
PR:
Title:
Recommendation: approve | request-changes | comment
Posted: yes | no
Top finding:
Finding counts:
Residual risk:
```

Concurrency: run up to 4-5 PR reviews in parallel. Lower concurrency if PRs are unusually large or the repo is resource constrained.

## Aggregate

```markdown
## Review Batch Complete — <N> PRs

| PR | Title | Recommendation | Key Finding | Posted |
|----|-------|----------------|-------------|--------|
| #1 |  | approve | Clean — no issues | yes |

### Needs Attention
- PR #<N>: <why it needs manual follow-up>
```

If all PRs are clean, write `All PRs reviewed cleanly`.

## Notes

Reviews are read-only. No worktrees are needed unless an optional external reviewer requires checkout isolation.
