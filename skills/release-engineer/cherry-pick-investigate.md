# Cherry-Pick Investigation

Use this phase before applying a cherry-pick.

## Goal

Determine whether the candidate change should:

- proceed automatically
- proceed after user approval
- stop and escalate to planning

This is the final per-change risk gate before apply.
Do not rebuild the batch dependency graph here unless the plan phase missed a prerequisite that materially changes the outcome.

## Parallel Work

Run these tracks in parallel when possible:

1. Source analysis
   - Resolve PR URL to commit(s) if needed
   - Inspect commit message, changed files, and nearby history in enough detail to confirm or override the provisional plan assessment
   - Classify the change as functional, structural, dependency-related, or mixed

2. Target compatibility scan
   - Check whether touched files and modules exist on the target branch
   - Compare imports, APIs, and obvious dependency differences
   - Detect deleted or renamed target-side modules
   - If `package.json`, lockfiles, or equivalent dependency manifests changed, treat validation as non-routine and call out whether build or CI verification is needed

3. Prerequisite scan
   - Look for earlier commits the change appears to depend on
   - Confirm whether an equivalent fix already exists on the target branch
   - Identify obvious backport ordering constraints

## Batch Execution

This file describes per-change investigation. When investigating multiple independent changes, prefer parallel subagents (one per change) over sequential investigation in the main context. The within-change tracks (source, target, prereq) are typically fast enough to run sequentially inside a single agent — the bigger parallelism win is across changes.

## Risk Assessment

Use `skills/shared/action-gate.md` for the final proceed/stop decision.

Always end with the shared execution gate block — this is required even for LOW/Auto changes:

```markdown
## Execution Gate
Risk: LOW / MED / HIGH
Confidence: X/10
Decision Required: YES / NO
Verification Strength: STRONG / PARTIAL / WEAK
Recommendation: Proceed automatically / Ask for approval / Stop and escalate
```

For cherry-pick work, set `Verification Strength` based on whether routine target-side validation is localized (`STRONG` / `PARTIAL`) or would require non-routine rebuild or environment refresh (`WEAK`).

**Fast path**: For single changes rated `Risk: LOW` / `Confidence >= 8/10` / `Decision: NO`, emit the gate block and proceed directly to apply without a separate presentation step. The gate block is still required — the presentation pause is what gets skipped.

## Rating Rules

Set `Risk: LOW` only when all of the following are true:

- the change is primarily functional, not structural
- no new dependencies, lockfile changes, or migrations are required
- no prerequisite commit is needed
- target-side APIs and modules are compatible or trivially adaptable
- expected validation is routine and localized

Set `Decision Required: YES` if any of the following are true:

- multiple prerequisite sequences are plausible
- the cherry-pick would require dropping or rewriting meaningful behavior
- the change touches architecture, schema, or cross-cutting wiring
- the right target branch or scope is ambiguous

## Cherry-Pick-Specific Auto-Proceed Exceptions

Even if the shared action gate would otherwise allow automatic action, stop and surface the decision instead when:

- destructive cleanup is needed
- a multi-commit sequencing choice is still unresolved

When this phase overrides the batch plan, update the execution table rather than carrying two competing assessments.
