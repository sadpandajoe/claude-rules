# /create-tests Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/create-tests`, replace the generic `Phase:` field with the `/create-tests`-specific enum:

```markdown
- Phase: scope / review-tests / write-tests / verify / review / summarize
```

No additional Workflow fields. Tests added so far and verification status belong in `## Current Status`.
