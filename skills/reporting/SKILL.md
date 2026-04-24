---
name: reporting
description: Shared structural rules and per-command templates for end-of-workflow summaries and continuation checkpoints. Internal helper used by end-to-end commands.
user-invocable: false
disable-model-invocation: true
---

# Reporting

Shared rules for the **shape** of two recurring outputs every end-to-end workflow produces:

1. **Summary** — emitted at the end of a successful workflow run.
2. **Continuation Checkpoint** — emitted when a workflow needs to pause and resume later.

The shapes are shared across commands; the specific fields are command-specific. Per-command templates live in [templates/](templates/).

## Summary structure

Every command's summary follows the same outer shape, even when the body fields differ.

### Rules

1. **Lead with the outcome, not the process.** First 1–2 lines must answer the user's actual question — "is the bug fixed", "is the feature shipped", "what does the cherry-pick result look like." Never lead with rounds, scores, or what the workflow did.
2. **State outcomes, not effort.** "Fixed the encoding bug; tests pass" is a result. "Ran 3 review rounds and 2 fix iterations" is process noise.
3. **End with actionable next steps.** A "What to do next" section listing concrete actions the user can take — PR, deploy, follow-up. Never recap what just happened.
4. **Never suggest internal phases as next steps.** If the workflow already ran `/review-code`, `/verify`, `/run-test-plan`, etc. as part of itself, do not list them as things for the user to do. The next step is what comes *after* this command, not what this command just finished.
5. **Optional details fold-out.** Use `<details><summary>Technical details</summary>` for things that are useful for audit but not for the next decision (file lists, round counts, raw scores).
6. **Omit empty sections.** If "Open risks" has nothing real, drop the section. Empty headers are noise.
7. **Match severity to format.** A 1-line outcome for a clean run; a longer body when partial success or remaining risks need surfacing.

### Outer shape

```markdown
## <Command-Name> Complete
[1–2 lines: the outcome]

### <Command-specific section 1>
- ...

### <Command-specific section 2>
- ...

### What to do next
- [Specific next action]
- [Another specific next action]

[Optional sections: Open risks, Verify manually, etc.]

<details><summary>Technical details</summary>

- [Audit-only detail]

</details>
```

The command-specific sections in the middle vary; the lead, the "What to do next", and the optional details fold-out are constant.

## Continuation Checkpoint structure

When a workflow pauses (cost/context threshold, user interrupt, blocker), it must emit a checkpoint that lets a future session resume from the exact state.

### Rules

1. **Workflow identification first.** The top-level command, its arguments, and the current phase. Without this, resumption guesses.
2. **Resume target second.** What artifact, file, ticket, or decision the next session should pick up at.
3. **State fields are command-specific.** Each command lists only the state that matters for its workflow — scores, classifications, completed items.
4. **No procedural recap.** The checkpoint records *state*, not *steps taken*.
5. **Timestamps in ISO format** so future sessions can compute staleness.

### Outer shape

```markdown
## Continuation Checkpoint — [ISO timestamp]
### Workflow
- Top-level command: /<command> <arguments>
- Phase: <phase identifier>
- Resume target: <what to pick up next>
- Completed items: <finished phases or accepted decisions>

### State
- <command-specific state field>: <value>
- <command-specific state field>: <value>
```

The Workflow block is identical across commands. The State block is per-command.

## How to use

End-to-end commands reference both this skill (for structural rules) and their specific template:

```markdown
### N. Summary
Use the template at [skills/reporting/templates/<command>-summary.md] following the structural rules in [skills/reporting/SKILL.md].

## Continuation Checkpoint
Use the template at [skills/reporting/templates/<command>-checkpoint.md].
```

When a new command is added, drop a new template file into [templates/](templates/) following the outer shapes documented above. The structural rules apply automatically.
