# Testing Principles

## Golden Rules
- [ ] **Test behavior, not implementation** — tests survive refactors
- [ ] **Use fixtures** — no hardcoded test data
- [ ] **Mock ONLY external boundaries** — APIs, databases, file systems, network, time
- [ ] **One assertion concept per test**
- [ ] **Fix failing tests immediately**
- [ ] **Delete tests for deleted features**
- [ ] **Follow project conventions** — test structure, naming, organization

## Testing Layers

| Layer | When | Mock? |
|-------|------|-------|
| **Unit** | Pure logic/calculation | No |
| **Integration** | Crosses external boundary | Mock the boundary |
| **E2E** | Full user workflow | No (real system) |

## What to Mock

| Mock | Don't Mock |
|------|------------|
| External APIs | Internal functions |
| Database calls | Business logic |
| File system | Calculations |
| Network | Data transforms |
| Time/dates | State management |

## Over-Mocking Signals

You're mocking too much when:
- Mock setup is longer than the test itself
- Removing the code under test doesn't break the test
- Test just verifies mock return values pass through unchanged
- You're mocking internal functions, not just boundaries
- Multiple layers of mocks needed to test one function
- Mocking things that are fast and deterministic (pure functions, transforms)

When you see these → reduce mocks, use real implementations.

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Flaky | Timing/async | Proper waits |
| False positive | Over-mocking | Test real code |
| Breaks on refactor | Testing implementation | Test behavior |
| Slow suite | Too many E2E | Push to lower layers |

## Related Commands
- `/generate-tests` — Write automated test code
- `/suggest-tests` — Suggest what to test
- `/refactor-tests` — Move tests to correct layers
- `/qa-discover` — Find bugs through code analysis
- `/qa-test` — Run test plans against live environments
