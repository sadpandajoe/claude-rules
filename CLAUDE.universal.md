# Claude Code Universal Workflow Guidelines

## Core Principles (MUST READ FIRST)

### Essential Workflow - Golden Rule
- [ ] **IMMEDIATELY create/update PROJECT.md for ANY work request** - Even "plans" and "analysis" are project work
- [ ] **After reading workflow instructions, create PROJECT.md to acknowledge understanding** - Proves you're following the guidelines
- [ ] **ALL project documentation goes in PROJECT.md** - Never create separate documentation files, fancy formatting, or external plans
- [ ] **Never use TodoWrite for project work** - TodoWrite is for personal tasks only, not project documentation
- [ ] **Document BEFORE any action** - Plan first, then document the plan, then implement
- [ ] **Golden rule applies in ALL modes** - Planning mode, implementation mode, investigation mode - always use PROJECT.md
- [ ] Always read/create PROJECT.md before starting any work
- [ ] Document what you're doing before doing it (not after)
- [ ] Update PROJECT.md after completing each major step
- [ ] Never make code changes without planning and documenting first

### Investigation Rules
- [ ] When investigating issues, document findings before proposing solutions
- [ ] **Use historical analysis first** - git blame, commit comparison, and cross-branch investigation
- [ ] **Understand full scope before making changes** - identify root cause before attempting fixes
- [ ] **Prefer tested solutions over manual fixes** - look for existing solutions in other branches/commits
- [ ] Verify dependencies exist before using them
- [ ] Test incrementally - make small changes and verify

### Implementation Standards
- [ ] Plan all tests before writing any code
- [ ] Study existing patterns before creating new ones
- [ ] **Use evidence-based decisions** - research git history, existing solutions, and proven approaches
- [ ] **Choose conservative solutions when possible** - tested fixes over custom implementations
- [ ] Complete working solution before suggesting optimizations
- [ ] Commit working state before any refactoring

### Testing Principles
- [ ] Use fixtures as source of truth - no hardcoded test data
- [ ] Mock external boundaries only - test real internal behavior
- [ ] Assign tests to appropriate layers - don't duplicate logic
- [ ] Test user-observable behavior - not implementation details

### Communication Rules
- [ ] Be direct about errors and issues - no unnecessary apologies
- [ ] Keep responses concise unless detail is specifically requested
- [ ] Ask for clarification when requirements are unclear
- [ ] Request confirmation before making destructive changes

### Recovery Protocols
- [ ] Stop and assess before making any recovery attempts
- [ ] Use safe recovery options first (stash, checkout, reset)
- [ ] Document what broke and how it was fixed
- [ ] Create rollback points before major changes

## Workflow Files - Read Before Starting

### 📋 CLAUDE.planning.md - Project Setup & Documentation
**Key Focus:**
- Always create/read PROJECT.md first
- Document before acting, update after completing
- Maintain session continuity through Development Log
- Plan solutions with multiple options and trade-offs

### 🔍 CLAUDE.investigation.md - Problem Solving & Root Cause Analysis  
**Key Focus:**
- Document the problem before proposing solutions
- Find the introducing commit/PR when possible
- Use systematic debugging standards and evidence-based investigation
- Follow structured investigation process with multiple solution options

### 💻 CLAUDE.implementation.md - Coding & Development Standards
**Key Focus:**
- Follow existing patterns before creating new ones
- Complete working solution before suggesting optimizations  
- Code quality standards and dependency validation
- Pre-implementation planning and incremental development

### 🧪 CLAUDE.testing.md - Testing Strategy & Quality Standards
**Key Focus:**
- Contract-based testing with fixture-driven development
- Strategic mocking (external boundaries only, test real behavior)
- Layered testing approach with appropriate test assignment
- Test real user behavior, avoid over-mocking anti-patterns

### 🚨 CLAUDE.troubleshooting.md - Recovery & Emergency Procedures
**Key Focus:**
- Investigation vs recovery decision framework
- Document recovery process and communicate status
- Systematic post-recovery learning and prevention planning
- Emergency procedures with escalation guidelines

