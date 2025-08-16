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

## Plan Mode Integration

### When to Use Plan Mode
- **Complex investigations** requiring systematic research
- **Multi-step implementation** with significant risk
- **Architecture analysis** before making changes
- **Cross-branch work** requiring careful compatibility assessment

### Plan Mode to Implementation Transition
Clear indicators for transitioning from planning to execution:

#### Investigation Tasks
- **Continue planning while**: Root cause unclear, multiple hypotheses to test, solution approach uncertain
- **Transition to implementation when**: Root cause identified, solution confirmed (e.g., fix exists in another branch), approach validated
- **Document transition**: Update PROJECT.md with "Investigation Complete - Moving to Implementation"

#### Implementation Tasks  
- **Continue planning while**: Architecture decisions uncertain, multiple technical approaches possible, risk assessment incomplete
- **Transition to implementation when**: Technical approach confirmed, dependencies validated, acceptance criteria clear
- **Document transition**: Update Current Status from "Planning" to "Implementation"

### Plan Mode Documentation Strategy
- **Heavy documentation upfront**: More detailed analysis in PROJECT.md Solutions section
- **Research-focused Development Log**: Document investigation findings, hypothesis testing, discovery process
- **Thorough solution analysis**: Multiple options with detailed pros/cons before choosing approach

### Current Status Format
Use a simple progress summary instead of rigid checklists:

```markdown
## Current Status
**In Progress**: [Brief description of current work]
**Next**: [What's planned next]
**Blocked**: [Any blockers, or "None"]
```

### Status Update Rules
- Update Current Status summary when major phases change
- Use Development Log for detailed progress tracking
- Document blockers immediately when encountered
- Keep status summary concise - details go in Development Log

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

### Workflow Hierarchy Effectiveness
The instruction hierarchy has proven successful:
1. **Universal guidelines** → Guide to appropriate specialized files
2. **Specialized files** (Investigation, Cherry-picking) → Structured approach for specific tasks
3. **Project-specific guidelines** → Technology and architecture context
4. **Evidence-based investigation** → Direct path to root cause and tested solutions

### Common Patterns
- **PROJECT.md-first approach** maintains organization throughout complex tasks
- **Historical analysis focus** (git blame, commit comparison) essential for debugging
- **Conservative resolution guidance** helps choose tested solutions over manual patches
- **Cross-branch comparison** instructions directly applicable to real scenarios

### Best Practices
- **Plan mode for investigation** works well when root cause unclear
- **Clear transition points** from research to implementation prevent confusion
- **Evidence-based decisions** using git history and existing fixes
- **Documentation during process** prevents context loss

### Pitfalls to Avoid
- **Jumping to solutions** without understanding root cause
- **Manual changes** instead of using tested fixes from other branches
- **Skipping documentation** during investigation process
- **Unclear mode transitions** leaving team uncertain about current phase

### Process Improvements
- **Plan mode integration** clarifies when to research vs implement
- **Transition documentation** makes phase changes explicit
- **Success factor identification** helps replicate effective approaches
- **Pitfall prevention** builds on real experience avoiding common mistakes