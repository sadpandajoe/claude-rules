# Refactoring Principles

## Golden Rules
- [ ] **Tests MUST pass before starting** — no refactoring without safety net
- [ ] **Commit working state first** — rollback point required
- [ ] **One change at a time** — atomic, verifiable refactors
- [ ] **No new functionality** — pure structure changes only
- [ ] **Tests pass after EACH change** — continuous validation
- [ ] **Behavior unchanged** — same inputs → same outputs

## When to Refactor

| Good Time | Bad Time |
|-----------|----------|
| Tests passing | Tests failing |
| Before adding feature | During bug fix |
| Pattern emerged (rule of 3) | First instance |
| Clear improvement | Speculative "might help" |
| Time allocated | Under deadline |

## Safe Techniques

| Technique | When | Risk |
|-----------|------|------|
| **Rename** | Unclear names | Low |
| **Extract function** | Long functions, duplication | Low |
| **Extract class/module** | Class doing too much | Medium |
| **Move** | Wrong location | Medium |
| **Inline** | Over-abstraction | Medium |
| **Change signature** | API improvement | High |

## Related Commands
- `/refactor` — Execute refactoring workflow
- `/refactor-tests` — Move tests to correct layers
