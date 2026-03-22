# /create-tests - Create Automated Tests

@/Users/joeli/opt/code/ai-toolkit/rules/testing.md

> **When**: Creating or improving automated tests (unit, integration, e2e).
> **Produces**: Test code following project conventions, validated by review-tests skill.

## Usage
```
/create-tests                         # Tests for uncommitted changes
/create-tests <file>                  # Tests for specific file
/create-tests --function <name>       # Tests for specific function
```

## Steps

1. **Determine Scope**

   Identify the code to test:
   - Uncommitted changes: `git diff --name-only`
   - Specific file or function: as provided
   - Read the code thoroughly before writing any tests

2. **Run review-tests Skill**

   Spawn a Task subagent (subagent_type: "general-purpose") with `skills/review-tests/SKILL.md` instructions to analyze:
   - Existing test coverage for the target code
   - Missing behavioral coverage
   - Weak or low-signal tests
   - Production failure scenarios without test protection

   This tells us what to write and what to fix.

3. **Study Project Conventions**
   - Read existing tests in the same area for structure and patterns
   - Check project CLAUDE.md or docs for testing guidelines
   - Follow the project's test naming and organization conventions

4. **Determine Test Types**
   ```
   Pure logic/calculation?      → Unit test
   Calls external services?     → Integration test
   Renders UI?                  → Component test
   Spans multiple systems?      → E2E test
   ```

5. **Create Fixtures**
   - All test data from fixtures — no hardcoded values
   - Use realistic data (from actual responses where possible)
   - Follow project's fixture organization conventions

6. **Write Tests**

   Address review-tests findings in priority order:
   1. Missing behavioral coverage (gaps)
   2. Production failure scenarios without protection
   3. Replacements for weak/low-signal tests

   For each test:
   - Mock ONLY external boundaries (APIs, DB, network, filesystem, time)
   - One assertion concept per test
   - Test behavior, not implementation

7. **What to Mock**
   | Mock | Don't Mock |
   |------|------------|
   | External APIs | Internal functions |
   | Database | Business logic |
   | File system | Calculations |
   | Network | State management |
   | Time/dates | Data transforms |

8. **Mock Audit** (before finalizing)
   For each mock in the test:
   - [ ] Is this at a system boundary? (API, DB, network, filesystem, time)
   - [ ] Would using the real implementation be slow or non-deterministic?
   - [ ] Does the test still verify real logic, not just mock wiring?
   If any mock fails these checks → remove it and use the real implementation.

9. **Run and Verify**
   - Run the tests — they should pass
   - Break the code → test should fail (validates it's testing real logic)

10. **Re-run review-tests Skill**

    Spawn review-tests again to verify:
    - Gaps are filled
    - New tests are high-signal
    - Score improved

    If score < 8/10 and there are actionable issues, iterate (max 3 rounds).

## Anti-Patterns
- Testing mocks (test fails only when mock changes)
- Testing implementation (breaks on refactor)
- Silent passes (test passes without testing)
- Multiple concerns per test

## Related Commands
- `/review-plan` — Reviews test strategy during plan phase via review-testplan skill
