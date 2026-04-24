---
name: shortcut
description: Use when a workflow needs Shortcut story, epic, iteration, or report operations through the Shortcut REST API: fetching records, parsing story fields, uploading evidence, posting comments, or linking PRs. Do NOT use for GitHub-only issue/PR work, local QA execution, or generic HTTP API calls unrelated to Shortcut.
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
