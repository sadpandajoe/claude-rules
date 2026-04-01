# /review-code - Adaptive Team Code Review

@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: You have local changes (uncommitted or committed) and want a quality pass with the right reviewers for the change type.
> **Produces**: Team-reviewed findings, fixes, test coverage assessment, and a Review Gate block.

## Usage
```
/review-code                    # Review all uncommitted changes
/review-code src/api/           # Review changes in specific path
/review-code --files a.ts b.ts  # Review specific files
/review-code --committed        # Review committed changes (diff base..HEAD)
```

## Steps

### 1. Gather Changed Files

- **Uncommitted** (default): `git diff --name-only` (unstaged + staged)
- **Committed** (`--committed`): `git diff base..HEAD --name-only`
- Apply path filtering if specified

If no changes found, stop: `"No changes to review."`

### 2. Complexity Gate

Classify the change scope:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files changed | 1-3 | 4+ |
| Lines changed | < 50 | 50+ |
| Logic changes | None / cosmetic | Functional |
| Cross-cutting | No | Yes |

Emit the Complexity Gate block per `rules/complexity-gate.md`.

- **Trivial**: Code quality reviewer only (step 3). No team.
- **Standard**: Code quality + adaptive team (step 4).

Only formatting-only diffs and micro-fixes (per `rules/review-gate.md`) skip the review loop entirely.

### 3. Code Quality Review (always runs)

Delegate to `review-code-quality.md`. This skill owns:
- Code review against `rules/code-review.md`
- Finding normalization (`[major]`, `[minor]`, `[nitpick]`)
- Fix + verify loop
- **Test check**: detects whether tests exist for changed logic
  - No tests → triggers test suggestion (`review-testplan.md`)
  - Tests found → triggers test quality review (`review-tests.md`) + suggestions for additional coverage

### 4. Adaptive Team (Standard complexity only)

Analyze the diff to select additional reviewers:

| Reviewer | Trigger | Focus |
|----------|---------|-------|
| Architecture (`review-architecture.md`) | Source files with logic changes | Right file? Right layer? Duplicate function? |

Launch selected reviewers as **parallel subagents** (`model: "opus"`). Each gets the diff + full file context.

Merge all findings with the code quality findings. Deduplicate.

### 5. Run Pre-flight Checks

Before declaring complete, run the repo's standard checks:
- Build, type check, lint, tests covering changed files
- If checks fail, fix and return to step 3
- If environment can't run checks: `Pre-flight: skipped` with reason

### 6. Emit Review Gate

```markdown
## Review Gate
Rounds: [N]
Pre-flight: [pass/fail/skipped]
Status: [clean/blocked/user decision/skipped/micro-fix]
```

### 7. Adversarial Suggestion

If the diff touches security-sensitive areas (auth, input handling, API endpoints, database queries, file operations, secrets), suggest:
> Consider running `/review-code-adversarial` for security-focused review.

### 8. Summary

```markdown
## Review-Code Complete
Rounds: [N] | Pre-flight: [pass/fail] | Status: [clean/blocked]

### Team Selected
| Reviewer | Why |
|----------|-----|
| Code quality | Always |
| [additional] | [reason] |

### Reviewed
- [What was checked — specific behaviors, edge cases verified]

### Not Reviewed
- [Deliberately out of scope]

### Fixed
- [Issues fixed, grouped by file — or "none"]

### Test Coverage
- [Tests found/missing, suggestions made]

### Remaining
- [Nitpicks or blockers — or "none"]
```

## Notes
- This command is used standalone and also called internally by `/create-feature`, `/fix-bug`, `/fix-ci`
- The team composition is adaptive — show it in the summary so the user can `/learn` to correct bad selections
- For a second model's perspective, use `/review-code-codex`
- For security/adversarial review, use `/review-code-adversarial`
