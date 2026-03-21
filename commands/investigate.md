# /investigate - Investigation & Root Cause

@/Users/joeli/opt/code/claude-rules/rules/investigation.md

> **When**: Something is broken and you need to find why.
> **Produces**: Root cause analysis documented in PROJECT.md, validated by review-rca skill.

## Steps

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
