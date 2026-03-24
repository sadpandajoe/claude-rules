# Check Existing Fix

Use this helper when a workflow needs to know whether a reported bug is already fixed in `master`, pending in an open PR, or still unfixed.

This is a shared helper for `developer`, `release-engineer`, and workflows such as `/fix-bug` and `/cherry-pick`.

## Goal

Run the relevant checks in parallel, merge the evidence, and return one normalized outcome that the calling workflow can act on.

## Parallel Checks

Run the relevant checks in parallel:

1. `upstream scan`
   - Is the bug already fixed in `master`?

2. `open PR scan`
   - Is there an open PR that appears to contain the fix but is not merged yet?

3. `release-target scan` when needed
   - If the repository supports multiple maintained lines, check the relevant target line as well.

## Output

Always return the normalized summary block below. The calling workflow branches on this output — gathering the evidence without producing this block is not sufficient.

```markdown
## Existing Fix Status

Status: FIXED_UPSTREAM / FIX_PENDING_PR / UNFIXED
Confidence: X/10

Upstream Evidence:
- <commit / PR / not found>

Open PR Evidence:
- <PR / none>

Recommended Action:
- <route to cherry-pick / monitor PR / continue bug-fix workflow>
```

`FIX_PENDING_PR` is not the same as fixed. Use it to stop and surface the active PR context instead of coding blindly.
