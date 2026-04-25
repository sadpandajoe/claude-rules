---
name: review
description: Use for reviewing actual code diffs: dispatching code-review lenses, code-quality checks, and adversarial review. Do NOT use for technical plan critique, product brief review, QA scenario design, or writing the fix.
user-invocable: false
disable-model-invocation: true
---

# Review

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

Umbrella for code-review work — review of *shipped code*, not plans. Two kinds of references:

- **Dispatch** — classify the diff to determine which reviewers fire
- **Lenses** — reviewer subagent prompts, each applying a specific lens

## Dispatch

| Reference | Role |
|-----------|------|
| [references/classify-diff.md](references/classify-diff.md) | Read diff + complexity tier, return which reviewer domains should activate |

## Reviewer Lenses

| Lens | When | Reference |
|------|------|-----------|
| Code quality | Always (every complexity tier) | [references/code-quality.md](references/code-quality.md) |
| Adversarial | Security-sensitive diffs; `/review-code-adversarial` command | [references/adversarial.md](references/adversarial.md) |

## Distinction vs Other Umbrellas

- **review/** (this skill) — reviews code (post-implementation)
- **plan-review/** — reviews plans (pre-implementation)
- **testing/** — includes `review-tests` + `review-testplan` (test-harness-specific reviewers)
- **qa/** — scenario-level critique (bug triage, validation)

The `/review-code` command dispatches through `classify-diff`, which chooses lenses from this umbrella **and** the `testing/` umbrella when tests are in scope.

## Invocation

Each reviewer reference is a subagent prompt. Orchestrator dispatches via `/review-code` or standalone:

```
Agent(subagent_type: "general-purpose", model: "opus", prompt: <reference contents>)
```

## Notes

- `classify-diff` has a different shape from the reviewer references (it's a classifier, not a reviewer). Grouped here because reviewer dispatch is the head of the review workflow.
- Reviewer descriptions declare their own `model:` in frontmatter for subagent spawning.
