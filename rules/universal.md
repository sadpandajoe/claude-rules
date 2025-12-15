# Claude Universal Workflow Guidelines

## CRITICAL: Always Start Here
1. **Read `CLAUDE.orchestration.md`** - Understand tool roles (Claude Code vs Codex MCP)
2. **Identify your workflow** - New feature? Bug fix? Code review? (see Workflow Selection)
3. **Create/update PROJECT.md** - Using `PROJECT_TEMPLATE.md`
4. **Document BEFORE acting** - Plan in PROJECT.md, then execute
5. **Update PROJECT.md after ANY action** - Including thinking, planning, reading, executing

## Tool Roles (Summary)

| Tool | Role | Use For |
|------|------|---------|
| **Claude Code** | Tech Lead | Planning, investigation, complex reasoning, verification, commits |
| **Codex MCP** | Fast Implementer | Bounded tasks, code review, boilerplate, mechanical transforms |

**Full details**: See `CLAUDE.orchestration.md`

## Workflow Selection

| Situation | Workflow | Start With |
|-----------|----------|------------|
| Building something new | New Feature | `CLAUDE.planning.md` |
| Something's broken | Bug Fix | `CLAUDE.investigation.md` |
| Reviewing someone's PR | Code Review | `CLAUDE.code-review.md` |
| Production incident | Root Cause Analysis | `CLAUDE.investigation.md` |
| Improving existing code | Refactoring | `CLAUDE.planning.md` |
| System in bad state | Recovery | `CLAUDE.troubleshooting.md` |
| Cross-branch work | Cherry-Pick | `CLAUDE.cherry-picking.md` |

**Full workflow diagrams**: See `CLAUDE.orchestration.md`

## Core Principles

### 🎯 Golden Rules (Apply to EVERY Project)
- **PROJECT.md is the single source of truth** - All documentation goes there
- **Evidence over assumptions** - Use version control history, test results, existing solutions
- **Working solution before optimization** - Get it working, commit, then improve
- **Incremental progress** - Small, verified changes over big risky ones
- **Document decisions and reasoning** - Future maintainers need context
- **TDD and YAGNI** - Test first, build only what's needed now

### 🔍 Investigation First
- Document the problem completely before proposing solutions
- **Always use git blame/bisect** to find introducing commits
- Find root cause, not just symptoms
- Check if solution exists in other branches/commits
- **Prefer existing fixes over creating new ones**

**Full details**: See `CLAUDE.investigation.md`

### 💻 Implementation Standards
- Study existing patterns before creating new ones
- Match project conventions
- **Add only files YOU modified** - Never use `git add -A` or `git add .`
- Commit working states frequently

**Full details**: See `CLAUDE.implementation.md`

### 🧪 Testing Philosophy
- Test behavior, not implementation
- Use real/realistic test data (fixtures)
- Mock only external boundaries

**Full details**: See `CLAUDE.testing.md`

### 🚨 Recovery Principles
- Stop and assess before any recovery attempt
- Try safe recovery first
- Document what broke and how it was fixed

**Full details**: See `CLAUDE.troubleshooting.md`

### 🗣️ Communication Rules
- **Be direct about errors** - No unnecessary apologies
- **Show, don't tell** - Include actual commands, outputs, evidence
- **Explain reasoning** - Why one approach over another
- **Ask for clarification** - Don't assume when unclear
- **Request confirmation** - Before destructive changes

## Quick Reference

### File Guide

| File | Purpose |
|------|---------|
| `CLAUDE.orchestration.md` | Multi-tool workflows, delegation framework |
| `CLAUDE.planning.md` | Planning, documentation, PROJECT.md workflow |
| `CLAUDE.investigation.md` | Root cause analysis, debugging, git history |
| `CLAUDE.implementation.md` | Code development, TDD, patterns |
| `CLAUDE.testing.md` | Test strategy, fixtures, mocking |
| `CLAUDE.troubleshooting.md` | Emergency recovery, git recovery |
| `CLAUDE.cherry-picking.md` | Cross-branch work, backports |
| `CLAUDE.code-review.md` | Review guidelines, scoring framework |
| `PROJECT_TEMPLATE.md` | Template for PROJECT.md |

### Essential Commands

```bash
# Investigation (see investigation.md for full details)
git status                          # Current state
git log --oneline -10               # Recent history  
git blame -- <file>                 # Who changed what
git diff <branch1>..<branch2>       # Compare branches
git log -S "search-term"            # Find code changes

# Safe Recovery (see troubleshooting.md for full details)
git stash                           # Save current work
git checkout -- .                   # Revert working directory
git reset --soft HEAD~1             # Undo commit, keep changes
```

## PROJECT.md Workflow

### Every Session
1. **Start**: Read PROJECT.md → Add timestamp → Plan work
2. **During**: Document before ANY action → Update after ANY action
3. **End**: Update Current Status → Document blockers → Note next steps

### Key Sections
- **Current Status**: What's active, next, blocked
- **Development Log**: Timestamped narrative (append only)
- **Solutions**: Options → Accepted → Failed
- **Implementation Notes**: Technical decisions, gotchas

## Decision Framework

### When Facing Choices
1. **Document options** in Solutions section
2. **Evaluate**: Risk, effort, maintainability, reversibility
3. **Choose based on evidence**: Existing solutions > custom fixes
4. **Document reasoning** in Accepted Solution
5. **Move failures** to Failed Solutions with lessons

### Risk Scale
- **Low**: Proven solution, minimal changes, easy rollback
- **Medium**: Some unknowns, moderate changes, needs testing
- **High**: Many unknowns, broad changes, difficult rollback

## Override Hierarchy

1. **Universal principles** (this file) - Always apply
2. **Orchestration rules** (`orchestration.md`) - Multi-tool workflows
3. **Domain-specific guides** (other CLAUDE.*.md) - Detailed practices
4. **Project-specific CLAUDE.md** - Project context
5. **PROJECT.md current state** - Most immediate context

## When to Update Universal Files

### Update When
- Pattern applies across multiple projects
- Found clearer way to explain existing rule
- Existing rule consistently causes problems
- Discovered new universal tool/technique

### What Belongs Where

| Universal Files | Project CLAUDE.md |
|----------------|-------------------|
| Patterns that work everywhere | Project-specific commands |
| Language-agnostic principles | Tech stack details |
| Git workflows | Local development setup |
| Communication standards | Team conventions |
| Multi-tool orchestration | Domain-specific rules |

## Best Practices Checklist

### Before Starting Work
- [ ] Identify workflow type
- [ ] Read/create PROJECT.md
- [ ] Understand current status
- [ ] Plan approach

### During Work
- [ ] Small, verified changes
- [ ] Match existing patterns
- [ ] Update documentation
- [ ] Commit working states

### Before Completing
- [ ] Validate changes work
- [ ] Update PROJECT.md
- [ ] Clean up temporary code
- [ ] Document lessons learned

## Remember
- **These principles apply to ANY language, framework, or project**
- **Claude Code is the tech lead; Codex MCP is fast implementation**
- **When in doubt, document in PROJECT.md and proceed incrementally**
- **Evidence-based decisions beat assumptions every time**
- **Working code with documentation beats perfect code without**

## Lessons Learned
<!-- Document when guidelines needed adjustment -->
<!-- Capture patterns that emerge across projects -->
<!-- Note which rules prove most/least valuable -->
