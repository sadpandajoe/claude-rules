# /analyze-tests - Analyze Test Coverage and Discover Bugs

@/Users/joeli/opt/code/claude-rules/rules/testing.md

> **When**: Exploring a feature area to find potential bugs, edge cases,
>   missing validations, and asymmetries before or instead of manual testing.
> **Produces**: Categorized use case matrix in PROJECT.md with severity/confidence ratings.

## Steps

1. **Define Scope**
   - Feature area, feature flags, key files
   - Related PRs, issues, epic descriptions
   - Existing test coverage

2. **Deep-Dive Code Analysis** (use Task/Explore agents)
   - Frontend: Component logic, state management, event handlers, validation
   - Backend: Models, commands, API schemas, execution paths
   - Cross-cutting: Feature flag checks, error handling, type safety

3. **Cross-Reference External Sources**
   - PR review comments (especially unresolved ones)
   - Issue tracker tickets and QA reports
   - Design docs (Figma, Notion, etc.)
   - Automated review tool findings

4. **Identify Bug Patterns**
   - Asymmetries (feature A has safeguard, feature B doesn't)
   - Unsafe access patterns (missing .get(), uncaught exceptions)
   - Validation gaps (create validates, update doesn't)
   - State management issues (race conditions, stale closures)
   - Feature flag interactions (flag A + flag B combinations)

5. **Generate Use Case Matrix**
   For each finding:

   | Field | Description |
   |-------|-------------|
   | ID | UC-NNN sequential |
   | Title | Short descriptive name |
   | Feature Flag | Which flags required |
   | Status | NOT TESTED / HIGH CONFIDENCE BUG / CONFIRMED BUG / FILED BUG |
   | Description | What happens, why it's a bug, where in code |

6. **Categorize by Priority**
   - **Filed bugs**: Already reported in issue tracker
   - **High confidence bugs**: Code analysis strongly suggests breakage
   - **Untested scenarios**: Behavior unknown, needs verification
   - **Code quality issues**: Tech debt, not bugs per se

7. **Update PROJECT.md**
   - Add use cases to QA Use Cases section
   - Update Confirmed Bugs in Current Status
   - Add findings to Development Log

## Tips
- Start with the "happy path" code, then trace error/edge paths
- Compare similar features for asymmetries (e.g., create vs update validation)
- Check what automated reviewers flagged in PRs — often still unfixed
- Look at test files for TODOs and commented-out tests
