# Verify CI Fix

Use this phase after a candidate CI fix has been applied.

## Goal

Run the smallest local validation set that gives strong confidence the CI failure was actually addressed.

## Verification Strength

Classify verification strength as:

- **STRONG**: the original failing step can be reproduced or closely mirrored locally, and the post-fix check passes
- **PARTIAL**: only adjacent or narrower checks can be run locally
- **WEAK**: the failure cannot be meaningfully exercised locally

## Rules

- Start with the command closest to the failing CI step.
- Then run nearby impacted checks for the changed files.
- Prefer targeted validation over broad rebuilds unless the changed files demand broader coverage.
- If validation would require environment rebuilds, non-routine setup, or infra-only changes, classify it honestly instead of forcing it.

## Stop Conditions

Stop and surface the result instead of continuing automatically when:

- verification is `WEAK`
- the failing step cannot be exercised locally
- the proposed fix changes behavior outside the failing surface
- the remaining uncertainty is higher than the repo should auto-apply
