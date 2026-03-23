# Capture Evidence

Use this phase when QA execution or bug validation needs durable screenshots, video, logs, or artifact organization.

## Goal

Capture only the evidence that materially improves confidence, and organize it so later reporting can reuse it without guessing.

## Core Steps

1. Capture the smallest useful artifact set for the scenario:
   - screenshot for visual failures
   - Playwright video for repro-heavy UI paths
   - console, network, or API output when it explains the failure
2. Keep naming descriptive and tied to the scenario or issue.
3. Save artifacts under a stable local structure such as `qa-evidence/<scenario>/`.
4. Record which artifact actually proves the behavior instead of dumping everything.

## Output

```markdown
## QA Evidence

- Scenario: <name>
- Artifacts:
  - <path and why it matters>
- Best proof:
  - <single artifact or log line to reference first>
```
