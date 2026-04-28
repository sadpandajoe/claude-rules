# /create-feature Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/create-feature`, replace the generic `Phase:` field with the `/create-feature`-specific enum:

```markdown
- Phase: input / complexity-gate / plan-mode / plan-md-write / review-iterations / action-gate / implement-and-review / summarize
```

No additional Workflow fields beyond the phase enum — `/create-feature` doesn't carry extra command-specific state on the checkpoint header.

When `Active plan: PLAN.md` is set, resuming sessions can read PROJECT.md alone for orientation — only load PLAN.md if the next phase requires it (review iterations or implementation slice).

For where-we-left-off details and any learnings worth carrying forward, write a Progress Update entry to the Development Log via `/checkpoint "message"` (the message becomes the "Where we left off" line).
