# Troubleshooting Principles

## Golden Rules
- [ ] **Stop and assess** before recovery attempts
- [ ] **Safe options first** — stash, checkout, reset --soft
- [ ] **Document what broke** in PROJECT.md
- [ ] **Create rollback points** before major changes
- [ ] **Verify recovery success**
- [ ] **Never make it worse** — if unsure, stop

## Recovery Levels

| Level | Risk | Examples |
|-------|------|----------|
| **Safe** | No data loss | `git stash`, `git checkout -- .`, `git reset --soft HEAD~1` |
| **Moderate** | Selective loss | `git reset --hard <commit>`, `git merge --abort` |
| **Nuclear** | Data loss | `git reset --hard origin/<branch>`, `git clean -fd` |

Always start at Safe. Escalate only when lower levels fail.

## When to Escalate
- Recovery attempts making things worse
- Data loss beyond acceptable
- Production affected
- Security implications
- Multiple cascading failures

## Related Commands
- `/investigate` — Debug and find root cause
- `/cherry-pick` — Move fixes across branches
