---
name: shortcut
description: "Shortcut REST API operations: fetch story/epic/iteration data, post comments, upload evidence, link PRs."
user-invocable: false
disable-model-invocation: true
---

# Shortcut

## Before Starting

Read any sibling `rules.md`, `lessons.md`, and `gotchas.md` files if present.

Shortcut work splits into two phases:

| Phase | When | Reference |
|-------|------|-----------|
| Fetch | Need story, epic, iteration, workflow, member, or search data | [references/fetch.md](references/fetch.md) |
| Report | Need to post QA/fix/test results, upload evidence, update metadata, or link PRs | [references/report.md](references/report.md) |

## Notes

- REST is preferred for repeatable workflow automation.
- Use `$SHORTCUT_API_TOKEN` by name only; never copy token values into prompts, rules, comments, or generated files.
- Global rules only route Shortcut work here. The detailed retry, parsing, field-shape, and posting protocols live in the references.
