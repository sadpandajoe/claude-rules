# /review-pr Continuation Checkpoint Extension

`/checkpoint` writes the generic `## Continuation Checkpoint` block (see [../SKILL.md](../SKILL.md) and [../../../commands/checkpoint.md](../../../commands/checkpoint.md)). When the detected top-level command is `/review-pr`, replace the generic `Phase:` field with the `/review-pr`-specific enum and add the PR identifier:

**Single-PR mode**:

```markdown
- Phase: gather / complexity-gate / understand-problem / detect-team / launch-review / pattern-analysis / scoring / gate / post / summarize
- PR: <number> — <title>
```

**Batch mode**:

```markdown
- Mode: batch
- Phase: gather-list / dispatch-reviews / collect-results / batch-summary
```

Reviewer team, scores, recommendation, and post status (single-PR), or per-PR completion counts (batch) belong in `## Current Status`.
