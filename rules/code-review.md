# Code Review Principles

## Core Principles
- **DRY** — similar logic? Extract or parameterize
- **Consistency** — follow existing patterns and conventions
- **Test quality** — tests should not silently pass; data should match types

## Scoring Framework

| Component | 1-3 | 4-7 | 8-10 |
|-----------|-----|-----|------|
| **Root Cause** | Missing/wrong | Incomplete | Thorough |
| **Solution** | Hacky | Reasonable | Clean |
| **Tests** | Missing | Partial | Comprehensive |
| **Code** | Poor | Functional | Clean |
| **Docs** | Missing | Partial | Self-explanatory |

## Severity Tags

| Tag | Meaning | When |
|-----|---------|------|
| **[major]** | Must fix | Logic errors, missing tests, security |
| **[minor]** | Should fix | Naming, DRY, partial docs |
| **[nitpick]** | Optional | Style, micro-optimizations |

## Invalid Review Patterns
- Minor formatting (periods, spacing)
- Personal style preferences
- Demanding specific implementation
- Scope creep (unrelated fixes)

## Related Commands
- `/review` — Review own code (iterate to 8/10)
- `/review-pr` — Review someone's PR
- `/review-plan` — Review plan quality
- `/review-feedback` — Process PR feedback
