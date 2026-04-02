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
```

## Orchestration Model

The main thread is the **orchestrator** — it gathers PR context, dispatches reviewer subagents, collects their findings, synthesizes the result, and handles GitHub interaction. The main thread does not review code itself. All review judgment comes from subagents running with fresh context.

## Steps

### 1. Gather PR Context

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

Emit the Complexity Gate block per `rules/complexity-gate.md`.

**Trivial + confidence 8/10+**: Code quality review only. Skip team.

### 3. Understand the Problem First (Standard only)

Before reviewing code, validate the premise of the PR:

1. **Read linked context**: issue/ticket (if linked), PR description, author's comments, prior reviewer comments
2. **Investigate the claim**: Does the stated problem actually exist? Is the root cause correct? Is this the right approach?
3. **For bug fixes**: verify the bug logic — does the fix address the actual cause?
4. **For features**: does the feature solve the stated need? Is it in the right place architecturally?

If the premise doesn't hold up, flag it as the **primary finding** — no amount of clean code matters if the PR is solving the wrong problem. Skip the remaining team review lanes (steps 4–6) but still route the finding through step 7's reasoning/confirmation flow before posting. The user must see and confirm this high-stakes finding like any other.

If the premise is valid, proceed to team review with that understanding as context for all reviewers.

### 4. Detect Reviewer Team

Analyze the PR diff to select reviewers:

| Reviewer | When | Focus |
|----------|------|-------|
| Code quality | Always | Readability, DRY, correctness, naming |
| Pattern analysis | Standard | Read 2-3 similar files in same directory; flag convention deviations |
| Architecture | Standard + logic changes | Right file? Right layer? Duplicate function? |
| Test check | Standard | No tests → suggest what to write. Has tests → review quality + suggest more |

### 5. Launch Team Review

**Trivial**: Single-pass code quality review. If clean, silent approve (no team, no report).

**Standard**: Launch all review lanes in parallel:

**Lane 1 — Regular team** (foreground subagents, `model: "opus"`):
Each reviewer gets the PR diff + full file context, applies its lens, returns severity-tagged findings. The team includes:
- Code quality (always)
- Architecture (if logic changes in source files)
- Tests (`review-tests.md`) or Test Plan (`review-testplan.md`) — like an SDET reviewing whether the test suite provides real regression protection
- Pattern analysis (step 6)

**Lane 2 — Codex second opinion** (background, if available):
Check if the Codex plugin is available. If yes, launch the Codex review in an **isolated worktree** so it never mutates the current checkout while other reviewers are reading files. Use `isolation: "worktree"` on a **foreground** subagent that: (1) runs `gh pr checkout <number> --detach` inside the worktree, (2) launches `/codex:review --base <base-branch>` synchronously, and (3) returns the findings. The subagent must stay alive until Codex completes — if it exits early the worktree is auto-cleaned and the review loses its checkout. Run Lane 2 in parallel with Lane 1 (both foreground); the orchestrator waits for all lanes before merging. If Codex is unavailable, skip this lane silently and note "Codex: skipped (plugin not available)" in the summary.

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

## Non-Negotiable Gates

- [ ] Full file context read (not just diff)
- [ ] Complexity Gate block emitted
- [ ] Pattern analysis completed (Standard)
- [ ] Test coverage check completed (Standard)
- [ ] All issues tagged by severity
- [ ] Review Gate recommendation determined
- [ ] Team selection shown in summary
- [ ] Summary emitted

## PROJECT.md Update Discipline

If a PROJECT.md exists, update after posting with PR number, recommendation, and key findings. Skip if no PROJECT.md exists and review completes without issues.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /review-pr <pr-reference>
- Phase: gather / complexity-gate / understand-problem / detect-team / launch-review / pattern-analysis / scoring / gate / post / summarize
- Resume target: PR #[number]
- Completed items: [phases finished]
### State
- PR: [number] — [title]
- Complexity: [trivial / standard]
- Team: [list of selected reviewers]
- Scores: [component: score, ...]
- Recommendation: [approve / request-changes / comment / pending]
- Posted: [yes / no / pending]
```

## Notes
- Read full files for context, only comment on changed lines
- Use diff positions (not file line numbers) when posting inline comments
- Default is auto-post; use `--draft` for local-only review
- Standard + clean PRs pause for confirmation before approving (step 9); use `--auto` to skip all confirmations
- Team selection is transparent in the summary so you can `/learn` to correct bad selections
- For adversarial review, check out the PR locally and run `/review-code-adversarial`
