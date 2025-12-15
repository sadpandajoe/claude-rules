# /review - Code Review (Iterate to 8/10)

Code review using Codex, iterating until score ≥ 8/10.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/code-review.md` - Review criteria and scoring
3. `rules/orchestration.md` - Claude + Codex workflows

Do not proceed until rules are read and understood.

---

## Usage
```
/review                     # Review uncommitted changes (default)
/review --branch <name>     # Review branch vs main
/review --commit <sha>      # Review specific commit
```

## Steps

1. **Determine Scope**
   ```bash
   # Default: uncommitted changes
   git diff --stat
   git diff --staged --stat
   
   # Branch comparison
   git diff --stat main..<branch>
   
   # Specific commit
   git show --stat <sha>
   ```

2. **Gather Context**
   
   Codex needs **full context** to review properly, but should only **comment on changed code**.
   
   ```bash
   # Get list of changed files
   git diff --name-only > /tmp/changed-files.txt
   
   # Get the diff (to identify what changed)
   git diff > /tmp/review-diff.txt
   
   # Get full content of changed files (for context)
   # Codex will read these to understand usage, types, etc.
   ```

3. **Codex Review**
   ```
   codex exec --sandbox read-only "Review these code changes.
   
   CHANGED FILES:
   [list of files]
   
   DIFF (what changed):
   ---
   [diff content]
   ---
   
   INSTRUCTIONS:
   - Read the FULL files to understand context
   - Check if functions are called correctly
   - Check if return values are handled properly
   - Check if types match
   - Check integration with surrounding code
   
   BUT:
   - ONLY comment on CHANGED lines (shown in diff)
   - Do NOT flag pre-existing issues in unchanged code
   - Focus feedback on the new/modified code
   
   Score each dimension (1-10):
   1. **Correctness**: Logic errors, bugs, wrong usage?
   2. **Security**: Vulnerabilities introduced?
   3. **Performance**: Inefficiencies added?
   4. **Maintainability**: Readable, follows patterns?
   5. **Testing**: Test coverage for changes?
   
   For each issue:
   - [major] Must fix - blocks merge
   - [minor] Should fix - important but not blocking
   - [nitpick] Optional - style/preference
   
   Include file:line references for all issues.
   
   Format:
   ## Scores
   | Dimension | Score | Reason |
   
   ## Issues
   ### [major]
   - file.js:42 - [issue description]
   
   ### [minor]  
   ### [nitpick]
   
   ## Overall
   **Score: X.X/10**
   **Verdict**: Approve / Request Changes"
   ```

4. **Check Score**
   
   - **Score ≥ 8/10**: Review passed ✅
   - **Score < 8/10**: Continue to step 6

5. **Claude Fixes Issues** (if < 8/10)
   
   Address feedback by priority:
   1. All `[major]` issues first
   2. All `[minor]` issues
   3. `[nitpick]` if time permits
   
   ```markdown
   ### Review Round [N] - Fixes
   - [major] Fixed: [issue] → [solution]
   - [minor] Fixed: [issue] → [solution]
   ```

6. **Commit Fixes**
   ```bash
   git add <fixed-files>
   git commit -m "fix: address review feedback round [N]"
   ```

7. **Re-Review** (Loop)
   
   Return to step 3 with new diff.
   
   Continue until:
   - Score ≥ 8/10, OR
   - Max 5 rounds reached

8. **Final Report**
   ```markdown
   ## Code Review Complete
   
   ### Rounds: [N]
   | Round | Score | Key Fixes |
   |-------|-------|-----------|
   | 1 | 5.2 | Security issue, missing validation |
   | 2 | 7.1 | Error handling |
   | 3 | 8.4 | Minor cleanup |
   
   ### Final Score: X.X/10 ✅
   
   ### Remaining Notes
   [Any nitpicks not addressed]
   ```

## Scope Control

Codex reviews with **full context** but **scoped comments**:
- ✅ Reads full files to understand usage, types, integration
- ✅ Checks if functions called correctly
- ✅ Checks if return values handled properly
- ❌ Does NOT comment on unchanged code
- ❌ Does NOT flag pre-existing issues

This lets Codex catch issues like:
- Calling a function with wrong arguments
- Ignoring a return value that matters
- Type mismatches with existing code
- Breaking existing contracts

## Notes
- Iterates until 8/10 or max 5 rounds
- Claude fixes, Codex reviews
- Only diff content is reviewed
- All [major] must be fixed before passing
