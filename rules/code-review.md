# Code Review Principles

## Core Principles
- **DRY** — similar logic? Extract if maintained together, parameterize if independent
- **Consistency** — follow existing patterns and conventions (grep for similar files to find them)
- **Test quality** — tests should not silently pass (always-green tests are noise); data should match types

## Scoring

Use the universal rubric in `rules/scoring.md`. Score each component:

| Component | What to evaluate |
|-----------|-----------------|
| **Root Cause** | Is the underlying problem identified? |
| **Solution** | Is the fix clean, maintainable, and minimal? |
| **Tests** | Do tests cover the changed behavior meaningfully? |
| **Code** | Is the code readable, consistent, and correct? |
| **Docs** | Are changes self-explanatory or properly documented? |

A single blocking component (1-2) pulls the overall score into the 3-5 range — the overall is not a simple average.

## Severity Tags

Use the code review tags from `rules/severity.md`:

| Tag | Meaning | When |
|-----|---------|------|
| **[major]** | Must fix before proceeding | Logic errors, security issues, missing tests (see calibration below) |
| **[minor]** | Should fix | Naming, DRY violations, incomplete docs, missing edge-case handling |
| **[nitpick]** | Optional | Style preferences, micro-optimizations, cosmetic issues |

### Test Coverage Severity Calibration

Missing tests are not always the same severity. Calibrate based on what the change actually does:

| Change Type | Missing Tests | Severity | Rationale |
|-------------|--------------|----------|-----------|
| New public function/method with logic | No tests | **[major]** | Untested logic is a regression waiting to happen |
| New API endpoint or route | No integration test | **[major]** | Contract changes need verification |
| Bug fix | No regression test | **[major]** | The same bug will come back |
| Behavioral change to existing code | No updated tests | **[major]** | Tests should prove the new behavior works |
| Config change, feature flag, env var | No test | **[minor]** | Lower risk, but still worth testing |
| Doc-only, comment-only, type annotation | No test | Not a finding | No behavior changed — tests would be noise |
| Rename, move, reformatting | No test | Not a finding | Mechanical change — compiler/linter covers this |
| One-liner typo fix in non-logic code | No test | Not a finding | Test would be testing a string literal |

**Impact escalation**: When the impact assessment (from `qa-assess-impact.md`) is CORE, shift all "missing test" findings up one severity level. A config change with no test is normally `[minor]` — but if it touches a CORE workflow (login, auth, payment), it becomes `[major]`.

When reviewing, **assess what the PR does before scoring test coverage**. A blanket "no tests = major" penalizes trivial PRs unfairly and lets risky PRs hide behind a few token tests.

## Invalid Review Patterns
- Minor formatting (periods, spacing)
- Personal style preferences
- Demanding specific implementation
- Scope creep (unrelated fixes)