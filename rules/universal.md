# Universal Principles

## Golden Rules
- **PROJECT.md is the single source of truth** — all documentation goes there
- **Evidence over assumptions** — use version control history, test results, existing solutions
- **Working solution before optimization** — get it working, commit, then improve
- **Incremental progress** — small, verified changes over big risky ones
- **Document decisions and reasoning** — future maintainers need context
- **TDD and YAGNI** — test first, build only what's needed now
- **End-to-end commands own their internal loops** — planning, review, and validation sub-phases should continue automatically until threshold or blocker; do not surface subcommands as the next user step unless the user explicitly chose them
- **Update PROJECT.md before completing any workflow** — every command that produces results must write current status, what was done, and remaining items to PROJECT.md before finishing
- **Checkpoint when context is deep** — at chain boundaries and loop iterations, if context is above ~70%, save state and continue in a fresh conversation (see Context Management below)

## Workflow Selection

| Situation | Workflow | Command |
|-----------|----------|---------|
| Building something new | New Feature | `/create-feature` |
| Something's broken | Bug Fix | `/fix-bug` |
| Reviewing someone's PR | Code Review | `/review-pr` |
| Improving existing code | Refactoring | `/create-feature` |
| Improving an existing test suite | Test Maintenance | `/update-tests` |
| Creating first tests for untested area | First Tests | `/create-tests` |
| Validating a story, PR, or environment | Test Plan Execution | `/run-test-plan` |
| Cross-branch work (single) | Cherry-Pick | `/cherry-pick` |
| Cross-branch work (batch) | Cherry-Pick | `/cherry-pick <multiple> [--plan-only]` |
| System in bad state | Recovery | See troubleshooting rules |
| CI build failed | CI Remediation | `/fix-ci` |
| Pre-commit quality pass | Self Review | `/review-code` |
| PR has review comments | PR Feedback | `/address-feedback` |
| Program health snapshot | PGM Report | `/create-status-report` |
| Monthly velocity metrics | Velocity | `/create-velocity-report` |

## Context Management

At every **chain boundary** or **loop iteration**, check context depth:

- **Below ~70%**: Continue automatically. Don't pause.
- **At or above ~70%**: Save state and continue in a fresh conversation. Don't ask — just do it.

Chain boundaries: `/fix-bug` internal phase transitions, `/create-feature` planning → implementation, `/create-feature` implementation → review, etc.
Loop iterations: each `/create-feature` planning round, each `/review-code` round.
Sub-invocations: when `/create-feature`, `/fix-bug`, `/update-tests`, or `/fix-ci` calls `/review-code`.

### Save & Continue Protocol

When context is ≥ 70%:
1. Update PROJECT.md with the current workflow status before clearing context.
2. Write a **continuation checkpoint** to PROJECT.md:
   ```markdown
   ## Continuation Checkpoint — [timestamp]
   ### Workflow
   - Top-level command: [the user-facing command to resume, e.g. `/cherry-pick ...`]
   - Phase: [current internal phase, e.g. `plan`, `investigate`, `apply`, `validate`]
   - Resume target: [current item, PR, SHA, file, or review round]
   - Completed items: [items already finished in this workflow]
   ### State
   - [Key decisions made]
   - [Current scores/results if in review loop]
   - [Files modified so far]
   - [Any pending issues or blockers]
   ```
3. Commit any uncommitted work if the workflow requires a durable checkpoint.
4. Run `/clear` to reset conversation context.
5. Run `/start` to reload PROJECT.md and pick up the checkpoint.
6. `/start` resumes the saved top-level command at the saved phase and target automatically.

The user should not need to do anything — this is a seamless context refresh.

Do not rely on chat memory after `/clear`. The checkpoint in PROJECT.md is the source of truth for where execution resumes.

### Why This Matters
Auto-compaction silently drops earlier context, which can cause Claude to lose track of decisions, review scores, or chain state mid-workflow. Checkpointing preserves full fidelity.

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

## Rules Files

| File | Purpose |
|------|---------|
| `orchestration.md` | Tool roles, delegation framework |
| `planning.md` | Documentation, PROJECT.md workflow |
| `investigation.md` | Root cause analysis, debugging |
| `implementation.md` | Code development, TDD, patterns |
| `testing.md` | Test strategy, mocking, over-mocking signals |
| `troubleshooting.md` | Emergency recovery |
| `resource-management.md` | Docker limits, test worker scaling |
| `cherry-picking.md` | Cross-branch work |
| `code-review.md` | Review guidelines, scoring |
| `api.md` | External API reference: GitHub CLI, Shortcut REST, Notion MCP |
| `pgm.md` | Program management: org context, audience tiers, data collection rules |
