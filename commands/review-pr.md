# /review-pr - Adaptive Team PR Review

@{{TOOLKIT_DIR}}/rules/complexity-gate.md
@{{TOOLKIT_DIR}}/rules/code-review.md

> **When**: Asked to review someone else's GitHub PR.
> **Produces**: Team-reviewed findings with pattern analysis, test coverage check, auto-approve or request changes, posted to GitHub.

Use `--draft` to show the review locally without posting.

## Usage

```
/review-pr <pr-number-or-url>
/review-pr <pr-number-or-url> --draft
/review-pr <pr-number-or-url> --adversarial
/review-pr <pr-number-or-url> --auto
/review-pr 101 102 103                                   # batch — review multiple PRs
/review-pr --all-open                                    # batch — review all open PRs in repo
```

## Orchestration Model

The main thread is the **orchestrator** — it gathers PR context, dispatches reviewer subagents, collects their findings, synthesizes the result, and handles GitHub interaction. The main thread does not review code itself. All review judgment comes from subagents running with fresh context.

## Steps

### 1. Gather PR Context

**Detect batch** — if multiple PR numbers are provided or `--all-open` is used:
- `--all-open`: run `gh pr list --json number,title --state open` to get all open PRs
- Multiple numbers: parse all provided refs
- **Single PR** → continue to step 2 (existing flow)
- **Multiple PRs** → use the **Batch Path** section below

```bash
gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,files,additions,deletions
gh pr diff $ARGUMENTS
gh pr view $ARGUMENTS --json files -q '.files[].path'
```

Read the full content of changed files — review comments target changed lines, but the review must understand surrounding context.

### 2. Complexity Gate

Classify the PR scope:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Files changed | 1–5 | 6+ |
| Lines changed | < 100 | 100+ |
| Behavioral change | None / cosmetic | Functional |
| Cross-cutting | No | Yes |

Examples — TRIVIAL: docs-only PR (3 files, 30 lines, no behavior change). STANDARD: new API endpoint with migration, tests, and frontend integration.

Emit the Complexity Gate block per `rules/complexity-gate.md`.

**Trivial + confidence 8/10+**: Code quality review only — unless impact assessment (step 3) escalates.

### 3. Assess Impact + Understand the Problem

Run the `qa` skill's [references/assess-impact.md](../skills/qa/references/assess-impact.md) on the PR diff to determine functional impact: CORE, STANDARD, or PERIPHERAL. This runs in parallel with the problem understanding below.

**Impact escalation**: If impact is CORE, escalate regardless of complexity tier:
- TRIVIAL + CORE → run full review team (not just code quality)
- STANDARD + CORE → full team + suggest `--adversarial`

**Understand the problem** (Standard or CORE impact):

Before reviewing code, validate the premise of the PR:

1. **Read linked context**: issue/ticket (if linked), PR description, author's comments, prior reviewer comments
2. **Investigate the claim**: Does the stated problem actually exist? Is the root cause correct? Is this the right approach?
3. **For bug fixes**: verify the bug logic — does the fix address the actual cause?
4. **For features**: does the feature solve the stated need? Is it in the right place architecturally?

If the premise doesn't hold up, flag it as the **primary finding** — no amount of clean code matters if the PR is solving the wrong problem. Skip the remaining team review lanes (steps 4–6) but still route the finding through step 7's reasoning/confirmation flow before posting. The user must see and confirm this high-stakes finding like any other.

If the premise is valid, proceed to team review with that understanding as context for all reviewers.

### 4. Detect Reviewer Team

Use `classify-diff.md` to determine which review domains apply to the PR diff. Pass the diff and complexity tier from step 2 (or escalated tier if CORE impact upgraded it). The skill returns triggered reviewers with reasons.

Pass the impact assessment from step 3 to all reviewer subagents so they can calibrate severity — CORE workflow findings get stricter treatment per `rules/code-review.md` calibration.

Additionally, for Standard PRs (or CORE-escalated), always include:
- **Pattern analysis** — read 2-3 similar files in the same directory; flag convention deviations (step 6)

### 5. Launch Team Review

**Trivial**: Single-pass code quality review. If clean, silent approve (no team, no report).

