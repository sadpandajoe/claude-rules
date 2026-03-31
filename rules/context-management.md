# Context Management

At every **chain boundary** or **loop iteration**, check context depth:

- **Below ~70%**: Continue automatically. Don't pause.
- **At or above ~70%**: Save state and continue in a fresh conversation. Don't ask — just do it.

Chain boundaries: `/fix-bug` internal phase transitions, `/create-feature` planning → implementation, `/create-feature` implementation → review, etc.
Loop iterations: each `/create-feature` planning round, each `/review-code` round.
Sub-invocations: when `/create-feature`, `/fix-bug`, `/update-tests`, or `/fix-ci` calls `/review-code`.

## Save & Continue Protocol

When context is ≥ 70%, run `/checkpoint`. It handles the full protocol:
1. Writes a continuation checkpoint to PROJECT.md (see `commands/checkpoint.md` for the canonical format)
2. Commits any uncommitted work
3. Runs `/clear` to reset conversation context

After `/clear`, run `/start` to reload PROJECT.md and resume the saved workflow automatically.

The user should not need to do anything — this is a seamless context refresh.

Do not rely on chat memory after `/clear`. The checkpoint in PROJECT.md is the source of truth for where execution resumes.

## Why This Matters
Auto-compaction silently drops earlier context, which can cause Claude to lose track of decisions, review scores, or chain state mid-workflow. Checkpointing preserves full fidelity.
