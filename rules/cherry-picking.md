# Cherry-Pick Principles

## Golden Rules
- [ ] **Understand before changing** — analyze full scope
- [ ] **Always use `cherry-pick -x`** — preserves source commit reference
- [ ] **Always use `cherry-pick --continue` to commit** — never `git commit` directly after resolving conflicts. `--continue` preserves original author, cherry-pick metadata, and the `(cherry picked from commit ...)` trailer.
- [ ] **Verify `.git/CHERRY_PICK_HEAD` exists before `--continue`** — if it doesn't, the cherry-pick state was lost (e.g., aborted or already committed). Running `--continue` without it will error or operate on stale state.
- [ ] **Validate bug exists in target branch** — before cherry-picking a fix, confirm it's present
- [ ] **Preserve working functionality**
- [ ] **Adapt rather than force** — work with target architecture
- [ ] **Verify imports/modules exist** in target branch
- [ ] **Prefer functional over structural** — extract value, not architecture
- [ ] **Document decisions** — what accepted, rejected, why

## Accept vs Reject

| Accept | Reject |
|--------|--------|
| Bug fixes | Architecture changes |
| Isolated features | Unverified imports |
| Algorithm improvements | Breaking API changes |
| Test additions | Build system changes |
| Documentation | File restructuring |

## Decision Framework

```
Can I extract just functional improvement?
  YES → Extract and adapt
  NO  → Consider if needed

Does target have equivalent?
  YES → Enhance existing
  NO  → Add without breaking

Will forcing this break existing?
  YES → Reject or find alternative
  NO  → Proceed with caution
```

## Conflict Resolution

| Conflict | Check | Safe | Risky |
|----------|-------|------|-------|
| Import | Module exists? | Keep target | Accept source |
| API | Compatible? | Adapt to target | Force source |
| Test fails | What expected? | Meet expectations | Change tests |
| Structure | Can extract logic? | Functional only | Force structure |

## Related Commands
- `/cherry-pick` — Plan, order, and cherry-pick one or more PRs/SHAs with conflict resolution
- `/review-issue` — Verify if bug exists across branches before cherry-picking
