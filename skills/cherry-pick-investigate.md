---
model: opus
---

# Cherry-Pick Investigation

Produces the raw analysis that the gate and plan phases consume. This phase does not make the go/no-go decision — that belongs to `cherry-pick-gate.md`.

## Goal

Understand the change deeply enough for the gate to decide whether to proceed and for the plan to determine how.

## Parallel Work

Run these tracks in parallel when possible:

1. Source analysis
   - Resolve PR URL to commit(s) if needed
   - Inspect commit message, changed files, and nearby history
   - Classify the change as functional, structural, dependency-related, or mixed
   - For bundled PRs: identify and list distinct sub-fixes

2. Target compatibility scan
   - Check whether touched files and modules exist on the target branch
   - Compare imports, APIs, and obvious dependency differences
   - Detect deleted or renamed target-side modules
   - **Flag modify/delete risk**: when source files don't exist on target, explicitly list the specific files — downstream phases need this
   - If `package.json`, lockfiles, or equivalent dependency manifests changed, flag as dependency change

3. Prerequisite scan
   - Look for earlier commits the change appears to depend on
   - Confirm whether an equivalent fix already exists on the target branch (via `check-existing-fix.md` — but see that file's skip rules for dependency upgrades and mixed PRs)
   - Identify obvious backport ordering constraints

## Bundled PRs

When a single PR or commit contains multiple independent fixes:

- Identify and list the distinct sub-fixes during source analysis
- Assess each sub-fix individually against the target branch — some may apply cleanly while others hit architecture mismatches
- If sub-fixes are independent, they can be included or excluded individually
- If sub-fixes are entangled (shared code paths, interdependent changes), note they must be treated atomically

## Batch Execution

When investigating multiple independent changes, prefer parallel subagents (one per change) over sequential investigation in the main context. The within-change tracks (source, target, prereq) are typically fast enough to run sequentially inside a single agent — the bigger parallelism win is across changes.

## Output

Keep investigation output compact. Produce:

```markdown
## Investigation: <sha-short> (<summary>)

### Source Analysis
Change type: functional / structural / dependency / mixed
Files changed: [N]
Key files: [list of most significant files]
Sub-fixes: [if bundled PR, list them; otherwise "N/A"]

### Target Compatibility
Compatible files: [N of total]
Modify/delete risk: [list of files or "none"]
API differences: [list or "none detected"]
Import/module mismatches: [list or "none detected"]
Dependency changes: [list or "none"]

### Prerequisites
Required prior commits: [list or "none identified"]
Existing fix status: [output from check-existing-fix.md or "not a bug fix"]
Ordering constraints: [list or "none"]

### Raw Signals for Gate
Files touched: [N]
New dependencies: YES / NO
Lockfile changes: YES / NO
Target APIs compatible: YES / NO / PARTIALLY
Conflicts expected: YES / NO / LIKELY
Prerequisite needed: YES / NO
```

Avoid exhaustive file-by-file tables when most files apply cleanly. A summary line ("12 files apply cleanly, 2 need adaptation, 1 doesn't exist on target") is better than a 12-row table with "OK" repeated.

The "Raw Signals for Gate" block is required — it provides the structured input the gate uses for its difficulty classification.
