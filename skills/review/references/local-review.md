---
model: opus
---

# Local Code Review Orchestration

Use for `/review-code` on local uncommitted, staged, committed, or path-filtered changes.

## Gather Changed Files

- Default: combine `git diff --name-only` and `git diff --cached --name-only`.
- `--committed`: compare `<base>..HEAD`.
- Path args or `--files`: filter to requested files.
- Read full content for changed files plus the relevant diff.

Stop if no changes are found.

## Complexity Gate

Classify scope with `rules/complexity-gate.md`:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files changed | 1-3 | 4+ |
| Lines changed | < 50 | 50+ |
| Logic changes | None or cosmetic | Functional |
| Cross-cutting | No | Yes |

Formatting-only diffs and micro-fixes may skip the review loop under `rules/review-gate.md`.

## Classify + Impact

Run these in parallel when possible:

- [classify-diff.md](classify-diff.md): choose reviewer domains.
- [../../qa/references/assess-impact.md](../../qa/references/assess-impact.md): classify functional impact as CORE, STANDARD, or PERIPHERAL.

Escalate CORE impact:

- TRIVIAL + CORE: run full review team.
- STANDARD + CORE: run full team and suggest adversarial review for security-sensitive areas.
- CORE test gaps use stricter severity calibration.

## Dispatch Reviewers

The main thread is an orchestrator. Dispatch fresh-context reviewer subagents with:

- Diff and full changed-file contents.
- Acceptance criteria from PROJECT.md if relevant.
- Complexity and impact assessment.
- The selected reviewer reference.

Use triggered references from `classify-diff.md`, including:

- [code-quality.md](code-quality.md)
- [../../testing/references/review-tests.md](../../testing/references/review-tests.md)
- [../../testing/references/review-testplan.md](../../testing/references/review-testplan.md)
- [../../plan-review/references/architecture.md](../../plan-review/references/architecture.md)
- [../../plan-review/references/frontend.md](../../plan-review/references/frontend.md)
- [../../plan-review/references/backend.md](../../plan-review/references/backend.md)

Collect findings, dedupe, sort by severity, and fix `[major]` and `[minor]` issues.

## Verify + Iterate

Run the repo's relevant checks:

- Build/typecheck/lint.
- Tests covering changed files or changed behavior.
- Targeted verification for fixed findings.

If checks fail, fix and re-run classification/review as needed.

## Optional Codex Second Opinion

For STANDARD complexity, use Codex review if available. Skip silently when unavailable and note that in the summary.

Map Codex findings to toolkit severity:

- Must fix / critical -> `[major]`
- Should fix / improvement -> `[minor]`
- Style/preference -> `[nitpick]`

Fix new `[major]` issues and verify again.

## Review Gate

Emit after all review lanes finish:

```markdown
## Review Gate
Rounds: [N]
Pre-flight: [pass/fail/skipped]
Status: [clean/blocked/user decision/skipped/micro-fix]
```

## Summary

Use the standalone summary only when `/review-code` is user-invoked directly. Internal callers own their next-step section.

```markdown
## Review-Code Complete
Rounds: [N] | Pre-flight: [pass/fail/skipped] | Status: [clean/blocked]

### Team Selected
| Reviewer | Why |
|----------|-----|

### Fixed
- [...]

### Test Coverage
- [...]

### Remaining
- [...]
```
