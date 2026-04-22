# Cherry-Pick Principles

## Golden Rules
- [ ] **Understand before changing** — investigate fully before deciding
- [ ] **Gate before planning** — decide whether to cherry at all before planning how
- [ ] **Always use `cherry-pick -x`** — preserves source commit reference
- [ ] **Always use `cherry-pick --continue` to commit** — never `git commit` directly after resolving conflicts. `--continue` preserves original author, cherry-pick metadata, and the `(cherry picked from commit ...)` trailer.
- [ ] **Verify `.git/CHERRY_PICK_HEAD` exists before `--continue`** — if it doesn't, the cherry-pick state was lost. Running `--continue` without it will error or operate on stale state.
- [ ] **Validate bug exists in target branch** — before cherry-picking a fix, confirm it's present
- [ ] **Preserve working functionality**
- [ ] **Adapt rather than force** — work with target architecture
- [ ] **Verify imports/modules exist** in target branch
- [ ] **Prefer functional over structural** — extract value, not architecture
- [ ] **Plan is reviewed before apply** — the plan subagent's work is always reviewed by a different agent
- [ ] **Audit cherry-pick scope** — diff-audit the result against the source commit to detect leaked changes from adjacent commits
- [ ] **Document decisions** — what accepted, rejected, why, and any `--force` overrides

## Conflict Resolution

| Conflict | Check | Safe | Risky |
|----------|-------|------|-------|
| Import | Module exists? | Keep target | Accept source |
| API | Compatible? | Adapt to target | Force source |
| Test fails | What expected? | Meet expectations | Change tests |
| Structure | Can extract logic? | Functional only | Force structure |
