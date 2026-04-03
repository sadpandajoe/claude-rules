# Investigation Principles

## Golden Rules
- [ ] **Document in PROJECT.md before proposing solutions** — include: problem statement, evidence gathered, root cause hypothesis, and how you confirmed it
- [ ] **Use git history first** — blame, log, bisect
- [ ] **Find root cause, not symptoms** — verify by writing a test that fails before the fix and passes after
- [ ] **Prefer existing solutions** — check other branches first
- [ ] **Parallelize when useful** — user-visible triage and code investigation can run together
- [ ] **Gather evidence** — logs, stack traces, reproduction steps
- [ ] **Verify assumptions** — dependencies, imports, file existence

When investigation is complete (root cause documented, evidence gathered, approach clear), move to planning per `rules/planning.md`.

## Common Mistakes

| Avoid | Do Instead |
|-------|------------|
| Jump to solutions | Understand problem first |
| Skip git history | Use blame/log liberally |
| Assume | Verify with commands |
| Patch symptoms | Fix root cause |
| Skip documentation | Document in PROJECT.md |