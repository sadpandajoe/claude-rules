# /fix-bug Continuation Checkpoint Template

Follow the structural rules in [../SKILL.md](../SKILL.md). Resume specifics live in the Progress Update entry — the Continuation Checkpoint header carries only workflow metadata.

```markdown
## Continuation Checkpoint — [ISO timestamp]
### Workflow
- Top-level command: /fix-bug <arguments>
- Phase: input / complexity-gate / existing-fix-check / plan-mode / plan-md-write / implement-and-review / qa-validate / summarize
- Active plan: PLAN.md (standard path) | none (trivial / moderate)
- Existing-fix status: FIXED_UPSTREAM | FIX_PENDING_PR | UNFIXED | SKIPPED | pending
```

When `Active plan: PLAN.md` is set, resuming sessions can read PROJECT.md alone for orientation — only load PLAN.md if the next phase requires it (implementation or QA validation).

For where-we-left-off details and any learnings worth carrying forward, write a Progress Update entry to the Development Log via `/checkpoint "message"` (the message becomes the "Where we left off" line).
