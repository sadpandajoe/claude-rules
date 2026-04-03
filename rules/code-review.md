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
| **[major]** | Must fix before proceeding | Logic errors, missing tests for changed behavior, security issues |
| **[minor]** | Should fix | Naming, DRY violations, incomplete docs, missing edge-case handling |
| **[nitpick]** | Optional | Style preferences, micro-optimizations, cosmetic issues |

## Invalid Review Patterns
- Minor formatting (periods, spacing)
- Personal style preferences
- Demanding specific implementation
- Scope creep (unrelated fixes)