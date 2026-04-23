# Execution Table Format (Full)

The 12-column table tracks each cherry through every phase. Produced by the plan phase, updated by apply/adapt/validate, preserved through the final report as detailed notes.

```markdown
| # | SHA | PR | Description | Depends On | Risk | Confidence | Decision | Status | Adaptation | Validation | Notes |
|---|-----|----|-------------|------------|------|------------|----------|--------|------------|------------|-------|
| 1 | `<sha>` | #123 | <summary> | — | LOW | 9/10 | Auto | Applied | None | Tested | Clean apply |
| 2 | `<sha>` | #124 | <summary> | #123 | MED | 7/10 | Approval | Partial | Medium | Checked | 2 of 3 sub-fixes applied |
```

## Field Meanings

| Field | Values | Populated by |
|-------|--------|--------------|
| `#` | Order in batch (1-based) | batch-sequence |
| `SHA` | Short commit sha | investigate |
| `PR` | `#NNN` or `—` | investigate |
| `Description` | One-line summary | investigate |
| `Depends On` | Other `#` or `—` | batch-sequence |
| `Risk` | `LOW`, `MED`, `HIGH` | gate |
| `Confidence` | `X/10` | gate |
| `Decision` | `Auto`, `Approval`, `Escalate` | gate |
| `Status` | `Planned`, `Applied`, `Partial`, `Blocked`, `Rejected`, `Skipped` | apply/adapt |
| `Adaptation` | `None`, `Minor`, `Medium`, `High` | adapt (see plan.md for definitions) |
| `Validation` | `Not run`, `Tested`, `Checked`, `Build-only`, `Structural` | validate |
| `Notes` | Short freeform | any phase |

## Status Semantics

- **Planned** — plan produced, not yet applied
- **Applied** — cherry-pick landed on target with or without adaptation
- **Partial** — applied but significant portions dropped. **Always requires detailed notes**.
- **Blocked** — cannot proceed (prerequisite missing, unresolvable conflict)
- **Rejected** — gate rejected, no `--force` supplied
- **Skipped** — duplicate of an existing fix, or explicitly skipped by user

## Validation Semantics

See [../references/validate.md](../references/validate.md) for the authoritative label definitions and failure-handling table. Never use "Clean" or "Validated" — they are ambiguous.
