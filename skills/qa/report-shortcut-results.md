# Report Shortcut Results

Use this optional phase only when a QA workflow needs to post results back to Shortcut or update Shortcut-specific workflow state.

## Goal

Keep Shortcut-specific media upload, verification comments, and state transitions out of the generic QA execution flow.

## Core Steps

1. Upload any required video or file evidence to the story.
2. Fetch the story again to retrieve the uploaded media URL.
3. Post one clean QA result comment that includes:
   - the actual repro steps or validation path used
   - expected versus actual behavior when reporting a failure
   - the single best proof link first
   - the overall QA result
4. Apply any required Shortcut-specific state or custom-field updates.

## Output

```markdown
## Shortcut QA Report

- Story: <id or url>
- Result: <pass / fail / blocked>
- Comment posted: <yes / no>
- Media URL: <url or none>
- Best proof: <url or artifact referenced first>
- State updates: <what changed>
```
