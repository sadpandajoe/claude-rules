# /refactor-tests - Move Tests to Correct Layers

Reorganize tests to appropriate testing layers.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/testing.md` - Testing layers and philosophy
3. `rules/orchestration.md` - Claude + Codex workflows

Do not proceed until rules are read and understood.

---

## Steps

1. **Analyze Current Test Structure**
   ```bash
   # Find all test files
   find . -name "*test*" -o -name "*spec*" | head -50
   
   # Check test organization
   ls -la tests/ test/ spec/ __tests__/
   ```

2. **Codex Analysis**
   
   Have Codex analyze test structure:
   ```
   codex exec --sandbox read-only "Analyze the test files in this repository.
   
   For each test file, determine:
   1. Current layer (unit/integration/e2e)
   2. Correct layer based on what it tests
   3. Issues found:
      - Testing mocks instead of behavior?
      - Unnecessary external dependencies?
      - Could be faster at lower layer?
      - Missing coverage at right layer?
   
   Output format:
   | File | Current Layer | Should Be | Issue | Recommendation |
   |------|---------------|-----------|-------|----------------|
   
   Focus on tests that are at the WRONG layer."
   ```

3. **Review Codex Findings**
   
   For each misplaced test, confirm:
   - Does it have external dependencies?
   - Does it test behavior or implementation?
   - Could it run faster at different layer?

4. **Layer Definitions**
   | Layer | Characteristics | Speed |
   |-------|-----------------|-------|
   | **Unit** | No external deps, tests logic | <10ms |
   | **Integration** | Mocked external boundaries | <100ms |
   | **Component** | UI rendering, DOM | <500ms |
   | **E2E** | Full system, real deps | Seconds |

5. **Refactor Tests**
   
   For each test to move:
   ```markdown
   ### Moving: [test name]
   - **From**: [current location/layer]
   - **To**: [new location/layer]
   - **Why**: [reason]
   - **Changes needed**:
     - [ ] Remove unnecessary mocks
     - [ ] Add/remove fixtures
     - [ ] Update imports
     - [ ] Adjust assertions
   ```

6. **Execute Moves** (Claude)
   
   For each test:
   ```
   1. Copy test to new location
   2. Adjust for new layer:
      - Unit: Remove all mocks of internals
      - Integration: Mock only external boundaries
      - E2E: Remove all mocks
   3. Run test in new location
   4. Delete from old location
   5. Commit: "refactor(tests): move X to [layer]"
   ```

7. **Codex Review Result**
   ```
   codex exec --sandbox read-only "Review the test structure changes.
   
   Score 1-10:
   - Test organization
   - Appropriate layering
   - Mock usage
   - Coverage distribution
   
   Remaining issues?"
   ```

8. **Iterate Until 8/10**
   
   If score < 8:
   - Address Codex feedback
   - Re-run analysis
   - Continue moving tests

## Common Moves

| Symptom | Current | Move To |
|---------|---------|---------|
| Mocks internal functions | Integration | Unit |
| Slow but no external deps | E2E | Unit |
| Tests DB but could use fixture | Integration | Unit |
| Tests API but mocks everything | Integration | Unit |
| Tests UI with mocked API | E2E | Component |

## Notes
- Tests should be as low as possible in pyramid
- More unit, fewer E2E
- Mock only external boundaries
- Speed matters - faster feedback loops
