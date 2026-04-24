# /fix-bug - End-to-End Bug Workflow

@{{TOOLKIT_DIR}}/rules/input-detection.md
@{{TOOLKIT_DIR}}/rules/orchestration.md
@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: You have a bug report and want the repo-standard workflow to triage it, check whether it is already fixed upstream or pending in a PR, implement a safe fix when needed, and finish end-to-end.
> **Produces**: Triage notes, upstream-fix decision, validated RCA, implemented fix when appropriate, review and QA results, and either a `fix:` commit or a handoff to the user.

## Contract

Non-negotiable guarantees this workflow maintains. If the workflow would skip any of these, stop and ask.

- [ ] Complexity Gate block emitted (step 1)
- [ ] Existing-fix check run (step 2) — produces `Existing Fix Status` block
- [ ] PLAN.md written (step 4) — standard path only
- [ ] `/review-code` Review Gate block emitted (step 5)
- [ ] PROJECT.md updated with current state and (on completion) Completed entry
- [ ] Summary emitted (step 6)

## Plan Mode Boundary

Plan mode is for investigation and RCA only — step 3. Everything else (writing PLAN.md, implementation, reviewer subagents) happens in normal mode, because plan mode is read-only except for the plan file and turns must end with `AskUserQuestion` or `ExitPlanMode`.

Standard path flow: complexity gate → existing-fix check → plan mode (investigate + RCA) → exit → write PLAN.md (hard gate) → implement + review → summarize.

Moderate and trivial paths skip plan mode. See `rules/complexity-gate.md` for canonical path behavior; step 1 below lists only the bug-specific overrides.

## Usage
```
/fix-bug "saving settings fails on Safari"
/fix-bug sc-12345
/fix-bug apache/superset#28456
/fix-bug https://github.com/owner/repo/issues/123
/fix-bug https://app.shortcut.com/.../story/123
```

## Steps

### 1. Normalize Input + Complexity Gate

Accept plain-language bug descriptions, Shortcut story IDs/URLs, or GitHub issue/PR references.

When a ticket URL or reference is provided, **fetch and parse it FIRST** before any code investigation. The reproduction URL, affected area, and error description in the ticket are authoritative — don't re-derive by scanning code.

Run the complexity gate as one sequence: classify → emit → route.

**a. Classify** using these bug-specific signals:

| Signal | Trivial | Moderate | Standard |
|--------|---------|----------|----------|
| Root cause | Obvious from report | Likely, needs confirmation | Needs investigation |
| Files touched | 1–2 | 2–4, single subsystem | 3+ or unclear scope |
| Fix type | Typo, config, off-by-one | Logic change, known pattern | Architecture, novel pattern |
| Regression risk | Isolated, testable | Contained, testable | Cross-cutting |

**b. Emit** the Complexity Gate block using the format in `rules/complexity-gate.md`. That rule also defines auto-proceed and general routing behavior — do not re-state it here.

**c. Route** per the classification. These are the bug-specific overrides to the rule's canonical paths:

