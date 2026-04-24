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

   If `gh run view --log-failed` returns empty output (exit 0 but no log lines), fall back to per-job logs:
   ```bash
   # List jobs for the run
   gh api repos/{owner}/{repo}/actions/runs/{run-id}/jobs \
     --jq '.jobs[] | select(.conclusion == "failure") | {id, name}'

   # Fetch logs for each failed job
   gh api repos/{owner}/{repo}/actions/jobs/{job-id}/logs
   ```

   If `gh` commands fail or CI is external (Jenkins, GitLab, etc.):
   - Check whether a local log file or zip bundle was provided in step 1.
   - If yes, use that file as the log source.
   - If no, ask the user for a log file path or URL. Do not proceed to classification without actual log output.

   If the input is a zip bundle:
   - unzip it automatically
   - locate the failing logs
   - split multi-job bundles into per-failure units before classification

3. **Classify Failures**

   The orchestrator classifies failures inline by default — no subagent needed for most CI failures. Read the gathered logs and:
   - identify the failing step for each failure
   - match known patterns where possible
   - produce a root-cause hypothesis per failure
   - produce a narrow proposed fix per failure
   - state local verification approach
   - rate each failure against the complexity signals in step 4

   **Spawn a triage subagent** (`model: "sonnet"`, `subagent_type: "general-purpose"`) only when:
   - Multiple independent failures need parallel analysis
   - Logs are very large (>500 lines) and need focused extraction
   - The failure pattern is novel and benefits from isolated reasoning

   Expected classification shape:
   ```
   failures:
     - name: <failing job/step>
       root_cause: <hypothesis>
       fix: <narrow proposed change>
       verification: <how to verify locally>
       complexity: trivial | moderate | standard
       confidence: <0-10>
       ours: true | false  # is this caused by our diff
   notes: <any cross-failure context>
   ```

   Commit to a classification rather than punt. If genuinely blocked (e.g., logs are missing the actual error), surface the specific question to the user.

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

   Evaluate each classified failure against:

   | Signal | Trivial | Moderate | Standard |
   |--------|---------|----------|----------|
   | Failure pattern | Known-pattern (all mechanical) | Known-pattern but behavioral | Novel or mixed |
   | Files touched | 1–2 | 2–4, single subsystem | 3+ or unclear scope |
   | Fix type | Mechanical (format, dep, config) | Logic change, known pattern | Behavioral, cross-cutting |
   | Verification | STRONG or PARTIAL available | STRONG or PARTIAL available | WEAK only |

   **Trivial path**: all signals are in the Trivial column and confidence is 8/10 or higher. Auto-proceed — do not ask the user for confirmation; execute the trivial path directly without entering standard-path steps 5–7:
   1. Apply the fix (step 8)
   2. Verify locally (step 9)
   3. Review gate — choose based on diff content:
      - **Zero logic diff** (formatting-only, lint-disable, import reorder): emit Review Gate directly with `Status: skipped` and reason. No `/review-code` invocation needed.
      - **Any other diff**: invoke `/review-code` — must produce Review Gate block.
   4. Update PROJECT.md (single update)
   5. Emit summary (step 11)

   **Moderate path**: signals are in the Moderate column and confidence is 8/10 or higher. Orchestrator works inline — no planning subagent:
   1. Plan the fix inline (orchestrator reasons about approach in conversation)
   2. Apply the fix (step 8)
   3. Verify locally (step 9)
   4. `/review-code` — still spawns a reviewer subagent (never review your own work)
   5. Update PROJECT.md (single update)
   6. Emit summary (step 11)

   If the fix turns out more complex than expected during inline planning, escalate to STANDARD.

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

   - **Trivial path** (mechanical fix, high confidence): orchestrator applies the proposed fix inline. No additional subagent.
   - **Standard path** (non-mechanical fix, multi-file, or behavioral change): spawn a planning subagent (Agent tool, `subagent_type: "general-purpose"`). Choose the model per `rules/orchestration.md` based on the actual planning load:
     - `model: "sonnet"` when the fix is non-mechanical but well-scoped (e.g., behavioral change confined to one module, or standard-path was triggered only by weak local verification).
     - `model: "opus"` when the fix involves real trade-offs across files/systems, or the root cause is still partially ambiguous.

     Pass the subagent the classification, RCA findings, gate result, and constraint that the plan must stay scoped to the failing surface. It returns a fix plan with file-level granularity and flags any cross-cutting concerns. The **orchestrator applies the plan** — the subagent does not edit files.

   Keep scope limited to the failing surface in either path.

   Otherwise:
   - stop
   - present the diagnosis, uncertainty, and recommended next step

   **Commit strategy**: Branch on fix type and verification strength:

   | Scenario | Action |
   |----------|--------|
   | Lint/style only, cherry-pick flow | Amend into the breaking cherry-pick commit + force-push |
   | Lint/style only, single parent commit clear | Amend + force-push feature branch |
   | Lint/style only, multiple parent commits | `style:` commit + push |
   | Trivial code fix + STRONG verification | New commit + push |
   | Standard path or PARTIAL/WEAK verification | Stop before commit — present diagnosis and recommended next step |

   **Detecting cherry-pick flow**: Check `git log --grep="cherry picked from commit"` on recent branch commits. If cherry-picked commits are present, trace which one last touched the lint-failing files (`git log -- <file>` filtered to cherry-picked SHAs) — that is the commit to amend into, not necessarily the latest.

   **Force-push safety**: Force-push is only permitted on the current feature branch, never on main/master or shared branches.

   **Amend mechanics**: Use the fixup+autosquash pattern when amending a non-tip commit:
   ```bash
   git commit --fixup=<originating-sha>
   git rebase --autosquash <base>
   ```

   Pre-commit hook warning: when staging files for commit A's fixup, hooks stash unstaged changes (including commit B's fix) and run checks against the incomplete state. Commit fixups in dependency order — fix the earliest commit first so later commits see clean state.

