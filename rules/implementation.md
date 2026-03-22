# Implementation Principles

## Golden Rules
- [ ] **Understand codebase** before writing code
- [ ] **Plan tests before implementation** — TDD
- [ ] **Follow existing patterns** — consistency over creativity
- [ ] **Update existing code** before creating new
- [ ] **Working solution before optimization**
- [ ] **Commit working states** — safe rollback points
- [ ] **NEVER use `git add -A` or `git add .`** — add only YOUR files
- [ ] **YAGNI** — build only what's needed now
- [ ] **Never rewrite git history** unless explicitly asked — no force push, no rebase of shared branches, no amending published commits
- [ ] **Only amend HEAD** — if asked to amend, verify it's the most recent commit. Never amend older commits without explicit instruction.
- [ ] **Be factual in PRs** — describe what changed and why, not how great the change is

## Code Standards

- Functions: ≤20 lines (guideline)
- Files: ≤300 lines
- Nesting: ≤2 levels (use early returns)
- Names: Descriptive > clever

## Best Practices

| Do | Don't |
|----|-------|
| Follow existing patterns | Create new patterns |
| Early returns | Deep nesting |
| Handle errors explicitly | Silent catches |
| Small, focused commits | Large commits |
| Add files individually | `git add -A` |
| `fixup` + `rebase` for old commits | Amend non-HEAD commits |
| Factual PR descriptions | Hyperbolic language |

## Pre-Flight Checks

**Before every commit**, verify:
1. **Build passes**: `npm run build`, `tsc --noEmit`, or equivalent
2. **Type-check passes**: if TypeScript/Flow/mypy is used
3. **Linting passes**: `npm run lint`, `ruff check`, or equivalent
4. **Tests pass**: run at minimum the tests related to changed files
5. **Pre-commit hooks**: let them run — do NOT use `--no-verify`

**In worktrees**: dependencies and build outputs may not exist. Run `npm install` / rebuild before pre-flight checks.

## Related Commands
- `/implement` — Write code (TDD workflow)
- `/create-plan` — Design implementation approach
- `/create-tests` — Write automated test code
- `/fix-ci` — Diagnose CI failures, apply safe fixes, and stop before commit
- `/review-code` — Wrapper around built-in `/review` for local fix + verify loops
