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

## Risk Assessment

Always end with this block:

```markdown
## Risk Assessment

Risk: LOW / MED / HIGH
Confidence: X/10
Decision Required: YES / NO

Recommendation:
- Proceed
- Ask for approval
- Escalate to planning
```

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

## Auto-Proceed Rule

Proceed without asking the user only when:

- `Risk: LOW`
- `Confidence: 8/10` or higher
- `Decision Required: NO`
- no destructive cleanup or multi-commit sequencing choice is needed

Otherwise stop and surface the decision clearly.

When this phase overrides the batch plan, update the execution table rather than carrying two competing assessments.
