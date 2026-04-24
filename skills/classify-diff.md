---
name: classify-diff
description: Analyze a changeset and return which review domains are relevant, with trigger reasons.
model: sonnet
---

# Classify Diff

Deterministic reviewer routing. Read the changeset and return which review domains should be activated, why each triggered, and whether the diff is security-sensitive.

This skill replaces inline reviewer-selection logic in commands. The calling command dispatches subagents based on this skill's output — this skill classifies, the command orchestrates.

## Required Context

The caller provides:
- The diff (staged, unstaged, or commit range)
- The complexity tier (`TRIVIAL` or `STANDARD`) from the Complexity Gate

## Steps

1. **Gather the changeset**: Read the diff. Identify all changed files with their paths and change types (added, modified, deleted, renamed).

2. **Classify each file** into domains based on path patterns and content:

   | Domain | File Signals | Content Signals |
   |--------|-------------|-----------------|
   | Frontend | `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `*.css`, `*.scss`, `components/`, `pages/`, `views/` | React hooks, state management, DOM manipulation, CSS-in-JS |
   | Backend | `*.py` (non-test), `*.go`, `*.rs`, `*.java`, `api/`, `server/`, `handlers/`, `middleware/` | Route definitions, DB queries, auth logic, API handlers |
   | Tests | `*_test.*`, `*.test.*`, `*.spec.*`, `test_*`, `tests/`, `__tests__/`, `conftest.py` | Test assertions, mocks, fixtures, test utilities |
   | Infrastructure | `Dockerfile`, `*.yml`/`*.yaml` (CI/CD), `terraform/`, `k8s/`, `.github/workflows/` | Pipeline configs, deploy scripts, container definitions |
   | Config | `*.json` (config), `*.toml`, `*.ini`, `.env*`, `settings.*` | Environment variables, feature flags, connection strings |

3. **Determine review domains** by mapping file domains to reviewers:

   | Review Domain | Trigger | Skill |
   |---------------|---------|-------|
   | Code quality | Always | `review-code-quality.md` |
   | Architecture | STANDARD + logic changes in source files (not just config/test) | `review-architecture.md` |
   | Tests | STANDARD + test files exist in diff OR test files exist for changed source files | `testing/references/review-tests.md` |
   | Test plan | STANDARD + no test files exist in diff AND no test files found for changed source files | `testing/references/review-testplan.md` |
   | Frontend | Frontend files changed | `review-frontend.md` |
   | Backend | Backend files changed | `review-backend.md` |

   Rules:
   - Code quality **always** triggers regardless of complexity tier
   - Architecture, Tests/Test Plan only trigger for STANDARD complexity
   - Frontend and Backend are additive — both can trigger on the same diff
   - Tests and Test Plan are mutually exclusive — if tests exist, use Tests; if not, use Test Plan
   - TRIVIAL complexity: code quality reviewer only

4. **Assess security sensitivity**: Flag as security-sensitive if the diff touches:
   - Authentication or authorization logic
   - Cryptographic operations
   - User input handling without sanitization
   - SQL queries or ORM calls with dynamic input
   - Secret management, token handling, or credential files
   - Permission checks or access control

## Output

```markdown
## Diff Classification

Complexity: TRIVIAL / STANDARD
Security-sensitive: YES / NO
Files analyzed: [count]

### Triggered Reviewers
| Review Domain | Trigger Reason | Skill |
|---------------|----------------|-------|
| Code quality | Always | review-code-quality.md |
| [domain] | [specific trigger reason] | [skill file] |

### File Domain Summary
| Domain | Files | Examples |
|--------|-------|---------|
| Frontend | [N] | [top 3 paths] |
| Backend | [N] | [top 3 paths] |
| Tests | [N] | [top 3 paths] |
```

## Notes
- This skill classifies — it does not dispatch reviewers or launch subagents. The calling command owns orchestration.
- File domain detection uses path patterns first, content signals second. When a file matches multiple domains (e.g., a test for a frontend component), classify it under each applicable domain.
- The trigger table is the single source of truth for which reviewers activate. If the table needs updating (new reviewer, new trigger), update it here rather than in individual commands.
