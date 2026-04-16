---
model: sonnet
---

# Cherry-Pick Validate

Use this phase after a cherry-pick applies cleanly or after conflict resolution completes.

**This phase must always run as a subagent**, never inline in the orchestrator thread. The thread that applied the cherry-pick must not validate its own work.

## Goal

Prove that the moved change is integrated cleanly, contains only the intended changes, and did not leave the target branch in a broken state.

This phase owns post-apply verification only.
It should consume risk signals from investigate and adaptation signals from adapt rather than re-litigating whether the cherry-pick should have happened.

## Parallel Work

When project tooling allows it safely, run these in parallel:

1. Conflict-marker scan
2. Fast build or type-check
3. Targeted tests for the touched area

Avoid parallel validation when the project's test/build tooling fights for the same generated outputs or shared local environment.

## Diff Audit (Scope Leak Check) — MANDATORY

Run this **before** build/test validation. A clean build doesn't catch unrelated changes that happen to compile.

**This step is mandatory for every cherry-pick, including clean applies with zero conflicts.** Clean applies are the highest-risk vector for scope leak — git silently picks up the source branch's current state of conflicting regions, which may include changes from adjacent commits that happened to touch the same lines. No conflicts are raised, no scrutiny is triggered, and the leaked code ships.

1. Get the source commit's diff: `git diff <source-commit>^..<source-commit>`
2. Get the cherry-pick result diff: `git diff HEAD^..HEAD`
3. Compare file-by-file:
   - **Extra files**: any file changed in the cherry-pick that wasn't in the source commit is a leak. Revert it with `git checkout HEAD^ -- <file>` and amend.
   - **Extra hunks**: within a shared file, any hunk in the cherry-pick diff that has no corresponding change in the source diff is a leak candidate. It may be a legitimate adaptation (e.g., import path change for the target branch) or an accidental pickup from an adjacent commit.
4. For each extra hunk, determine origin: `git log --oneline --all -S "<leaked line>" -- <file>` — if it belongs to a different commit than the one being cherry-picked, it's a leak.
5. Report findings as a **Scope Audit** block:

```markdown
## Scope Audit
Files in source: [N] | Files in cherry-pick: [M]
Extra files: [list or "none"]
Extra hunks: [list with origin commit or "none"]
Verdict: [clean / leaked — reverted / leaked — kept with justification]
```

If the audit finds leaks, revert them before proceeding to build/test validation. If a leaked change appears to be a required prerequisite, escalate to the user rather than silently keeping it.

## Validation Order

At minimum:

1. Confirm there are no conflict markers.
2. Run the smallest relevant build or type-check.
3. Run targeted tests covering the changed area.

For config-only changes (YAML, JSON, feature flags) where there is no build or test to run, validate by parsing the file programmatically and verifying the intended effect (e.g., load YAML and assert the expected keys/values are present).

Run broader validation when:

- the cherry-pick touched shared infrastructure
- the target branch differs materially from the source branch
- the targeted checks fail to provide confidence

## Minimum Validation Bar

For Python files changed by the cherry-pick, run at minimum:
- `ruff check <changed-files>` (or the repo's lint command)
- `mypy <changed-files>` (or the repo's type-check command) when the repo uses type checking

For JavaScript/TypeScript files, run at minimum:
- The repo's lint command (e.g., `npm run lint`)
- `tsc --noEmit` when the repo uses TypeScript

Discover commands from `package.json` scripts, `Makefile` targets, `pyproject.toml`, `setup.cfg`, or CI config. These checks are mandatory, not aspirational — if skipped, the validation status must reflect it.

## Validation Gap Flagging

When targeted tests exist and are runnable but were not executed, explicitly flag the gap — do not silently record a weaker status label. Include in the output:

- what tests were available (e.g., "pytest tests/unit_tests/mcp_service/ covers the changed area")
- why they weren't run (e.g., "time constraint", "environment not set up", "skipped in favor of build-only")
- what the recommended follow-up is (e.g., "run before merging")

Recording `Checked` or `Structural` when `Tested` was achievable without extraordinary effort is an undercount that must be called out, not accepted silently.

## Dependency Manifest Rule

If the cherry-pick touches dependency manifests or lockfiles such as `package.json`, `package-lock.json`, `npm-shrinkwrap.json`, `pnpm-lock.yaml`, `yarn.lock`, `requirements.txt`, `setup.py`, or `pyproject.toml`:

1. Do not treat validation as routine.
2. Treat manifest or lockfile changes detected during investigate as a validation escalation, not as a reason to reopen planning unless validation cannot proceed safely.
3. Prefer the repo's existing build, type-check, or CI verification commands over reinstalling dependencies locally.
4. Treat any rebuild or environment refresh as an intervention point unless the command is already the standard non-destructive verification path for this repo.
5. Run the smallest verification command that gives confidence, and surface when stronger validation would require rebuilding or environment changes.
6. For pip-compiled lockfiles (`requirements.txt` generated from `setup.py` or `pyproject.toml`): resolve the source file (`setup.py`, `pyproject.toml`) first, then decide whether to regenerate the lockfile via `pip-compile` or resolve surgically. Surface the choice rather than guessing.

If the target branch uses a different package manager or lockfile than the source branch, stop and surface that mismatch rather than guessing.

## Validation Status Labels

Use these labels in the execution table. Do not overstate what was actually verified:

| Label | Meaning |
|-------|---------|
| **Tested** | Build + targeted tests passed |
| **Checked** | Lint/type-check passed, no targeted tests run |
| **Build-only** | Build passed (pre-commit hooks or equivalent), no lint/type-check/test beyond that |
| **Structural** | Conflict markers clear, file parse OK, no lint/build/test run |
| **Not run** | No validation performed |

Never use "Clean" or "Validated" as a status — they are ambiguous about what was actually run.

## What To Do When Validation Fails

| Current Label | Failure | Action |
|---------------|---------|--------|
| Tested | Test failure | Re-run failed tests, fix the issue, re-validate |
| Checked | Lint or type error | Fix errors, re-run checks |
| Build-only | Build failure | Fix build, re-run |
| Structural | Parse error or conflict markers found | Fix by hand, re-validate |
| Not run | No validation performed | Run at least structural validation before merging |

## Output

Summarize:

- what validated successfully and what commands were run
- what was skipped and why
- the final validation status label (from the table above) to record in the execution table
- remaining residual risk, if any
