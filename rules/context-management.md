# Context Management

At every **chain boundary** or **loop iteration**, check two things:

### 1. Context depth (existing rule)
- **Below ~70%**: Continue automatically.
- **At or above ~70%**: Finish the current action, then checkpoint.

### 2. Session cost
Read session cost from the statusline JSON (`cost.total_cost_usd`) or estimate from conversation length. Thresholds:

- **Below $3** (green): Continue automatically.
- **$3–$8** (yellow): Be aware. Consider whether the remaining work justifies continuing in this session.
- **Above $8** (red): Finish the current action, then checkpoint. Don't ask — just do it.

Cost grows quadratically in long conversations (each API call replays the full history). A fresh session with a checkpoint is cheaper than continuing a bloated one, even with the reload overhead.

### Where to check
Chain boundaries: `/fix-bug` internal phase transitions, `/create-feature` planning → implementation, `/create-feature` implementation → review, etc.
Loop iterations: each `/create-feature` planning round, each `/review-code` round.
Sub-invocations: when `/create-feature`, `/fix-bug`, `/update-tests`, or `/fix-ci` calls `/review-code`.

**"Finish the current action"** means: complete the in-flight tool call, subagent, or review round. Don't cut off mid-edit or mid-test. But don't start the *next* phase — checkpoint first.

## Save & Continue Protocol

When either trigger fires (context ≥ 70% OR cost > $8), run `/checkpoint`. It handles the full protocol:
1. Writes a continuation checkpoint to PROJECT.md (see `commands/checkpoint.md` for the canonical format)
2. Leaves uncommitted work untouched unless the calling workflow already has explicit commit authorization; otherwise records dirty state in PROJECT.md
3. Runs `/clear` to reset conversation context

After `/clear`, run `/start` to reload PROJECT.md and resume the saved workflow automatically.

The user should not need to do anything — this is a seamless context refresh.

Do not rely on chat memory after `/clear`. The checkpoint in PROJECT.md is the source of truth for where execution resumes.

## Batch Manifest Checkpoints

For large batch workflows, checkpointing should preserve the manifest pointer and next unit/wave, not raw per-item history. The manifest is the source of truth; chat is only the control surface.

Examples:
- Cherry-pick trains: `PROJECT.md` points to `CHERRY_PICK.md`, current wave, and next PR/SHA.
- Multi-failure CI fixes: `PROJECT.md` points to `CI_FIX.md`, current failure group, and next verification step.
- Large feature builds: `PROJECT.md` points to `PLAN.md`, current slice/wave, and pending workstream handoffs.

If a manifest exists, update it before `/checkpoint --clear` so resume does not depend on context that will be discarded.

## Reference Loading Policy

Commands should eagerly import only short rules the main thread needs immediately. Skills and detailed workflow references belong behind step routing: name or link the skill/reference in the command, then load it only when entering that step.

This preserves the old command reliability (the gates and sequence stay visible) without paying the token cost for every phase at command start. If a command needs a long procedure for only one branch of a workflow, keep it as a skill reference, not an `@{{TOOLKIT_DIR}}/...` import.

## Why This Matters
- **Context depth**: Auto-compaction silently drops earlier context, which can cause Claude to lose track of decisions, review scores, or chain state mid-workflow.
- **Session cost**: With a 1M context window, you can burn $50+ before hitting 70% context. Cost-based checkpointing catches the token burn that context % misses. A fresh session with a PROJECT.md checkpoint is both cheaper and higher fidelity than a long session with compacted history.
