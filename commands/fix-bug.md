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
/fix-bug sc-123 sc-456 sc-789                           # batch — parallel worktrees
/fix-bug "list: sc-123, apache/superset#28456, sc-789"  # batch — mixed refs
```

## Steps

1. **Normalize Input**

   Accept:
   - plain-language bug description
   - Shortcut story ID or URL
   - GitHub issue or PR reference / URL

   When a ticket URL or issue reference is provided, **fetch and parse it FIRST** before any code investigation. Extract the reproduction URL, affected page/area, and error description. These are authoritative — don't re-derive the affected area from scratch by scanning code.

   Pull in external context when references are provided.

   **Detect batch** — if multiple bug references are provided (multiple arguments, comma-separated list, or a ticket that links to several bugs):
   - **Single bug** → continue to step 2 (existing flow)
   - **Multiple bugs** → use the **Batch Path** section below

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

   Record lifecycle: `gate`

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
   - let the cherry-pick workflow own the branch movement
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

   Record lifecycle: `plan-complete`

12. **Exit Plan Mode → PROJECT.md**

   Read the plan file produced by plan mode. Write its content into PROJECT.md:
   - bug summary, repro status, affected area
   - upstream-fix status
   - validated RCA
   - fix approach with structured slices (from Architect)
   - QA test plan mapped to slices
   - action-gate outcome

   This is the first PROJECT.md write for the standard path. All findings collected during plan mode are flushed here.

12½. **Checkpoint Before Implementation**

   The plan→implement transition is the deepest context point — investigation findings, RCA, QA plans, and structured slices are all in memory. Check context depth per `rules/context-management.md`. If at or above ~70%, run `/checkpoint --commit --clear` before proceeding. After `/clear`, `/start` reloads PROJECT.md (which has the full plan from step 12) and resumes at step 13.

13. **Implement**

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
   - after all subagents complete, use `sync-workstreams.md` to collect results, update the slice status table in PROJECT.md, and merge worktree branches. Branch on its recommendation (`proceed-to-review` / `stop-for-failure` / `stop-for-conflict`).

   Record lifecycle: `impl-complete`

14. **QA Validates the Fix**

   Execute the QA test plan from step 11 against the implemented code:
   - Dev subagents already wrote unit/integration tests per-slice (from the QA test scenarios) — verify they exist and pass
   - Run `qa-execute-use-cases.md` for cross-slice integration scenarios
   - Use `qa-validate-fix.md` for scenarios that need live environment validation
   - If any test is missing, add it now — do not proceed to commit without regression coverage for the root cause

   Do not proceed to commit if no test was added or updated. If tests cannot run locally (missing Docker, env, data), write the test anyway and note the verification gap.

15. **Review Changed Files** (gate)

   Launch `/review-code` as a **subagent** (`model: "opus"`) with context isolation per `rules/orchestration.md`. Pass the merged diff, validated RCA, acceptance criteria, and QA test results from step 14.

   For multi-slice implementations: review the full merged diff. Per-slice exit criteria already verified each slice individually — this review checks the integrated result.

   **Classify review findings before looping:** Use `feedback-classify.md` to classify each finding as code-level or plan-level.
   - **Code-level** (logic, edge case, test gap): fix in the review loop as normal
   - **Plan-level** (RCA was incomplete, slice boundary wrong, fix scope too narrow/wide): route back to step 11 for re-planning rather than looping review

   If step 14 or the trivial path already assessed verification strength (STRONG/PARTIAL/WEAK), pass it to `/review-code` — do not re-run the same test discovery.

   Emit a Review Gate block per `rules/review-gate.md`. For truly minimal mechanical fixes, apply the skip rule.

   Record lifecycle: `review-gate`

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

   Record lifecycle: `command-complete`

## Batch Path

When step 1 detects multiple bugs, use this path instead of steps 2–17.

### B1. Triage for Shared Root Causes

Before dispatching, do a lightweight investigation of all bugs together:
- Fetch each bug's description, affected area, and error details
- Look for overlap: do multiple bugs reference the same file, component, or behavior?
- **Shared root cause** → group them into one fix (single `/fix-bug` run, not parallel)
- **Independent bugs** → dispatch in parallel

Output:

```markdown
## Bug Batch — [N] bugs

