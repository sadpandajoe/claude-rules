# Testing Strategy & Implementation

## Core Testing Philosophy

### Why We Test This Way

We adopt a **layered, contract-based testing model** to:
- ✅ Build trust in UI/API changes through real behavior validation
- 🐛 Catch defects early while developers are still in context
- 🚀 Reduce manual effort and testing time during releases
- 📐 Improve test clarity and separation of concerns
- 👁 Ensure visual correctness of components and interfaces
- 🎯 Prevent over-mocking that creates false confidence

## Core Testing Principles

### 1. 📄 API Is the Contract

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
<!-- Add successful testing approaches discovered through experience -->

### Common Testing Pitfalls
- Over-mocking internal components
- Hardcoding test data instead of using fixtures
- Testing implementation instead of behavior
- Duplicating test logic across layers

### Quality Improvements
- Fixture-driven development prevents unrealistic test scenarios
- Minimal mocking catches integration issues early
- Layer-appropriate testing reduces maintenance burden

### Framework-Specific Insights
<!-- Add insights specific to testing frameworks and tools used -->
