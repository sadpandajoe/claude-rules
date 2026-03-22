# Cherry-Pick Validate

Use this phase after a cherry-pick applies cleanly or after conflict resolution completes.

## Goal

Prove that the moved change is integrated cleanly and did not leave the target branch in a broken state.

This phase owns post-apply verification only.
It should consume risk signals from investigate and adaptation signals from adapt rather than re-litigating whether the cherry-pick should have happened.

## Parallel Work

When project tooling allows it safely, run these in parallel:

1. Conflict-marker scan
2. Fast build or type-check
3. Targeted tests for the touched area

Avoid parallel validation when the project's test/build tooling fights for the same generated outputs or shared local environment.

## Validation Order

At minimum:

1. Confirm there are no conflict markers.
2. Run the smallest relevant build or type-check.
3. Run targeted tests covering the changed area.

Run broader validation when:

- the cherry-pick touched shared infrastructure
- the target branch differs materially from the source branch
- the targeted checks fail to provide confidence

## Dependency Manifest Rule

If the cherry-pick touches dependency manifests or lockfiles such as `package.json`, `package-lock.json`, `npm-shrinkwrap.json`, `pnpm-lock.yaml`, or `yarn.lock`:

1. Do not treat validation as routine.
2. Treat manifest or lockfile changes detected during investigate as a validation escalation, not as a reason to reopen planning unless validation cannot proceed safely.
3. Prefer the repo's existing build, type-check, or CI verification commands over reinstalling dependencies locally.
4. Treat any rebuild or environment refresh as an intervention point unless the command is already the standard non-destructive verification path for this repo.
5. Run the smallest verification command that gives confidence, and surface when stronger validation would require rebuilding or environment changes.

If the target branch uses a different package manager or lockfile than the source branch, stop and surface that mismatch rather than guessing.

## Output

Summarize:

- what validated successfully
- what was skipped and why
- the final validation status to record in the execution table
- remaining residual risk, if any
