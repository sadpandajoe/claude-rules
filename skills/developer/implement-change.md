# Implement Change

Use this phase when the workflow is ready to apply a code change after investigation and any needed planning are complete.

## Goal

Implement the narrowest fix that resolves the validated issue, add the right regression protection, and hand the result back for review and QA validation.

## Core Steps

1. Write or update the smallest high-signal failing test when practical.
2. Implement the minimum code change that satisfies the validated RCA.
3. Run targeted verification for changed files and the reported bug path.
4. Note anything that could not be verified locally.
5. Hand changed files back to the calling workflow for `/review-code`.

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
