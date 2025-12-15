# /archive - Archive Completed Work

Move completed phases from PROJECT.md to PROJECT_ARCHIVE.md.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/planning.md` - PROJECT.md structure

Do not proceed until rules are read and understood.

---

## When to Archive

**Good times:**
- After investigation completes and solution chosen
- After feature implemented and merged
- After major refactoring finishes
- When PROJECT.md becomes hard to navigate
- Before starting new major phase

**Don't archive yet if:**
- Work still in progress
- Solution not validated
- Tests still failing
- Under active review

## Steps

1. **Identify What to Archive**
   
   Ask user: "What phase would you like to archive?"
   
   Common phases:
   - Completed investigation
   - Implemented feature
   - Finished refactoring
   - Closed milestone

2. **Read Current PROJECT.md**
   ```bash
   cat PROJECT.md
   ```

3. **Determine Sections to Archive**
   
   **Archive these:**
   - ✅ Completed investigation timelines
   - ✅ Failed Solutions (once solution working)
   - ✅ Old Development Log entries
   - ✅ Resolved blockers
   - ✅ Completed implementation notes
   
   **Keep in PROJECT.md:**
   - ❌ Current Status
   - ❌ Active/In Progress work
   - ❌ Recent Development Log (last few entries)
   - ❌ Open blockers
   - ❌ Next steps

4. **Create Archive Entry**
   ```markdown
   # PROJECT_ARCHIVE.md
   
   ---
   
   ## Archive: [Phase Name] - [Date]
   
   ### Summary
   - **Timeline**: [Start] to [End]
   - **Goal**: [What we tried to accomplish]
   - **Outcome**: [What actually happened]
   - **Key Commits**: [sha1, sha2]
   
   ### Key Decisions
   - [Decision 1 and why]
   - [Decision 2 and why]
   
   ### Lessons Learned
   - [Learning 1]
   - [Learning 2]
   
   ---
   
   ### Full Details
   
   [Paste archived sections here]
   ```

5. **Update PROJECT.md**
   
   Replace archived sections with reference:
   ```markdown
   ## Previous Work
   
   ### [Phase Name] - Completed [Date]
   [1-2 sentence summary]
   See PROJECT_ARCHIVE.md for details.
   
   ---
   
   ## Current Status
   [Continue with active work]
   ```

6. **Write Archive File**
   
   Create/append to PROJECT_ARCHIVE.md.

7. **Update PROJECT.md**
   
   Remove archived sections, add reference.

8. **Log Archiving**
   ```markdown
   ### [Timestamp] - Archived: [Phase Name]
   - Moved [X] sections to PROJECT_ARCHIVE.md
   - Reason: [Why archived]
   - PROJECT.md focus now: [Current work]
   ```

9. **Verify**
   - [ ] Archive file created/updated
   - [ ] Critical info preserved
   - [ ] PROJECT.md more concise
   - [ ] References work

## Example Result

**PROJECT.md (after):**
```markdown
## Overview
[unchanged]

## Previous Work
### Auth Investigation - Completed 2025-01-15
Found issue in middleware. Fixed in PR #123.
See PROJECT_ARCHIVE.md.

## Current Status
**In Progress**: Performance optimization
**Next**: Deploy to staging
```

**PROJECT_ARCHIVE.md:**
```markdown
## Archive: Auth Investigation - 2025-01-15

### Summary
- Timeline: 2025-01-10 to 2025-01-15
- Goal: Fix intermittent auth failures
- Outcome: Root cause in middleware, fixed

### Key Decisions
- Chose Option 2 (proper fix over quick patch)

[Full investigation details, timeline, failed attempts...]
```

## Notes
- Archive completed phases, don't delete
- Keep PROJECT.md focused on current work
- Searchable history in archive
- Run when context gets too large
