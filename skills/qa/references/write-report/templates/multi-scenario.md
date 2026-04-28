# Multi-Scenario Template

For distinct viewports, roles, configs, browsers, feature-flag states, or independent flows. See [../../write-report.md](../../write-report.md) for shape selection and tone rules.

```markdown
## QA Verification — PASS ✅ / FAIL ❌ / PARTIAL ⚠️

**Tested on**: <environment URL or description> (<version/branch/build info>)
**Date**: <YYYY-MM-DD>
**Tester**: <who or what ran the test>

### Scenario 1 — <short label, e.g. "Desktop 1440×900" or "Read-only role">
1. <step>
2. <step>

**Result:** <one-sentence verdict + 1–2 sentences of narrative.>

![Scenario 1 — <label>](<hosted PNG URL>)

### Scenario 2 — <short label>
1. <step>
2. <step>

**Result:** <one-sentence verdict + 1–2 sentences of narrative.>

![Scenario 2 — <label>](<hosted PNG URL>)

### Full-flow evidence:
[<descriptive-filename.webm>](<hosted media URL>) — <one-line description of what the recording covers>
```

Notes:
- Each scenario gets its own steps + result + inline screenshot, in that order.
- One full-flow video at the end (not one per scenario) — the recording covers login + setup + all scenarios in sequence.
- Scenario labels should be self-describing: viewport size, role name, browser, flag state — whatever distinguishes them.
