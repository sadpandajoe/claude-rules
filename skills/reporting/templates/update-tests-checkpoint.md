# /update-tests Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/update-tests`, replace the generic `Phase:` field with the `/update-tests`-specific enum:

```markdown
- Phase: scope / gap-analysis / update-tests / verify / review / commit / summarize
```

No additional Workflow fields. Existing-suite status, files changed, and verification status belong in `## Current Status`.