### Groups
| Group | Bugs | Reason | Strategy |
|-------|------|--------|----------|
| 1 | [refs] | Shared root cause: [description] | Single fix |
| 2 | [ref] | Independent | Parallel worktree |
| 3 | [ref] | Independent | Parallel worktree |
```

### B2. Write Batch Plan to PROJECT.md

Write the group table and tracking status:

```markdown
### Batch Status
| # | Bug | Group | Branch | Status |
|---|-----|-------|--------|--------|
| 1 | [ref] | 1 | `fix/[slug]` | pending |
| 2 | [ref] | 2 | `fix/[slug]` | pending |
```

### B3. Execute in Parallel

For each independent group, dispatch a subagent:

```
Agent(
  isolation: "worktree",
  model: "opus",
  prompt: "Read and follow {{TOOLKIT_DIR}}/commands/fix-bug.md for bug [ref].
    This is a single bug — use the standard flow (steps 1–17).
    You are the orchestrator for this bug: create your own PROJECT.md, investigate, fix, review, and commit.
    Create branch: fix/[slug].
    Return: branch name, commit SHAs, root cause summary, and any blockers."
)
```

Each subagent is a **full orchestrator** for its bug (nested orchestration per `rules/orchestration.md`).

For shared-root-cause groups: run as a single `/fix-bug` in one worktree with all grouped bugs as context.

**Concurrency**: Check resources per `rules/resource-management.md`. Typical limits: 2–3 parallel bugs with Docker running, 3–4 without.

### B4. Collect Results and Create PRs

After all subagents complete:
- Collect results (success/failure/blocked per bug)
- Run `/create-pr` for each successful fix branch
- Update batch status in PROJECT.md

### B5. Batch Summary

```markdown
## Fix-Bug Batch Complete

### Results
| Bug | PR | Root Cause | Status |
|-----|----|-----------|--------|
| [ref] | #[N] | [one-line RCA] | fixed |
| [ref] | — | [reason] | blocked |

### Remaining
- [Blocked bugs and what's needed to unblock them, or "None"]
```

Record lifecycle: `command-complete`

## Continuation Checkpoint

**Single-bug phases**: triage / complexity-gate / existing-fix-check / ui-repro / rca / action-gate / exit-plan-mode / checkpoint / implement / review / qa-validate / commit / summarize

**Batch phases**: normalize / triage-shared-causes / write-batch-plan / execute-parallel / collect-results / batch-summary

State (single bug):
- Complexity: <trivial / standard>
- Existing-fix status: <FIXED_UPSTREAM / FIX_PENDING_PR / UNFIXED>
- RCA status: <validated / pending / not needed>
- Review status: <clean / blocked / pending>
- Files changed so far: <files or none>
- Pending blockers or decisions: <if any>

State (batch):
- Mode: batch
- Bugs: <N total, N complete, N failed, N blocked>
- Groups: <N independent, N shared-root-cause>
- PRs created: <list or none>

## Cross-Repo Bugs

When the symptom is in repo A (e.g., CI failure in a downstream fork) but the fix goes in repo B (e.g., upstream):
- The verification target is repo A's CI, not repo B's local test suite
- Skip local test steps that cannot exercise the failure path (e.g., `pytest` in repo B when the failure only manifests with repo A's migrations or config)
- Note the cross-repo gap in the summary under "Open risks"
- If local tests in repo B can partially cover the fix (e.g., model introspection, type checks), still run them — partial coverage beats none

## Notes
- `/fix-bug` accepts single bugs or batches — batch detection is automatic based on input count
- Batch path: independent bugs run in parallel worktrees, shared-root-cause bugs are grouped into one fix
- `/fix-bug` is the public bug entrypoint; RCA-only work stays inside the internal investigation skills
- Keep `PROJECT.md` updates command-owned
- Prefer the open-PR or cherry-pick path over inventing a new fix
- Use test-first implementation by default; document why when the failing test cannot be written first
- `/review-code` is an internal phase here, not the expected next top-level user step
- Auto-commit only when this workflow implemented a fresh bug fix itself
- When resuming from a pre-built plan, enter at the implementation phase but still run review, QA, and pre-flight checks before declaring done
