# Expand Scenarios

Use this phase after the likely fix is known to identify the smallest set of extra behavioral checks that would catch meaningful regressions without widening scope.

## Goal

Strengthen regression protection without bloating the workflow with redundant QA passes or turning the current bug fix into a broader testing initiative.

## Core Steps

1. Identify adjacent user flows affected by the bug or fix.
2. Call out edge cases that differ by browser, role, data shape, or state transition.
3. Separate must-check-now scenarios from suggested follow-up tests.
4. Flag risks that are real but out of scope for this bug fix.
5. Hand the result back to the calling workflow so developer and QA can split ownership without widening the current change.

## Output

```markdown
## QA Scenario Expansion

- Must-check scenarios:
  - <scenario>
- Suggested follow-up tests:
  - <scenario>
- Out-of-scope risks:
  - <what could still regress if untested>
```
