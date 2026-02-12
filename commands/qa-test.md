# /qa-test - Execute QA Test Plan & File Bugs

> **When**: You have use cases (from /qa-discover or PROJECT.md) and a running
>   environment to test against.
> **Produces**: Bug tickets in issue tracker with repro steps, screenshots/video,
>   and logs. Updated use case matrix with PASS/FAIL status.

## Prerequisites
- Use cases documented in PROJECT.md (run /qa-discover first if needed)
- Running environment (local Docker, staging, ephemeral)
- Browser automation MCP connected (for UI testing)
- Issue tracker MCP connected (for bug filing)

## Steps

1. **Filter Testable Use Cases**
   From PROJECT.md use cases, filter to those testable now:
   - Requires browser UI? → Browser automation MCP
   - Requires API only? → curl/httpie via Bash
   - Requires background worker? → Mark BLOCKED
   - Requires specific data setup? → Note prerequisites

2. **Environment Check**
   Verify app health, feature flags, test data, and user permissions.

3. **Execute Each Use Case**
   For each testable use case:

   a. **Setup**: Navigate to starting state, create prerequisites
   b. **Execute**: Follow the repro steps
   c. **Capture Evidence**:
      - Screenshot on failure (browser automation MCP)
      - Console logs if relevant
      - Network responses for API issues
      - Save to local directory: `qa-evidence/UC-NNN/`
   d. **Record Result**: PASS, FAIL, BLOCKED, or SKIP

4. **File Bugs for Failures**
   For each FAIL, create a bug ticket with:
   - **Title**: Specific description of the failure
   - **Environment**: URL, branch, feature flags, browser
   - **Repro Steps**: Numbered steps from a clean state
   - **Expected vs Actual**: What should happen vs what happened
   - **Evidence**: Screenshot/video, logs
   - **Severity**: Based on user impact
   - **Related Use Case**: UC-NNN from PROJECT.md

5. **Update PROJECT.md**
   - Update use case Status: PASS / FAIL (with ticket link) / BLOCKED
   - Add execution notes to Development Log
   - Update Current Status with summary

## Evidence Organization
```
qa-evidence/
  UC-143/
    screenshot.png
    console-log.txt
  UC-145/
    screenshot.png
```

## Bug Filing Checklist
- [ ] Title is specific (not "filter broken" but "filter fields hidden until clicked when editing existing alert")
- [ ] Repro steps start from a clean state
- [ ] Expected vs actual is clear
- [ ] Screenshot or video attached
- [ ] Feature flags and environment noted
- [ ] Linked to epic/parent if applicable

## Tips
- Test happy paths first, then edge cases
- Group related use cases to minimize navigation
- If browser automation unavailable, document manual repro steps
- For intermittent failures, note frequency and any patterns
