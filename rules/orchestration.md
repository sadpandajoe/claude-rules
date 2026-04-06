# Orchestration Principles

## Claude Code-First Model

Claude Code is the primary orchestrator: planning, investigation, complex reasoning, verification, and commits. Codex CLI is an optional delegatee for bounded, well-specified tasks when available.

| Role | Owner | Examples |
|------|-------|---------|
| **Orchestrator** | Claude Code | Planning, architecture, RCA, multi-file refactors, security-sensitive code |
| **Delegatee** (optional) | Codex CLI | Single-file implementations, boilerplate, mechanical transforms, test generation from spec |
| **Internal workers** | Subagents | Exploration, planning, research (via Agent tool) |
| **Domain reviewers** | Skill subagents | Architecture, implementation, testing, frontend, backend perspectives |

## Model Selection

Each skill specifies its recommended model in its frontmatter (`model: opus`, `model: sonnet`, or `model: haiku`). When dispatching a subagent for a skill, pass the skill's model to the Agent tool.

The default is **opus** — quality matters most. Only skills doing mechanical work (pattern matching, environment checks, API wrappers) use sonnet or haiku. When unsure, use opus.

**Dynamic override for trivial work**: When the Complexity Gate classifies work as TRIVIAL, pass `model: "sonnet"` to subagents regardless of the skill's frontmatter. Trivial changes (cosmetic fixes, renames, config swaps) don't need opus-level reasoning — sonnet handles them well at lower cost and latency. This override does not apply to the `/review-code` subagent itself (review quality should stay high even for trivial changes), only to implementation and investigation subagents.

## Subagent Context Loading

Subagents load their own domain rules — commands should not `@import` rules that only subagents use.

- **Main thread imports**: rules the main thread directly evaluates (complexity gate, input routing, orchestration, planning)
- **Subagent reads**: domain rules the subagent applies (code-review, testing, implementation, investigation, review-gate, stop-rules, shortcut-api)
- **Skill files reference rules by path**: e.g., "Read and apply `rules/review-gate.md`"
- **Commands tell subagents which files to read**: include the rule file path in the Agent tool prompt

Never load the same rule in both contexts.

## Skill Execution: In-Thread vs Subagent

When a command says "use `skill-name.md`", it means the main thread reads the skill file and follows its instructions — same agent, same context. This is the default for sequential, single-track work.

When a command says "launch as subagent" or "dispatch as parallel subagents", it means creating isolated agents via the Agent tool. Each subagent gets fresh context with only what it needs — the skill file, the relevant slice/diff, and any criteria. Subagents are used for:
- **Parallel work**: independent slices in worktrees
- **Isolation**: reviewers that should not see planning context (prevents confirmation bias)
- **Domain focus**: each reviewer applies its own lens independently

Pass the skill's `model` frontmatter value to the Agent tool. If the skill has no model field, default to opus.

## Command Composition

Commands orchestrate skills as their primary workers. A small set of utility commands (`/review-code`, `/checkpoint`, `/verify`) may be invoked as internal phases by end-to-end commands. This is intentional — these commands contain adaptive logic (team selection, flag handling) that would be duplicated if extracted into skills.
