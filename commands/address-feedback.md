# /address-feedback - Address PR Review Feedback

@{{TOOLKIT_DIR}}/rules/complexity-gate.md

> **When**: A PR has review comments that need to be addressed.
> **Produces**: Fixes committed, responses posted, threads resolved.

Use `--draft` to show responses locally without posting to GitHub.

## Golden Rule
Always investigate before triaging — read the actual code, verify claims, check git blame. Evidence-based triage, not guess-based.

## Usage

```
/address-feedback <pr-number-or-url>
/address-feedback <pr-number-or-url> --draft
```

## Steps

### 1. Gather + Complexity Gate

Fetch PR comments:
```bash
gh pr view <number> --comments
gh api repos/<owner>/<repo>/pulls/<number>/comments
```

Classify feedback scope:

| Signal | Trivial | Standard |
|--------|---------|----------|
| Comment count | 1–3 | 4+ |
| Fix type | Cosmetic, naming | Logic, behavior |
| Scope | Single area | Cross-cutting |
| Discussion items | 0 | 1+ |

Emit the Complexity Gate block per `rules/complexity-gate.md`.

**Trivial + confidence 8/10+**: Quick-fix path — fix, post, summary. Skip triage table.

### 2. Investigate + Triage

For each review comment:
- Read the actual code referenced
- Verify the reviewer's claim (don't assume correctness)
- Check if handled elsewhere (guard clause, try/catch, middleware)
- Check git blame for context on why the code exists

Triage each item with full reasoning — present to the user BEFORE taking action:

| # | Reviewer | Comment | Verdict | Reasoning | Confidence |
|---|----------|---------|---------|-----------|------------|
| 1 | @user | ... | Fix | [why this should be fixed — what's the actual risk] | 9/10 |
| 2 | @user | ... | Skip | [why this is not valid — evidence from code, git blame, existing patterns] | 7/10 |
| 3 | @user | ... | Discuss | [why this is ambiguous — what are the trade-offs] | 5/10 |

- **Fix**: bugs, security issues, missing error handling, project standards
- **Skip**: style preferences, out of scope, misunderstanding, incorrect assessment
- **Discuss**: architectural disagreements, ambiguous requirements, trade-offs

**User confirmation gate**: Present the triage table with reasoning and wait for the user to confirm, adjust verdicts, or override. Do not start fixing or posting until the user approves the triage. This prevents wasted work on items the user disagrees with and catches cases where the reviewer's comment is actually correct but Claude mistriaged it.

### 3. Fix

Address fixes by priority:
1. Bugs and security issues
2. Missing error handling
3. Standards compliance

**TDD for behavioral changes**: write a test first (RED), then fix (GREEN).
**Direct fix for cosmetic/pattern-following**: fix directly, existing tests cover it.

Commit fixes: `fix: address PR feedback — [summary]`

### 4. Review Gate

Run `/review-code` on changed files. The developer emits a Review Gate block per `rules/review-gate.md`.

For truly minimal fixes (renames, typo corrections), the review may be skipped per the skip rule in `rules/review-gate.md`.

### 5. Draft Responses

For each item, draft a reply:

**Fixed**: Short confirmation with commit reference.
```
Fixed in `abc1234` — added null guard for `getData()` return value.
```

**Skipped**: Explanation with evidence.
```
Thanks for the suggestion. Keeping the current approach — it follows existing patterns in this area.
```

**Discuss**: Context and question.
```
Good question — auth is handled by middleware upstream. The changes here operate after auth validation.
```

### 6. Push + Post

**Default**: Push commits and post replies automatically.

```bash
git push

# Reply to specific review comments
gh api repos/<owner>/<repo>/pulls/comments/<comment-id>/replies \
  -f body="<response>"
```

**Stop conditions** (present to user instead of auto-posting):
- `--draft` flag was used
- Any "Discuss" item has genuine ambiguity needing user input before posting
- Push would fail (diverged branch, protected branch)

**Auto-resolve bot threads**: Resolve conversation threads from bot authors (`[bot]` suffix or `type: "Bot"`). Mechanical checks — if the fix passes, the comment is addressed.

**Leave human threads open**: Post the "Fixed in `<sha>`" reply but do not resolve. Human reviewers verify themselves.

### 7. Summary

```markdown
## Address-Feedback Complete
PR #[number] — [N] fixed, [N] skipped, [N] discussed

### Actions Taken
- **Fixed**: [count] items (committed + pushed)
- **Skipped**: [count] items (responses posted)
- **Discussed**: [count] items (responses posted / awaiting user input)

### What to do next
- Request re-review if fixes were made
```

## Non-Negotiable Gates

- [ ] Complexity Gate block emitted
- [ ] Evidence-based investigation before every triage verdict
- [ ] Review Gate block emitted (after fixes, unless skipped per skip rule)
- [ ] Summary emitted

## PROJECT.md Update Discipline

If a PROJECT.md exists, update after fixes are committed with feedback resolution counts. Skip if no PROJECT.md exists and work completes without issues.

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /address-feedback <pr-reference>
- Phase: gather / complexity-gate / investigate / triage / fix / review / draft / post / summarize
- Resume target: PR #[number]
- Completed items: [phases finished]
### State
- PR: [number] — [title]
- Complexity: [trivial / standard]
- Triage: [N] fix, [N] skip, [N] discuss
- Fixes committed: [yes / no / partial]
- Review: [clean / blocked / pending]
- Posted: [yes / no / pending]
```

## Notes
- Always investigate before triaging — read the actual code
- TDD for behavioral changes, direct fix for cosmetic/pattern-following
- Default is auto-push and auto-post; use `--draft` for local-only
