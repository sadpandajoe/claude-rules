# /review-code-codex - Codex Second-Opinion Review

> **When**: You want a second model's perspective on your local changes, optionally with a cross-model fix chain.
> **Produces**: Codex review findings translated to toolkit severity format, optional Claude fixes, Review Gate block.

This command uses the Codex plugin (`/codex:review`) to get an independent review from a different model (GPT-5.4), then optionally chains with Claude to fix issues.

## Usage

```
/review-code-codex                  # Codex reviews uncommitted changes
/review-code-codex --committed      # Codex reviews committed changes (base..HEAD)
/review-code-codex --fix            # Codex reviews, Claude fixes, Codex re-reviews
```

## Steps

### 1. Discover Changed Files

Same as `/review-code`:
- Default: uncommitted changes via `git diff --name-only`
- `--committed`: committed changes via `git diff base..HEAD --name-only`

If no changes found, stop: `"No changes to review."`

### 2. Launch Codex Review

Invoke the Codex plugin review in background:

```
/codex:review --background --scope working-tree
```

Or for committed changes:
```
/codex:review --background --base main
```

While Codex runs, inform the user: `"Codex review running in background..."`

### 3. Collect Codex Findings

When the Codex job completes, retrieve the result:

```
/codex:result
```

Parse the Codex output. Codex produces structured findings with its own scoring (Implementation Quality, Test Signal, Regression Protection on 1-10 scale per the AGENTS.md config).

### 4. Translate to Toolkit Format

Map Codex findings to toolkit severity tags:
- Codex "must fix" / critical findings → `[major]`
- Codex "should fix" / improvement suggestions → `[minor]`
- Codex style/preference comments → `[nitpick]`

Present the translated findings:

```markdown
## Codex Review Findings
Model: GPT-5.4 via Codex plugin

### Issues
- [major] {description} — {file}:{line}
- [minor] {description} — {file}:{line}
- [nitpick] {description}

### Codex Scores
| Component | Score |
|-----------|-------|
| Implementation Quality | X/10 |
| Test Signal | X/10 |
| Regression Protection | X/10 |
```

### 5. Fix Chain (if `--fix`)

When `--fix` is specified:

1. For each `[major]` and `[minor]` finding from Codex, Claude implements the fix
2. Run pre-flight checks (build, lint, tests)
3. Re-run Codex review on the fixed code: `/codex:review --background`
4. Collect and present the re-review results
5. If new issues found, iterate (max 2 rounds)

### 6. Emit Review Gate

```markdown
## Review Gate
Rounds: [N] (Codex review + [N] fix rounds if --fix)
Pre-flight: [pass/fail/skipped]
Status: [clean/blocked]
Reviewer: Codex (GPT-5.4)
```

### 7. Summary

```markdown
## Review-Code-Codex Complete
Reviewer: Codex (GPT-5.4) | Rounds: [N] | Status: [clean/blocked]

### Findings
- [N] major, [N] minor, [N] nitpick

### Fixed (if --fix)
- [What Claude fixed based on Codex findings]

### Remaining
- [Unfixed items or none]
```

## Notes
- This is a second-opinion review, not a replacement for `/review-code`
- Codex runs in background — you can continue working while it reviews
- The `--fix` flag creates a unique cross-model workflow: Codex finds issues, Claude fixes them
- Requires the Codex plugin to be installed and configured (`/codex:setup`)
