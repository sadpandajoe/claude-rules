# /fix-ci Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/fix-ci`, replace the generic `Phase:` field with the `/fix-ci`-specific enum:

```markdown
- Phase: gather-logs / classify / ownership-check / complexity-gate / rca / gate / apply / verify / review / summarize
```

No additional Workflow fields. Failure classification, gate result, review status, and files changed belong in `## Current Status`.
