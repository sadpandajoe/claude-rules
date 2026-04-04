# /fix-bug - End-to-End Bug Workflow

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: You have a bug report and want the repo-standard workflow to triage it, check whether it is already fixed upstream or pending in a PR, implement a safe fix when needed, and finish the local bug-fix flow end to end.
> **Produces**: Triage notes, upstream-status decision, validated RCA, implemented fix when appropriate, review and QA results, and either an automatic `fix:` commit or a handoff to the user.

## Plan Mode Usage

Steps 1–2 (normalize input, complexity gate) happen **before** plan mode in normal mode. The complexity gate must be visible in conversation, and a TRIVIAL result skips plan mode entirely.

**Standard path**: After the complexity gate, enter plan mode for investigation and planning (steps 3–10). Let plan mode's natural phases drive the work, seeded with this command's requirements:

| Plan mode phase | `/fix-bug` work |
|-----------------|----------------|
| **Explore** | Early lanes — triage, investigate, check existing fix, prepare env (steps 3–5) |
| **Design** | Branch on existing-fix status, validate RCA (steps 6–9) |
| **Review** | Action gate — risk, confidence, verification strength (step 10) |
| **Final Plan** | Produce plan file with: RCA, fix approach, test strategy, validation plan |

On exit, plan mode produces a plan file. Step 11 reads it: flush findings to PROJECT.md, then implement, review, QA, commit.

**Trivial path**: Do not enter plan mode. Go straight to implementation.

**Exit trigger**: When the action gate (step 10) says "proceed" or "plan first," exit plan mode immediately — the next steps require file writes. If it says "stop and escalate," exit plan mode and surface the decision to the user.

## Usage
```
/fix-bug "saving settings fails on Safari"
/fix-bug sc-12345
/fix-bug apache/superset#28456
/fix-bug https://github.com/owner/repo/issues/123
/fix-bug https://app.shortcut.com/.../story/123
```

## Steps

1. **Normalize Input**

   Accept:
   - plain-language bug description
   - Shortcut story ID or URL
   - GitHub issue or PR reference / URL

   When a ticket URL or issue reference is provided, **fetch and parse it FIRST** before any code investigation. Extract the reproduction URL, affected page/area, and error description. These are authoritative — don't re-derive the affected area from scratch by scanning code.

   Pull in external context when references are provided.

2. **Complexity Gate**

   Assess the bug before launching investigation lanes:

   | Signal | Trivial | Standard |
   |--------|---------|----------|
   | Root cause | Obvious from report | Needs investigation |
   | Files touched | 1–2 | 3+ or unclear |
   | Fix type | Typo, config, off-by-one | Logic, architecture |
   | Regression risk | Isolated, testable | Cross-cutting |

   Examples — TRIVIAL: error message has a typo (`settngs` → `settings`), one file, no logic change. STANDARD: dashboard filter applies to wrong panel — requires tracing filter propagation across 4+ files.

   Emit the Complexity Gate block per `rules/complexity-gate.md`.

   **Trivial + confidence 8/10+**: Execute the trivial path directly — do not enter standard-path steps 3–10:
   1. Write the regression test (test-first when feasible) — even for 1-line fixes, a cheap assertion (model introspection, config check, type guard) is worth writing if it catches future drift
   2. Implement the fix — do not enter plan mode for trivial fixes; go straight to the edit
   3. Run the actual test suite covering the changed files (e.g., `pytest -k ...`, `jest --testPathPattern ...`) — pre-commit alone is not sufficient. Record the result:
      - **STRONG**: test suite ran and passes
      - **PARTIAL**: related checks ran but not the exact suite
      - **WEAK**: tests could not run locally (missing Docker, env, data) — note why
      `/review-code` inherits this assessment — do not re-discover the same limitation there.
   4. `/review-code` — developer emits a Review Gate block per `rules/review-gate.md`
   5. Commit the fix (step 16)
   6. Update PROJECT.md (single update)
   7. Emit summary (step 17)

   The review gate is mid-workflow — see Continuation Rule in `rules/review-gate.md`.

   **Micro-fix** (subset of trivial): per the micro-fix rule in `rules/review-gate.md`, emit `Status: micro-fix` with the diff inlined — no iterative loop needed.
   - PROJECT.md update is optional if no PROJECT.md exists and the workflow completes in a single pass

   **Standard**: Continue to step 3.

3. **Launch Early Lanes**

   These tracks are independent and can run together:
   - `qa-triage-bug.md` for first-pass triage and repro requirements
   - `investigate-bug.md`
   - `check-existing-fix.md`
   - `prepare-environment.md` when UI or workflow validation is likely

   Determine whether to spin up subagents (via the Agent tool) for parallel investigation or run the lanes sequentially in the main thread. Subagents are worth it when multiple lanes involve non-trivial work (e.g., code investigation + upstream scan + environment prep). For simpler bugs, sequential in the main thread is fine.

   When using subagents, pass each one the bug context (ticket summary, affected area, branch) and the relevant skill file. Collect the normalized output blocks before proceeding to step 4.

