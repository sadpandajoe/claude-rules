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

## Subagent Context Loading

Subagents load their own domain rules — commands should not `@import` rules that only subagents use.

- **Main thread imports**: rules the main thread directly evaluates (complexity gate, input routing, orchestration, planning)
- **Subagent reads**: domain rules the subagent applies (code-review, testing, implementation, investigation, review-gate, stop-rules, shortcut-api)
- **Skill files reference rules by path**: e.g., "Read and apply `rules/review-gate.md`"
- **Commands tell subagents which files to read**: include the rule file path in the Agent tool prompt

Never load the same rule in both contexts.

## Command Composition

Commands orchestrate skills as their primary workers. A small set of utility commands (`/review-code`, `/checkpoint`, `/verify`) may be invoked as internal phases by end-to-end commands. This is intentional — these commands contain adaptive logic (team selection, flag handling) that would be duplicated if extracted into skills.
