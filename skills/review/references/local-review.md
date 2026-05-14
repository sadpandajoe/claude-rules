---
tier: Heavy
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

Classify scope with `rules/complexity-gate.md` and this review-specific routing:

| Signal | Trivial | Moderate | Standard |
|--------|---------|----------|----------|
| Files changed | 1-2 | 2-4 in one subsystem | 5+ or unclear ownership |
| Lines changed | < 50 | 50-200 | 200+ |
| Logic changes | None or cosmetic | Contained functional change | Cross-cutting behavior |
| Reviewer lanes | Code quality only | Triggered lanes only | Full triggered team, plus optional second opinion |

Formatting-only diffs and micro-fixes may skip the review loop under `rules/review-gate.md`.

## Classify + Impact

Run these in parallel when possible:

- [classify-diff.md](classify-diff.md): choose reviewer domains.
- [../../qa/references/assess-impact.md](../../qa/references/assess-impact.md): classify functional impact as CORE, STANDARD, or PERIPHERAL.

Escalate CORE impact:

- TRIVIAL + CORE: run full review team.
- MODERATE + CORE: run triggered reviewer lanes and escalate any security-sensitive or data-loss risk to Standard handling.
- STANDARD + CORE: run full team and suggest adversarial review for security-sensitive areas.
- CORE test gaps use stricter severity calibration.

## Pre-Flight Verification

Run the repo's relevant checks before reviewer dispatch:

- Build/typecheck/lint when applicable.
- Tests covering changed files or changed behavior when they are quick enough for the review scope.
- A clear skipped reason when the app or suite is not runnable locally.

If pre-flight fails, fix the failure or report it as a blocker before launching reviewer lanes. Reviewer context should include the pre-flight result.

## Dispatch Reviewers

The main thread is an orchestrator. Dispatch fresh-context reviewer subagents with:

- Diff and full changed-file contents.
- Acceptance criteria from PROJECT.md if relevant.
- Complexity and impact assessment.
- Pre-flight verification result.
- The selected reviewer reference.

Use triggered references from `classify-diff.md`, including:

- [code-quality.md](code-quality.md)
- [../../testing/references/review-tests.md](../../testing/references/review-tests.md)
- [../../testing/references/review-testplan.md](../../testing/references/review-testplan.md)
- [../../plan-review/references/architecture.md](../../plan-review/references/architecture.md)
- [../../plan-review/references/frontend.md](../../plan-review/references/frontend.md)
- [../../plan-review/references/backend.md](../../plan-review/references/backend.md)

Collect findings, dedupe, sort by severity, and write the Review Record to PROJECT.md before fixing `[major]` and `[minor]` issues or checkpointing.

## Re-Verify + Iterate

After applying reviewer fixes, re-run relevant checks:

- Build/typecheck/lint.
- Tests covering changed files or changed behavior.
- Targeted verification for fixed findings.

If checks fail, fix and re-run classification/review as needed.

## Optional Second Opinion

For STANDARD complexity, use an external or platform-native second opinion if available. Skip silently when unavailable and note that in the summary.

Map second-opinion findings to toolkit severity:

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

## PROJECT.md Review Record

Write or update this compact record before fixing findings or clearing context. Keep only actionable state; do not paste full reviewer transcripts.

```markdown
## Current Code Review

**Scope:** <changed files or path filter>
**Pre-flight:** <pass/fail/skipped — command or reason>
**Review Gate:** <pending/clean/blocked/user decision/skipped/micro-fix>

### Findings
| ID | Severity | File | Finding | Status |
|----|----------|------|---------|--------|
| R1 | major/minor/nitpick | path:line | concise issue | open/fixed/deferred/user-decision |

### Fix Queue
- [ ] R1 — <specific next action>

### Resume Notes
- Next: <fix R1 / re-run verification / emit Review Gate / continue caller workflow>
```

If there are no actionable findings, write `Findings: none` and the clean Review Gate status so `/checkpoint --clear` can resume without reconstructing review context from chat.

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
