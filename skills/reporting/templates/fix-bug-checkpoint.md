# /fix-bug Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/fix-bug`, append these additional fields to the `### Workflow` block:

```markdown
- Phase: input / complexity-gate / existing-fix-check / plan-mode / plan-md-write / implement-and-review / qa-validate / summarize
- Existing-fix status: FIXED_UPSTREAM | FIX_PENDING_PR | UNFIXED | SKIPPED | pending
```

The `Phase` line replaces the generic `Phase:` field with the `/fix-bug`-specific enum. The `Existing-fix status:` line is added below the generic fields.

When `Active plan: PLAN.md` is set, resuming sessions can read PROJECT.md alone for orientation — only load PLAN.md if the next phase requires it (implementation or QA validation).

For where-we-left-off details and any learnings worth carrying forward, write a Progress Update entry to the Development Log via `/checkpoint "message"` (the message becomes the "Where we left off" line).
