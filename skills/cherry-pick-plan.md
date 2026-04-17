# Cherry-Pick Plan

Per-cherry application strategy. This phase runs as a subagent — model is set by the gate's difficulty classification (Sonnet for trivial, Opus for non-trivial).

## Goal

Produce a concrete plan for how to apply this specific cherry-pick to the target branch. The plan is reviewed by the main thread before apply proceeds.

This phase consumes investigation output and gate decision. Do not re-litigate whether the cherry-pick should happen — the gate already decided that.

## Inputs

- Investigation output (source analysis, target compat, prereq scan, file lists)
- Gate decision (difficulty tier, adapt required, any force-override warnings)
- Target branch name

## Plan Contents

Produce a plan covering:

### 1. File Strategy

- **Include list**: files from the source commit that apply to the target
- **Exclude list**: files to exclude and why (e.g., CI configs, submodule pointers, files not relevant to target)
- **Modify/delete files**: files that exist on source but not target — will need `git rm` during apply

### 2. Conflict Forecast

- **Expected conflicts**: based on investigation's target compat scan, list files likely to conflict and why
- **Resolution approach per file**: adapt to target API, import path fix, trivial rename, etc.
- **Unknown risks**: areas where the investigation couldn't determine compatibility

### 3. Adaptation Strategy (non-trivial only)

- **API differences**: target-side APIs that differ from source, how to adapt
- **Import/module changes**: paths or modules that need updating
- **Logic adaptation**: behavioral changes needed to fit target architecture
- **Scope boundary**: what parts of the commit to include, what to drop

### 4. Validation Approach

- **Minimum checks**: lint/type-check commands to run
- **Targeted tests**: specific test files/suites covering the changed area
- **Build verification**: whether a build step is needed
- **Gaps**: validation that would be ideal but requires environment setup

## Output Format

```markdown
## Cherry-Pick Plan: <sha-short> (<summary>)

### File Strategy
Include: [N files]
Exclude: [list with reasons or "none"]
Modify/delete expected: [list or "none"]

### Conflict Forecast
Expected conflicts: [list with resolution approach or "none expected"]
Unknown risks: [list or "none"]

### Adaptation Strategy
[For non-trivial: detailed per-file approach]
[For trivial: "Clean apply expected, no adaptation needed"]

### Validation Approach
Checks: [specific commands]
Tests: [specific test files/suites or "none identified"]
Gaps: [what can't be validated locally]

### Execution Table
| SHA | PR | Description | Risk | Confidence | Decision | Status | Adaptation | Validation | Notes |
|-----|----|-------------|------|------------|----------|--------|------------|------------|-------|
| `<sha>` | #NNN | <summary> | LOW/MED/HIGH | X/10 | Auto/Approval/Escalate | Planned | None/Minor/Medium/High | Not run | <notes> |

### Risk Summary
Overall risk: LOW / MED / HIGH
Key concern: [one line or "none"]
```

The execution table is required for every cherry-pick (single or batch). It is the tracking artifact that follows the cherry through apply → adapt → validate, updated at each phase.

## Plan Review Cycle

This plan will be reviewed by the main thread (Opus). If the review sends feedback:

1. Read the feedback carefully
2. Revise the plan to address concerns
3. Re-emit the full plan (not just the changed sections)
4. Repeat until approved

Common review feedback:
- "Missing file X from exclude list" — add it with justification
- "Conflict approach for Y is wrong, target uses Z API" — revise adaptation strategy
- "Risk is understated" — re-evaluate and adjust
- "This should be rejected, not planned" — the plan subagent does not override the gate, but can note disagreement for the reviewer

## Adaptation Severity Definitions

Used in execution tables across cherry-pick phases:

- `None` = applied mechanically, no conflict resolution
- `Minor` = resolved import paths, renamed variables, or trivial API differences
- `Medium` = rewrote logic to fit target-side APIs or extracted functional subset from a mixed commit
- `High` = dropped significant chunks (entire functions, files, or bug fixes) because the target lacks required architecture. Requires user awareness — always pair with detailed notes.

## Bundled PRs

When a single PR contains multiple independent fixes:

- List each sub-fix and its applicability to the target
- Recommend which to include/exclude
- If sub-fixes are entangled, treat atomically
- Note in plan: "N of M sub-fixes planned for inclusion"
