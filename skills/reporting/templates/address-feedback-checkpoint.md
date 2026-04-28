# /address-feedback Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/address-feedback`, replace the generic `Phase:` field with the `/address-feedback`-specific enum and add the PR identifier:

```markdown
- Phase: gather / complexity-gate / investigate / triage / fix / review / draft / post / summarize
- PR: <number> — <title>
```

Triage counts, review status, and post status belong in `## Current Status`.
