# Claude Universal Workflow Guidelines

## CRITICAL: Always Start Here
1. **Read all CLAUDE.*.md files** in `~/opt/code/claude-rules/` before starting work
2. **Create/update PROJECT.md immediately** using template from `~/opt/code/claude-files/PROJECT_TEMPLATE.md`
3. **Document BEFORE acting** - Plan in PROJECT.md, then execute
4. **Update PROJECT.md after ANY action** - Including thinking, planning, reading, executing

## Core Universal Principles

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
- Use version control history (`git blame`, `git log`, `git bisect`)
- Find root cause, not just symptoms
- Check if solution exists in other branches/commits
- Verify dependencies exist before using them
- **Prefer existing fixes over creating new ones**

### 💻 Implementation Standards
- Study existing patterns before creating new ones
- Match project conventions (indentation, naming, structure)
- **Add only files YOU modified** - Never use `git add -A` or `git add .`
- Validate each change before proceeding
- Commit working states frequently
- Keep functions/files manageable (guideline: <20 lines/function, <300 lines/file)

### 🧪 Testing Philosophy
- Test behavior, not implementation
- Use real/realistic test data (fixtures)
- Mock only external boundaries
- One test layer per concern (don't duplicate)
- Manual testing when automation unavailable

### 🚨 Recovery Principles
- Stop and assess before any recovery attempt
- Try safe recovery first (`git stash`, `git checkout`)
- Document what broke and how it was fixed
- Create rollback points before risky changes

### 🗣️ Communication Rules
- **Be direct about errors** - No unnecessary apologies, state the issue clearly
- **Show, don't just tell** - Include actual commands, outputs, and evidence
- **Explain reasoning** - Why choosing one approach over another
- **Full context in responses** - Include all relevant changes and findings
- **Ask for clarification** - Don't assume when requirements unclear
- **Request confirmation** - Before destructive changes or major decisions
- **Focus on practical solutions** - Implementable over theoretical
- **No hedging** - "This will" not "This should" when certain

## Quick Navigation Guide

| Situation | Use This Guide | Key Focus |
|-----------|---------------|-----------|
| Starting new work | `CLAUDE.planning.md` | PROJECT.md setup, document before acting, solution planning with trade-offs |
| Debugging issues | `CLAUDE.investigation.md` | Root cause analysis, git blame/bisect, evidence-based fixes |
| Writing code | `CLAUDE.implementation.md` | TDD, YAGNI, match patterns, working before optimizing |
| Creating tests | `CLAUDE.testing.md` | Behavior not implementation, fixture-driven, strategic mocking |
| System broken | `CLAUDE.troubleshooting.md` | Safe recovery first, document what broke, prevent recurrence |
| Cross-branch work | `CLAUDE.cherry-picking.md` | Verify dependencies, separate functional/structural, conservative |
| Reviewing code | `CLAUDE.code-review.md` | Constructive feedback, security focus, best practices |

## Universal Commands (Language-Agnostic)

```bash
# Investigation
git status                          # Current state
git log --oneline -10               # Recent history
git blame -- <file>                 # Who changed what when
git diff <branch1>..<branch2>       # Compare branches
git log -S "search-term"            # Find when code was added/removed

# Safe Recovery  
git stash                           # Save current work
git checkout -- .                   # Revert working directory
git reset --soft HEAD~1             # Undo commit, keep changes
git reset --hard HEAD               # Nuclear option - lose all changes

# Validation
grep -r "search-pattern" .          # Find in files
find . -name "*.ext"                # Find files by extension
ls -la <path>                       # Verify file/directory exists
```

## PROJECT.md Workflow

### Every Session
1. **Start**: Read PROJECT.md → Add timestamp to Development Log → Plan work
2. **During**: Document before ANY action → Update after ANY action
3. **End**: Update Current Status → Document blockers → Note next steps

### Key Sections to Maintain
- **Current Status**: What's active, next, blocked (keep current)
- **Development Log**: Timestamped narrative of work (append only)
- **Solutions**: Options under evaluation → Accepted → Failed
- **Implementation Notes**: Technical decisions, gotchas, patterns

## Decision Framework

### When Facing Choices
1. **Document multiple options** in Solutions section
2. **Evaluate each**: Risk, effort, maintainability, reversibility
3. **Choose based on evidence**: Existing solutions > custom fixes
4. **Document reasoning** in Accepted Solution
5. **Move failed attempts** to Failed Solutions with lessons learned

### Risk Assessment Scale
- **Low**: Proven solution, minimal changes, easy rollback
- **Medium**: Some unknowns, moderate changes, needs testing
- **High**: Many unknowns, broad changes, difficult rollback

## Language-Agnostic Patterns

### Investigation Pattern
```
1. Reproduce issue
2. Check version control history  
3. Compare working vs broken states
4. Identify introducing change
5. Understand why it broke
6. Find existing fix or create minimal one
```

### Implementation Pattern
```
1. Understand requirements
2. Study existing code patterns
3. Plan approach in PROJECT.md
4. Implement incrementally
5. Validate each step
6. Commit working state
7. Optimize if needed
```

### Testing Pattern
```
1. Identify what needs testing
2. Choose appropriate test layer
3. Use realistic test data
4. Test behavior not implementation
5. Mock only external dependencies
6. Verify test actually catches issues
```

## Project-Specific Integration

### Project CLAUDE.md
Each project should have its own `CLAUDE.md` that includes:
- Reference to universal guidelines (`~/opt/code/claude-rules/`)
- Technology stack (language, framework, tools)
- Project-specific commands (build, test, validate)
- Project patterns and conventions
- Known issues and gotchas

### Override Hierarchy
1. Universal principles (these files) - Always apply
2. Project-specific CLAUDE.md - Adds project context
3. PROJECT.md current state - Most immediate context

## When to Update Universal Files

### Update These Files When
- **Pattern applies across multiple projects** - Not just current project
- **Found clearer way to explain existing rule** - Improve clarity for future use
- **Existing rule consistently causes problems** - Document exception or update rule
- **Discovered new universal tool/technique** - Proven valuable across projects
- **Rule is consistently ignored or impractical** - Reassess if rule should exist

### How to Update Universal Files
1. **Add to "Lessons Learned" section** of the appropriate file
2. **Include context** - Why the change/addition is needed
3. **Explain failures** - If modifying existing rule, explain why original didn't work
4. **Keep language-agnostic** - Mark language-specific items clearly
5. **Test across projects** - Ensure change doesn't break other workflows

### What Belongs in Universal vs Project
| Universal Files | Project CLAUDE.md |
|----------------|-------------------|
| Patterns that work everywhere | Project-specific commands |
| Language-agnostic principles | Tech stack details |
| Git workflows | Local development setup |
| Communication standards | Team conventions |
| General best practices | Domain-specific rules |

## Best Practices Checklist

### Before Starting Work
- [ ] Read/create PROJECT.md
- [ ] Understand current status
- [ ] Plan approach
- [ ] Document plan

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

## Lessons Learned Using These Guidelines
<!-- Add experiences when guidelines needed adjustment or clarification -->
<!-- Document when rules were intentionally broken and why -->
<!-- Capture patterns that emerge across multiple projects -->
<!-- Note which rules prove most/least valuable in practice -->

## Remember
- **These principles apply to ANY language, framework, or project type**
- **When in doubt, document in PROJECT.md and proceed incrementally**
- **Evidence-based decisions beat assumptions every time**
- **Working code with documentation beats perfect code without**
