# /review-pr - Adaptive Team PR Review

@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: Asked to review someone else's GitHub PR.
> **Produces**: Team-reviewed findings, recommendation, and optional GitHub review posting.

Use `--draft` to show the review locally without posting. Use `--auto` to skip confirmations.

## Usage

```
/review-pr <pr-number-or-url>
/review-pr <pr-number-or-url> --draft
/review-pr <pr-number-or-url> --adversarial
/review-pr <pr-number-or-url> --auto
/review-pr 101 102 103
/review-pr --all-open
```

## Contract

- Main thread orchestrates; reviewer judgment comes from fresh reviewer contexts.
- Read full changed-file context, not only the diff.
- Emit a Complexity Gate block for single-PR reviews.
- Assess impact before calibrating severity.
- Validate PR premise for Standard or CORE-impact PRs.
- Show findings and severity reasoning to the user before posting unless `--auto` is passed.
- Post only clean, user-confirmed finding text to GitHub.
- For batch reviews, keep the main thread as a thin orchestrator and use compact per-PR handoffs.

## Steps

### 1. Resolve Input

Detect whether the input is a single PR, multiple PRs, or `--all-open`.

For multiple PRs or `--all-open`, follow [skills/review/references/pr-batch.md](../skills/review/references/pr-batch.md) and stop after the aggregate summary.

Batch mode should group independent PRs into small waves only when context does not overlap. Do not carry full per-PR diffs in the main thread; keep compact findings, recommendation, blockers, and posting state.

### 2. Single-PR Review

Follow [skills/review/references/pr-review.md](../skills/review/references/pr-review.md).

That reference owns:
- PR context gathering
- Complexity Gate classification
- impact assessment
- premise validation
- reviewer-team dispatch
- pattern analysis
- synthesis, scoring, and recommendation

Use fresh reviewer subagents for each single-PR review pass. Reuse a reviewer only to clarify that reviewer's own finding in the same pass.

### 3. Post or Draft

Follow [skills/review/references/pr-posting.md](../skills/review/references/pr-posting.md).

Respect:
- `--draft`: never post
- `--auto`: skip confirmations
- clean Standard reviews: confirm before approving unless `--auto`
- findings: post only user-confirmed finding descriptions

### 4. Summary

Emit the summary from [skills/review/references/pr-posting.md](../skills/review/references/pr-posting.md).

## Non-Negotiable Gates

- [ ] Full file context read
- [ ] Complexity Gate block emitted for single PRs
- [ ] Impact assessment completed
- [ ] Premise validation completed for Standard or CORE-impact PRs
- [ ] All findings tagged by severity
- [ ] Recommendation determined before posting
- [ ] Posting action respects `--draft`, `--auto`, and user-confirmation boundaries
- [ ] Summary emitted

## Notes

- Batch mode defaults to `--auto` unless the user asked for draft/review-only behavior.
- Read-only reviews should not mutate the worktree.
- For security-sensitive areas, suggest or run the adversarial lane when appropriate.
