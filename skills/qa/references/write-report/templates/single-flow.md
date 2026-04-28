# Single-Flow Template

For one bug, one repro path. See [../../write-report.md](../../write-report.md) for shape selection and tone rules.

```markdown
## QA Verification — PASS ✅ / FAIL ❌ / PARTIAL ⚠️

**Tested on**: <environment URL or description> (<version/branch/build info>)
**Date**: <YYYY-MM-DD>
**Tester**: <who or what ran the test>

### Repro steps followed:
1. <what you actually did, step by step>
2. <be specific — name the dashboard, chart, page, action>
3. <include what you looked for and how you verified>

### Result:
**<One-sentence verdict.>** <2–3 sentences of narrative explaining what you observed. What rendered, what didn't break, what you checked.>

### Evidence:
[<descriptive-filename.webm>](<hosted media URL>)
```

If the report has multiple related checks within the same flow, label them inline in the Result block (e.g. `**Test 1 (delete value):** ...`, `**Test 2 (type 365):** ...`) rather than splitting into separate sections.
