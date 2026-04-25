# Cherry-Pick Validate

Use after a cherry-pick applies cleanly or after conflict resolution completes.

**Always runs as a subagent** — the thread that applied must not validate its own work.

**Model selection**: set by the gate (Sonnet for trivial, Opus for non-trivial). The caller spawns this subagent with the correct model.

## Goal

Prove that the moved change is integrated cleanly, contains only the intended changes, and did not leave the target branch broken.

Consume risk signals from investigate and adaptation signals from adapt. Do not re-litigate whether the cherry-pick should have happened.

## Parallel Work

When project tooling allows it safely, run these in parallel:

1. Conflict-marker scan
2. Fast build or type-check
3. Targeted tests for the touched area

Avoid parallel validation when the project's test/build tooling fights for the same generated outputs or shared local environment.

## Diff Audit (Scope Leak Check) — MANDATORY

Run this **before** build/test validation. A clean build doesn't catch unrelated changes that happen to compile.

**Mandatory for every cherry-pick, including clean applies with zero conflicts.** This intentionally re-checks scope even when adapt already ran its own leak detection — defense in depth. Do not skip because adapt "already checked." See [../gotchas.md](../gotchas.md) for the scope-leak failure mode.

### Step 1: Mechanical Pre-Check

Run the bundled script:

```bash
${CLAUDE_SKILL_DIR}/scripts/scope-audit.sh <source-commit>
```

This produces a mechanical comparison (file list, line counts) — no LLM judgment. It outputs:
- Extra files in cherry-pick result not in source
- Missing files (may be legitimate exclusions)
- Line count divergence per shared file

**Interpretation:**
- **Extra files found** → scope leak until proven otherwise. Investigate each in Step 2.
- **Line count differs by >20% for a shared file** → flag for hunk-level investigation.
- **Both checks clean** → still run Step 2, but with higher confidence.

### Step 2: LLM Hunk-Level Audit

1. Get the source commit's diff: `git diff <source-commit>^..<source-commit>`
2. Get the cherry-pick result diff: `git diff HEAD^..HEAD`
3. Compare file-by-file:
   - **Extra files** (already flagged mechanically): revert with `git checkout HEAD^ -- <file>` and amend. No exceptions unless the file is a legitimate adaptation (new test file for the cherry-picked change).
   - **Extra hunks**: within a shared file, any hunk in the cherry-pick diff with no corresponding change in the source diff is a leak candidate. May be a legitimate adaptation (import path change for target) or an accidental pickup from an adjacent commit.
4. For each extra hunk, determine origin:
   ```bash
   git log --oneline --all -S "<leaked line>" -- <file>
   ```
   If it belongs to a different commit than the one being cherry-picked, it's a leak.

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
1. Confirm no conflict markers.
2. Run the smallest relevant build or type-check.
3. Run targeted tests covering the changed area.

For config-only changes (YAML, JSON, feature flags) where there is no build or test to run, validate by parsing the file programmatically and verifying the intended effect (load YAML and assert the expected keys/values are present).

Run broader validation when:
- the cherry-pick touched shared infrastructure
- the target branch differs materially from the source branch
- the targeted checks fail to provide confidence

## Minimum Validation Bar

**Python:**
- `ruff check <changed-files>` (or repo's lint command)
- `mypy <changed-files>` when the repo uses type checking

**JavaScript/TypeScript:**
- The repo's lint command (e.g., `npm run lint`)
- `tsc --noEmit` when the repo uses TypeScript

Discover commands from `package.json` scripts, `Makefile`, `pyproject.toml`, `setup.cfg`, or CI config. These checks are mandatory, not aspirational — if skipped, the validation status must reflect it.

## Validation Gap Flagging

When targeted tests exist and are runnable but were not executed, flag the gap — do not silently record a weaker status label. Include:
- what tests were available (e.g., "pytest tests/unit_tests/mcp_service/ covers the changed area")
- why they weren't run (time constraint, environment not set up)
- recommended follow-up ("run before merging")

Recording `Checked` or `Structural` when `Tested` was achievable without extraordinary effort is an undercount that must be called out. See [../gotchas.md](../gotchas.md).

## Dependency Manifest Rule

If the cherry-pick touches dependency manifests or lockfiles (`package.json`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `requirements.txt`, `setup.py`, `pyproject.toml`):

1. Do not treat validation as routine.
2. Treat manifest/lockfile changes detected during investigate as a validation escalation, not as a reason to reopen planning unless validation cannot proceed safely.
3. Prefer the repo's existing build, type-check, or CI verification commands over reinstalling dependencies locally.
4. Treat any rebuild or environment refresh as an intervention point unless the command is already the standard non-destructive verification path for this repo.
5. Run the smallest verification command that gives confidence, and surface when stronger validation would require rebuilding or environment changes.
6. For pip-compiled lockfiles (`requirements.txt` generated from `setup.py`/`pyproject.toml`): resolve the source file first, then decide whether to regenerate via `pip-compile` or resolve surgically. Surface the choice rather than guessing.

If the target branch uses a different package manager or lockfile than the source, stop and surface that mismatch.

## Validation Status Labels

Use these strictly in the execution table. Do not overstate:

| Label | Meaning |
|-------|---------|
| **Tested** | Build + targeted tests passed |
| **Checked** | Lint/type-check passed, no targeted tests run |
| **Build-only** | Build passed (pre-commit hooks or equivalent), no lint/type-check/test beyond that |
| **Structural** | Conflict markers clear, file parse OK, no lint/build/test run |
| **Not run** | No validation performed |

Never use "Clean" or "Validated" — they are ambiguous.

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
- the final validation status label (from the table) to record in the execution table
- remaining residual risk, if any
