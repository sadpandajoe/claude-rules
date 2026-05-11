# /address-feedback - Address PR Review Feedback

@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: A PR has review comments that need investigation, fixes, replies, or thread handling.
> **Produces**: Evidence-based triage, approved fixes, verification, reviewer replies, and a final feedback-round summary.

## Usage

```bash
/address-feedback <pr-number-or-url>
/address-feedback <pr-number-or-url> --draft
/address-feedback <pr-number-or-url> --auto
```

## Routing

Use the `feedback` skill phase-by-phase. Do not preload every reference up front:

1. Gather comments and triage with [skills/feedback/references/gather-triage.md](../skills/feedback/references/gather-triage.md).
2. Apply approved fixes and run review with [skills/feedback/references/fix-review.md](../skills/feedback/references/fix-review.md).
3. Draft/post replies and resolve eligible bot threads with [skills/feedback/references/reply-resolve.md](../skills/feedback/references/reply-resolve.md).

## Orchestration Model

The main thread owns PR state: comment ids, triage verdicts, posting decisions, thread resolution, and final summary.

For large review rounds, batch independent fixes into subagent waves only when ownership is disjoint. Send each subagent only the relevant comments, files, current diff, validation expectation, and reply-draft requirement. The subagent returns a compact handoff; the main thread reviews, verifies, and posts.

## Gates

- Emit a Complexity Gate before fixing.
- Investigate before triage; never accept or reject comments by guess.
- Pause after triage unless `--auto` was passed.
- Run `/verify` or equivalent pre-flight checks before `/review-code`, and record the result in the Review Gate.
- Use the Review Gate skip/micro-fix exceptions only when `rules/review-gate.md` allows them; otherwise run `/review-code` after substantive fixes.
- Stop before posting when `--draft` was passed, a discussion needs user wording, verification failed, or push safety is unclear.

## Summary Contract

End with:

```markdown
## Address-Feedback Complete
PR #[number] - [N] fixed, [N] skipped, [N] discussed

### Actions Taken
- Fixed: [...]
- Skipped: [...]
- Discussed: [...]

### Verification
- [...]

### Posting
- [...]

### Suggested Next Steps
- [...]
```

Record a `metrics-emit` event using the fields from `feedback/references/reply-resolve.md`.
