# Universal Testing Strategy & Implementation

## 🎯 Testing Golden Rules
- [ ] **Test behavior, not implementation** - What users see, not how it works
- [ ] **Use fixtures as source of truth** - No hardcoded test data
- [ ] **Mock ONLY external boundaries** - APIs, databases, file systems
- [ ] **Avoid testing your mocks** - Don't write tests that just verify mock setup
- [ ] **One assertion concept per test** - Keep tests focused
- [ ] **Fix failing tests immediately** - Don't accumulate test debt
- [ ] **Delete tests for deleted features** - Keep suite clean
- [ ] **Test as you develop** - Not just at the end

## Core Testing Philosophy

### Why We Test This Way
- **Build trust** through real behavior validation
- **Catch defects early** while context is fresh
- **Reduce manual effort** during releases
- **Prevent over-mocking** that creates false confidence
- **Ensure correctness** of functionality

## Testing Layers (Universal)

### Layer Selection Guide
| Layer | Purpose | When to Use | Speed |
|-------|---------|-------------|-------|
| **Unit** | Individual functions/methods | Pure logic, calculations | ⚡⚡⚡ |
| **Integration** | Component interactions | API calls, database ops | ⚡⚡ |
| **UI/Component** | User interface behavior | DOM interactions, state | ⚡⚡ |
| **E2E** | Full workflows | Multi-system integration | ⚡ |
| **Manual** | Exploratory/visual | When automation unavailable | 🐌 |

### Test Assignment Decision Tree
```
1. Is it pure logic/calculation? → Unit test
2. Does it call external services? → Integration test + mock boundary
3. Does it render UI? → Component test
4. Does it span multiple systems? → E2E test
5. Is automation unavailable? → Manual test with documentation
```

## Test Implementation Standards

### Fixture-Driven Testing
```
tests/
  fixtures/
    feature-name/
      input/
        scenario_1.json
      expected/
        scenario_1_success.json
        scenario_1_error.json
      metadata.json
```

#### Fixture Rules
- **All test data from fixtures** - No hardcoded values
- **Realistic data** - From actual system responses
- **Shared across test layers** - Same fixtures everywhere
- **Version controlled** - Track changes over time
- **Updated with API changes** - Keep synchronized

### What to Mock vs Test Real

| ✅ Mock These | ❌ Don't Mock These |
|---------------|-------------------|
| External APIs | Internal functions |
| Database calls | Business logic |
| File system | Calculations |
| Network requests | State management |
| Time/dates | Data transformations |
| Random values | Component rendering |

### Test Structure Pattern
```
# Pseudocode - adapt to your language

DESCRIBE "Feature/Component"
  BEFORE EACH
    Setup fixtures
    Initialize mocks for external only
  
  TEST "should handle success case"
    GIVEN valid input from fixture
    WHEN action performed
    THEN verify expected outcome
    
  TEST "should handle error case"
    GIVEN error condition
    WHEN action performed
    THEN verify graceful handling
    
  AFTER EACH
    Cleanup
```

## Writing Effective Tests

### Test Naming Convention
```
"should [expected behavior] when [condition]"

Examples:
"should return user data when valid ID provided"
"should show error message when network fails"
"should disable button when form invalid"
```

### Test Coverage Strategy
1. **Happy path** - Normal successful flow
2. **Error cases** - Invalid input, failures
3. **Edge cases** - Boundaries, empty, null
4. **Integration points** - Where components meet
5. **User workflows** - Common user actions

### Common Testing Anti-Pattern: Testing Your Mocks

#### ❌ Bad: Testing Mock Behavior
```
// This just tests that your mock works, not your code
TEST "returns mocked user data"
  mockAPI.returns({name: "John"})
  result = getUser()
  assert result.name === "John"  // Just testing the mock!
```

#### ✅ Good: Testing Real Behavior
```
// This tests actual logic and transformations
TEST "transforms user data correctly"
  mockAPI.returns({firstName: "John", lastName: "Doe"})
  result = getUserFullName()
  assert result === "John Doe"  // Tests real transformation logic
```

#### The Rule
- **If removing the code under test doesn't break the test, you're testing mocks**
- **Tests should fail when actual logic breaks, not just when mocks change**
- **Mock setup is test infrastructure, not what you're testing**

