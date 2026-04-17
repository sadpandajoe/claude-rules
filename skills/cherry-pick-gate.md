# Cherry-Pick Gate

Decides whether a change should be cherry-picked at all, and sets the difficulty tier that controls model selection for downstream phases.

This phase consumes the output of `cherry-pick-investigate.md` and produces the go/no-go decision plus tier classification.

## Inputs

- Investigation output (source analysis, target compat, prereq scan)
- `--force` flag (if set by user)

## Decision: Should We Cherry?

Evaluate the change against the accept/reject matrix in `rules/cherry-picking.md`:

| Accept | Reject |
|--------|--------|
| Bug fixes | Architecture changes |
| Isolated features | Unverified imports |
| Algorithm improvements | Breaking API changes |
| Test additions | Build system changes |
| Documentation | File restructuring |

### Reject-category changes

If the change falls into a reject category:

- **Without `--force`**: Stop. Explain why this change is not suitable for cherry-pick. List which reject criteria it hits. Suggest alternatives if applicable (e.g., "consider a targeted rewrite on the target branch instead").
- **With `--force`**: Warn explicitly what reject criteria are being overridden, then continue. The warning must appear in the final report. Force does not skip any downstream phase — it only overrides the accept/reject gate.

### Bug fixes

When the change is a bug fix (tagged `fix`/`bugfix`, or commit message indicates corrective behavior):

- Consume the existing-fix status from the investigation output (investigate already runs `check-existing-fix.md` — do not re-run it).
- If `Status: FIXED_UPSTREAM` with high confidence, stop — the fix is already there.
- If `Status: FIX_PENDING_PR`, surface the pending PR and ask whether to wait or proceed.
- If `Status: UNFIXED` or `SKIPPED`, continue.

### Features with `--force`

When force-cherry-picking a feature, additionally flag:
- Dependency additions the target branch doesn't have
- API surface changes that may break consumers
- Whether the feature requires follow-up work on the target branch

These are warnings, not blockers — `--force` means proceed.

## Difficulty Classification

After the go/no-go decision, classify the change:

| Signal | Trivial | Non-Trivial |
|--------|---------|-------------|
| Files touched | 1-2 | 3+ |
| Change type | Version bump, config, import fix, one-liner | Logic change, behavioral, multi-component |
| Conflicts expected | None (clean apply likely) | Conflicts expected or detected |
| Dependencies | No new dependencies | Adds/changes dependencies |
| Target compatibility | APIs and modules exist and match | APIs differ, modules missing or renamed |
| Prerequisite commits | None needed | Prerequisites identified |

Classify as **trivial** only when ALL trivial signals apply. Any single non-trivial signal makes the change **non-trivial**.

Emit the classification:

```markdown
## Gate Decision

Verdict: PROCEED / REJECT / FORCE-PROCEED
Difficulty: TRIVIAL / NON-TRIVIAL
Reject Criteria Hit: [list or "none"]
Force Override: YES / NO

### Model Tier
Plan: sonnet / opus
Validate: sonnet / opus
Adapt Required: YES / NO
```

## Model Tier Selection

The difficulty classification determines model selection for all downstream phases:

| Phase | Trivial | Non-Trivial |
|-------|---------|-------------|
| Plan (subagent) | Sonnet | Opus |
| Plan Review | Main thread (Opus) | Main thread (Opus) |
| Apply | Opus | Opus |
| Adapt | skipped | Opus |
| Validate (subagent) | Sonnet | Opus |

## Forced Non-Trivial Escalation

Regardless of signals, classify as **non-trivial** when:

- `--force` is overriding a reject-category change
- Investigation flagged modify/delete risk
- Investigation flagged prerequisite commits
- The change is a bundled PR with multiple sub-fixes
- Dependency manifests or lockfiles are touched
