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
   ```bash
   # Get failed run
   gh run list --branch <branch> --status failure --limit 1
   gh run view <run-id> --log-failed

   # Or from PR
   gh pr checks <number>
   gh run view <run-id> --log-failed
   ```

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

4. **Update PROJECT.md**

   Record:
   - failing run or artifact source
   - failure summary
   - evidence
   - root-cause hypothesis
   - confidence and proposed next action

5. **Validate RCA When Needed**

   Use the shared RCA validator only when:
   - the failure is novel
   - confidence is below the auto-proceed threshold
   - multiple plausible root causes exist
   - the proposed fix changes behavior

   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-rca/SKILL.md

6. **Run the Action Gate**

   @/Users/joeli/opt/code/ai-toolkit/skills/shared/action-gate.md

   Proceed automatically only when the gate says the fix is low-risk, high-confidence, and sufficiently verifiable.

7. **Apply Safe Fixes**

   If the gate allows automatic action:
   - apply the narrow proposed fix
   - keep scope limited to the failing surface
   - hand off to `developer` only when code adaptation becomes non-mechanical

   Otherwise:
   - stop
   - present the diagnosis, uncertainty, and recommended next step

8. **Verify Locally** (`build-engineer`)

   @/Users/joeli/opt/code/ai-toolkit/skills/build-engineer/verify-fix.md

9. **Review Changed Files**

   If repo-tracked files changed, invoke `/review-code` on the changed files before presenting the result.

10. **Summary**
   ```markdown
   ## Fix-CI Complete

   ### Run: [run-id / url]
   ### Branch: [branch]

   ### Failure Summary
   - [What failed and why]

   ### Changes Applied
   - [What was changed]

   ### Verification
   - [What was run locally]
   - [Verification strength]

   ### Review-Code
   - [Rounds run or skipped]

   ### Commit Recommendation
   - Recommend: `new commit` / `amend HEAD`
   - Do not commit automatically
   ```

## Notes
- Always read the actual failing log output — don't guess from job names alone
- Auto-fixing is a phase, not the contract; the command still stops before commit
- Keep PROJECT.md updates command-owned, not skill-owned
- If verification is weak or the root cause is ambiguous, stop instead of widening scope
