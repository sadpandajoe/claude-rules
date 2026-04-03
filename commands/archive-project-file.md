---
model: sonnet
---

# /archive-project-file - Archive Completed Work

> **When**: A project/feature is done and needs to be preserved.
> **Produces**: Archived PROJECT.md and metadata.

This command should be owned by one main agent.
Do not split the write across multiple agents — the archive boundary, breadcrumb, and preserved active context must stay consistent.

## Contract

### Goal
Keep PROJECT.md focused on active work by moving completed-phase detail into PROJECT_ARCHIVE.md.

### In Scope
- completed investigations, implementations, milestones, and resolved blockers
- older log sections that are no longer needed for active execution
- leaving a short summary and reference behind in PROJECT.md

### Out of Scope
- active work
- current status
- current continuation checkpoint
- anything still needed for the next immediate phase

## When to Archive

**Good times:**
- After a major phase is complete and no longer active
- After feature implementation is merged and follow-up work is minimal
- After major refactoring finishes
- When PROJECT.md becomes hard to navigate
- Before starting new major phase

**Don't archive yet if:**
- Work still in progress
- Solution not validated
- Tests still failing
- Under active review
- The archived material is still needed for the next immediate phase

## Steps

1. **Identify What to Archive**

   Infer the best archive candidate from PROJECT.md first.

   Common candidates:
   - completed investigation
   - implemented feature
   - finished refactoring
   - closed milestone

   Only ask the user if multiple archive candidates are equally plausible or if the boundary is unclear.
   If there is one clear completed phase, proceed automatically once the command is invoked.

2. **Read Current PROJECT.md**

   Use the `Read` tool to view PROJECT.md contents.

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
   - ❌ Current continuation checkpoint
   - ❌ Anything needed for the next immediate phase

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

   Leave a short breadcrumb only:
   - phase name and completion date
   - 1-3 sentence summary
   - pointer to `PROJECT_ARCHIVE.md`

6. **Write Archive File**
   
   Append to PROJECT_ARCHIVE.md.
   Preserve prior archive history; do not rewrite old archive entries unless explicitly needed.

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
- Use when completed phases are cluttering active work, not as a substitute for checkpointing
- Once invoked, auto-archive the clear candidate rather than pausing for routine confirmation
- Ask only when the archive boundary is genuinely ambiguous
