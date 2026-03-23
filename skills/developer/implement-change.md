# Implement Change

Use this phase when the workflow is ready to apply a code change after investigation and any needed planning are complete.

## Goal

Implement the narrowest fix that resolves the validated issue, add the right regression protection, and hand the result back for review and QA validation.

## Core Steps

1. Write or update the smallest high-signal failing test before the code change when feasible.
2. If test-first is blocked by repro, env, or harness constraints, record why before continuing.
3. Implement the minimum code change that satisfies the validated RCA.
4. Run targeted verification for changed files and the reported bug path.
5. Note anything that could not be verified locally.
6. Hand changed files back to the calling workflow for `/review-code`.

## Output

```markdown
## Implementation Handoff

- Files changed:
  - <file>
- Tests added or updated:
  - <test>
- Checks run:
  - <command>
- Unverified areas:
  - <gap or none>
```
