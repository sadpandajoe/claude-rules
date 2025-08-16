# Project Planning & Documentation Workflow

## Project Initialization

### New Project Setup
1. [ ] Create PROJECT.md in repo root using the template below
2. [ ] Fill out Overview, Goal, and Assumptions based on initial request
3. [ ] Document initial understanding in Implementation Notes
4. [ ] Set up Current Status with preliminary task breakdown
5. [ ] Add first entry to Development Log with timestamp

### Existing Project Continuation
1. [ ] Read PROJECT.md completely
2. [ ] Review Development Log to understand what's been done
3. [ ] Check Current Status to see what's in progress/blocked
4. [ ] Add new session entry to Development Log with timestamp

## PROJECT.md Template

Use the template located at: `~/opt/code/claude-files/PROJECT_TEMPLATE.md`
- Make a copy of the project template inside the repo
- This will be the single source of truth for all actions and knowledge for the work

## Documentation Workflow

### Before Any Action
**CRITICAL**: Document your plan BEFORE taking any action

Update PROJECT.md with:
- [ ] **What you plan to do and why** (in Development Log)
- [ ] **Expected approach and steps** (before attempting)
- [ ] **Anticipated outcome** (what you expect to happen)

### After Completing Actions
Update PROJECT.md with:
- [ ] **What actually happened** (vs what was planned)
- [ ] **Key findings or discoveries** (any surprises)
- [ ] **Any changes to approach or understanding** (deviations from plan)
- [ ] **Updated Current Status** (move items between Not Started/In Progress/Done/Blocked)

### This Applies To All Actions
- Git operations (diff, status, log, etc.)
- File analysis or reading
- Code changes or creation
- Testing or validation
- Problem investigation
- Manual accept requests
- Any work-related activity

## Solution Planning Process

### When Planning Solutions
Document in PROJECT.md "Solutions" section:
- **Multiple options** with pros/cons/risks for each
- **Risk assessment** for each approach
- **Impact analysis** on existing functionality
- **Clear recommendation** with reasoning

### Solution Analysis Framework
For each option, include:
- Risk level assessment
- Impact on existing functionality
- Future maintenance implications
- Resource requirements
- Timeline considerations

### Moving Solutions Between Categories
- Start in "Solutions" during evaluation
- Move chosen option to "Accepted Solution"
- Move failed attempts to "Failed Solutions" with explanation
- Update "Implementation Notes" with insights gained

## Status Management

### Status Categories
- **Not Started**: Tasks identified but not begun
- **In Progress**: Currently working on
- **Done**: Completed tasks  
- **Blocked**: Cannot proceed due to external dependency/issue

### Status Update Rules
- Update status movement in Development Log for context
- When moving to "Blocked", document what's needed to unblock
- When completing items, note any deviations from plan
- Break down large tasks into smaller trackable items

## Session Continuity

### Starting Any Session
- [ ] Read PROJECT.md completely
- [ ] Understand current project state
- [ ] Add timestamped session start entry to Development Log
- [ ] Review any blocked items to see if they can be unblocked

### Maintaining Context
- All discoveries and decisions must be documented
- Development Log should tell the complete story
- Anyone should be able to pick up work by reading PROJECT.md
- Never assume previous context will be remembered

## Template Universality

This workflow applies to all development work:
- New features
- Bug fixes
- Refactoring  
- Infrastructure changes
- Documentation updates
- Code reviews
- Testing

The PROJECT.md template is flexible enough to accommodate any project type through the Goal and Implementation Notes sections.

## Lessons Learned

### Common Patterns
<!-- Add insights discovered through experience -->

### Best Practices
<!-- Add practices that consistently work well -->

### Pitfalls to Avoid
<!-- Add mistakes that have been made before -->

### Process Improvements
<!-- Add workflow enhancements discovered over time -->
