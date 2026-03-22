# /run-qa - Execute QA Test Plan & File Bugs

@/Users/joeli/opt/code/ai-toolkit/rules/testing.md

> **When**: You have use cases (from /analyze-tests or PROJECT.md) and a running
>   environment to test against.
> **Produces**: Bug tickets in issue tracker with repro steps, screenshots/video,
>   and logs. Updated use case matrix with PASS/FAIL status.

## Prerequisites
- Use cases documented in PROJECT.md (run /analyze-tests first if needed)
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
  videos/
    sc-NNNNN-description.webm
  UC-143/
    screenshot.png
    console-log.txt
```

### Video Recording via Playwright
Record video evidence by creating a new browser context with `recordVideo` enabled.
Copy cookies from the main session to avoid re-login. Close the context to finalize the video.
Name videos descriptively: `sc-NNNNN-short-description.webm`

### Embedding Videos in Shortcut Comments
Shortcut only renders inline video/media when you use a markdown link pointing to a **Shortcut media URL** (not a local filename). Follow this exact sequence:

1. **Upload** the video file to the story using `stories-upload-file`
2. **Fetch** the story with `full: true` to get the uploaded file's `url` field
3. **Use** the media URL in the comment: `[descriptive-name.webm](https://media.app.shortcut.com/api/attachments/files/...)`

A plain filename like `video.webm` will NOT render — it must be a markdown link with the Shortcut media URL.

## QA Verification Comment Format

When posting QA results on a story, use **one clean comment** per story:

```markdown
## QA Verification — PASS ✅

**Tested on**: <staging-url> (staging)
**Date**: <YYYY-MM-DD>
**Tester**: Playwright automation (<email>)

### Repro steps followed:
1. <exact step matching what the video shows>
2. <step 2>
...

### Result:
**Bug appears fixed.** <description of observed behavior>

### Evidence:
[filename.webm](<shortcut-media-url-from-uploaded-file>)
```

### Rules:
- **Repro steps MUST match what the video actually shows** — never describe steps that aren't visible in the recording
- One comment, one video — no multi-comment update chains
- Embed the video link in Evidence using the Shortcut media URL from the upload
- For FAIL: replace header with `## QA Verification — FAIL ❌` and describe what went wrong

## Story State Transitions

When a bug passes QA:
1. Upload video evidence to the story (`stories-upload-file`)
2. Fetch story with `full: true` to get the uploaded file's media URL from the `files` array
3. Post QA verification comment with inline video link using the media URL
4. Set custom fields: **QA Assigned** and **Card Status** = "Passed QA"
5. Move story to **Validate/QA** workflow state

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
- **Verify element selectors before recording** — use the main browser session to snapshot the DOM and identify correct selectors, then record with the verified selectors
- **Icons in antd are `span[role="img"]`** not `<img>` — accessibility snapshots may show `img` but the actual DOM uses antd span icons
- **Avoid generic selectors like `.last()`** — they grab page elements instead of component-scoped elements
