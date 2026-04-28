---
name: reporting
description: Use when an end-to-end command needs a final summary or continuation checkpoint shape from shared templates. Do NOT use for progress logging, metrics emission, code review findings, or PROJECT.md archival.
user-invocable: false
disable-model-invocation: true
---

# Reporting

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

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

`/checkpoint` is the single writer of `## Continuation Checkpoint` blocks in PROJECT.md. End-to-end commands do **not** define their own checkpoint sections — they rely on the user (or an internal context-management trigger) invoking `/checkpoint`, which autodetects the active top-level command and extends its generic header with per-command fields.

### Rules

1. **Workflow identification first.** The top-level command, its arguments, and the current phase. Without this, resumption guesses.
2. **Header stays light.** Workflow metadata only. Resume specifics belong in the `### [timestamp] — Progress Update` entry; state details belong in `## Current Status`. Do not duplicate across sections.
3. **Per-command fields extend the Workflow block.** Each command's template adds extra Workflow lines (e.g., `Existing-fix status:` for `/fix-bug`); it does not introduce a separate `### State` section.
4. **No procedural recap.** The checkpoint records *state*, not *steps taken*.
5. **Timestamps in ISO format** so future sessions can compute staleness.

### Outer shape

```markdown
## Continuation Checkpoint — [ISO timestamp]
### Workflow
- Top-level command: /<command> <arguments>
- Phase: <phase identifier>
- Active plan: PLAN.md | none
- <per-command field>: <value>     # appended from skills/reporting/templates/<command>-checkpoint.md, if present
```

The first three Workflow lines are owned by `/checkpoint`. Per-command templates contribute only the additional lines.

## How to use

End-to-end commands reference this skill for **summaries only**. Continuation Checkpoints are owned by `/checkpoint`, not by the commands.

```markdown
### N. Summary
Use the template at [skills/reporting/templates/<command>-summary.md] following the structural rules in [skills/reporting/SKILL.md].
```

When a new end-to-end command is added:

1. Drop a `<command>-summary.md` template into [templates/](templates/) following the Summary outer shape.
2. If the command has command-specific Workflow fields worth capturing on pause, drop a `<command>-checkpoint.md` template too — `/checkpoint` will pick it up automatically by command name. Skip this file for commands that need no extra fields beyond the generic header.
