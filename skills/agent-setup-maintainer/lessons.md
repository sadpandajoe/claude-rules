# Agent Setup Maintainer Lessons

## `/create-feature` Is The Current Command Pattern

Use `commands/create-feature.md` as the reference shape when refactoring long-running workflow commands.

Good command shape:

- Header imports only the short rules the main thread needs immediately.
- The command keeps visible gates, path rules, and final stop conditions.
- Command-specific complexity signals stay in the command.
- A short happy path appears before any dense routing table.
- Step routing names the owner, route, and load/handoff condition.
- Skills and references load only at phase entry.
- Subagents return compact handoffs; the main thread writes durable state (`PROJECT.md`, `PLAN.md`, manifests).
- TRIVIAL paths stay inline; if reviewer subagents are needed, reclassify as MODERATE.
- MODERATE paths run inline-first with `/verify` or equivalent pre-flight before review.
- STANDARD paths, including workstream-shaped work, use fresh reviewer subagents after material revisions and bounded implementation handoffs.
- Implementation stays inline by default; delegate only when isolation, fresh context, or real parallelism helps.
- Review Gate skip/micro-fix exceptions are explicit and never replace review for meaningful logic changes.

Avoid:

- Header-importing skills, long references, templates, or examples.
- Splitting ownership and routing into separate sections that can drift.
- Letting subagents update `PROJECT.md` or `PLAN.md` directly.
- Moving command-owned end-to-end flows into a domain skill whose boundary says it should not own that work.

When auditing another command, compare it to `/create-feature` before inventing a new structure.
