# Testing Strategy

## 🎯 Testing Golden Rules
- [ ] **Test behavior, not implementation**
- [ ] **Use fixtures** - No hardcoded test data
- [ ] **Mock ONLY external boundaries** - APIs, databases, file systems
- [ ] **Avoid testing your mocks** - Test real logic
- [ ] **One assertion concept per test**
- [ ] **Fix failing tests immediately**
- [ ] **Delete tests for deleted features**

## Testing Layers

| Layer | Purpose | When | Speed |
|-------|---------|------|-------|
| **Unit** | Functions/methods | Pure logic | ⚡⚡⚡ |
| **Integration** | Component interactions | API/DB calls | ⚡⚡ |
| **E2E** | Full workflows | Multi-system | ⚡ |
| **Manual** | Exploratory | Automation unavailable | 🐌 |

### Decision Tree
```
Pure logic/calculation?     → Unit test
Calls external services?    → Integration + mock boundary
Spans multiple systems?     → E2E test
Automation unavailable?     → Manual test (document steps)
```

## Fixtures

```
tests/fixtures/
  feature/
    input/scenario.json
    expected/scenario.json
```

### Fixture Rules
- All test data from fixtures
- Realistic data (from actual responses)
- Shared across test layers
- Updated with API changes

## What to Mock

| ✅ Mock | ❌ Don't Mock |
|---------|--------------|
| External APIs | Internal functions |
| Database calls | Business logic |
| File system | Calculations |
| Network | State management |
| Time/dates | Data transforms |

## Test Structure

```
DESCRIBE "Feature"
  BEFORE EACH: Setup fixtures, mock externals only
  
  TEST "should [behavior] when [condition]"
    GIVEN valid input
    WHEN action performed
    THEN verify outcome
```

## Anti-Pattern: Testing Mocks

```
❌ BAD: Just tests mock returns value
  mock.returns({name: "John"})
  result = getUser()
  assert result.name === "John"

✅ GOOD: Tests real transformation
  mock.returns({first: "John", last: "Doe"})
  result = getFullName()
  assert result === "John Doe"
```

**Rule**: If removing code under test doesn't break test, you're testing mocks.

## Coverage Strategy

1. **Happy path** - Normal flow
2. **Error cases** - Invalid input, failures
3. **Edge cases** - Boundaries, empty, null
4. **Integration points** - Where components meet

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Flaky | Timing/async | Proper waits |
| False positive | Over-mocking | Test real code |
| Breaks on refactor | Testing implementation | Test behavior |
| Slow suite | Too many E2E | Lower layers |
| Hard to maintain | Hardcoded data | Use fixtures |

## Manual Testing

When automation unavailable:
```markdown
### Test: [Feature]
1. Setup: [Prerequisites]
2. Steps: [Actions]
3. Expected: [Result]
4. Actual: [What happened]
5. Status: Pass/Fail
```

## Quality Checklist
- [ ] Name describes what's tested
- [ ] Uses fixtures
- [ ] Mocks only externals
- [ ] Tests behavior
- [ ] Single concept per test
- [ ] Runs independently
- [ ] Clear failure messages
