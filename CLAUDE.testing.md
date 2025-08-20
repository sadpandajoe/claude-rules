# Testing Strategy & Implementation

## Core Testing Philosophy

### Primary Goals (In Priority Order)

1. **Make existing tests pass** - Fix failing tests in the repository
2. **Create production-ready tests when needed** - Test the actual code/feature being implemented
3. **Never create throwaway tests** - All tests must be commit-worthy and test real app code

**CRITICAL RULE**: Every test created must be production-ready and committable to the repository

**All tests created must:**
- [ ] **Be commit-worthy** - Ready to be checked into the repository
- [ ] **Test actual app code** - Validate real functionality in the codebase
- [ ] **Follow project conventions** - Match existing test structure and patterns
- [ ] **Be maintainable** - Other developers can understand and maintain them
- [ ] **Have clear purpose** - Document what specific functionality they validate
- [ ] **Use project test data** - Real fixtures, not made-up data

### What NOT to Create
❌ **Don't create these types of tests:**
- Temporary test files that won't be committed
- Test files that test general concepts unrelated to your code changes
- Example/demo tests that don't test actual repository functionality  
- Generic utility tests when you're working on a specific feature
- Tests for code that already has adequate test coverage
- Tests that duplicate existing test functionality
- "Practice" or "experimental" tests that aren't part of the actual codebase
- One-off test files to validate a concept or approach

### What TO Create
✅ **DO create tests when:**
- Implementing a new feature that needs permanent test coverage
- Fixing a bug that existing tests didn't catch (add regression test to be committed)
- Adding functionality to a component/module that lacks tests
- Explicitly requested to add test coverage for specific code
- Your code changes require test updates to maintain coverage

### Test Relevance & Commit Check
**Before creating any test, ask:**
- [ ] Does this test directly validate the code I'm implementing?
- [ ] Will this test be committed to the repository as permanent test coverage?
- [ ] Is this testing actual repository functionality vs. general concepts?
- [ ] Are there already existing tests that cover this functionality?
- [ ] Was I asked to create tests for this specific code?
- [ ] Will this test help catch real bugs in the codebase going forward?
- [ ] Does this follow the project's existing test patterns and conventions?

### Why We Test This Way

We adopt a **layered, contract-based testing model** to:
- ✅ Build trust in UI/API changes through real behavior validation
- 🛡 Catch defects early while developers are still in context
- 🚀 Reduce manual effort and testing time during releases
- 📖 Improve test clarity and separation of concerns
- 👁 Ensure visual correctness of components and interfaces
- 🎯 Prevent over-mocking that creates false confidence

## DRY Principles in Testing

When you have multiple similar tests with different inputs, use parameterized testing to reduce duplication while maintaining test clarity and isolation.

### When to Use Parameterized Tests
- **Same function, different inputs**: Testing ID vs UUID, different data types
- **Success and failure cases**: Same setup with different expected outcomes  
- **Boundary conditions**: Testing min, max, edge cases with similar logic
- **Cross-platform testing**: Same test logic across different environments

### Benefits of Parameterized Testing
- **Reduces code duplication significantly**: Multiple test methods → single parameterized method
- **Maintains test isolation**: Each parameter runs as separate test case
- **Clear failure identification**: Tests get descriptive names like `test_function_0_numeric_id`
- **Easy maintenance**: Adding new test cases requires only adding parameters
- **Better coverage visualization**: Each scenario shows up separately in test reports

### Parameterized Testing Pattern

```python
from parameterized import parameterized

@parameterized.expand([
    ("test_scenario_name", input_value, expected_result),
    ("numeric_id", "123", True),
    ("uuid_string", "550e8400-e29b-41d4-a716-446655440000", True),
    ("invalid_input", "not-a-number", False),
])
def test_function(self, test_name, input_value, expected):
    """Test function with various input types."""
    result = function_under_test(input_value)
    assert result == expected
```

### When NOT to Use Parameterized Tests
- **Different test logic**: If test setup or assertions differ significantly
- **Complex interdependencies**: When parameters affect each other in complex ways
- **Single test case**: No point in parameterizing one scenario
- **Different error handling**: When each case needs different exception handling

## Working with Existing Tests

### Test Analysis First
**Before implementing any feature, analyze existing tests:**

```bash
# Find existing tests for the area you're working on
find . -name "*.test.*" -o -name "*.spec.*" | grep -i "component-name"
grep -r "describe\|it\|test" . | grep -i "functionality-name"

# Run existing tests to see what's expected
npm test -- ComponentName.test.tsx
npm test -- --testNamePattern="specific test"

# Check test patterns in codebase
ls -la **/*.test.* | head -10
```

