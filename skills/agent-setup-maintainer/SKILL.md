---
name: agent-setup-maintainer
description: Reviewing, auditing, updating, or refactoring Claude Code agent setup — skills, commands, rules, CLAUDE.md, subagent prompts, or workflow orchestration. Do NOT use for product code, app features, bug fixes, or product QA.
---

# Agent Setup Maintainer Skill

## Before Starting

1. Read sibling `lessons.md` if present.
2. Read the project Claude config. In this toolkit source repo, that is [config/CLAUDE.md](../../config/CLAUDE.md); in an installed Claude profile, it is `~/.claude/CLAUDE.md`.
3. Inspect the relevant source files under `commands/`, `skills/`, `rules/`, and `config/`. Only inspect `.claude/` installed copies when the user specifically asks about install output.

## Core principles

- Rules are always-on constraints and routing hints — keep them short.
- Skills are selected via their descriptions; descriptions are classifiers, not documentation.
- Commands are prompt expanders that can bias skill selection.
- Move task-specific detail into skills or referenced docs, not global rules.
- Prefer small surgical edits over broad rewrites.

## Checklist

- Does each skill have clear use cases and non-use cases?
- Are broad instructions moved out of global rules?
- Are routing hints present where skill selection needs reliability?
- Is `lessons.md` read at the start of each skill that has one?
- Are commands phrased as workflow triggers, not magical skill invocations?
- Are README, installer, and doctor checks updated when skill structure changes?
