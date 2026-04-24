# /create-feature Continuation Checkpoint Template

Follow the structural rules in [../SKILL.md](../SKILL.md). State fields are feature-workflow-specific.

```markdown
## Continuation Checkpoint — [ISO timestamp]
### Workflow
- Top-level command: /create-feature <arguments>
- Phase: input / complexity-gate / plan-mode / project-md-write / review-iterations / action-gate / implement-and-review / summarize
- Resume target: <story, issue, milestone, PR slice, file set, or current blocker>
- Completed items: <finished phases or accepted decisions>

### State
- Complexity: <trivial / moderate / standard>
- PM required: <yes / no / skipped — trivial>
- PM brief score: <score or skipped>
- Technical plan scores: <reviewer: score, ... or pending>
- Cold read: <go / no-go / pending>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>
```