### Using Existing Tests as Specifications
When tests fail, they provide precise specifications for expected behavior:

```bash
# Run specific failing test with verbose output
npm test -- TestFile.test.tsx -t "specific test name" --verbose

# For debugging, run single test in watch mode (if available)
npm test -- --watch TestFile.test.tsx
```

### Test Analysis Framework
When working with existing tests:
1. **Read the test code**: Understand exactly what it's testing
2. **Examine test data**: What input does the test provide?
3. **Check assertions**: What specific output does it expect?
4. **Trace execution path**: Follow the code from input to assertion
5. **Identify the gap**: Where does reality diverge from expectation?

### Making Tests Pass Strategy
1. **Understand what the test expects** - Read the test thoroughly
2. **Implement to meet expectations** - Don't change tests unless absolutely necessary
3. **Use test data as specification** - Tests show exactly what data structures are expected
4. **Verify with related tests** - Ensure your changes don't break other tests

## When to Create New Tests

### Test Creation Guidelines
**Create tests only when they directly relate to your implementation:**

#### ✅ Valid Reasons to Create Tests:
- [ ] **Feature implementation**: You're building new functionality that needs test coverage
- [ ] **Bug fix**: Adding regression test for a bug that existing tests missed
- [ ] **Explicit request**: User specifically asked for test coverage
- [ ] **Coverage gap**: Your code changes expose areas lacking test coverage
- [ ] **API changes**: You modified interfaces that need contract validation

#### ❌ Invalid Reasons (Don't Create These):
- [ ] **General testing practice** - Creating tests unrelated to your current work
- [ ] **Example/demo tests** - Tests that demonstrate concepts but don't test real code
- [ ] **Theoretical coverage** - Testing edge cases not relevant to current implementation
- [ ] **Duplicating existing tests** - Adding tests for functionality already covered
- [ ] **Testing external dependencies** - Testing third-party code instead of your code

### Universal Testing Standards for New Tests
**If you must create tests, follow these rules:**

#### Pre-Testing Planning
**Before coding tests, always list out all tests beforehand**

- [ ] Plan test coverage and structure before implementation
- [ ] Make sure tests aren't too large or granular
- [ ] If testing for a view, it is ok to chain everything that should be in that view
- [ ] Tests should be able to tell me exactly what has failed
- [ ] Consider if the tests should live in other locations or in lower components
- [ ] Determine if the test is best in current repo or should be recommended for upstream

#### Avoiding Test Duplication
**Don't duplicate scenarios**

- [ ] Check if there are lower components the test should live in first
- [ ] See if the test already exists in dependencies/submodules - if it does, consider that a duplicate
- [ ] **Before creating new test files, always check for existing tests first:**
  - Look for existing test files that cover the same code/class/component
  - Check common test file patterns: `*.test.js`, `*.spec.js`, `__tests__/` folders
  - Search for tests of the same file/class/function before suggesting new ones
  - If existing tests are found, suggest adding to or modifying those instead
  - Only create new test files when no relevant existing tests exist
  - When adding to existing tests, maintain the same testing style and structure

## Core Testing Principles

### 1. 🔄 API Is the Contract

Every API interaction has structured `request.json` and `expected_response.json` stored in fixtures.

- **Source of truth**: These define what valid interactions look like
- **Shared fixtures**: Used for both backend validation and frontend mocking
- **No hardcoded data**: All test data comes from validated, real API responses
- **Version control**: Keep fixtures in sync with actual API responses

### 2. 🎯 Strategic Mocking Only

**Mock external boundaries, test real internal behavior**

| ✅ DO Mock | ❌ DON'T Mock |
|------------|---------------|
| External APIs and services | Internal components and functions |
| Database connections | Business logic and calculations |
| File system operations | Component interactions |
| Network requests | State management |
| Third-party libraries | Internal utility functions |

### 3. 🧩 Layered Testing Strategy

Each layer has a specific purpose - **don't duplicate logic across layers**

| Layer | Speed | Purpose | When to Use |
|-------|--------|---------|-------------|
| **API/Contract** | ⚡⚡⚡ | Request/response validation | Always for API interactions |
| **Component (RTL)** | ⚡⚡ | UI logic, state, conditionals | For component behavior |
| **Cypress Component** | ⚡⚡ | DOM interaction, layout | For complex interactions |
| **Visual Tests** | ⚡ | Appearance, charts, styling | For visual components |
| **E2E Tests** | ⚡ | Multi-system integration | For complete workflows only |

