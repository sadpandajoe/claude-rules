# /fix-ci - Fix CI Failures

@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: A CI build has failed and you want the repo-standard workflow to diagnose it, apply safe fixes, verify locally, and stop before commit.
> **Produces**: Failure classification, PROJECT.md update, safe fixes where appropriate, validation results, and a recommended commit action.

## Usage
```
/fix-ci <run-url>          # Fix a specific CI run
/fix-ci <pr-number>        # Fix latest CI run for a PR
/fix-ci <log-file>         # Fix from a local CI log file
/fix-ci <zip-file>         # Fix from a local CI artifact bundle
/fix-ci                    # Fix latest failed CI run for current branch
```

## Steps

1. **Normalize Input**

   Accept one of:
   - GitHub Actions run URL
   - PR number
   - local log file
   - local zip artifact bundle
   - no argument: latest failed run on current branch

2. **Gather CI Logs**

   Follow this decision tree to obtain failure logs:

   1. **Local file provided?** (log or zip from step 1)
      - YES → Use it. For zips, unzip and locate failing logs; split multi-job bundles into per-failure units.
      - NO → Continue.

   2. **`gh run view <run-id> --log-failed` produces output?**
      ```bash
      gh run list --branch <branch> --status failure --limit 1
      gh run view <run-id> --log-failed
      # Or from PR: gh pr checks <number> → gh run view <run-id> --log-failed
      ```
      - YES → Use it.
      - NO (empty output or no failures listed) → Continue.

   3. **Check-run or per-job logs available?**
      ```bash
      # Check-runs (failures may be at check-run level, not workflow-run level)
      gh api repos/{owner}/{repo}/commits/{sha}/check-runs \
        --jq '.check_runs[] | select(.conclusion == "failure")'

      # Per-job logs
      gh api repos/{owner}/{repo}/actions/runs/{run-id}/jobs \
        --jq '.jobs[] | select(.conclusion == "failure") | {id, name}'
      gh api repos/{owner}/{repo}/actions/jobs/{job-id}/logs
      ```
      - YES → Use them.
      - NO → Continue.

   4. **All methods failed** (or CI is external — Jenkins, GitLab, etc.)
      - Ask the user for a log file path or URL. Do not proceed to classification without actual log output.

3. **Classify Failures**

   For each failure:
   - identify the failing step
   - match known patterns where possible
   - produce a root-cause hypothesis
   - produce a narrow proposed fix
   - state local verification approach

4. **Complexity Gate**

   **Not-our-failure fast path**: If ALL classified failures are **Pre-existing / not-our-failure**, exit the workflow early — no fix/verify/review cycle. Emit:
   ```markdown
   ## Fix-CI Complete — Not Our Failure

   **Run**: [run URL]

   | Failure | Evidence |
   |---------|----------|
   | [failure name] | Not in diff; same failure on [base branch] run [link] |

   ### What to do next
   - Re-run the failed job if it's flaky, or file a separate issue for the pre-existing failure.
   - This branch's changes are not implicated.
   ```
   If SOME failures are ours and some are pre-existing, note the pre-existing ones and continue the workflow for the remaining failures.

   Evaluate each classified failure against the complexity signals, then emit the Complexity Gate block per `rules/complexity-gate.md`.

   Record lifecycle: `gate`

   Evaluate each classified failure against:

   | Signal | Trivial | Standard |
   |--------|---------|----------|
   | Failure pattern | Known-pattern matches (all mechanical) | Novel failure, or mixed mechanical + behavioral |
   | Files touched | 1-2 | 3+ or unclear |
   | Fix type | Mechanical (format, dep, config) | Logic or behavioral change |
   | Verification | STRONG or PARTIAL available | WEAK only |

   Examples — TRIVIAL: lint failure from trailing whitespace (1 file, mechanical fix). STANDARD: test fails due to race condition in async setup (requires understanding test lifecycle, 3+ files).

   **Trivial path**: all signals are in the Trivial column and confidence is 8/10 or higher. Execute the trivial path directly — do not enter standard-path steps 5–7:
   1. Apply the fix (step 8)
   2. Verify locally (step 9)
   3. Review gate — choose based on diff content:
      - **Zero logic diff** (formatting-only, lint-disable, import reorder): emit Review Gate directly with `Status: skipped` and reason. No `/review-code` invocation needed.
      - **Any other diff**: invoke `/review-code` — must produce Review Gate block.
   4. Update PROJECT.md (single update)
   5. Emit summary (step 11)

   **Standard path**: any signal is in the Standard column, or confidence is below 8/10. Continue to step 5.

5. **Update PROJECT.md**

   Record:
   - failing run or artifact source
   - failure summary
   - evidence
   - root-cause hypothesis
   - confidence and proposed next action

6. **Validate RCA When Needed**

   Use the shared RCA validator only when:
   - the failure is novel
   - confidence is below the auto-proceed threshold
   - multiple plausible root causes exist
   - the proposed fix changes behavior

7. **Run the Action Gate**

   Proceed automatically only when the gate says the fix is low-risk, high-confidence, and sufficiently verifiable.

8. **Apply Safe Fixes**

   If the gate allows automatic action (or the complexity gate routed here directly):
   - apply the narrow proposed fix
   - keep scope limited to the failing surface
   - hand off to `implement-change.md` only when code adaptation becomes non-mechanical

   Otherwise:
   - stop
   - present the diagnosis, uncertainty, and recommended next step

   **Commit strategy**: The default is to stop before commit and let the user decide. When the user requests fixes folded back into originating commits, follow the fixup+autosquash pattern in `rules/implementation.md` (Commit Strategy section).

   Record lifecycle: `impl-complete`

9. **Verify Locally**

10. **Review Changed Files** (gate)

   If repo-tracked files changed, invoke `/review-code` on the changed files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

   The developer emits a Review Gate block per `rules/review-gate.md`. Callers branch on Status: `clean`, `blocked`, `user decision`, `skipped`.

   For zero-logic diffs (formatting-only, lint-disable, import reorder), apply the skip rule from `rules/review-gate.md`.
   If the diff touches any logic, invoke `/review-code` — do not skip.

   Record lifecycle: `review-gate`

11. **Summary**
   **Full template** (standard path or trivial path with PARTIAL verification):
   ```markdown
   ## Fix-CI Complete
   [1-2 lines: what failed and what was fixed]

   ### Review
   - Rounds: [N] | Pre-flight: [pass/fail] | Status: [clean/blocked]

   ### What to do next
   - [Specific next action]

   ### Open risks
   - [Anything uncertain or untested]
   ```

   **Compact template** (trivial path + STRONG verification + review skipped or clean):
   ```markdown
   ## Fix-CI Complete
   [1 line: what failed → what was fixed] | Verification: STRONG | Review: skipped — [reason]
   Next: [specific next action]
   ```

   Record lifecycle: `command-complete`

## Continuation Checkpoint

Phases: gather-logs / classify / ownership-check / complexity-gate / rca / gate / apply / verify / review / summarize

State:
- Complexity: <trivial / standard>
- Failure summary: <current best classification>
- Gate result: <proceed / approval / stop>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>

## Notes
- Always read the actual failing log output — don't guess from job names alone
- Auto-fixing is a phase, not the contract; the command still stops before commit
- Keep PROJECT.md updates command-owned, not skill-owned
- If verification is weak or the root cause is ambiguous, stop instead of widening scope
- `/review-code` is an internal phase here, not the expected next top-level user step
