# Universal Planning & Documentation Workflow

## Project Initialization

### New Project Setup
1. Create PROJECT.md in repository root
2. Fill out Overview, Goal, and Assumptions from requirements
3. Document initial understanding
4. Set up Current Status with preliminary breakdown
5. Add first Development Log entry with timestamp

### Existing Project Continuation
1. Read PROJECT.md completely
2. Review Development Log for history
3. Check Current Status for active/blocked work
4. Add new session entry with timestamp

## PROJECT.md Template

Use the template at: `~/opt/code/claude-rules/PROJECT_TEMPLATE.md`

Key sections to maintain:
- **Current Status**: What's active, next, blocked
- **Development Log**: Timestamped narrative of work
- **Solutions**: Options being evaluated (not yet tried)
- **Accepted Solution**: ONLY when fully working and tested
- **Failed Solutions**: Attempted solutions that didn't work
- **Implementation Notes**: Technical decisions, gotchas

## Documentation Workflow

### Before Any Action
Document in PROJECT.md:
- **What you plan to do** and why
- **Expected approach** and steps
- **Anticipated outcome**
- **Risk assessment** if applicable

### After Completing Actions
Update PROJECT.md with:
- **What actually happened** vs planned
- **Key findings or discoveries**
- **Any approach changes** and why
- **Updated Current Status**

### This Applies To ALL Activities
- Version control operations
- File analysis or reading
- Code changes or creation
- Testing or validation
- Problem investigation
- Any project-related work

## Solution Planning Framework

### Solution Workflow
1. **Document options in Solutions section** - All possibilities, even if similar
2. **Try an option** - Move to Development Log what you're attempting
3. **If it fails** - Move to Failed Solutions with why it failed
4. **If it works partially** - Keep refining, document progress
5. **When FULLY working** - Move to Accepted Solution with final details

### Solution Documentation
```markdown
### Solutions (Not Yet Tried)
#### Option 1: [Approach Name]
- **Description**: [What this involves]
- **Pros**: [Benefits]
- **Cons**: [Drawbacks]
- **Risk**: Low/Medium/High

#### Option 2: [Alternative]
[Same structure]

[Add more options as discovered]

### Accepted Solution
[ONLY move here when tests pass, implementation complete, validation done]
- **Final Approach**: [What actually worked]
- **Implementation Details**: [How it was done]
- **Validation**: [How we know it works]

### Failed Solutions
#### Attempt: [Name]
- **What we tried**: [Description]
- **Why it failed**: [Root cause]
- **Lessons learned**: [What we discovered]
```

## Planning Mode Guidelines

### When to Use Planning Mode
- **Complex investigations** requiring systematic research (use Opus)
- **Multi-step implementations** with significant risk (use Opus)
- **Architecture decisions** affecting multiple components
- **Cross-cutting changes** spanning multiple areas

**Note**: Planning mode should prefer Opus for complex reasoning and analysis

### Planning vs Implementation Transition

#### Clear Transition Indicators
**Stay in Planning When**:
- Root cause unclear
- Multiple approaches possible
- Risk assessment incomplete
- Dependencies unverified

**Move to Implementation When**:
- Problem understood
- Approach validated
- Risks assessed and acceptable
- Dependencies confirmed

**Document Transition**:
```markdown
### Development Log
[Time]: Investigation complete - root cause identified as [issue]
[Time]: Moving to implementation with [chosen approach]
```

## Session Continuity

### Session Start Checklist
1. Read PROJECT.md completely
2. Understand current state
3. Add timestamped session entry
4. Review blockers
5. Plan session work

### Maintaining Context
- Document all decisions immediately
- Keep Development Log chronological
- Anyone should understand state from PROJECT.md
- Never assume context carries over

### Session End Checklist
1. Update Current Status
2. Document any blockers
3. Note clear next steps
4. Capture session learnings

## Decision Documentation

### Architecture Decisions
```markdown
## Decision: [Title]

### Context
[What situation requires this decision]

### Options Considered
1. [Option with pros/cons]
2. [Option with pros/cons]

### Decision
[What was chosen]

### Rationale
[Why this was chosen]

### Consequences
[What this means going forward]
```

### Risk Documentation
```markdown
## Risk: [Title]

### Description
[What could go wrong]

### Probability
[Low/Medium/High]

### Impact
[Low/Medium/High]

### Mitigation
[How we reduce risk]

### Contingency
[What to do if it happens]
```

## Best Practices

### Documentation Quality
- **Write for clarity** - Simple, direct language
- **Be specific** - Concrete over abstract
- **Include context** - Why matters as much as what
- **Stay current** - Update as things change

### Planning Effectiveness
- **Start broad, narrow down** - Overview before details
- **Consider alternatives** - Multiple options prevent tunnel vision
- **Assess risks early** - Identify problems before they occur
- **Define success** - Clear criteria for completion

### Workflow Efficiency
- **Document once, reference many** - PROJECT.md as single source
- **Timestamp everything** - Chronological clarity
- **Separate concerns** - Different sections for different purposes
- **Keep it maintainable** - Regular cleanup of outdated info

## Common Patterns

### Investigation Planning
1. Document the problem clearly
2. List hypotheses to test
3. Plan verification approach
4. Execute systematically
5. Document findings
6. Draw conclusions

### Implementation Planning
1. Define requirements clearly
2. Identify dependencies
3. Plan incremental steps
4. Define validation approach
5. Document rollback plan
6. Execute with checkpoints

### Recovery Planning
1. Assess current state
2. Identify safe state
3. Plan path to safety
4. Document steps taken
5. Verify recovery
6. Document lessons

## Lessons Learned Using This Guide
<!-- Document when these planning guidelines needed adjustment -->
<!-- Capture cases where solution workflow didn't match reality -->
<!-- Note patterns in how solutions actually evolve -->
