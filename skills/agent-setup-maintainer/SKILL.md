---
name: agent-setup-maintainer
description: Use when auditing or updating Claude Code commands, skills, CLAUDE.md, rules, subagent prompts, or agent workflow docs. Use when the task involves skill activation, rule placement, command design, routing hints, lessons/gotchas, or orchestration docs. Do NOT use for normal product code changes, app feature work, bug fixes, or product QA.
---

# Agent Setup Maintainer Skill

## Before Starting

1. Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.
2. Read the agentic AI primer if it is present or supplied by the user (`agentic-ai-primer.md`, attached PDF, or equivalent).
3. Read the project Claude config. In this toolkit source repo, that is [config/CLAUDE.md](../../config/CLAUDE.md); in an installed Claude profile, it may be `CLAUDE.md`.
4. Inspect the relevant source files under `commands/`, `skills/`, `rules/`, and `config/`. Only inspect `.claude/` installed copies when the user specifically asks about install output.

## Core principles
- Rules are always-on constraints and routing hints.
- Skills are selected, not called.
- Skill descriptions are classifiers.
- Commands are prompt expanders that can bias skill selection.
- Keep global rules short.
- Move task-specific detail into skills or referenced docs.
- Prefer small surgical edits over broad rewrites.

## Checklist
- Does each skill have clear use cases?
- Does each skill have clear non-use cases?
- Are broad instructions moved out of global rules?
- Are routing hints present where skill selection needs reliability?
- Are lessons/gotchas read at the start of each skill?
- Are commands phrased as workflow triggers, not magical skill invocations?
- Are README, installer, and doctor checks updated when skill structure changes?
