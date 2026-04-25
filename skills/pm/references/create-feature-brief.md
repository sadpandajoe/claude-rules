---
name: pm-create-feature-brief
description: Turn a raw feature request into a product-facing brief with goals, non-goals, acceptance criteria, assumptions, dependencies, and risks. Active investigation, not just reformatting. Internal helper called during feature planning.
user-invocable: false
disable-model-invocation: true
model: opus
---

# Create Feature Brief

Use this phase when a workflow needs a clear product-facing brief before technical planning. This is the PM role — actively investigate the request, don't just reformat it.

## Goal

Turn a raw feature request into a brief that is specific enough for technical planning and later validation. Ambiguities caught here save entire review rounds downstream.

## Core Steps

1. **Investigate the request** — don't just restate it:
   - If a ticket URL was provided, read it thoroughly (description, comments, linked issues)
   - Read the relevant code area to understand current behavior
   - Identify what the user is actually asking for vs. what they literally said (these often differ)
   - Check git history for prior attempts or related work

2. **Identify ambiguities and resolve them**:
   - What edge cases aren't mentioned in the request?
   - What existing behavior might this conflict with?
   - Are there multiple valid interpretations? If so, pick the most likely and state the assumption explicitly
   - If ambiguity is too large to resolve, surface it as a decision for the user before proceeding

3. **Define goals and non-goals**:
   - Goals: what changes for the user or system
   - Non-goals: what this explicitly does NOT include (prevents scope creep during implementation and review — without them, reviewers will suggest additions that were intentionally excluded)

4. **Write acceptance criteria** — these become the exit criteria for implementation slices:
   - Each criterion should be verifiable (testable assertion or observable behavior)
   - Include the happy path AND at least one edge case
   - Avoid vague criteria like "works correctly" — state what "correctly" means

5. **Note dependencies and risks**:
   - External dependencies (APIs, libraries, other teams)
   - Migration or backward compatibility concerns
   - Rollout considerations (feature flags, staged rollout)

## Output

```markdown
## Feature Brief

### Goal
<what changes for the user or system — 1-2 sentences>

### Non-goals
- <what this does not include>

### Acceptance Criteria
- [ ] <verifiable criterion — happy path>
- [ ] <verifiable criterion — edge case>
- [ ] <verifiable criterion>

### Assumptions
- <assumption made during investigation — and why>

### Dependencies
- <external dependency or "none">

### Risks
- <risk with mitigation, or "none identified">

### Open Questions
- <questions that need user input before planning, or "none — brief is complete">
```
