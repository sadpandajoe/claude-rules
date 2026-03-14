# Universal Principles

## Golden Rules
- **PROJECT.md is the single source of truth** — all documentation goes there
- **Evidence over assumptions** — use version control history, test results, existing solutions
- **Working solution before optimization** — get it working, commit, then improve
- **Incremental progress** — small, verified changes over big risky ones
- **Document decisions and reasoning** — future maintainers need context
- **TDD and YAGNI** — test first, build only what's needed now

## Workflow Selection

| Situation | Workflow | Command |
|-----------|----------|---------|
| Building something new | New Feature | `/create-plan` → `/review-plan` → `/finalize-plan` → `/create-tests` → `/implement` |
| Something's broken | Bug Fix | `/investigate` → `/create-plan` → `/review-plan` → `/create-tests` → `/implement` |
| Exploring for bugs | QA Discovery | `/qa-discover` |
| Testing against live env | QA Testing | `/qa-test` |
| Is this bug fixed somewhere? | Issue Review | `/review-issue` |
| Reviewing someone's PR | Code Review | `/review-pr` |
| Improving existing code | Refactoring | `/refactor` |
| Cross-branch work (single) | Cherry-Pick | `/review-issue` → `/cherry-pick` |
| Cross-branch work (batch) | Cherry-Pick | `/cherry-plan` → `/cherry-pick` each |
| System in bad state | Recovery | See troubleshooting rules |

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
| `refactor.md` | Restructuring without behavior changes |
