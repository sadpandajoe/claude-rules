# /fix-ci - Fix CI Failures

@/Users/joeli/opt/code/ai-toolkit/rules/implementation.md
@/Users/joeli/opt/code/ai-toolkit/skills/build-engineer/SKILL.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md

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

   Try `gh` first:
   ```bash
   # Get failed run
   gh run list --branch <branch> --status failure --limit 1
   gh run view <run-id> --log-failed

   # Or from PR
   gh pr checks <number>
   gh run view <run-id> --log-failed
   ```

   If `gh run list` returns no failures, check the check-runs endpoint — failures may be at the check-run level rather than the workflow-run level:
   ```bash
   gh api repos/{owner}/{repo}/commits/{sha}/check-runs \
     --jq '.check_runs[] | select(.conclusion == "failure")'
   ```

   If `gh` commands fail or CI is external (Jenkins, GitLab, etc.):
   - Check whether a local log file or zip bundle was provided in step 1.
   - If yes, use that file as the log source.
   - If no, ask the user for a log file path or URL. Do not proceed to classification without actual log output.

   If the input is a zip bundle:
   - unzip it automatically
   - locate the failing logs
   - split multi-job bundles into per-failure units before classification

3. **Classify Failures** (`build-engineer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/build-engineer/classify-failure.md

   For each failure:
   - identify the failing step
   - match known patterns where possible
   - produce a root-cause hypothesis
   - produce a narrow proposed fix
   - state local verification approach

4. **Complexity Gate**

   Evaluate each classified failure against:

   | Signal | Trivial | Standard |
   |--------|---------|----------|
   | Failure pattern | Known-pattern matches (all mechanical) | Novel failure, or mixed mechanical + behavioral |
   | Files touched | 1-2 | 3+ or unclear |
   | Fix type | Mechanical (format, dep, config) | Logic or behavioral change |
   | Verification | STRONG or PARTIAL available | WEAK only |

   **Trivial path**: all signals are in the Trivial column and confidence is 8/10 or higher. Execute the trivial path directly — do not enter standard-path steps 5–7:
   1. Apply the fix (step 8)
   2. Verify locally (step 9)
   3. `/review-code` — must produce Review Gate block (this is not optional)
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

   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-rca/SKILL.md

7. **Run the Action Gate**

   @/Users/joeli/opt/code/ai-toolkit/skills/shared/action-gate.md

   Proceed automatically only when the gate says the fix is low-risk, high-confidence, and sufficiently verifiable.

8. **Apply Safe Fixes**

   If the gate allows automatic action (or the complexity gate routed here directly):
   - apply the narrow proposed fix
   - keep scope limited to the failing surface
   - hand off to `developer` only when code adaptation becomes non-mechanical

   Otherwise:
   - stop
   - present the diagnosis, uncertainty, and recommended next step

   **Commit strategy**: The default is to stop before commit and let the user decide. When the user requests fixes folded back into originating commits, use the fixup+autosquash pattern:
   ```bash
   git commit --fixup=<originating-sha>
   # repeat for each originating commit
   git rebase --autosquash <base>
   ```

   Pre-commit hook warning: when staging files for commit A's fixup, hooks stash unstaged changes (including commit B's fix) and run checks against the incomplete state. Commit fixups in dependency order — fix the earliest commit first so later commits see clean state.

9. **Verify Locally** (`build-engineer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/build-engineer/verify-fix.md

10. **Review Changed Files** (gate)

   If repo-tracked files changed, invoke `/review-code` on the changed files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

   This step is a gate — `/review-code` must produce its Review Gate block before the workflow can proceed. If the block is missing, the review has not been completed.

   For truly minimal mechanical fixes (lint-disable comments, import reordering, duplicate removal), the review loop may be skipped — but the Review Gate block must still be emitted with `Status: skipped` and a reason:
   ```markdown
   ## Review Gate
   Rounds: 0
   Pre-flight: pass
   Status: skipped — [reason, e.g. "lint-disable additions only, no logic changes"]
   ```

11. **Summary**
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

## PROJECT.md Update Discipline

**Standard path** — update `PROJECT.md` at these points:
- after log collection and initial failure classification
- after RCA validation when that path runs
- after the action gate determines whether the fix will proceed automatically
- after local verification and `/review-code`
- at final completion with verification strength and commit recommendation

**Trivial path** — single `PROJECT.md` update after implementation, verification, and `/review-code` are all complete.

**No PROJECT.md** — if no `PROJECT.md` exists and the workflow completes in a single pass without blockers, creating one is not required. Note the skip in the summary.

Keep the updates compact, but do not defer all state changes to the end of the workflow.

## Continuation Checkpoint

If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /fix-ci <arguments>
- Phase: gather-logs / classify / complexity-gate / rca / gate / apply / verify / review / summarize
- Resume target: <run id, artifact, failing job, or changed file set>
- Completed items: <finished phases or already-fixed failures>
### State
- Complexity: <trivial / standard>
- Failure summary: <current best classification>
- Gate result: <proceed / approval / stop>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>
```

After writing the checkpoint:
- run `/clear`
- run `/start`
- resume `/fix-ci` at the saved phase and target

Use `/update-project-file --checkpoint ...` only when you need a manual checkpoint outside the normal flow.

## Notes
- Always read the actual failing log output — don't guess from job names alone
- Auto-fixing is a phase, not the contract; the command still stops before commit
- Keep PROJECT.md updates command-owned, not skill-owned
- If verification is weak or the root cause is ambiguous, stop instead of widening scope
- `/review-code` is an internal phase here, not the expected next top-level user step
