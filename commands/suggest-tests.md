# /suggest-tests - Generate Test Cases (Codex)

> **When**: Analyzing code to identify what needs testing.
> **Produces**: Prioritized test case list with coverage notes.

## Usage
```
/suggest-tests                      # Tests for uncommitted changes
/suggest-tests <file>               # Tests for specific file
/suggest-tests --function <name>    # Tests for specific function
```

## Steps

1. **Determine Scope**

   Use native tools to gather code:
   - **Uncommitted changes**: Use `git diff --name-only` via Bash
   - **Specific file**: Use `Read` tool
   - **Specific function**: Use `Grep` tool with pattern and context

2. **Codex Generate Tests**
   ```
   codex exec --sandbox read-only "Generate test cases for this code.
   
   CODE:
   ---
   [insert code]
   ---
   
   For each function/method, suggest:
   
   ## Test Cases
   
   ### [Function Name]
   
   #### Unit Tests (no external deps)
   | Test Case | Input | Expected Output | Why |
   |-----------|-------|-----------------|-----|
   | Happy path | [input] | [output] | Normal case |
   | Edge: empty | [] | [output] | Boundary |
   | Edge: null | null | throws/[output] | Null handling |
   | Error case | [bad input] | throws X | Error path |
   
   #### Integration Tests (if external deps)
   | Test Case | Setup | Action | Verify |
   |-----------|-------|--------|--------|
   
   ## Fixture Suggestions
   [Suggested test data structures]
   
   ## Coverage Notes
   - Branches covered: [list]
   - Branches NOT covered: [list]
   - Recommended priority: [which tests first]"
   ```

3. **Review Suggestions**
   
   For each suggested test, evaluate:
   - Is this testing behavior (✅) or implementation (❌)?
   - Does it need external mocks?
   - What layer should it be? (unit/integration/e2e)

4. **Present to User**
   ```markdown
   ## Suggested Tests for [scope]
   
   ### High Priority
   - [ ] [Test case 1] - [why important]
   - [ ] [Test case 2] - [why important]
   
   ### Medium Priority
   - [ ] [Test case 3]
   - [ ] [Test case 4]
   
   ### Edge Cases
   - [ ] [Edge case 1]
   - [ ] [Edge case 2]
   
   ### Fixture Data Needed
   ```json
   {
     "scenario1": { ... }
   }
   ```
   
   Would you like me to implement any of these tests?
   ```

5. **Optional: Implement Selected Tests**
   
   If user selects tests to implement:
   - Switch to Claude implementation
   - Use `/test` workflow
   - Create fixtures first
   - Write tests following rules

## Notes
- Codex suggests, Claude implements
- Focus on behavior, not implementation
- Consider test layers when implementing
- Create fixtures before tests
