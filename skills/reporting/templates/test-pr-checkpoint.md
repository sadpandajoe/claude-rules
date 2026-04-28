# /test-pr Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/test-pr`, replace the generic `Phase:` field with the `/test-pr`-specific enum and add the PR identifier:

```markdown
- Phase: resolve-pr / detect-url / assess-impact / derive-scenarios / confirm-scenarios / execute / report
- PR: <number> — <title>
```

Impact tier, scenarios, and per-scenario results belong in `## Current Status`.
