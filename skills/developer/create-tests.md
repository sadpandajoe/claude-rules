# Create Tests

Use this phase when the workflow needs to add or improve automated tests without running a larger end-to-end feature or bug workflow.

## Goal

Write the smallest set of high-signal tests that protects the intended behavior, follows project conventions, and survives refactors.

## Core Steps

1. Determine the exact code or behavior under test.
2. Use `review-tests` to identify missing coverage, weak tests, and realistic failure paths.
3. Choose the narrowest useful test layer.
4. Write or replace tests with a bias toward behavioral signal over quantity.
5. Run the tests, confirm they fail when the behavior breaks, then re-run `review-tests` if needed.

## Output

```markdown
## Test Creation Handoff

- Scope: <files, behavior, or function>
- Test layer: <unit / integration / component / e2e>
- Tests added or updated:
  - <file>
- Checks run:
  - <command>
- Remaining gaps:
  - <gap or none>
```