**Standard**: Launch all review lanes in parallel:

**Lane 1 — Regular team** (foreground subagents, `model: "opus"`):
Each reviewer subagent runs with context isolation per `rules/orchestration.md`. Each applies its lens independently and returns severity-tagged findings. The team includes all reviewers triggered by `classify-diff.md` plus pattern analysis (step 6).

**Lane 2 — Codex second opinion** (if available):
Check if the Codex plugin is available. If unavailable, skip silently and note "Codex: skipped (plugin not available)" in the summary.

If available, launch as a **foreground** subagent with `isolation: "worktree"` (prevents mutating the current checkout while other reviewers read files):
1. Inside the worktree: `gh pr checkout <number> --detach`
2. Run `/codex:review --base <base-branch>` synchronously
3. Return findings to orchestrator

The subagent must stay alive until Codex completes — early exit auto-cleans the worktree and loses the checkout. Run Lane 2 in parallel with Lane 1; the orchestrator waits for all lanes before merging.

**Lane 3 — Adversarial** (background, only with `--adversarial` flag or auto-suggested):
Launch Claude adversarial + `/codex:adversarial-review --background` (if Codex available). Dual-model red-team. Only runs when explicitly requested or when security-sensitive code is detected. Falls back to Claude-only adversarial if Codex unavailable.

### 6. Pattern Analysis (Standard)

For each changed file:
- Read 2-3 similar files in the same directory or module
- Compare naming conventions, error handling, import structure, function signatures
- Flag deviations as `[minor]` with the existing pattern shown as reference
- If the change introduces an improvement over existing patterns, note it positively

### 7. Deep Review + Scoring

Merge all team findings. Score using the framework from `rules/code-review.md`:

| Component | Score | Notes |
|-----------|-------|-------|
| Root Cause | /10 | Why was this change needed? |
| Solution | /10 | Efficient, maintainable? |
| Tests | /10 | Realistic, covering? |
| Code | /10 | Readable, consistent? |
| Docs | /10 | Clear, complete? |

Tag issues by severity: `[major]`, `[minor]`, `[nitpick]`.

**Reasoning review (before posting)**: When there are findings, present them to the user FIRST with full reasoning — never post directly. For each finding show:
1. The issue and proposed severity
2. **Why this severity** — what evidence supports this classification
3. **Confidence** — how certain (and what could change the assessment)
4. **Evidence** — the specific code, pattern, or documentation that informed the judgment

This lets the user adjust severities, remove false positives, or escalate missed issues before anything is posted. Only after user confirmation does the review get posted to GitHub.

**Clean reviews skip the reasoning review** — if overall 8/10+ with zero findings, proceed directly to step 9 (which handles the confirmation gate).

Use `gh api repos/{owner}/{repo}/pulls/{number}/files --paginate` for accurate diff positions.

### 8. Determine Review Recommendation

Determine the recommendation — do NOT post or approve yet (step 9 handles that):
- **Approve**: Overall 8/10+, zero `[major]`
- **Request Changes**: Any `[major]` issue, or overall below 6/10
- **Comment**: Overall 6-7/10, no `[major]` but notable `[minor]` issues

### 9. Post to GitHub

Detail level scales with complexity and findings.

**Trivial + clean**: Silent approve — no comments, no report, no user pause.

**Standard + clean (8/10+, zero findings)**: Pause with one-line confirmation before approving:
```
"Clean review (9/10, zero findings). Approve and post? [Y/n]"
```
Proceed on confirmation. If declined, show the full review in conversation only.

**Any findings**: User has already reviewed and adjusted the findings in step 7. Post only the user-confirmed findings with their adjusted severities. The reasoning/confidence/evidence shown to the user is NEVER posted — only the clean finding descriptions go to GitHub.

**`--draft` flag**: Show the review in conversation only. Do not post.

**`--auto` flag**: Skip all confirmations — auto-approve and auto-post (original behavior for scripted or batch use).

### 10. Adversarial Suggestion

If `--adversarial` was not used and the diff touches security-sensitive areas (auth, input handling, API endpoints, database queries, file operations), suggest:
> Consider re-running with `--adversarial` for dual-model security review.

