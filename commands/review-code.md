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

Emit the Complexity Gate block per `rules/complexity-gate.md`.

- **Trivial**: Code quality reviewer only.
- **Standard**: Full review team.

Only formatting-only diffs and micro-fixes (per `rules/review-gate.md`) skip the review loop entirely.

### 3. Launch Review Team

Dispatch all reviewers as **parallel subagents** (`model: "opus"`). Each gets the diff + full file context, applies its lens independently, and returns severity-tagged findings.

| Reviewer | Trigger | Focus |
|----------|---------|-------|
| Code quality (`review-code-quality.md`) | Always | Code review against `rules/code-review.md`, finding normalization, fix suggestions |
| Architecture (`review-architecture.md`) | Standard + logic changes | Right file? Right layer? Duplicate function? |
| Tests (`review-tests.md`) | Standard + tests exist | Behavioral coverage, weak tests, production failure scenarios, blind spots |
| Test Plan (`review-testplan.md`) | Standard + no tests exist | Coverage approach, test layers, edge cases, what tests to write |

**Trivial**: Code quality subagent only.
**Standard**: Code quality + all triggered reviewers in parallel.

Collect all findings. Deduplicate. Apply fix + verify loop for any `[major]` or `[minor]` issues.

### 4. Run Pre-flight Checks

Before declaring complete, run the repo's standard checks:
- Build, type check, lint, tests covering changed files
- If checks fail, fix and return to step 3
- If environment can't run checks: `Pre-flight: skipped` with reason

### 5. Codex Second Opinion (Standard only, if available)

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

### 6. Emit Review Gate

Emit the gate **after all review lanes have finished** (including Codex). Internal callers branch on this status.

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
| Tests / Test plan | Tests exist → review-tests.md; no tests → review-testplan.md |
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
```

## Notes
- This command is used standalone and also called internally by `/create-feature`, `/fix-bug`, `/fix-ci`, `/create-tests`, `/update-tests`
- Internal callers invoke `/review-code` as an internal review phase. This is an allowed composition pattern alongside `/checkpoint` and `/verify` — see `rules/orchestration.md`
- The team composition is adaptive — show it in the summary so the user can `/learn` to correct bad selections
- Codex second opinion runs automatically for Standard complexity when the plugin is available
- For security/adversarial review, use `/review-code-adversarial`
