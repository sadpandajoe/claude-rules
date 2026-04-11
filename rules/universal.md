# Universal Principles

## Golden Rules
- **PROJECT.md is the single source of truth** — all documentation goes there; PROJECT.md is local-only and must never be committed to git
- **Evidence over assumptions** — use version control history, test results, existing solutions
- **Working solution before optimization** — get it working, commit, then improve
- **Incremental progress** — small, verified changes over big risky ones
- **Document decisions and reasoning** — future maintainers need context
- **TDD and YAGNI** — test first, build only what's needed now
- **End-to-end commands own their internal loops** — planning, review, and validation sub-phases should continue automatically until threshold or blocker; do not surface subcommands as the next user step unless the user explicitly chose them
- **Update PROJECT.md before completing any workflow** — every command or ad-hoc work session that produces results must write current status, what was done, and remaining items to PROJECT.md before finishing
- **Checkpoint when context is deep** — see `rules/context-management.md` for thresholds and protocol
- **Rules evolve from usage** — see `rules/rule-maintenance.md` for how to strengthen, update, or extract rules

## Communication Rules
- **Be direct about errors** — no unnecessary apologies
- **Show, don't tell** — include actual commands, outputs, evidence
- **Explain reasoning** — why one approach over another
- **Ask for clarification** — don't assume when unclear
- **Request confirmation** — before destructive changes

## Override Hierarchy

1. **Universal principles** (this file) — always apply
2. **Orchestration rules** — multi-tool workflows
3. **Domain-specific rules** — testing, investigation, etc.
4. **Project-specific CLAUDE.md** — project context
5. **PROJECT.md current state** — most immediate context
