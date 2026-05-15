# /audit-agent-setup - Audit Agent Setup


Audit this repo’s agent setup.

Use [skills/agent-setup-maintainer/SKILL.md](../skills/agent-setup-maintainer/SKILL.md) as the workflow reference. Load it before evaluating setup-specific rules, lessons, command routing, or skill boundaries.

Read:
- `config/CLAUDE.md`
- `commands/**`
- `skills/**`
- `rules/**`
- `README.md`
- `install.sh`
- `commands/toolkit-doctor.md`

Evaluate:
1. Are global rules acting as a short index?
2. Are skill descriptions written like classifiers?
3. Do skills have clear “use when” and “do NOT use when” boundaries?
4. Are skill-scoped rules kept out of global rules?
5. Do commands bias skill selection without pretending to directly call skills?
6. Are lessons/gotchas being read at the start of each skill?
7. Are any skills over-triggering, under-triggering, or overlapping?
8. Do README, installer, and toolkit-doctor reflect the actual command/skill layout?
9. Do long-running workflow commands match the `/create-feature` pattern: lean header imports, visible gates, command-specific complexity signals, happy path, single owner/route/handoff table, lazy skill/reference loading, and main-thread durable-state ownership?
10. Are model and subagent hints expressed in platform-neutral terms where possible, with provider-specific names isolated to adapter docs or runtime-specific sections?

Return:
- Findings by file
- Severity: high / medium / low
- Suggested patch
- Whether to update rules, skills, commands, or docs
