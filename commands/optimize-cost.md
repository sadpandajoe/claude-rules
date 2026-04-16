# /optimize-cost - Usage Pattern Analysis and Recommendations

> **When**: You want actionable insights on how to reduce Claude Code token usage.
> **Produces**: Analysis of usage patterns with severity-ranked findings and specific recommendations.

## Usage
```
/optimize-cost              # Analyze last 7 days (default)
/optimize-cost today        # Today only
/optimize-cost 30d          # Last 30 days
/optimize-cost month        # Current calendar month
/optimize-cost all          # All time
```

## Steps

### 1. Run the Analysis Script

```bash
python3 {{TOOLKIT_DIR}}/scripts/optimize-cost.py <period>
```

Where `<period>` is the argument from the user (default: `7d`).

### 2. Present the Output

The script handles all formatting. Present its output directly.

### 3. Offer Context-Specific Follow-Up

After presenting the analysis, offer to:
- Apply model tiering changes to specific commands (if the model concentration finding fires)
- Adjust checkpoint thresholds in `rules/context-management.md` (if expensive sessions are flagged)
- Review a specific command or project that dominates cost

## What It Detects

| Pattern | Severity | Trigger |
|---------|----------|---------|
| 100% Opus usage | high | >90% cost on Opus |
| Expensive sessions (no checkpoint) | high | Sessions exceeding $8 |
| Long sessions (>150 messages) | medium | Quadratic cost growth |
| Low cache hit rate | medium | <70% cache reads |
| Command cost hotspots | medium | One command >30% of cost |
| Project hotspots | info | One project >40% of cost |
| High output token ratio | medium | Output >40% of cost |
| Savings estimate | summary | Always shown |

## Notes
- This is a read-only command — it analyzes but does not modify anything
- Costs are API-equivalent estimates for subscription users
- Command attribution is approximate (session cost split across commands detected in that session)
- The script parses the same JSONL files as `/show-cost`