### 🍒 CLAUDE.cherry-picking.md - Cross-Branch Safety (Universal)
**Key Focus:**
- Understand full scope before cherry-picking
- Verify imports exist in target branch
- Separate functional from structural changes
- Conservative resolution with documented decisions

## Quick Reference

### When to Use Each Guide
- **Planning new work or project setup?** → CLAUDE.planning.md
- **Debugging issues or investigating problems?** → CLAUDE.investigation.md  
- **Writing code or implementing features?** → CLAUDE.implementation.md
- **Planning tests or improving test quality?** → CLAUDE.testing.md
- **Things broken and need recovery?** → CLAUDE.troubleshooting.md
- **Cherry-picking between branches?** → CLAUDE.cherry-picking.md

### Emergency Commands
```bash
# Safe recovery
git stash                      # Save current work safely
git reset --hard HEAD          # Revert to last commit
git status                     # Check current state

# Quick validation
grep -E "<<<|===|>>>" **/*     # Check for merge conflicts
git log --oneline -5           # Recent commit history

# Investigation basics
git blame -- file.ext          # Find when lines were last modified
git bisect start               # Systematic bug hunting
```

## Session Completion (When Ending Work)

### Standard Cleanup
- [ ] Ensure PROJECT.md reflects current state
- [ ] Document any in-progress work clearly
- [ ] Update Current Status to reflect actual progress

### Learning Capture & Process Improvement
- [ ] Review the session for new insights or better approaches
- [ ] **Document what worked well vs what could be improved** - capture success factors
- [ ] **Identify effective investigation techniques** - git blame, cross-branch analysis, evidence-based decisions
- [ ] Identify any workflow gaps or improvements discovered
- [ ] Update relevant CLAUDE.*.md files with new learnings

### Learning Update Process
1. Identify which workflow file the learning applies to:
   - Project local → `CLAUDE.local.md`
   - Core principles → `~/opt/code/claude-files/CLAUDE.universal.md`
   - Planning insights → `~/opt/code/claude-files/CLAUDE.planning.md`
   - Debugging discoveries → `~/opt/code/claude-files/CLAUDE.investigation.md`  
   - Implementation improvements → `~/opt/code/claude-files/CLAUDE.implementation.md`
   - Testing strategies → `~/opt/code/claude-files/CLAUDE.testing.md`
   - Recovery procedures → `~/opt/code/claude-files/CLAUDE.troubleshooting.md`
   - Cherry picking → `~/opt/code/claude-files/CLAUDE.cherry-picking.md`
2. Add to appropriate section (e.g., "Common Patterns", "Lessons Learned", "Best Practices")
3. Keep updates concise and actionable
4. Remove outdated practices that no longer work

## Using Project-Specific Guidelines

### Each project should have its own `CLAUDE.local.md` that:
1. **References universal guidelines first** - `~/opt/code/claude-files/`
2. **Adds project-specific overrides** - technology stack, validation commands, patterns
3. **Documents temporary notes** - project-specific context that doesn't belong in universal files

### Project CLAUDE.local.md Template
Use the template at: `~/opt/code/claude-files/CLAUDE.local-template.md`

Example structure:
```markdown
# Read Universal Guidelines First  
- ~/opt/code/claude-files/CLAUDE.universal.md
- ~/opt/code/claude-files/CLAUDE.*.md

# Project-Specific Core Principles
- Technology stack overrides
- Project-specific validation commands  
- Framework-specific patterns

# Project Intricacies
- Architecture-specific quirks and patterns
- Team collaboration details
- Current project state and evolution
```

## Lessons Learned

### Common Recovery Patterns
<!-- Add recovery strategies that have worked well -->

### Prevention Strategies
<!-- Add practices that prevent common issues -->

### Emergency Procedures
<!-- Add quick fixes for recurring problems -->

### Tool-Specific Recovery
<!-- Add recovery procedures for specific tools/frameworks -->