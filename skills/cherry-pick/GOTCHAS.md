# Cherry-Pick Gotchas

Empirical failure modes observed in past sessions. Read at decision points; update when a new failure surfaces.

Format per entry: **Symptom** → **Why** → **Do instead** → **First seen**.

---

## Clean apply silently leaks code from adjacent commits

**Symptom:** `git cherry-pick` succeeds with zero conflicts, build passes, tests pass — and an unrelated change from a neighboring commit on the source branch ships with the cherry-pick.

**Why:** When the source branch's version of a region differs from the target's, git takes the source side wholesale during a clean apply. If neighboring commits on the source branch touched the same region, their changes ride along. No conflict markers, no scrutiny, no escape hatch.

**Do instead:** Run the diff audit (`scripts/scope-audit.sh`) on **every** cherry-pick — including clean applies with zero conflicts. Compare source-commit diff vs cherry-pick result diff. Revert any hunks that don't trace to the cherry-picked commit.

**First seen:** PR #38809 / SC-104110 (P1) — clean cherry-pick leaked the `hideTab` guard from an adjacent commit.

---

## `git checkout --theirs` / `--ours` silently discards changes

**Symptom:** Conflicts "resolved" instantly with `git checkout --theirs <file>` or `--ours <file>`. The result looks plausible but is missing the other side's changes entirely.

**Why:** In cherry-pick context, `--theirs` takes the source branch's full file (not a merge), `--ours` takes the target's. Both throw away the other side wholesale.

**Do instead:** Always read conflict markers and edit surgically. If the file is too large to resolve by hand, abort and split the cherry-pick into smaller pieces.

**First seen:** Pre-existing rule, repeatedly re-learned.

---

## CHERRY_PICK_HEAD missing after modify/delete-only conflicts

**Symptom:** `git cherry-pick --continue` errors with "no cherry-pick or revert in progress" after resolving a set of modify/delete conflicts with `git rm`.

**Why:** Some git versions drop `CHERRY_PICK_HEAD` when all remaining conflicts are modify/delete and no content conflicts exist. It can also disappear after an abort that wasn't followed by a fresh cherry-pick.

**Do instead:** Verify `.git/CHERRY_PICK_HEAD` exists before `--continue`. If missing after re-running the cherry-pick produces the same modify/delete-only state, resolve with `git rm` + `git commit` (manually writing the cherry-pick message with the `(cherry picked from commit <sha>)` reference). Do not fall back to `git apply` for ≤5 excluded files.

**First seen:** Standing rule encoded in apply phase.

---

## Re-running `check-existing-fix` after the gate already consumed it

**Symptom:** Duplicate work — the investigate phase ran `check-existing-fix.md`, then the gate re-ran it, then the plan phase considered re-running it.

**Why:** Investigation already runs the existing-fix check. The gate consumes the result; it does not re-check. Downstream phases must trust the gate's decision.

**Do instead:** Investigate runs the check once. Gate consumes the output. Plan and apply do not re-litigate.

**First seen:** Standing rule encoded in gate phase.

---

## Plan subagent tries to override the gate

**Symptom:** Plan subagent comes back with "this should be rejected" or restructures the cherry-pick scope contrary to the gate's decision.

**Why:** Plan operates downstream of the gate and should treat the go/no-go as decided. Re-litigating wastes the cycle and confuses orchestration.

**Do instead:** The plan can note disagreement for the reviewer to consider, but produces a plan as instructed. Only the main thread (Opus) re-evaluates gate decisions.

**First seen:** Standing rule encoded in plan phase.

---

## Bug-fix dropped due to architecture mismatch — underlying bug forgotten

**Symptom:** Cherry-pick rejected or significantly trimmed because target lacks required architecture. Adaptation notes capture the trim. The user is told "Rejected" — and the underlying bug, which still affects the target via a different code path, is never surfaced.

**Why:** Adaptation severity buries the residual risk. "Rejected" sounds final; users assume the bug was someone else's problem.

**Do instead:** When a bug-fix cherry-pick is rejected or trimmed, assess whether the underlying bug exists on the target via a different code path. If yes, surface it as an actionable residual item in the final report's "What to do next" — not buried in adaptation notes.

**First seen:** Standing rule encoded in adapt phase.

---

## Validation status overstated as "Tested" when only build ran

**Symptom:** Execution table says `Tested` for a cherry-pick where only the build passed; targeted tests existed but weren't executed.

**Why:** Easy to conflate "validation passed" with "tested." Tests existed and were runnable; they just weren't run.

**Do instead:** Use the validation status table strictly:
- `Tested` = build + targeted tests passed
- `Checked` = lint/type only
- `Build-only` = just build/pre-commit
- `Structural` = parse + no markers
- `Not run` = nothing

If tests existed and weren't run, flag the gap explicitly with what was available, why skipped, and recommended follow-up.

**First seen:** Standing rule encoded in validate phase.
