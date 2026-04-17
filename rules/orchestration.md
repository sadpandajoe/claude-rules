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

Match subagent model to the **actual reasoning load of this specific task**, not the category label. A "trivial architecture review" runs on Sonnet; a gnarly multi-constraint planning task runs on Opus regardless of label. The Agent tool accepts a `model` parameter — pass it explicitly on every invocation.

| Reasoning load | Model | Examples |
|----------------|-------|----------|
| Mechanical — no judgment, just retrieval or pattern-match | `haiku` | File search, symbol grep, listing definitions, fetching a known artifact |
| Standard — apply known patterns, classify, review bounded change, single-file work | `sonnet` | Triage, RCA validation, single-file implementation, log classification, **reviews where the diff or plan is small/well-scoped — including architecture/adversarial reviews of trivial changes** |
| Heavy — multi-constraint trade-offs, novel design, deep adversarial probing across many files | `opus` | Plan reviews when the plan spans systems, architectural decisions with real trade-offs, adversarial review of substantial diffs, hard fix planning where the failure surface is unclear |

**The decision rule**: assess the *substance* of this specific task before choosing. Default to `sonnet`. Drop to `haiku` only for purely mechanical work. Escalate to `opus` only when this specific instance genuinely requires deep reasoning. Role labels (e.g., "architecture reviewer") do not auto-promote to Opus — the actual scope does.

**Cherry-pick model tiering**: Cherry-pick phases use gate-driven model selection rather than the general reasoning-load heuristic above. The gate classifies difficulty (TRIVIAL vs NON-TRIVIAL) and that classification determines models for plan, validate, and adapt phases. See `cherry-pick-gate.md` for the tier table.

The orchestrator (main thread) may run on any model the user has selected — these tiers apply to **subagents** spawned from it. A Sonnet orchestrator escalating to an Opus subagent for genuinely hard work is the canonical cost-efficient pattern.

## Inline-First Principle

Every subagent spawn costs orchestrator messages. On subscription plans, this directly reduces how much work fits in a session. Before spawning a subagent, ask: **does this task need a separate agent, or can the orchestrator do it inline?**

Spawn a subagent when:
- Parallelism provides a clear wall-clock win (multiple independent investigation lanes)
- Isolation matters (reviewer should not see implementation context, cold read needs fresh eyes)
- The work is a **review** — never review your own work; always use a separate subagent for code and plan reviews

Do it inline when:
- The work is sequential anyway (classification, single-file investigation, planning a scoped fix)
- The orchestrator already has the relevant context loaded
- The task is bounded and the result is short (triage, RCA for a single failure mode)

When the complexity gate classifies work as MODERATE, default to inline for investigation and planning, but still spawn a reviewer subagent. When STANDARD, use subagents per command-specific steps.

## Subagent Context Loading

Subagents load their own domain rules — commands should not `@import` rules that only subagents use.

- **Main thread imports**: rules the main thread directly evaluates (complexity gate, input routing, orchestration, planning)
- **Subagent reads**: domain rules the subagent applies (code-review, testing, implementation, investigation, review-gate, stop-rules, shortcut-api)
- **Skill files reference rules by path**: e.g., "Read and apply `rules/review-gate.md`"
- **Commands tell subagents which files to read**: include the rule file path in the Agent tool prompt

Never load the same rule in both contexts.
