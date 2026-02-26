# /generate-tests - Write Automated Test Code

@/Users/joeli/opt/code/claude-rules/rules/testing.md

> **When**: Creating or restructuring automated test files (unit, integration, e2e).
> **Produces**: Test code following project conventions with proper fixtures and mocking.

## Steps

1. **Determine Test Type**
   ```
   Pure logic/calculation?      → Unit test
   Calls external services?     → Integration test
   Renders UI?                  → Component test
   Spans multiple systems?      → E2E test
   ```

2. **Study Project Conventions**
   - Read existing tests in the same area for structure and patterns
   - Check project CLAUDE.md or docs for testing guidelines
   - Follow the project's test naming and organization conventions

3. **Create Fixtures**
   - All test data from fixtures — no hardcoded values
   - Use realistic data (from actual responses where possible)
   - Follow project's fixture organization conventions

4. **Write Test**
   - Follow project conventions for test structure and organization
   - Mock ONLY external boundaries (APIs, DB, network, filesystem, time)
   - One assertion concept per test
   - Test behavior, not implementation

5. **What to Mock**
   | Mock | Don't Mock |
   |------|------------|
   | External APIs | Internal functions |
   | Database | Business logic |
   | File system | Calculations |
   | Network | State management |
   | Time/dates | Data transforms |

6. **Mock Audit** (before finalizing)
   For each mock in the test:
   - [ ] Is this at a system boundary? (API, DB, network, filesystem, time)
   - [ ] Would using the real implementation be slow or non-deterministic?
   - [ ] Does the test still verify real logic, not just mock wiring?
   If any mock fails these checks → remove it and use the real implementation.

7. **Avoid Anti-Patterns**
   - Testing mocks (test fails only when mock changes)
   - Testing implementation (breaks on refactor)
   - Silent passes (test passes without testing)
   - Multiple concerns per test

8. **Coverage Strategy**
   - [ ] Happy path
   - [ ] Error cases
   - [ ] Edge cases (boundaries, empty, null)
   - [ ] Integration points

9. **Run and Verify**
   - Run the tests — they should pass
   - Break the code → test should fail (validates it's testing real logic)

## Related Commands
- `/suggest-tests` — Suggest what test cases to write first
- `/refactor-tests` — Move tests to correct layers
