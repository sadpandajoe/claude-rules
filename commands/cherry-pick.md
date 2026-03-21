# /cherry-pick - Cherry-Pick a Single Change

@/Users/joeli/opt/code/claude-rules/rules/cherry-picking.md

> **When**: Moving a specific change (bug fix, isolated feature) to another branch.
> **Produces**: Clean cherry-pick with conflicts resolved, documented in PROJECT.md.

## Usage
```
/cherry-pick <pr-url>                   # Cherry-pick from a PR
/cherry-pick <sha>                      # Cherry-pick a specific commit
/cherry-pick <sha> --target <branch>    # Cherry-pick to specific branch
```

## Steps

1. **Identify the Change**

   From PR URL: use `gh pr view` to get merge commit and files changed.
   From SHA: use `git show --stat` to understand the commit.

   ```bash
   git show --stat <commit-hash>
   git log --oneline <commit>~5..<commit>+5
   ```

2. **Pre-Analysis**

   Check compatibility with target branch:
   ```bash
   # Compare dependencies
   git diff <target>..<source> -- package.json requirements.txt go.mod

   # Check if modules exist in target
   git ls-tree <target> -- <path/to/module>

   # Compare imports
   git show <source>:<file> | grep "import\|require"
   git show <target>:<file> | grep "import\|require"
   ```

   Classification:
   - [ ] Functional (logic, algorithms) → Usually safe
   - [ ] Structural (architecture) → Usually reject
   - [ ] Dependencies → Verify exist

3. **Execute Cherry-Pick**
   ```bash
   git checkout <target-branch>
   git cherry-pick -x <commit-hash>
   ```
   Always use `-x` to preserve the source commit reference.

4. **Handle Conflicts**

   If conflicts occur, first verify cherry-pick state:
   ```bash
   # Verify cherry-pick is in progress
   test -f .git/CHERRY_PICK_HEAD && echo "Cherry-pick active" || echo "WARNING: No active cherry-pick"
   ```

   **If `.git/CHERRY_PICK_HEAD` does not exist**: the cherry-pick state was lost. Do NOT run `--continue`. Instead, re-run the cherry-pick from step 3.

   Determine the cause of conflicts:

   **Option A: Resolvable conflicts**
   Spawn parallel Task subagents — one per conflicting file:
   - Pass each agent: the file's conflict diff, target branch context, source intent
   - Each agent resolves its file independently and explains the resolution
   - Agents run in parallel for speed

   After all agents complete, collect resolutions and apply:
   ```bash
   git add <resolved-files>
   # Verify cherry-pick state is still active
   test -f .git/CHERRY_PICK_HEAD
   git cherry-pick --continue
   ```

   **Option B: Missing prerequisite**
   If the conflict is caused by a missing prior change:
   - Identify the prerequisite commit(s) using `git log` and `git blame`
   - Present to user: "This cherry-pick depends on `<sha>` — cherry-pick that first?"
   - If yes, recurse: cherry-pick the prerequisite first, then retry

   Decision framework:
   - **Import conflict**: Module exists in target? If not → find prerequisite or reject
   - **Structure conflict**: Extract functional changes only
   - **API conflict**: Adapt to target's API

5. **Validate**
   ```bash
   # No conflict markers
   grep -rE "<<<|===|>>>" .

   # Builds
   [language-specific build]

   # Tests pass
   [language-specific tests]
   ```

6. **Document**
   ```markdown
   ## Cherry-Pick: [Feature]

   ### Source
   - **Commit**: `<hash>`
   - **Branch**: <source>
   - **PR**: #[number]

   ### Accepted
   - [What was taken]

   ### Adapted
   - [What was modified and why]

   ### Rejected
   - [What was excluded and why]

   ### Prerequisites
   - [Any commits cherry-picked first to enable this one]
   ```

## Chained Cherry-Pick Safety

When cherry-picking multiple commits in sequence:
- Verify each cherry-pick completes before starting the next
- If one fails mid-chain, do NOT continue with subsequent picks
- Clean up the failed state (`git cherry-pick --abort`) before deciding next steps
- Document which picks succeeded and which didn't

## Notes
- Always use `cherry-pick -x` to preserve source reference
- Always verify `.git/CHERRY_PICK_HEAD` before `--continue`
- Always use `cherry-pick --continue` after resolving conflicts (preserves author + metadata)
- Prefer functional over structural changes
- When in doubt, reject
- For multiple PRs, use `/cherry-plan` first to determine order
