# /fix-ci - Fix CI Failures

@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: A CI build has failed and you want the repo-standard workflow to diagnose it, apply safe fixes, verify locally, and stop before commit when risk remains.
> **Produces**: Failure classification, PROJECT.md update, safe fixes where appropriate, validation results, Review Gate status, and a recommended commit action.

## Usage
```
/fix-ci <run-url>          # Fix a specific CI run
/fix-ci <pr-number>        # Fix latest CI run for a PR
/fix-ci <log-file>         # Fix from a local CI log file
/fix-ci <zip-file>         # Fix from a local CI artifact bundle
/fix-ci                    # Fix latest failed CI run for current branch
```

## Command Contract

- Read actual failing log output before classifying.
- Keep raw logs out of chat when they are large; use log paths and compact excerpts.
- For 3+ failed jobs, artifact bundles, or large logs, create local `CI_FIX.md` via [skills/debug/templates/ci-fix-manifest.md](../skills/debug/templates/ci-fix-manifest.md).
- Group failures by root cause before fixing.
- Keep fixes scoped to the failing surface.
- Run local verification before review, and emit a Review Gate block whenever repo-tracked files changed.
- Update PROJECT.md at standard-path boundaries.
- The main thread owns `CI_FIX.md` and PROJECT.md. Subagents return compact handoffs; they do not update durable state directly.
- Do not commit, amend, rebase, push, or force-push unless the user explicitly authorized that git boundary for this run.
- For STANDARD or expensive CI work, checkpoint/clear after `CI_FIX.md` or PROJECT.md captures classification/grouping, after Action Gate/RCA decisions, after local verification, and after `/review-code` when commit recommendation work remains.

## Happy Paths

- **Trivial**: gather logs, classify/group, apply the safe fix inline, verify locally, emit Review Gate `skipped`/`micro-fix` only when the Review Gate exception applies, update PROJECT.md when useful, summarize.
- **Moderate**: gather logs, classify/group, plan inline, apply inline by default, verify locally, run `/review-code`, update PROJECT.md, summarize.
- **Standard**: create/update `CI_FIX.md` when useful, checkpoint/clear, validate RCA when needed, run Action Gate, checkpoint/clear, apply only if the gate allows it, verify locally, review, then present commit recommendation.

## Steps

### 1. Normalize Input

Accept a GitHub Actions run URL, PR number, local log file, local zip artifact bundle, or no argument. With no argument, resolve the latest failed run for the current branch.

### 2. Gather Logs

Follow [skills/debug/references/ci-gather-logs.md](../skills/debug/references/ci-gather-logs.md).

Stop if no actual log output or artifact source can be resolved.
For Jenkins or authenticated external CI, stop after the first auth failure and ask for a log excerpt/artifact instead of reasoning from the dashboard.

### 3. Classify + Group Failures

Use [skills/debug/references/ci-classify-failure.md](../skills/debug/references/ci-classify-failure.md) for log classification.

Then load [skills/debug/references/ci-fix-orchestration.md](../skills/debug/references/ci-fix-orchestration.md) for grouping, ours/pre-existing classification, complexity routing, and commit recommendation strategy. Do not load the full orchestration reference before real logs exist.

If all failures are pre-existing or not caused by this branch, exit early with evidence and no fix/review cycle.

### 4. Complexity Gate

Emit the Complexity Gate block per `rules/complexity-gate.md`.

Route using the CI-specific matrix in [skills/debug/references/ci-fix-orchestration.md](../skills/debug/references/ci-fix-orchestration.md):
- **Trivial**: apply, verify, Review Gate skip/micro-fix only when allowed, update PROJECT.md when useful, summarize.
- **Moderate**: plan inline, apply, verify locally, then `/review-code`, update PROJECT.md, summarize.
- **Standard**: update PROJECT.md, validate RCA when needed, run Action Gate, then apply only if the gate allows it.

### 5. Apply Safe Fixes

Apply only the fix path selected by the grouped classification. For standard-path planning, use a bounded planning subagent only when it materially improves isolation or reasoning; the orchestrator applies the final patch.

### 6. Verify Locally

Follow [skills/debug/references/ci-verify-fix.md](../skills/debug/references/ci-verify-fix.md) and record verification strength as `STRONG`, `PARTIAL`, or `WEAK`.

### 7. Review Changed Files

If repo-tracked files changed, invoke `/review-code` on the changed files as an internal loop after local verification.

For zero-logic diffs, apply the skip rule from `rules/review-gate.md`. For true micro-fixes, apply the micro-fix rule only when relevant checks/tests pass. If any logic changed beyond micro-fix scope, do not skip `/review-code`.

### 8. Commit Recommendation

Use the commit recommendation strategy in [skills/debug/references/ci-fix-orchestration.md](../skills/debug/references/ci-fix-orchestration.md).

Do not commit standard-path or PARTIAL/WEAK fixes automatically. Do not commit, amend, rebase, push, or force-push any fix unless the user explicitly authorized that git boundary for this run. Present the diagnosis, verification gap, and recommended next action.

### 9. Summary + Metrics

Use the summary shapes in [skills/debug/references/ci-fix-orchestration.md](../skills/debug/references/ci-fix-orchestration.md).

Record metrics with:
- `command`: `fix-ci`
- `complexity`: `trivial` / `moderate` / `standard`
- `status`: Review Gate status
- `rounds`: total review iteration rounds
- `gate_decisions`: complexity, action gate, review, verification strength
- `worker_usage`: subagent/worker invocation counts when applicable

## PROJECT.md Update Discipline

Standard path updates PROJECT.md:
- after log collection and initial failure classification
- after RCA validation when it runs
- after the Action Gate
- after local verification and `/review-code`
- at final completion with verification strength and commit recommendation

Keep updates compact. If `CI_FIX.md` exists, PROJECT.md should point to it rather than duplicating its table.
