# Cherry-Pick Validate

Use this phase after a cherry-pick applies cleanly or after conflict resolution completes.

**This phase must always run as a subagent**, never inline in the orchestrator thread. The thread that applied the cherry-pick must not validate its own work.

**Model selection**: Set by the gate's difficulty classification — Sonnet for trivial, Opus for non-trivial. The caller (main thread or orchestrator) is responsible for spawning this subagent with the correct model.

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

**This step is mandatory for every cherry-pick, including clean applies with zero conflicts.** This intentionally re-checks scope even when the adapt phase already ran its own leak detection — defense in depth. Do not skip this because adapt "already checked." Clean applies are the highest-risk vector for scope leak — git silently picks up the source branch's current state of conflicting regions, which may include changes from adjacent commits that happened to touch the same lines. No conflicts are raised, no scrutiny is triggered, and the leaked code ships.

### Step 1: Mechanical Pre-Check (bash — run first)

Run these commands to produce a mechanical comparison. These are not LLM judgment calls — they are deterministic checks that flag discrepancies for investigation.

```bash
# 1. File list comparison
SOURCE_FILES=$(git diff --name-only <source-commit>^..<source-commit> | sort)
RESULT_FILES=$(git diff --name-only HEAD^..HEAD | sort)

# 2. Find extra files in cherry-pick result that weren't in source
EXTRA_FILES=$(comm -13 <(echo "$SOURCE_FILES") <(echo "$RESULT_FILES"))

# 3. Find missing files (in source but not in result — may be legitimate exclusion)
MISSING_FILES=$(comm -23 <(echo "$SOURCE_FILES") <(echo "$RESULT_FILES"))

# 4. Per-file line count comparison for shared files
SHARED_FILES=$(comm -12 <(echo "$SOURCE_FILES") <(echo "$RESULT_FILES"))
for f in $SHARED_FILES; do
  SOURCE_LINES=$(git diff --stat <source-commit>^..<source-commit> -- "$f" | tail -1)
  RESULT_LINES=$(git diff --stat HEAD^..HEAD -- "$f" | tail -1)
  echo "$f | source: $SOURCE_LINES | result: $RESULT_LINES"
done
```

**Interpretation rules (mechanical, no judgment):**
- **Extra files found** → scope leak until proven otherwise. Each must be investigated in step 2.
- **Line count differs by >20% for a shared file** → flag for hunk-level investigation in step 2. Minor differences are expected from adaptation (import paths, API names).
- **Both checks clean** → still run step 2 (LLM hunk audit), but with higher confidence. Note "mechanical pre-check clean" in the scope audit.

### Step 2: LLM Hunk-Level Audit

Now investigate anything the mechanical check flagged, plus do a full hunk comparison:

1. Get the source commit's diff: `git diff <source-commit>^..<source-commit>`
2. Get the cherry-pick result diff: `git diff HEAD^..HEAD`
3. Compare file-by-file:
   - **Extra files** (already flagged by mechanical check): revert with `git checkout HEAD^ -- <file>` and amend. No exceptions unless the file is a legitimate adaptation (new test file for the cherry-picked change).
   - **Extra hunks**: within a shared file, any hunk in the cherry-pick diff that has no corresponding change in the source diff is a leak candidate. It may be a legitimate adaptation (e.g., import path change for the target branch) or an accidental pickup from an adjacent commit.
4. For each extra hunk, determine origin: `git log --oneline --all -S "<leaked line>" -- <file>` — if it belongs to a different commit than the one being cherry-picked, it's a leak.

### Step 3: Report

```markdown
## Scope Audit

### Mechanical Pre-Check
Files in source: [N] | Files in cherry-pick: [M]
Extra files: [list or "none"]
Missing files: [list or "none"]
Line count divergence: [list of flagged files or "none"]
Mechanical verdict: CLEAN / FLAGGED

### Hunk-Level Audit
Extra hunks: [list with origin commit or "none"]
Legitimate adaptations: [list or "none"]
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
