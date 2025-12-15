# /test - Testing Workflow

Write and organize tests.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/testing.md` - Testing-specific rules

Do not proceed until rules are read and understood.

---

## Steps

1. **Determine Test Type**
   ```
   Pure logic/calculation?      → Unit test
   Calls external services?     → Integration test
   Renders UI?                  → Component test
   Spans multiple systems?      → E2E test
   ```

2. **Test Structure**
   ```
   tests/
   ├── unit/           # Fast, no external deps
   ├── integration/    # External boundaries mocked
   ├── e2e/            # Full system tests
   └── fixtures/       # Shared test data
   ```

3. **Create Fixture First**
   ```
   tests/fixtures/
   └── feature-name/
       ├── input/
       │   └── scenario.json
       └── expected/
           └── scenario.json
   ```
   
   - All test data from fixtures
   - Realistic data (from actual responses)
   - No hardcoded values in tests

4. **Write Test**
   ```
   DESCRIBE "Feature/Component"
     BEFORE EACH
       Setup fixtures
       Mock ONLY external boundaries
     
     TEST "should [behavior] when [condition]"
       GIVEN input from fixture
       WHEN action performed
       THEN verify outcome
   ```

5. **What to Mock**
   | ✅ Mock | ❌ Don't Mock |
   |---------|--------------|
   | External APIs | Internal functions |
   | Database | Business logic |
   | File system | Calculations |
   | Network | State management |
   | Time/dates | Data transforms |

6. **Avoid Anti-Patterns**
   - ❌ Testing mocks (test fails only when mock changes)
   - ❌ Testing implementation (breaks on refactor)
   - ❌ Silent passes (test passes without testing)
   - ❌ Multiple concerns per test

7. **Coverage Strategy**
   - [ ] Happy path
   - [ ] Error cases
   - [ ] Edge cases (boundaries, empty, null)
   - [ ] Integration points

8. **Run and Verify**
   ```bash
   # Run tests
   [language-specific test command]
   
   # Verify test actually tests
   # Break the code → test should fail
   ```

## Helpful Commands

- `/suggest-tests` - Have Codex generate test cases
- `/refactor-tests` - Move tests to correct layers

## Notes
- Test behavior, not implementation
- Use fixtures, not hardcoded data
- Mock only external boundaries
- One concept per test
