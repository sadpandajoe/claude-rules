---
name: learning
description: Use when capturing memories, reviewing or pruning memory files, recording workflow failures, proposing rules from recurring patterns, or promoting memories into rules. Do NOT use for ordinary project documentation, code review, or implementation planning.
user-invocable: false
disable-model-invocation: true
---

# Learning

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

This skill owns memory management and rule-promotion workflows used by `/learn`.

## Phases

| Phase | When | Reference |
|-------|------|-----------|
| Add/List memories | Capture a memory or inspect memory inventory | [references/memory-basics.md](references/memory-basics.md) |
| Review/Prune memories | Assess accuracy, duplication, staleness, and deletion candidates | [references/memory-review.md](references/memory-review.md) |
| Propose/Promote rule | Convert recurring patterns into rule changes | [references/rule-promotion.md](references/rule-promotion.md) |
| Failure postmortem | Record a structured failure memory with prevention guidance | [references/failure-postmortem.md](references/failure-postmortem.md) |

## Notes

- `/learn` works with the configured agent memory directory. For Claude Code installs, this is usually `~/.claude/projects/<path>/memory/`.
- Memory files use YAML frontmatter plus structured body.
- Rule changes require confirmation.
- A pattern seen once is a memory; a pattern seen across projects can become a rule candidate.
