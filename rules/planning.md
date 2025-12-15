# Planning & Documentation Workflow

## Project Initialization

### New Project
1. Create PROJECT.md using `PROJECT_TEMPLATE.md`
2. Fill Overview, Goal, Assumptions from requirements
3. Set up Current Status with preliminary breakdown
4. Add first Development Log entry with timestamp

### Existing Project
1. Read PROJECT.md completely
2. Review Development Log for context
3. Check Current Status for active/blocked work
4. Add new session entry with timestamp

## Documentation Workflow

### Before Any Action
Document in PROJECT.md:
- What you plan to do and why
- Expected approach
- Risk assessment (if applicable)

### After Any Action
Update PROJECT.md:
- What actually happened
- Key findings
- Updated Current Status

### Applies To ALL Activities
Version control, file analysis, code changes, testing, investigation

## Solution Planning

### Workflow
1. **Document options** in Solutions section (all possibilities)
2. **Try an option** → Log in Development Log
3. **If fails** → Move to Failed Solutions with why
4. **If works** → Move to Accepted Solution when FULLY working

### Solution Template
```markdown
#### Option N: [Name]
- **Approach**: [Description]
- **Pros**: [Benefits]
- **Cons**: [Drawbacks]  
- **Risk**: Low/Medium/High
```

## Plan Mode

When in plan mode, Claude should:
- **Read and update PROJECT.md** - This is expected and encouraged
- **Explore codebase** - Understand existing patterns and constraints
- **Document findings** - Add to PROJECT.md as you learn
- **Iterate on the plan** - Refine based on discoveries

Plan mode is for active planning work, not just reading.

## Planning vs Implementation

### Stay in Planning When
- Root cause unclear
- Multiple approaches possible
- Risk assessment incomplete
- Dependencies unverified

### Move to Implementation When
- Problem understood
- Approach validated
- Risks assessed
- Dependencies confirmed

## Session Management

### Session Start
1. Read PROJECT.md
2. Add timestamped entry
3. Review blockers
4. Plan session work

### Session End
1. Update Current Status
2. Document blockers
3. Note next steps

## Key Principles

- **Document once, reference many** - PROJECT.md as single source
- **Timestamp everything** - Chronological clarity
- **Write for clarity** - Simple, direct language
- **Include context** - Why matters as much as what
- **Define success** - Clear completion criteria
