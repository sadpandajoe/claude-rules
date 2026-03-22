# /investigate - Investigation & Root Cause

@/Users/joeli/opt/code/claude-rules/rules/investigation.md
@/Users/joeli/opt/code/claude-rules/rules/api.md

> **When**: Something is broken and you need to find why.
> **Produces**: Root cause analysis documented in PROJECT.md, validated by review-rca skill.

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

1. **Document the Problem**
   ```markdown
   ## Investigation: [Issue Name]

   ### The Problem
   - **What's broken**: [Exact symptoms/error]
   - **When it occurs**: [Trigger conditions]
   - **Impact**: [What functionality affected]
   - **Environment**: [Branch, version, setup]

   ### Timeline
   - [Timestamp]: Starting investigation
   ```

2. **Reproduce**
   ```bash
   # Verify issue exists
   [Run failing command/test]

   # Check current state
   git status
   git branch
   git log --oneline -5
   ```

3. **Git History Analysis**
   ```bash
   # Blame - who/when changed it
   git blame -- <file>

   # Search history
   git log -S "problematic-code" --oneline
   git log --grep="keyword" --oneline

   # Binary search (if needed)
   git bisect start
   git bisect bad
   git bisect good <known-good>
   ```

4. **Find Introducing Commit**
   ```bash
   git show <commit-hash>
   git show --stat <commit-hash>
   git log --oneline <commit>~5..<commit>+5

   # Find associated PR
   git log --grep="Merge pull request" --oneline
   ```

5. **Check for Existing Fixes**
   ```bash
   git log --all --grep="fix.*<issue>"
   git branch -a --contains <commit>
   ```

6. **Document Root Cause**
   ```markdown
   ### Root Cause
   - **Introducing commit**: `<hash>` - "<message>"
   - **Author**: [author]
   - **PR**: #[number] (if applicable)
   - **Why it broke**: [Explanation]

   ### Evidence
   [Command outputs, code snippets, git history that support the RCA]

   ### Existing Fix?
   [Yes/No - details if yes]
   ```

7. **Validate RCA**

   Spawn a Task subagent (subagent_type: "general-purpose") with `skills/review-rca/SKILL.md` instructions to validate:
   - Is the root cause plausible?
   - Could alternative root causes exist?
   - Is the evidence sufficient?
   - Are there missing investigation steps?

   If the review identifies gaps, investigate further before proceeding.

8. **Update PROJECT.md**

   Write the validated RCA to PROJECT.md.

9. **Auto-Chain: Create Plan**

   After validated RCA is documented in PROJECT.md, automatically invoke `/create-plan`:
   - Pass the RCA context (root cause, evidence, introducing commit)
   - `/create-plan` will use this as the foundation for the fix plan

## Notes
- Always use git history first
- Find root cause, not just symptoms
- Prefer existing fixes over creating new ones
- Document with evidence (command outputs)
- Do NOT propose solutions — that's `/create-plan`'s job
