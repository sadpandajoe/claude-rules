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

## Orchestrator Owns PROJECT.md

The orchestrating agent (PM/EM role) owns all PROJECT.md writes. Subagents report results back to the orchestrator — they never write to PROJECT.md directly.

**Default behavior** — update PROJECT.md at phase boundaries when the workflow has materially advanced. Don't defer everything to the end. Record the smallest useful status refresh each time: what phase completed, key findings, what's next.

**Exceptions** (called out inline in the command that deviates):
- Commands invoked as internal phases of a parent workflow (e.g., `/cherry-pick` called by `/fix-bug`) — the parent owns the update
- Commands that may run without a PROJECT.md (e.g., `/review-pr`, `/address-feedback`) — skip if no PROJECT.md exists and the workflow completes cleanly
- Hard gates — some commands require a PROJECT.md write before proceeding to the next phase (e.g., flushing a plan before implementation). These are marked explicitly in the command.

## Continuation Checkpoints

All commands use the same checkpoint structure. The canonical format is defined in `commands/checkpoint.md`:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: [command with arguments]
- Phase: [current phase from command's phase list]
- Resume target: [current item, PR, SHA, file, or blocker]
- Completed items: [items already finished]
### State
[command-specific fields]
```

The `### Workflow` section is standard — commands do not restate it. Each command defines only its **phase list** and **state fields**.

## Subagent Isolation

When dispatching review subagents, enforce context isolation to prevent confirmation bias:

- Reviewers receive **only**: the diff, changed file contents, acceptance criteria, and their skill file
- Reviewers do **not** receive: conversation history, planning rationale, investigation context, or implementation decisions
- **Why**: A reviewer who watched planning and implementation will rationalize issues away. Fresh context produces honest review.

This applies to all `/review-code` dispatches — standalone or as an internal phase of `/fix-bug`, `/create-feature`, `/fix-ci`, etc. The calling command specifies what criteria to pass (RCA, PM brief, QA results); the isolation principle is the same.

For implementation subagents dispatched in parallel:
- Use `isolation: "worktree"` for independent slices to avoid file conflicts
- Each subagent gets its slice context, the skill file, and exit criteria
- After all complete, use `sync-workstreams.md` to merge results

## Lifecycle Recording

Event schemas are defined in `skills/workflow-lifecycle.md`. Commands record lifecycle events at phase boundaries — just specify the event type (e.g., `Record lifecycle: 'gate'`). The skill provides the field schema; do not restate it inline.

**Internal phase rule**: When a command is invoked as an internal phase of a parent workflow (e.g., `/review-code` called by `/fix-bug`), skip lifecycle recording — the parent command records its own events.

## Nested Orchestration

Some workflows spawn subagents that are themselves orchestrators — not just workers. This happens when:
- An epic dispatches per-story subagents, each running the full `/create-feature` flow
- A multi-repo workflow dispatches per-repo subagents, each running end-to-end

In nested orchestration:
- The **parent orchestrator** tracks high-level progress (waves, repos) in its own PROJECT.md
- Each **child orchestrator** (subagent in a worktree) owns its own PROJECT.md, plans, reviews, and commits independently
- Child orchestrators do not report to the parent's PROJECT.md — the parent collects results when the subagent returns
- The parent dispatches children with a prompt that tells them to read and follow a specific command file, not just a skill

This is distinct from flat orchestration (one orchestrator, many workers) where subagents run skills and report back without owning their own planning or review cycles.

## Command Composition

Commands orchestrate skills as their primary workers. A small set of utility commands (`/review-code`, `/checkpoint`, `/verify`) may be invoked as internal phases by end-to-end commands. This is intentional — these commands contain adaptive logic (team selection, flag handling) that would be duplicated if extracted into skills.