### 4. 👁 Test Real Behavior, Not Implementation

- **Test outcomes, not internals**: Verify what users see and experience
- **Use real data structures**: Fixtures from actual API responses
- **Validate actual interactions**: Real DOM events, real state changes
- **Minimize test doubles**: Only mock what you absolutely must

## Test Layer Decision Framework

### Test Layer Assignment Decision Tree

**Step 1: Does this involve external API calls?**
- Yes → API/Contract test required
- No → Skip API layer

**Step 2: Is this pure UI logic (conditionals, state changes, field behavior)?**
- Yes → Component test sufficient
- No → Consider additional layers

**Step 3: Does this involve complex DOM interactions (drag/drop, hover, focus)?**
- Yes → Cypress Component test needed
- No → RTL component test sufficient

**Step 4: Is visual appearance critical (charts, layouts, styling)?**
- Yes → Visual test required
- No → Skip visual layer

**Step 5: Does this require multiple systems, routing, or auth flows?**
- Yes → E2E test needed
- No → Lower layers sufficient

### Example Test Assignment

| Test Case | API | RTL | Cypress CT | Visual | E2E | Reasoning |
|-----------|-----|-----|------------|--------|-----|-----------|
| "Edit" button shows only if `can_edit: true` | ✅ | ✅ | ❌ | ❌ | ❌ | Pure UI conditional logic |
| Form submits valid payload | ✅ | ✅ | ❌ | ❌ | ❌ | Logic + contract coverage sufficient |
| Drag column to metric field | ❌ | ✅ | ✅ | ✅ | ❌ | RTL for logic, CT for drag, visual for layout |
| Chart renders correctly | ✅ | ✅ | ✅ | ✅ | ❌ | Full coverage, no E2E needed |
| Multi-page dashboard workflow | ✅ | ✅ | ❌ | ❌ | ✅ | Integration between systems |
| Loading spinner during fetch | ❌ | ✅ | ❌ | ❌ | ❌ | Pure UI state logic |

## Test Implementation Standards

### Fixture-Driven Testing

#### Fixture Organization
```
tests/
  fixtures/
    feature-name/
      requests/
        scenario_name.json
      expected_responses/
        scenario_name_200.json
        scenario_name_404.json
      metadata.json
```

#### Fixture Usage Rules
- **All mocks use fixtures**: No hardcoded test data in tests
- **Keep fixtures current**: Update when API changes
- **Realistic data**: Fixtures should represent actual API responses
- **Shared across layers**: Same fixtures used for API, RTL, and CT tests

### Component Testing with MSW

#### MSW Setup for Realistic Mocking
```javascript
// Example: Using fixtures with MSW
import { rest } from 'msw';
import expectedResponse from '@/tests/fixtures/chart-post/expected_responses/success_200.json';

beforeEach(() => {
  server.use(
    rest.post('/api/v1/chart/', (req, res, ctx) => {
      // Validate request structure
      expect(req.body.form_data).toBeDefined();
      // Return realistic response
      return res(ctx.json(expectedResponse));
    })
  );
});

test('component behavior with real API structure', async () => {
  render(<ChartForm />);
  // Test actual user interactions
  fireEvent.click(screen.getByLabelText(/chart type/i));
  fireEvent.click(screen.getByText('Submit'));
  // Verify real outcomes
  expect(await screen.findByText('Chart created')).toBeInTheDocument();
});
```

#### Component Testing Guidelines
- **Use MSW for API mocking**: Intercept network requests, not components
- **Test user interactions**: Click, type, select - real user actions
- **Verify real outcomes**: What users see, not internal state
- **Use fixture data**: Realistic API responses via MSW

### Cypress Component Testing

#### When to Use Cypress CT
- **Complex DOM interactions**: Drag and drop, hover states, focus management
- **Layout validation**: Component positioning, responsive behavior
- **Real browser behavior**: Events that require actual browser environment
- **Visual snapshots**: Capture appearance for regression testing

#### Cypress CT Best Practices
```javascript
// Example: Real interaction testing
it('handles drag and drop correctly', () => {
  cy.mount(<ChartBuilder data={fixtureData} />);
  
  // Real drag and drop interaction
  cy.get('[data-testid="column-field"]').drag('[data-testid="metric-zone"]');
  
  // Verify real outcome
  cy.get('[data-testid="metric-zone"]').should('contain', 'Column Name');
  
  // Visual snapshot for layout verification
  cy.percySnapshot('Chart Builder - After Drag Drop');
});
```

