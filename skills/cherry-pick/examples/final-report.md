# Final Report Format

Use this format at the end of every cherry-pick (single or batch). Lead with the ticket outcome — what the user cares about — then the execution table, then actionable residuals.

## Rules

- The compact 5-column table replaces the full 12-column execution table only in the final report. See [execution-table.md](execution-table.md) for the full table.
- Add **Detailed Notes** for any row that is not `Applied` with `None` adaptation, plus any `Applied` row with notable adaptation.
- Keep the dependency graph from the batch-sequence phase if inter-change dependencies were detected.
- "What to do next" is actionable only — no recap of what just happened.
- Lead with the ticket outcome. The user cares about "is the fix on the branch" more than about the process.

## Template

```markdown
## Cherry-Pick Summary

[1–2 lines answering the user's original question — e.g., "The StructuredContentStripperMiddleware (the encoding fix) is now active on this branch." or "The fix from #38837 is applied; CI re-run needed to confirm."]

[X of N applied, Y rejected, Z partial] -> <target branch>

### Results
| SHA | PR | Status | Validation | Notes |
|-----|----|--------|------------|-------|
| `<sha>` | #123 | Applied | Tested | Clean apply |
| `<sha>` | #124 | Partial | Checked | 5 of 7 sub-fixes applied; encoding fix dropped — see below |
| `<sha>` | #125 | Rejected | — | Feature change, no --force |

### Detailed Notes
#### `<sha>` — <summary>
- **Why non-trivial**: [conflict, rejection reason, or intervention point]
- **Gate decision**: [PROCEED / REJECT / FORCE-PROCEED + criteria]
- **Adaptation details**: [What was modified and why]
- **What was dropped**: [specific functions, files, or sub-fixes omitted]
- **Residual risk**: [What remains uncertain]

### What to do next
- [Actionable residual items — e.g., "encoding bug likely affects target via different code path — needs separate fix"]
- [Validation gaps — e.g., "run pytest tests/unit_tests/mcp_service/ before merging"]
- [Pending PRs to monitor — e.g., "#38676 still open — pick when merged"]
```
