# Implementation Principles

## Golden Rules
- [ ] **Understand codebase** before writing code
- [ ] **Plan tests before implementation** — TDD
- [ ] **Follow existing patterns** — consistency over creativity
- [ ] **Update existing code** before creating new
- [ ] **Working solution before optimization**
- [ ] **Commit working states** — safe rollback points
- [ ] **NEVER use `git add -A` or `git add .`** — add only YOUR files
- [ ] **YAGNI** — build only what's needed now

## Code Standards

- Functions: ≤20 lines (guideline)
- Files: ≤300 lines
- Nesting: ≤2 levels (use early returns)
- Names: Descriptive > clever

## Best Practices

| Do | Don't |
|----|-------|
| Follow existing patterns | Create new patterns |
| Early returns | Deep nesting |
| Handle errors explicitly | Silent catches |
| Small, focused commits | Large commits |
| Add files individually | `git add -A` |

## Related Commands
- `/implement` — Write code (TDD workflow)
- `/plan` — Design implementation approach
- `/generate-tests` — Write automated test code
