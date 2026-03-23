# Investigation Principles

## Golden Rules
- [ ] **Document in PROJECT.md before proposing solutions**
- [ ] **Use git history first** — blame, log, bisect
- [ ] **Find root cause, not symptoms**
- [ ] **Prefer existing solutions** — check other branches first
- [ ] **Parallelize when useful** — user-visible triage and code investigation can run together
- [ ] **Gather evidence** — logs, stack traces, reproduction steps
- [ ] **Verify assumptions** — dependencies, imports, file existence

## Common Mistakes

| Avoid | Do Instead |
|-------|------------|
| Jump to solutions | Understand problem first |
| Skip git history | Use blame/log liberally |
| Assume | Verify with commands |
| Patch symptoms | Fix root cause |
| Skip documentation | Document in PROJECT.md |

## Related Commands
- `/fix-bug` — End-to-end bug workflow with triage, existing-fix checks, RCA, implementation, and validation
- `/investigate` — Standalone RCA and evidence gathering
