---
name: review-rca
description: Review root cause analysis and proposed fix before implementation.
---

# Review RCA

Review the root cause analysis and proposed solution before implementation.

If PROJECT.md exists, read it first.

Focus on these sections if present:
- Issue
- Evidence
- Root Cause
- Proposed Fix
- Tests

## Root Cause Validation

Determine whether the stated root cause is plausible.

Check:
- whether the explanation matches the behavior of the code
- whether alternative root causes could exist
- whether the evidence is sufficient
- whether assumptions require validation

Identify missing investigation steps if the RCA is uncertain.

## Proposed Fix Evaluation

Analyze the proposed solution.

Determine:
- whether the fix actually addresses the root cause
- whether the approach introduces unnecessary complexity
- whether the plan could introduce new bugs
- whether important edge cases are unhandled

## Risk Analysis

Identify possible failure scenarios such as:
- race conditions
- state inconsistencies
- partial failures
- integration issues
- performance risks

## Output

Provide:
- Summary
- Plan score (1-10)
- Root Cause Validation
- Plan Evaluation
- Potential Risks
- Suggested Improvements
- Next Steps