### API/Contract Testing

#### Contract Validation
```python
# Example: API contract testing
def test_chart_creation_contract():
    request_data = load_fixture("chart-post/requests/basic_chart.json")
    expected_response = load_fixture("chart-post/expected_responses/basic_chart_200.json")
    
    response = client.post("/api/v1/chart/", json=request_data)
    
    # Validate structure matches contract
    assert response.status_code == 200
    assert sanitize_response(response.json()) == sanitize_response(expected_response)
```

### E2E Testing Strategy

#### E2E Test Scope - Integration Only
- **Multi-system workflows**: Features that span multiple services
- **Authentication flows**: Login, permissions, session management
- **Navigation and routing**: Page-to-page interactions
- **Real user journeys**: Complete workflows from start to finish

#### What E2E Should NOT Test
- ❌ Component logic already covered in unit tests
- ❌ API responses already validated in contract tests
- ❌ UI interactions covered in component tests
- ❌ Visual appearance handled in visual tests

#### E2E Best Practices
```javascript
// Example: E2E for integration workflows
it('creates chart and adds to dashboard', () => {
  cy.login(); // Real auth flow
  cy.visit('/explore'); // Real navigation
  
  // Use real user actions, not implementation details
  cy.get('[data-testid="chart-type"]').select('Bar Chart');
  cy.contains('Save Chart').click();
  cy.contains('Add to Dashboard').click();
  
  // Verify integration outcome
  cy.visit('/dashboard/my-dashboard');
  cy.contains('My New Chart').should('exist');
});
```

## Anti-Patterns to Avoid

### ❌ Over-Mocking Anti-Patterns

| ❌ Anti-Pattern | ✅ Better Approach |
|----------------|-------------------|
| Mock every internal function | Test real function interactions |
| Hardcode test data in tests | Use realistic fixtures from API |
| Mock component props extensively | Test component with real data structures |
| Duplicate logic across test layers | Assign tests to appropriate layers |
| Test implementation details | Test user-observable behavior |
| Mock internal state management | Test state changes through user actions |

### ❌ False Confidence Indicators
- Tests pass but feature is broken in real usage
- Mocks return data that doesn't match real API
- Tests become outdated when implementation changes
- High test coverage but low confidence in deployments
- Tests that break when refactoring without behavior changes

## Test Quality Validation

### Quality Checklist for Test Reviews
- [ ] **Realistic data**: Uses fixtures from actual API responses
- [ ] **Minimal mocking**: Only mocks external boundaries
- [ ] **User-focused**: Tests what users see and do
- [ ] **Appropriate layer**: Test is in the right layer for what it validates
- [ ] **No duplication**: Doesn't repeat logic tested elsewhere
- [ ] **Fixture-driven**: No hardcoded test data
- [ ] **Clear purpose**: Obviously validates specific behavior

### Test Maintenance Standards
- **Fix failing tests immediately**: Don't accumulate broken tests
- **Update fixtures with API changes**: Keep contracts current
- **Remove obsolete tests**: Delete tests for removed functionality
- **Refactor test code**: Apply same quality standards as production code

## Framework-Agnostic Implementation

### Universal Testing Principles
1. **Test behavior, not implementation**: Focus on outcomes users care about
2. **Use real data**: Fixtures from actual system responses
3. **Mock minimally**: Only external boundaries, never internal logic
4. **Layer appropriately**: Right test type for what you're validating
5. **Maintain contracts**: Keep test data synchronized with reality

### Adapting to Different Tech Stacks
```markdown
### Technology-Specific Adaptations

#### For Web Applications:
- **API mocking**: MSW, nock, or equivalent
- **Component testing**: Testing Library for your framework
- **E2E testing**: Cypress, Playwright, or Selenium
- **Visual testing**: Percy, Applitools, or Chromatic

#### For Backend Services:
- **Contract testing**: Pact, OpenAPI validation
- **Integration testing**: Real database with test fixtures
- **Unit testing**: Focus on business logic, not framework code

#### For Mobile Applications:
- **Component testing**: Framework-specific testing libraries
- **Integration testing**: Real device testing when possible
- **Visual testing**: Screenshot comparison tools
```

## Lessons Learned

### Testing Strategies That Work
- **Fixture-driven development** prevents unrealistic test scenarios
- **Minimal mocking** catches integration issues early
- **Layer-appropriate testing** reduces maintenance burden
- **Contract-based testing** keeps API and UI tests synchronized
- **Existing test analysis** provides clear specifications for implementation

