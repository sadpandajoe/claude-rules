# /cherry-plan - Plan Cherry-Pick Order for Multiple Changes

@/Users/joeli/opt/code/ai-toolkit/rules/cherry-picking.md

> **When**: You have multiple PRs/commits to cherry-pick and need to determine the right order.
> **Produces**: Ordered cherry-pick sequence with dependency analysis.

## Usage
```
/cherry-plan <pr-url-1> <pr-url-2> <pr-url-3>
/cherry-plan <sha-1> <sha-2> <sha-3>
/cherry-plan <sha-1> <sha-2> --target <branch>
```

## Steps

1. **Gather Change Details**

   For each PR/SHA, spawn parallel Task subagents (subagent_type: "general-purpose") to analyze:
   - Files changed
   - Functions/modules added or modified
   - Dependencies introduced (imports, new modules, schema changes)
   - What the change assumes already exists in the codebase

2. **Build Dependency Graph**

   From the parallel analysis, determine:
   - Which changes touch the same files
   - Which changes depend on modules/functions introduced by other changes
   - Which changes are fully independent

   ```markdown
   ## Dependency Graph

   | Change | Depends On | Independent |
   |--------|-----------|-------------|
   | PR #101 (auth middleware) | — | Yes |
   | PR #105 (auth endpoints) | PR #101 | No |
   | PR #110 (logging) | — | Yes |
   | PR #112 (auth logging) | PR #101, PR #110 | No |
   ```

3. **Determine Order**

   Topological sort of the dependency graph:
   1. Independent changes first (no dependencies)
   2. Then changes whose dependencies are satisfied
   3. Flag circular dependencies as blockers

4. **Dry-Run Validation**

   For each change in the proposed order:
   ```bash
   git cherry-pick --no-commit <sha>
   git diff --stat
   git cherry-pick --abort
   ```
   Verify it would apply cleanly in sequence.

5. **Present Plan**

   ```markdown
   ## Cherry-Pick Plan

   ### Target Branch: <branch>

   ### Sequence
   1. `<sha>` — PR #101: Auth middleware (independent)
   2. `<sha>` — PR #110: Logging (independent)
   3. `<sha>` — PR #105: Auth endpoints (depends on #101)
   4. `<sha>` — PR #112: Auth logging (depends on #101, #110)

   ### Conflicts Expected
   - Step 3 may conflict in `auth/routes.ts` — PR #101 changes the same area

   ### Excluded
   - [Any changes that can't be cleanly cherry-picked and why]

   ### Ready to proceed?
   Run `/cherry-pick <sha>` for each in order, or I can execute the sequence.
   ```

## Notes
- Parallel analysis for speed — one subagent per PR
- Dry-run catches conflicts before committing to an order
- Independent changes can be cherry-picked in any order
- If circular dependencies exist, flag and ask user to resolve
