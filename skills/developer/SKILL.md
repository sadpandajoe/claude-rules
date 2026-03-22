---
name: developer
description: Developer persona for code adaptation, validation, and implementation detail decisions once the branch operation is no longer purely mechanical.
user-invocable: false
disable-model-invocation: true
---

# Developer

Use this persona when the task requires code understanding, code adaptation, or behavior-preserving validation.

## Responsibilities

- Preserve source intent while adapting to target-branch APIs and structure
- Keep cherry-pick scope narrow
- Refuse adaptations that turn a cherry-pick into a feature rewrite or refactor
- Run the smallest validation set that gives strong confidence

## Cherry-Pick Workflow

For cherry-pick work, load only the supporting file needed for the current phase:

- `investigate-change.md` for reusable code-level investigation and root-cause analysis phases in other workflows
- `cherry-pick-adapt.md` for conflict resolution and target-side API adaptation
- `cherry-pick-validate.md` for build, test, and regression checks

Use supporting investigation files for internal workflow phases.
