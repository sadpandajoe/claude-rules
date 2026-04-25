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

## Orchestration Model

The main thread is the **orchestrator** — it gathers context, dispatches reviewer subagents, collects their findings, and synthesizes the result. The main thread does not review code itself. All review judgment comes from subagents running with fresh context.

## Steps

### 1. Gather Changed Files

- **Uncommitted** (default): `git diff --name-only` + `git diff --cached --name-only` (deduplicated — captures both unstaged and staged changes)
- **Committed** (`--committed`): `git diff base..HEAD --name-only`
- Apply path filtering if specified
- Read the full content of each changed file

If no changes found, stop: `"No changes to review."`

### 2. Complexity Gate

Classify the change scope:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files changed | 1-3 | 4+ |
| Lines changed | < 50 | 50+ |
| Logic changes | None / cosmetic | Functional |
| Cross-cutting | No | Yes |

Examples — TRIVIAL: renamed a variable in one file (10 lines, no logic). STANDARD: refactored error handling across 6 files (200+ lines, behavioral change).

Emit the Complexity Gate block per `rules/complexity-gate.md`.

- **Trivial**: Code quality reviewer only.
- **Standard**: Full review team.

Only formatting-only diffs and micro-fixes (per `rules/review-gate.md`) skip the review loop entirely.

### 3. Classify and Assess Impact

Follow these two reference paths in parallel on the changeset:
- **`review/references/classify-diff.md`** — determines which review domains apply (structure: which reviewers)
- **[skills/qa/references/assess-impact.md](../skills/qa/references/assess-impact.md)** — determines functional impact: CORE, STANDARD, or PERIPHERAL (function: how critical)

**Impact escalation**: If the impact is CORE, escalate regardless of complexity tier:
- TRIVIAL + CORE → run full review team (not just code quality)
- STANDARD + CORE → full team + suggest `--adversarial` for security-sensitive areas
- Test coverage findings for CORE workflows use stricter severity per `rules/code-review.md` calibration

Pass the impact assessment to all reviewer subagents so they can calibrate severity accordingly.

### 4. Launch Review Team

Dispatch all triggered reviewers as **parallel subagents** (`model: "opus"`) with context isolation per `rules/orchestration.md`. Each receives: the diff, full content of changed files, acceptance criteria from PROJECT.md if available, the impact assessment from step 3, and its skill file. Each applies its lens independently and returns severity-tagged findings.

Collect all findings. Deduplicate. Apply fix + verify loop for any `[major]` or `[minor]` issues.

### 5. Run Pre-flight Checks

Before declaring complete, run the repo's standard checks:
- Build, type check, lint, tests covering changed files
- If checks fail, fix and return to step 3
- If environment can't run checks: `Pre-flight: skipped` with reason

### 6. Codex Second Opinion (Standard only, if available)

Skip this step for Trivial complexity.

Check if the Codex plugin is available (i.e., `/codex:setup` is a recognized command). If unavailable, skip silently and note "Codex: skipped (plugin not available)" in the summary.

If available:

1. Detect the base branch: check for `main`, `master`, or query `gh repo view --json defaultBranchRef`
2. Launch Codex in background: `/codex:review --background --base <base-branch>`
3. Collect findings via `/codex:result`
4. Translate to toolkit severity:
   - Codex "must fix" / critical → `[major]`
   - Codex "should fix" / improvement → `[minor]`
   - Codex style/preference → `[nitpick]`
5. Merge with existing findings, marking source as "Codex" for any new issues
6. If Codex surfaces new `[major]` issues not caught by Claude, fix and re-run pre-flight (step 4)
7. Include Codex scores in summary (Implementation Quality, Test Signal, Regression Protection)

### 7. Emit Review Gate

Emit the gate **after all review lanes have finished** (including Codex). Internal callers branch on this status.

```markdown
## Review Gate
Rounds: [N]
Pre-flight: [pass/fail/skipped]
Status: [clean/blocked/user decision/skipped/micro-fix]
```

### 8. Adversarial Suggestion

If the diff touches security-sensitive areas (auth, input handling, API endpoints, database queries, file operations, secrets), suggest:
> Consider running `/review-code-adversarial` for security-focused review.

### 9. Summary

```markdown
## Review-Code Complete
Rounds: [N] | Pre-flight: [pass/fail] | Status: [clean/blocked]

### Team Selected
| Reviewer | Why |
|----------|-----|
| Code quality | Always |
| Tests / Test plan | Tests exist → testing/references/review-tests.md; no tests → testing/references/review-testplan.md |
| Architecture | Logic changes in source files |
| Codex (GPT-5.4) | Standard complexity (or: skipped — plugin not available) |

### Reviewed
- [What was checked — specific behaviors, edge cases verified]

### Not Reviewed
- [Deliberately out of scope]

### Fixed
- [Issues fixed, grouped by file — or "none"]

### Test Coverage
- [Tests found/missing, suggestions made]

### Codex Scores (if ran)
| Component | Score |
|-----------|-------|
| Implementation Quality | X/10 |
| Test Signal | X/10 |
| Regression Protection | X/10 |

### Remaining
- [Nitpicks or blockers — or "none"]

### Suggested Next Steps
**Skip this section when invoked as an internal phase** — the calling command (`/create-feature`, `/fix-bug`, etc.) owns the next steps after the Review Gate.

**Standalone only** — pick based on Review Gate status:
- **Clean + uncommitted**: Commit your changes, then `/create-pr` when ready
- **Clean + committed**: `/create-pr` to open the PR
- **Blocked**: Fix the blockers, then re-run `/review-code` to iterate
- **User decision**: A trade-off or scope question needs your input — decide, then re-run `/review-code`
- **Micro-fix**: Minimal mechanical change — commit directly, no further review needed
- **Skipped**: Review was skipped (formatting-only or micro-fix) — commit directly
- **Security-sensitive areas detected**: `/review-code-adversarial` for red-team review
- **Test gaps identified**: `/create-tests` or `/update-tests` to fill coverage
```

## Notes
- This command is used standalone and also called internally by `/create-feature`, `/fix-bug`, `/fix-ci`, `/create-tests`, `/update-tests`
- Internal callers invoke `/review-code` as an internal review phase. This is an allowed composition pattern alongside `/checkpoint` and `/verify` — see `rules/orchestration.md`
- The team composition is adaptive — show it in the summary so the user can `/learn` to correct bad selections
- Codex second opinion runs automatically for Standard complexity when the plugin is available
- For security/adversarial review, use `/review-code-adversarial`
