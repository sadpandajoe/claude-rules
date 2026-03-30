# Complexity Gate

Classification protocol for commands that branch on trivial vs. standard paths. This defines the output block format and fast-path rule. Signal tables are command-specific and stay in commands.

## Block Format

Always emit this block in conversation before branching:

```markdown
## Complexity Gate
Classification: TRIVIAL / STANDARD
Confidence: X/10
Reason: [one line]
```

## Trivial Fast-Path

When classification is `TRIVIAL` and confidence is `8/10` or higher:
- Skip the standard path (plan mode, investigation lanes, RCA validation)
- Go directly to implementation, verify, review, summary

## Never Silently Decide

Always emit the gate block above. Do not silently choose a path — the block must be visible in conversation so the user and any continuation checkpoint can see the classification.

## Scope

This rule defines an output contract. It does not define the signal tables (those are command-specific) or the trivial-path steps (those are command-owned).
