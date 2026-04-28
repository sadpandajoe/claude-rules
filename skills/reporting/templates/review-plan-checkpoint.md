# /review-plan Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/review-plan`, replace the generic `Phase:` field with the `/review-plan`-specific enum:

```markdown
- Phase: read-plan / detect-reviewers / review-iterations / cold-read / update / summarize
```

No additional Workflow fields. Reviewers selected, current scores, and revision count belong in `## Current Status`.
