# /review-code-adversarial - Dual-Model Red-Team Review

@{{TOOLKIT_DIR}}/skills/review/references/adversarial.md

> **When**: You want to stress-test changes for security holes, edge cases, race conditions, and failure modes using both Claude and Codex in parallel.
> **Produces**: Merged adversarial findings from two models, fixes, and a Review Gate block.

## Usage

```
/review-code-adversarial                # Red-team uncommitted changes
/review-code-adversarial --committed    # Red-team committed changes (base..HEAD)
/review-code-adversarial src/api/       # Red-team specific path
```

## Steps

### 1. Discover Changed Files

- Default: uncommitted changes via `git diff --name-only` + `git diff --cached --name-only` (deduplicated)
- `--committed`: committed changes via `git diff <base>..HEAD --name-only`, where `<base>` is resolved dynamically: use `git merge-base HEAD origin/<main-branch>` with the main branch detected from `git remote show origin | sed -n 's/.*HEAD branch: //p'` (fallback: `main`). Always use the `origin/` remote-tracking ref — bare branch names may not exist locally in fresh clones or CI worktrees.
- Path argument: filter to matching files

Read the full content of each changed file plus surrounding context.

### 2. Launch Dual-Model Adversarial Review

Run both models in parallel:

**Claude adversarial** (foreground subagent):
- Apply `review/references/adversarial.md`
- Analyze through all lenses: security, edge cases, race conditions, error handling, data integrity, input validation
- Produce findings with concrete failure scenarios

**Codex adversarial** (background, if available):
- Check if the Codex plugin is available (i.e., `/codex:setup` is a recognized command)
- If available: launch `/codex:adversarial-review --background` — different model (GPT-5.4), different blind spots
- If unavailable: skip Codex lane, proceed with Claude-only adversarial review

### 3. Merge Findings

When both complete:

1. Collect findings from both models
2. Deduplicate — same issue found by both = **high confidence** (mark as `[confirmed by both models]`)
3. Unique findings from either model are included at normal confidence
4. Sort by severity: `[vulnerability]` > `[race-condition]` > `[edge-case]` > `[missing-validation]`

Present unified findings. Adapt the template to reflect which models actually ran:

**Dual-model** (both Claude and Codex available):
```markdown
### Adversarial Findings (Claude + Codex)

**High confidence** (found by both):
- [finding]

**Claude only**:
- [finding]

**Codex only**:
- [finding]
```

**Claude-only fallback** (Codex unavailable):
```markdown
### Adversarial Findings (Claude only)

- [finding]
```

### 4. Fix + Verify Loop

For each finding (confirmed by both models OR reported by a single model):
1. Implement the fix
2. Run pre-flight checks (build, lint, tests)
3. Re-review the fix through the adversarial lens
4. Iterate until findings are resolved or only accepted risks remain

Single-model findings are fixed at normal confidence — they may be false positives, but a real vulnerability found by only one lane must still be remediated and verified. When running in Claude-only fallback mode (Codex unavailable), all findings come from one model and all get fixed.

### 5. Emit Review Gate

```markdown
## Review Gate
Rounds: [N]
Pre-flight: [pass/fail/skipped]
Status: [clean/blocked]
Adversarial Rating: [Hardened/Adequate/Vulnerable/Critical]
Reviewers: [Claude (adversarial) + Codex (adversarial) | Claude (adversarial, solo)]
```

Use `Claude (adversarial, solo)` when Codex was unavailable. Never claim dual-model coverage for a Claude-only run.

### 6. Summary

```markdown
## Review-Code-Adversarial Complete
Rating: [Hardened/Adequate/Vulnerable/Critical] | Rounds: [N] | Status: [clean/blocked]
Reviewers: [Claude + Codex (dual-model) | Claude only (Codex unavailable)]

### Findings
- [N] high confidence (both models), [N] Claude only, [N] Codex only
- By type: [N] vulnerability, [N] edge-case, [N] race-condition, [N] missing-validation

### Fixed
- [What was fixed — or "none found"]

### Accepted Risks
- [Findings acknowledged but not fixed, with justification — or "none"]
```

## Notes
- Two different models trying to break the code catches more than either alone
- Findings confirmed by both models are highest priority
- Every finding must have a concrete failure scenario — no theoretical hand-waving
- "No adversarial findings" from both models is a strong positive signal
- Requires Codex plugin (`/codex:setup`). If Codex unavailable, falls back to Claude-only adversarial review.
