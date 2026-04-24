# Worked Example: Archiving the Auth Investigation

A concrete before/after for what the templates produce in practice. Use this when you're unsure how the breadcrumb and archive entry should look.

## PROJECT.md after archiving

```markdown
## Overview
[unchanged]

## Previous Work

### Auth Investigation — Completed 2025-01-15
Found issue in middleware (token caching race condition). Fixed in PR #123.
See PROJECT_ARCHIVE.md.

## Current Status
**In Progress**: Performance optimization
**Next**: Deploy to staging
```

## PROJECT_ARCHIVE.md (newly appended)

```markdown
---

## Archive: Auth Investigation — 2025-01-15

### Summary
- Timeline: 2025-01-10 to 2025-01-15
- Goal: Fix intermittent auth failures reported by SRE
- Outcome: Root cause in middleware token caching; fixed in PR #123
- Key Commits: a1b2c3d, e4f5g6h

### Key Decisions
- Chose Option 2 (proper fix in middleware) over Option 1 (quick patch in route handler) — quick patch would have masked the cache invalidation bug and let it recur in adjacent flows

### Lessons Learned
- Token caching with TTL needs explicit invalidation on logout, not just expiry
- Integration tests for the middleware caught the race condition that unit tests missed

---

### Full Details

[Full investigation timeline, failed attempts, and resolution detail pasted verbatim from PROJECT.md]
```

## Development Log entry that captures the operation

```markdown
### 2025-01-15T14:30 — Archived: Auth Investigation
- Moved 4 sections to PROJECT_ARCHIVE.md
- Reason: Phase complete, fix merged in PR #123
- PROJECT.md focus now: Performance optimization
```

## Why this shape

- The breadcrumb in PROJECT.md is small enough to skim past when looking for active work
- The archive entry preserves enough context to rehydrate the investigation later
- Decisions and lessons are captured separately from the raw timeline so readers can extract reusable knowledge without re-reading everything