### Common Testing Pitfalls
- Over-mocking internal components creates false confidence
- Hardcoding test data instead of using realistic fixtures
- Testing implementation instead of behavior leads to brittle tests
- Duplicating test logic across layers wastes effort
- **Creating new tests instead of using existing tests as specifications**
- **Creating throwaway tests that don't get committed to the repository**

### Test Quality Improvements
- **Test-driven investigation** - failing tests reveal exact specifications
- **Realistic data structures** from API fixtures prevent integration surprises
- **User-focused testing** catches real usability issues
- **Systematic test planning** ensures comprehensive coverage
- **Existing test analysis** speeds up implementation and reduces bugs
- **Production-ready test creation** ensures all tests add permanent value to the codebase

### Manual Testing When Automation Fails (Emerging Pattern)
**Note**: Developing approaches for projects with limited test infrastructure

#### Manual Testing Strategy for Components
When automated testing unavailable:
- **Browser dev tools**: Test component functionality in development mode
- **Visual inspection**: Verify DOM structure and element rendering manually
- **Console log validation**: Add temporary logs to trace data flow
- **Manual component mounting**: Test components in isolation

#### Test Output Analysis Techniques
```bash
# Extract specific elements from test output
npm test -- TestFile.test.tsx -t "test name" 2>&1 > /tmp/test-output.txt
grep -o "pattern" /tmp/test-output.txt | sort | uniq
grep -c "expected-element" /tmp/test-output.txt

# Count rendered elements to identify limits
grep -c "specific-class-name" /tmp/test-output.txt

# Extract text content for analysis
sed -n 's/.*>\(.*\)<\/div>/\1/p' /tmp/test-output.txt
```

#### Documentation Requirements for Manual Testing
- Document what manual testing was performed
- Note limitations of manual vs automated testing
- Specify areas that need future automated test coverage
- Record manual test procedures for repeatability


### Test Data Contract Validation

**Critical Rule**: Test data must exactly match the API contracts and type hints.

#### Pre-Test Validation Checklist
- [ ] **Check function signatures**: What types does the function actually expect?
- [ ] **Review type hints**: Use them as the source of truth for expected inputs
- [ ] **Verify attribute existence**: Don't assume optional attributes exist
- [ ] **Match data formats**: Strings vs objects, lists vs single items, etc.

#### Common Test Data Pitfalls
1. **Object vs String Confusion**:
   ```python
   # BAD: Passing UUID object to string-expecting function
   result = function_expecting_string(chart.uuid)  # UUID object
   
   # GOOD: Convert to string first
   result = function_expecting_string(str(chart.uuid))  # String
   ```

2. **Silent Test Failures**:
   ```python
   # BAD: Test silently passes if uuid is None
   if chart.uuid:
       result = test_function(chart.uuid)
       assert result is not None
   
   # GOOD: Explicit validation or skip
   if chart.uuid is None:
       pytest.skip("Chart has no UUID, cannot test UUID functionality")
   result = test_function(str(chart.uuid))
   assert result is not None
   ```

3. **Type Assumption Errors**:
   ```python
   # BAD: Assuming type coercion
   assert function_expecting_int(user_id) == expected
   
   # GOOD: Explicit type handling
   assert function_expecting_int(int(user_id)) == expected
   ```

#### Test Data Validation Pattern

```python
def test_function_with_validation(self):
    """Test with explicit validation of test data."""
    # Validate test data matches expectations
    assert isinstance(test_input, str), f"Function expects string, got {type(test_input)}"
    assert test_input is not None, "Test input cannot be None"
    
    # Test the actual functionality
    result = function_under_test(test_input)
    assert result == expected_output
```

### Complex Component Testing Debugging (Emerging Pattern)
**Note**: Based on debugging experience with virtual scrolling and state management

#### Debugging Missing Elements in Tests
1. **Check if element exists at all**: Search entire test output for expected text
2. **Verify parent containers**: Missing elements might indicate parent isn't rendering
3. **Check virtual scrolling**: Element might be below visible area in virtual lists
4. **Validate data structure**: Ensure test data matches component expectations

#### Component Testing Strategy for Complex State
- **Test state transitions**, not just final states
- **Use realistic data structures** from fixtures that match production
- **Test both positive and negative cases** (success and error scenarios)  
- **Verify edge cases** (empty data, single items, maximum items)
- **Test timing issues** with async state updates