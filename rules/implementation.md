# Implementation Principles

## Golden Rules
- [ ] **Understand codebase** before writing code
- [ ] **Plan tests before implementation** — TDD (see Test-First Modes below)
- [ ] **If test-first is blocked, record why** — do not silently skip the order
- [ ] **Follow existing patterns** — consistency over creativity
- [ ] **Update existing code** before creating new
- [ ] **Commit working states** — safe rollback points
- [ ] **NEVER use `git add -A` or `git add .`** — add only YOUR files
- [ ] **Never rewrite git history** unless explicitly asked — no force push, no rebase of shared branches, no amending published commits
- [ ] **Only amend HEAD** — if asked to amend, verify it's the most recent commit. Never amend older commits without explicit instruction.
- [ ] **Be factual in PRs** — describe what changed and why, not how great the change is

## Test-First Modes

Two modes. Plans pick which mode applies, and `skills/implement-change/` executes accordingly. Both share "tests before implementation"; granularity and intent differ.

### RED/GREEN per slice — for bug fixes

Write the failing regression test → run it and confirm it fails (**RED**) → implement the minimum code change → run again and confirm it passes (**GREEN**).

The cycle proves the test captures the bug. If the test passes before the fix, it does not capture the bug — rewrite it. If the test fails for a reason other than the bug, narrow it.

### Test set as specification — for features

Write the slice's full acceptance test set first. The test set encodes the specification you're committing to before implementation begins, so design choices don't get rationalized into the spec.

Then implement. Then run the test set and reconcile any failures:

- **Implementation wrong** → fix the code.
- **Test assumed wrong** → update the test, and **note in the slice's notes (or PR) what changed and why** (the test is committing to a spec; if the spec evolved, that's a real decision).

The full set up-front (vs. one-at-a-time RED/GREEN) is deliberate for features — it forces the spec to be visible before implementation lock-in.

### When test-first is blocked

Both modes default to writing the test first. When env, repro, or harness constraints make running the test impossible:

- Write the test anyway (writing is separate from running)
- Record the verification gap explicitly in the slice or PR
- Do not silently fall back to "test alongside" or "test after" — record the reason

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
4. **Formatting passes**: run the formatter in check mode (`ruff format --check`, `prettier --check`, `gofmt -l`) in addition to the linter — lint and format are separate passes and CI runs both. If the check reports diffs, apply the formatter and re-stage before committing.
5. **Tests pass**: run at minimum the tests related to changed files
6. **Pre-commit hooks**: let them run — do NOT use `--no-verify`

**In worktrees**: dependencies and build outputs may not exist. Run `npm install` / rebuild before pre-flight checks.
