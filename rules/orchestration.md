# Orchestration Principles

## Golden Rules
- [ ] **Claude Code owns planning and verification**
- [ ] **Delegate bounded, well-specified tasks** to Codex
- [ ] **Verify before accepting** delegated work
- [ ] **PROJECT.md is shared truth**
- [ ] **Right tool for right job**

## Tool Roles

| Tool | Role | Strengths |
|------|------|-----------|
| **Claude Code** | Tech Lead | Planning, investigation, complex reasoning, verification, commits |
| **Codex CLI** | Implementer | Bounded tasks, code review, boilerplate, mechanical transforms |
| **Subagents** | Internal workers | Exploration, planning, research (via Task tool) |
| **Skill Subagents** | Domain reviewers | Architecture, implementation, testing, frontend, backend perspectives via Task tool |

## Delegation Decision

| Delegate to Codex | Keep in Claude Code |
|--------------------|---------------------|
| Single-file implementations | Multi-file refactors |
| Boilerplate generation | Architecture decisions |
| Code review (second opinion) | Root cause analysis |
| Test generation (from spec) | Test strategy design |
| Mechanical transforms | Security-sensitive code |

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Delegate architecture | Keep complex reasoning in CC |
| Accept without testing | Verify before accepting |
| Lose context | Update PROJECT.md |
| Use wrong tool | Match tool to task type |
| Retry failures blindly | Understand and simplify |

## Model Selection

Always use **opus** for subagents and parallel agents. When invoking the Agent tool, pass `model: "opus"`.

## Subagent Context Loading

Subagents load their own domain rules — commands should not `@import` rules that only subagents use.

- **Main thread imports**: rules the main thread directly evaluates (complexity gate, input routing, orchestration, planning)
- **Subagent reads**: domain rules the subagent applies (code-review, testing, implementation, investigation, review-gate, stop-rules, shortcut-api)
- **Skill files reference rules by path**: e.g., "Read and apply `rules/review-gate.md`"
- **Commands tell subagents which files to read**: include the rule file path in the Agent tool prompt

Never load the same rule in both contexts.
