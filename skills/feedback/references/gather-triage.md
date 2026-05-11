---
model: opus
---

# Gather + Triage PR Feedback

## Inputs

- PR number or URL
- Flags: `--draft`, `--auto`

## Gather

Detect the PR input, then fetch both top-level discussion and inline review comments:

```bash
gh pr view <number> --comments
gh api repos/<owner>/<repo>/pulls/<number>/comments
```

Prefer API/GraphQL thread data when resolution status matters.

## Complexity Gate

Classify scope before acting:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Comment count | 1-3 | 4+ |
| Fix type | Cosmetic, naming | Logic, behavior |
| Scope | Single area | Cross-cutting |
| Discussion items | 0 | 1+ |

Emit the Complexity Gate block from `rules/complexity-gate.md`.

Trivial plus confidence 8/10 or higher can use the quick-fix path: fix, post, summarize, and skip the full triage table.

## Investigate

For each actionable review comment:

- Read the referenced code and surrounding file.
- Verify the claim; do not assume the reviewer is correct.
- Check whether another guard, middleware, caller contract, or test already covers the concern.
- Use git blame/log when the existing shape looks intentional.

## Triage Output

Present this table before fixing unless `--auto` was passed:

```markdown
| # | Reviewer | Comment | Verdict | Reasoning | Confidence |
|---|----------|---------|---------|-----------|------------|
| 1 | @user | ... | Fix | Evidence and actual risk | 9/10 |
| 2 | @user | ... | Skip | Evidence for why current code is valid | 7/10 |
| 3 | @user | ... | Discuss | Trade-off or missing product decision | 5/10 |
```

Verdicts:

- `Fix`: bugs, security issues, missing error handling, established project standards.
- `Skip`: style preference, out of scope, misunderstanding, or false positive.
- `Discuss`: architecture disagreement, ambiguous requirement, or user/product trade-off.

## Confirmation Gate

Pause after triage unless `--auto` was passed.

Ask the user to confirm, adjust verdicts, or override. Do not start fixing or posting until approved.

`--draft` still runs triage and draft response work, but does not post.
`--auto` skips the pause; still include the triage table in the summary.
