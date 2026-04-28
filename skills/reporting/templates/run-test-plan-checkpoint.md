# /run-test-plan Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/run-test-plan`, replace the generic `Phase:` field with the `/run-test-plan`-specific enum:

```markdown
- Phase: resolve-plan / review-plan / execute / capture-evidence / report / summarize
```

No additional Workflow fields beyond the phase enum. Plan score, execution counts, and evidence status belong in `## Current Status` (Done / In Progress / Next / Blocked), not on the checkpoint header.