9. **Verify Locally** (`build-engineer`)

10. **Review Changed Files** (gate)

   If repo-tracked files changed, invoke `/review-code` on the changed files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

   The developer emits a Review Gate block per `rules/review-gate.md`. Callers branch on Status: `clean`, `blocked`, `user decision`, `skipped`.

   For zero-logic diffs (formatting-only, lint-disable, import reorder), apply the skip rule from `rules/review-gate.md`.
   If the diff touches any logic, invoke `/review-code` — do not skip.

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

   **Record metrics**: include `metrics-emit` context with:
   - `command`: `fix-ci`
   - `complexity`: classification from the complexity gate (`trivial` / `moderate` / `standard`)
   - `status`: outcome from the Review Gate (`clean` / `blocked` / `user-decision` / `skipped` / `micro-fix`)
   - `rounds`: total review iteration rounds
   - `gate_decisions`: `{ complexity: <gate>, action_gate: <gate>, review: <gate>, verification_strength: <STRONG | PARTIAL | WEAK> }`
   - `models_used`: subagent model invocation counts

## PROJECT.md Update Discipline

**Standard path** — update `PROJECT.md` at these points:
- after log collection and initial failure classification
- after RCA validation when that path runs
- after the action gate determines whether the fix will proceed automatically
- after local verification and `/review-code`
- at final completion with verification strength and commit recommendation

Keep the updates compact, but do not defer all state changes to the end of the workflow.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /fix-ci <arguments>
- Phase: gather-logs / classify / ownership-check / complexity-gate / rca / gate / apply / verify / review / summarize
- Resume target: <run id, artifact, failing job, or changed file set>
- Completed items: <finished phases or already-fixed failures>
### State
- Complexity: <trivial / moderate / standard>
- Failure summary: <current best classification>
- Gate result: <proceed / approval / stop>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>
```

## Notes
- Always read the actual failing log output — don't guess from job names alone
- Auto-fixing is a phase, not the contract; trivial fixes with STRONG verification commit and push automatically — standard-path and weak-verification fixes still stop before commit
- Keep PROJECT.md updates command-owned, not skill-owned
- If verification is weak or the root cause is ambiguous, stop instead of widening scope
- `/review-code` is an internal phase here, not the expected next top-level user step
