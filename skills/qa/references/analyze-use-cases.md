---
model: opus
---

# Analyze Use Cases

Use this phase when a workflow needs exploratory QA discovery rather than immediate implementation.

## Goal

Turn code, issue context, and known risk areas into a compact use-case matrix that helps QA or developers focus on the most meaningful scenarios.

## Core Steps

1. Define the feature area, flags, entrypoints, and likely user roles.
2. Read the happy path first, then inspect edge paths, validations, and asymmetric behavior.
3. Cross-reference issues, PR comments, and known bug reports when they exist.
4. Turn findings into a small use-case matrix with confidence and priority.
5. Separate likely bugs from unknown-but-worth-testing scenarios.

## Output

```markdown
## QA Use-Case Matrix

- Use case: <name>
  - Status: <likely bug / needs validation / known issue>
  - Confidence: <high / medium / low>
  - Context: <flags, roles, env needs>
  - Why it matters: <user or regression impact>
```