4. **Sync the Early Findings**

   Merge the outputs from QA, developer, and the existing-fix check.
   For UI and workflow bugs, treat QA repro as a two-stage flow:
   - first-pass triage from the report and available evidence
   - full reproduction once the local app or target environment is ready

   Track the merged findings in conversation (plan mode prevents file writes):
   - bug summary
   - repro status
   - likely affected area
   - upstream-fix status
   - intended next action

5. **Re-Sync Once UI Repro Is Runnable**

   For UI and workflow bugs:
   - wait for environment prep to make the app runnable when possible
   - have QA re-run the repro with Playwright MCP
   - record the stronger repro result in conversation before moving into RCA

6. **Branch on Existing-Fix Status**

   The shared helper returns one of:
   - `FIXED_UPSTREAM`
   - `FIX_PENDING_PR`
   - `UNFIXED`

   Also allow the workflow to stop early if QA concludes the report is not a bug.
   If QA cannot reproduce but production evidence is strong, continue as a plausible bug with lower confidence and a stricter action gate.

7. **Stop Early When No Code Change Is Needed**

   If QA cannot reproduce and evidence is weak:
   - stop with the missing evidence called out clearly

   If the helper returns `FIX_PENDING_PR`:
   - stop with the PR reference and recommendation to monitor, adopt, or supersede it
   - do not auto-review or merge it inside `/fix-bug`

8. **Route to Cherry-Pick When the Fix Exists Upstream**

   If the helper returns `FIXED_UPSTREAM`:
   - route internally to `/cherry-pick`
   - let `release-engineer` own the branch movement
   - return to this workflow for validation, `/review-code`, and final summary
   - do not auto-commit after the cherry-pick path; let the user decide whether any follow-up should be amended or added separately

9. **Validate the RCA for Unfixed Bugs**

   For `UNFIXED` issues:
   - validate the diagnosis with the shared RCA reviewer

10. **Run the Action Gate**

   Decide whether to:
   - fix directly now
   - do internal planning first
   - stop for ambiguity or risk

11. **Plan Fix + QA in Parallel**

   Once RCA is validated and the action gate says proceed, launch two workstreams together:

   **Architect**: Use `plan-change.md` to produce structured slices with scope, entrance/exit criteria, and acceptance. The RCA tells the Architect *what* to fix; the slices define *how*.

   **QA**: Use `qa-analyze-use-cases.md` to derive test scenarios from the validated RCA — what behaviors should the fix restore? What edge cases surround the root cause? Use `qa-expand-scenarios.md` to identify adjacent flows that might be affected. Produce a test plan that maps scenarios to the fix slices.

   QA doesn't need the slices to plan — it needs the RCA. The Architect doesn't need the test plan to slice — it needs the RCA. Both consume the RCA, both produce criteria. Running them in parallel means devs get both the slice definitions AND the test plan before writing code.

12. **Exit Plan Mode → PROJECT.md**

   Read the plan file produced by plan mode. Write its content into PROJECT.md:
   - bug summary, repro status, affected area
   - upstream-fix status
   - validated RCA
   - fix approach with structured slices (from Architect)
   - QA test plan mapped to slices
   - action-gate outcome

   This is the first PROJECT.md write for the standard path. All findings collected during plan mode are flushed here.

13. **Implement Through `developer`**

   Dev subagents get both the slice context AND the QA test scenarios — they know exactly what tests to write (TDD from the QA plan).

   Before changing the code:
   - define the regression this fix must catch
   - write or update the failing test first when feasible
   - if test-first is blocked by repro, env, or harness constraints, write the test anyway and record the verification gap — writing is separate from running
   - for mechanical changes (renames, config swaps, off-by-one with no new logic), writing tests alongside the implementation is acceptable — record why test-first was skipped

   Before removing or renaming any public function, method, class, or API endpoint, check for callers outside the immediate fix scope. Removing a method that other code depends on is a breaking change — raise it as a decision for the user rather than treating it as cleanup.

   For direct fixes:
   - use `implement-change.md`

   For non-trivial fixes (slices already produced in step 11):
   - dispatch slices through `implement-change.md`:
     - **Independent slices**: launch as parallel subagents with `isolation: "worktree"`, each verifying its own exit criteria and committing on the worktree's temp branch
     - **Sequential slices**: implement in dependency order
     - **Single slice**: implement as one unit (no worktree needed)
   - after all slices complete, merge worktree branches back one at a time in dependency order. If a merge conflict occurs, stop and surface it.

