# /investigate - Standalone Investigation & RCA

@/Users/joeli/opt/code/ai-toolkit/rules/investigation.md
@/Users/joeli/opt/code/ai-toolkit/rules/api.md
@/Users/joeli/opt/code/ai-toolkit/skills/developer/SKILL.md

> **When**: You want a standalone investigation and root-cause analysis without running the full `/fix-bug` workflow.
> **Produces**: Root cause analysis documented in PROJECT.md, validated by the shared review-rca skill, plus recommended next steps.

## Usage
```
/investigate "the login page is broken"          # Describe the problem
/investigate sc-12345                             # Start from a Shortcut story
/investigate apache/superset#28456               # Start from a GitHub issue
/investigate https://github.com/.../issues/123   # Start from a GitHub URL
/investigate https://app.shortcut.com/...        # Start from a Shortcut URL
```

## Steps

0. **Fetch External Context (if reference provided)**

   Use the Input Detection table in `rules/api.md` to identify the source type from the argument.

   **Shortcut story** (`sc-12345`, Shortcut URL):
   - Query the story via Shortcut REST API (see `api.md`)
   - Extract: title, description, acceptance criteria, labels, story type, linked PRs (`external_links`), comments, epic context
   - Use the description and comments to understand what's broken and any prior investigation

   **GitHub issue/PR** (`#12345`, `owner/repo#12345`, GitHub URL):
   - Query via `gh issue view` or `gh pr view` (see `api.md`)
   - Extract: title, body, labels, linked PRs, comments, repro steps
   - Check for linked Shortcut stories in the body/comments

   Fold the extracted context into the problem documentation in Step 1.

1. **Document and Investigate the Problem**

   Delegate the code-level RCA to the developer persona:

   @/Users/joeli/opt/code/ai-toolkit/skills/developer/investigate-bug.md

   Pull in external context first when the input is a Shortcut story, GitHub issue, or GitHub PR.

2. **Validate RCA**

   Use the shared validator:

   @/Users/joeli/opt/code/ai-toolkit/skills/core/review-rca/SKILL.md

   If the review identifies gaps, investigate further before summarizing.

3. **Update PROJECT.md**

   Write the validated RCA, evidence, and open questions to `PROJECT.md`.

4. **Recommend the Next Action**

   Do not auto-chain.
   Recommend the next best workflow explicitly:
   - `/fix-bug` when the issue should move into the end-to-end bug workflow
   - `/cherry-pick` when the fix already exists elsewhere
   - `/create-feature` when the work is feature-like or needs broader design
   - stop when the RCA is still too weak

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:
- after the first substantial investigation pass
- after RCA validation
- at final completion with the validated RCA and recommended next action

## Continuation Checkpoint

If context gets deep before the workflow completes, write a continuation checkpoint before clearing:

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /investigate <arguments>
- Phase: fetch-context / investigate / rca-review / summarize
- Resume target: <issue, story, PR, file set, or remaining open question>
- Completed items: <finished investigation steps>
### State
- Current RCA: <best hypothesis so far>
- Evidence status: <strong / partial / weak>
- Remaining gaps: <what still needs validation>
```

After writing the checkpoint:
- run `/clear`
- run `/start`
- resume `/investigate` at the saved phase and target

Use `/update-project-file --checkpoint ...` only when you need a manual checkpoint outside the normal flow.

## Notes
- Always use git history first
- Find root cause, not just symptoms
- Prefer existing fixes over creating new ones
- Document with evidence (command outputs)
- Use `/fix-bug` for the full bug workflow; `/investigate` is the manual RCA-only entrypoint