- **Trivial**: skip to step 5. Skip existing-fix check (mechanical fixes don't need upstream scan). Update PROJECT.md with action items only (no PLAN.md).
- **Moderate**: run step 2 (existing-fix check), then skip plan mode and go to step 5. Investigate inline. No PLAN.md. Escalate to STANDARD if investigation reveals cross-system complexity.
- **Standard**: continue to step 2 — produces a validated RCA and a formal plan in PLAN.md.

### 2. Check Existing Fix

Run the `check-existing-fix.md` skill. It returns a normalized block with `Status: FIXED_UPSTREAM | FIX_PENDING_PR | UNFIXED | SKIPPED`.

- **FIXED_UPSTREAM**: route to `/cherry-pick`. It owns the rest of the flow — return here only to emit the final summary. Do not auto-commit beyond the cherry-pick result.
- **FIX_PENDING_PR**: stop. Surface the PR reference and recommend monitor / adopt / supersede. Do not auto-review or merge the PR inside `/fix-bug`.
- **UNFIXED**: continue.

This gate runs before investigation on the standard path and before implementation on the moderate path — don't invest in planning or coding when the fix already exists.

### 3. Plan Mode → Investigate + RCA (standard only)

Enter plan mode. Inside plan mode, produce validated investigation and RCA:

**a. Triage and repro**: use `qa-triage-bug.md` for repro requirements. For UI and workflow bugs, run `prepare-environment.md` so repro can actually execute — first-pass triage from the report, then full Playwright MCP repro once the environment is runnable.

**b. Investigate**: use `investigate-change.md` (follow "When Investigating a Bug"). Re-run repro with stronger evidence once the environment is ready before moving into RCA.

**c. Validate the RCA**: spawn a reviewer subagent using `review-rca.md`. Model per `rules/orchestration.md` — `sonnet` when the RCA is well-bounded, `opus` when multiple plausible root causes exist or the failure crosses systems.

Decide whether to parallelize investigation lanes via subagents per `rules/orchestration.md` — worth it when multiple lanes have non-trivial work; sequential in the main thread is fine otherwise.

**Stop-early conditions**:
- QA concludes the report is not a bug → exit with findings.
- QA cannot reproduce and production evidence is weak → stop with a missing-evidence note.
- QA cannot reproduce but production evidence is strong → continue as a plausible bug with lower confidence and stricter action gate.

Exit plan mode when the RCA is validated.

### 4. Write PLAN.md (hard gate, standard only)

After exiting plan mode, write plan content into `PLAN.md` at the repo root with these sections:
- `Bug Summary` (symptom, affected area, repro status)
- `Root Cause Analysis` (validated RCA with evidence)
- `Fix Approach` (intended change, scope boundary, alternatives considered)
- `Test Strategy` (regression test plan, expected verification strength)

Update PROJECT.md with a pointer:
- Set current workflow + phase ("Working on: <bug>; phase: implementing")
- Add "Active plan: PLAN.md" pointer

**Do not proceed to step 5 until this confirmation block is emitted:**

```markdown
## PLAN.md Written
Sections: [list of sections written]
PROJECT.md updated: pointer to PLAN.md added
```

This gate ensures the plan is durable before implementation begins. PLAN.md is loaded during implementation; PROJECT.md is the lightweight state pointer that subsequent sessions read first.

### 5. Implement + Review

Implementation and review run as one tight loop. Test-first when feasible — write the failing regression test first (RED), then fix (GREEN). If test-first is blocked by repro, env, or harness constraints, write the test anyway and record the verification gap; writing the test is separate from running it.

Before removing or renaming any public function, method, class, or API endpoint, check for callers outside the immediate fix scope. Removing something other code depends on is a breaking change — raise it as a user decision, don't treat it as cleanup.

**Standard path**: spawn `implement-change.md` (use the "For Bug Fixes" RED/GREEN mode). After the fix lands, run `/review-code` as an internal loop until only nitpicks remain. For UI/workflow bugs, run `qa-validate-fix.md` when the app is runnable — prefer Playwright MCP.

**Moderate path**: orchestrator investigates inline (no investigation-lane subagents), writes the test, implements the fix inline, then spawns one reviewer subagent via `/review-code`.

**Trivial path**: write a cheap regression assertion (model introspection, config check, type guard) even for 1-line fixes — future drift protection is worth it. Apply the fix. Run the actual test suite covering the changed files (`pytest -k ...`, `jest --testPathPattern ...` — pre-commit alone is not sufficient) and record STRONG/PARTIAL/WEAK. Run `/review-code`. For truly minimal mechanical fixes (typo, config value, lint-disable), the review loop may be skipped per the skip rule in `rules/review-gate.md`.

The reviewer emits a Review Gate block per `rules/review-gate.md`. Branch on Status: `clean`, `blocked`, `user decision`, `skipped`, `micro-fix`. If step 5 already assessed verification strength, pass it to `/review-code` — don't re-run the same discovery.

**Commit and push** when this workflow implemented a fresh fix:

| Scenario | Action |
|----------|--------|
| STRONG verification + Review clean | Commit (`fix:`) + push automatically |
| PARTIAL or WEAK verification | Commit (`fix:`) — stop before push, note verification gap |
| Routed through `/cherry-pick` | No auto-commit beyond cherry-pick result; user decides follow-up |

Don't proceed to commit without a test added or updated. If tests cannot run locally, the test must still exist in the commit; CI or a future local run validates it.

**Resuming from a pre-built plan**: enter at this step, but still run `/review-code` and QA validation before declaring done.

If a meaningful decision surfaces during implementation or review, stop and present it clearly.

### 6. Summary

Use the template at [skills/reporting/templates/fix-bug-summary.md](../skills/reporting/templates/fix-bug-summary.md) following the structural rules in [skills/reporting/SKILL.md](../skills/reporting/SKILL.md).

Lead with whether the user's reported symptom is fixed — if the user gave you a ticket, answer whether it's done.

**Update PROJECT.md** (standard path only): on successful completion:
- Remove the "Active plan" pointer (PLAN.md is no longer driving active work)
- Append a "Completed" entry: `<date> — <bug summary>`

**Do not delete PLAN.md.** It persists in place after completion. Cleanup happens when the user explicitly runs `/archive-project-file` — workflows do not auto-delete files.

**Record metrics**: call the `metrics-emit` skill with:
- `command`: `fix-bug`
- `complexity`: classification from step 1 (`trivial` / `moderate` / `standard`)
- `status`: outcome from step 5 Review Gate (`clean` / `blocked` / `user-decision` / `skipped` / `micro-fix`)
- `rounds`: total review iteration rounds from step 5 (0 for trivial path)
- `gate_decisions`: `{ complexity: <step 1>, existing_fix: <FIXED_UPSTREAM | FIX_PENDING_PR | UNFIXED | SKIPPED>, review: <step 5> }`
- `models_used`: subagent model invocation counts

## Continuation Checkpoint

Use the template at [skills/reporting/templates/fix-bug-checkpoint.md](../skills/reporting/templates/fix-bug-checkpoint.md).

## Cross-Repo Bugs

When the symptom is in repo A (e.g., CI failure in a downstream fork) but the fix goes in repo B (e.g., upstream):
- The verification target is repo A's CI, not repo B's local test suite.
- Skip local tests in repo B that cannot exercise the failure path.
- Note the cross-repo gap in the summary under "Open risks".
- Partial coverage in repo B (model introspection, type checks) still beats none.
