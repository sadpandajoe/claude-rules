# /review-issue - Verify Bug Across Branches

> **When**: You have a bug report and need to know if it exists in your
>   current branch, master, or both — and find the fixing commit if applicable.
> **Produces**: Branch status matrix. If fixed elsewhere, the fixing commit
>   hash ready for `/cherry-pick`.

## Steps

1. **Understand the Bug**
   - Read the bug report / issue description
   - Identify affected code paths and files
   - Determine reproduction criteria (what makes it a bug)

2. **Check Current Branch**
   - Read the relevant code on current branch
   - Does the buggy pattern exist?
   - Run the failing scenario if possible
   - Record: EXISTS or FIXED

3. **Check Master**
   - Compare the same code paths on master
   ```bash
   git show master:<file>
   git diff HEAD..master -- <affected-files>
   ```
   - Record: EXISTS or FIXED

4. **Branch Status Matrix**

   | Current Branch | Master | Action |
   |---------------|--------|--------|
   | EXISTS | EXISTS | Bug is unfixed everywhere → `/investigate` |
   | EXISTS | FIXED | Find fixing commit → `/cherry-pick -x` |
   | FIXED | EXISTS | Your branch has the fix already |
   | FIXED | FIXED | Bug is resolved everywhere |

5. **Find Fixing Commit** (when EXISTS in branch, FIXED in master)
   ```bash
   git log master -S "relevant-code-pattern" --oneline
   git log master --all --grep="bug-keyword" --oneline
   git log master -- <affected-files> --oneline
   ```
   - Identify the commit that introduced the fix
   - Verify by checking the commit's diff

6. **Recommend Next Step**
   - If cherry-pick needed: provide commit hash, recommend `/cherry-pick`
   - If unfixed everywhere: recommend `/investigate`
   - If already fixed: close the issue

7. **Update PROJECT.md**
   - Document findings in Development Log
   - Update Current Status