14. **QA Validates the Fix**

   Execute the QA test plan from step 11 against the implemented code:
   - Dev subagents already wrote unit/integration tests per-slice (from the QA test scenarios) — verify they exist and pass
   - Run `qa-execute-use-cases.md` for cross-slice integration scenarios
   - Use `qa-validate-fix.md` for scenarios that need live environment validation
   - If any test is missing, add it now — do not proceed to commit without regression coverage for the root cause

   Do not proceed to commit if no test was added or updated. If tests cannot run locally (missing Docker, env, data), write the test anyway and note the verification gap.

15. **Review Changed Files** (gate)

   For multi-slice implementations: review the full merged diff. Per-slice exit criteria already verified each slice individually — this review checks the integrated result.

   Run `/review-code` on changed repo-tracked files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

   If step 14 or the trivial path already assessed verification strength (STRONG/PARTIAL/WEAK), pass it to `/review-code` — do not re-run the same test discovery.

   The developer emits a Review Gate block per `rules/review-gate.md`. Callers branch on Status: `clean`, `blocked`, `user decision`, `skipped`, `micro-fix`.

   For truly minimal mechanical fixes (typo, config value, lint-disable), the review loop may be skipped per the skip rule in `rules/review-gate.md`.

   Do not skip this step when resuming from a pre-built plan.

   After the review gate passes, continue to steps 16–17 — see Continuation Rule in `rules/review-gate.md`.

16. **Commit New Bug Fixes**

   If this workflow implemented a new fix itself:
   - create a normal `fix:` commit after review and validation pass

   If this workflow routed through cherry-pick:
   - do not auto-commit beyond the cherry-pick result
   - leave any follow-up amend or extra-commit decision to the user

17. **Summary** (PM wrap-up)

   Lead with the answer to the user's original question — not the implementation details. If the user asked "did X break things?", answer that first. Technical details go in a collapsible section or are omitted unless the user asked for them.

   ```markdown
   ## Fix-Bug Complete
   [1-2 lines answering the user's original question, then: what fixed it, confidence level]

   ### What was fixed
   - [Specific behavior change — what the user or system does differently now]

   ### Verify manually
   - [Things automated tests can't cover — live integration, UI rendering, environment-specific behavior]
   - [Omit section if everything is covered by automated tests]

   ### Key decisions
   - [Non-obvious choices made during investigation or fix — e.g., fix layer, scope boundary, alternative approaches rejected]
   - [Omit section for straightforward fixes with no meaningful alternatives]

   ### What to do next
   - [Specific next action — PR link, CI re-run, merge step]

   ### Open risks
   - [Anything uncertain or untested — omit section if none]

   <details><summary>Technical details</summary>

   - Root cause: [brief]
   - Fix: [what changed]
   - Files changed: [list]
   - Review: Rounds [N] | Status [clean/blocked]

   </details>
   ```

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:

**Standard path:**
- **step 11** — after exiting plan mode, flush all investigation findings (triage, RCA, upstream status, action-gate outcome) into PROJECT.md. This is the first write.
- after implementation, review, and QA validation
- at final completion with the branch outcome and commit result

Record the smallest useful status refresh each time. Do not wait until the end if the workflow has materially advanced.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /fix-bug <arguments>
- Phase: triage / complexity-gate / existing-fix-check / ui-repro / rca / action-gate / exit-plan-mode / implement / review / qa-validate / commit / summarize
- Resume target: <issue, PR, repro path, file set, or current validation target>
- Completed items: <finished phases or decisions already locked in>
### State
- Complexity: <trivial / standard>
- Existing-fix status: <FIXED_UPSTREAM / FIX_PENDING_PR / UNFIXED>
- RCA status: <validated / pending / not needed>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>
```

## Cross-Repo Bugs

When the symptom is in repo A (e.g., CI failure in a downstream fork) but the fix goes in repo B (e.g., upstream):
- The verification target is repo A's CI, not repo B's local test suite
- Skip local test steps that cannot exercise the failure path (e.g., `pytest` in repo B when the failure only manifests with repo A's migrations or config)
- Note the cross-repo gap in the summary under "Open risks"
- If local tests in repo B can partially cover the fix (e.g., model introspection, type checks), still run them — partial coverage beats none

## Notes
- `/fix-bug` is the public bug entrypoint; RCA-only work now stays inside the internal `developer` and `core` helpers
- Keep `PROJECT.md` updates command-owned
- Prefer the open-PR or cherry-pick path over inventing a new fix
- Use test-first implementation by default; document why when the failing test cannot be written first
- `/review-code` is an internal phase here, not the expected next top-level user step
- Auto-commit only when this workflow implemented a fresh bug fix itself
- When resuming from a pre-built plan, enter at the implementation phase but still run review, QA, and pre-flight checks before declaring done