## Manual Testing Strategy

### When Automation Isn't Available
```markdown
## Manual Test Plan

### Test: [Feature Name]
1. **Setup**: [Prerequisites]
2. **Steps**:
   - Step 1: [Action]
   - Step 2: [Action]
3. **Expected**: [Result]
4. **Actual**: [What happened]
5. **Status**: Pass/Fail

### Coverage Notes
- What was tested manually
- What couldn't be tested
- Risks of manual-only testing
```

### Manual Testing Checklist
- [ ] Happy path verified
- [ ] Error conditions tested
- [ ] Edge cases checked
- [ ] Visual appearance confirmed
- [ ] Performance acceptable
- [ ] Document test steps for repeatability

## Test Debugging

### When Tests Fail
```bash
# 1. Run single test in verbose mode
[Language-specific: test command with debug flags]

# 2. Check test output
[Language-specific: examine error messages]

# 3. Verify fixtures are current
diff tests/fixtures/current expected/

# 4. Check for environment issues
[Language-specific: dependency checks]

# 5. Isolate the failure
# Comment out parts to narrow down issue
```

### Common Test Issues
| Issue | Likely Cause | Solution |
|-------|--------------|----------|
| Flaky tests | Timing/async issues | Add proper waits/promises |
| False positives | Over-mocking | Reduce mocks, test real code |
| Broken after refactor | Testing implementation | Test behavior instead |
| Slow test suite | Too many E2E tests | Move to lower layers |
| Hard to maintain | Hardcoded data | Use fixtures |

## Test Maintenance

### Keeping Tests Healthy
- **Run tests before committing** - Every time
- **Fix immediately when broken** - Don't let them accumulate
- **Update fixtures when APIs change** - Keep in sync
- **Delete tests for deleted features** - Don't keep dead code
- **Refactor test code** - Apply same standards as production
- **Review test quality** - In code reviews

### Test Quality Checklist
- [ ] Test name clearly describes what's tested
- [ ] Uses fixtures, not hardcoded data
- [ ] Mocks only external dependencies
- [ ] Tests behavior, not implementation
- [ ] Single assertion/concept per test
- [ ] Can run independently
- [ ] Provides clear failure messages

## Language-Agnostic Patterns

### Test Organization
```
project/
  src/               # Source code
  tests/             # Test files
    unit/           # Unit tests
    integration/    # Integration tests
    e2e/           # End-to-end tests
    fixtures/      # Test data
    helpers/       # Shared test utilities
```

### Universal Test Commands
```bash
# Find test files
find . -name "*test*" -o -name "*spec*"

# Check test coverage trends
git log --oneline -- tests/

# Find untested code
grep -r "export\|public" src/ | grep -v test

# Find test fixtures
find tests/fixtures -type f
```

## TDD Workflow Integration

### TDD with Testing Strategy
1. **Write failing test first** - Define expected behavior
2. **Use appropriate test layer** - Unit for logic, integration for APIs
3. **Create/update fixtures** - For test data
4. **Write minimal code to pass** - Just enough
5. **Verify test actually tests** - Make it fail again
6. **Refactor with confidence** - Tests protect you

### TDD Documentation
```markdown
## Development Log
[Time]: Writing test for [feature] - RED phase
[Time]: Test failing with: [error]
[Time]: Implementing minimal solution - GREEN phase
[Time]: Test passing
[Time]: Refactoring while keeping tests green
[Time]: All tests passing - feature complete
```

## Quick Reference Card

| Test Type | What to Test | What to Mock | Tools Needed |
|-----------|--------------|--------------|--------------|
| Unit | Functions, methods | Nothing internal | Test framework |
| Integration | API calls, DB ops | External services | Mocks, fixtures |
| Component | UI behavior | API calls | DOM testing lib |
| E2E | Full workflows | Nothing | Browser automation |
| Manual | Everything | N/A | Documentation |

## Lessons Learned Using This Guide
<!-- Document when mocking internals was actually necessary -->
<!-- Capture patterns in identifying "testing mocks" anti-pattern -->
<!-- Note when fixture-driven approach caused issues -->
<!-- Record testing strategies that improved confidence -->
