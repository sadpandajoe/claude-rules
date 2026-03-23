# Action Gate

Use this helper after an investigation or classification phase has produced a root-cause hypothesis, a proposed fix, and a validation plan.

## Output Contract

Always end with this block:

```markdown
## Execution Gate

Risk: LOW / MED / HIGH
Confidence: X/10
Decision Required: YES / NO
Verification Strength: STRONG / PARTIAL / WEAK

Recommendation:
- Proceed automatically
- Ask for approval
- Stop and escalate
```

## Auto-Proceed Rule

Proceed without asking the user only when all of the following are true:

- `Risk: LOW`
- `Confidence: 8/10` or higher
- `Decision Required: NO`
- `Verification Strength` is not `WEAK`

Otherwise stop and surface the reason clearly.

## Rating Guidance

Set `Decision Required: YES` when:

- multiple root causes or fix interpretations are plausible
- the fix changes product or runtime behavior in a meaningful way
- the workflow would widen scope beyond the failing surface
- branch, environment, or validation assumptions are ambiguous

Set `Risk: LOW` only when the fix is narrow, behavior-preserving, and locally verifiable with routine checks.

Treat confidence numerically:

- `8-10` = high confidence
- `5-7` = medium confidence
- `1-4` = low confidence