### 11. Summary

```markdown
## Review-PR Complete
PR #[number]: [title] — [Approve / Request Changes / Comment]

### Team Selected
| Reviewer | Why |
|----------|-----|
| Code quality | Always |
| [additional] | [reason] |

### Scores
| Component | Score |
|-----------|-------|
| Root Cause | X/10 |
| Solution | X/10 |
| Tests | X/10 |
| Code | X/10 |
| Docs | X/10 |
| **Overall** | **X/10** |

### Issues Found
- [N] major, [N] minor, [N] nitpick

### Test Coverage
- [Tests found/missing, suggestions made]

### Posted
[Yes — link to review / No — draft mode]

### Suggested Next Steps
[Pick based on current state:]
- **Approved**: Done — PR is ready to merge
- **Request Changes posted**: Wait for author to address, then `/review-pr` again to re-review
- **Comment posted**: Author should review comments; re-run when updated
- **Draft mode**: Post with `/review-pr <number>` (without `--draft`) when ready
- **Security-sensitive areas detected**: Re-run with `--adversarial` for red-team review
- **Author asked you to address feedback**: `/address-feedback <number>`
```

## Batch Path

When step 1 detects multiple PRs, use this path instead of steps 2–11. Reviews are read-only — no worktrees needed, just parallel subagents.

### B1. Dispatch Parallel Reviews

For each PR, dispatch a subagent:

```
Agent(
  model: "opus",
  prompt: "Read and follow {{TOOLKIT_DIR}}/commands/review-pr.md for PR #[number].
    This is a single PR — use the standard flow (steps 1–11).
    Flags: --auto (skip confirmations, post directly).
    Return: PR number, recommendation (approve/request-changes/comment), key findings, and whether it was posted."
)
```

Each subagent runs the full single-PR review flow independently. Use `--auto` by default in batch mode to avoid N confirmation prompts.

**Concurrency**: Reviews are CPU-light. Run up to 4–5 in parallel.

### B2. Collect Results

After all subagents complete, aggregate:

```markdown
## Review Batch Complete — [N] PRs

| PR | Title | Recommendation | Key Finding | Posted |
|----|-------|---------------|-------------|--------|
| #[N] | [title] | approve | Clean — no issues | yes |
| #[N] | [title] | request-changes | [top issue] | yes |
| #[N] | [title] | comment | [observation] | yes |

### Needs Attention
- PR #[N]: [why it needs manual follow-up]
- {Or "All PRs reviewed cleanly"}
```

## Non-Negotiable Gates

- [ ] Full file context read (not just diff)
- [ ] Complexity Gate block emitted
- [ ] Pattern analysis completed (Standard)
- [ ] Test coverage check completed (Standard)
- [ ] All issues tagged by severity
- [ ] Review Gate recommendation determined
- [ ] Team selection shown in summary
- [ ] Summary emitted

## Continuation Checkpoint

**Single-PR phases**: gather / complexity-gate / understand-problem / detect-team / launch-review / pattern-analysis / scoring / gate / post / summarize

**Batch phases**: gather-list / dispatch-reviews / collect-results / batch-summary

State (single PR):
- PR: [number] — [title]
- Complexity: [trivial / standard]
- Team: [list of selected reviewers]
- Scores: [component: score, ...]
- Recommendation: [approve / request-changes / comment / pending]
- Posted: [yes / no / pending]

State (batch):
- Mode: batch
- PRs: [N total, N complete, N failed]
- Recommendations: [N approve, N request-changes, N comment]

## Notes
- Accepts single PRs or batches — batch detection is automatic. Use `--all-open` to review every open PR in the repo.
- Batch mode defaults to `--auto` (posts reviews without confirmation). No worktrees needed — reviews are read-only.
- Read full files for context, only comment on changed lines
- Use diff positions (not file line numbers) when posting inline comments
- Default is auto-post; use `--draft` for local-only review
- Standard + clean PRs pause for confirmation before approving (step 9); use `--auto` to skip all confirmations
- Team selection is transparent in the summary so you can `/learn` to correct bad selections
- For adversarial review, check out the PR locally and run `/review-code-adversarial`
