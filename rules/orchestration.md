# Claude Code + Codex CLI Orchestration

## 🎯 Orchestration Golden Rules
- [ ] **Claude Code owns planning and verification**
- [ ] **Delegate bounded, well-specified tasks** to Codex
- [ ] **Verify RCA with Codex** before designing solutions
- [ ] **Verify before accepting** delegated work
- [ ] **PROJECT.md is shared truth**
- [ ] **Right tool for right job**

## Tool Roles

| Tool | Role | Strengths |
|------|------|-----------|
| **Claude Code** | Tech Lead | Planning, investigation, complex reasoning, verification, commits |
| **Codex CLI** | Implementer | Bounded tasks, code review, boilerplate, mechanical transforms |

### How Claude Code Invokes Codex

Claude Code runs Codex CLI via the **Bash tool**:
```bash
codex exec --sandbox read-only "Your prompt here..."
```

Codex CLI is a separate shell command, NOT a native Claude Code tool.

## Native Claude Code Features (2.1.x)

### Task Tool Subagents

Claude Code can spawn specialized subagents via the Task tool:

| Subagent | Role | Use For |
|----------|------|---------|
| **Explore** | Codebase explorer | Finding files, searching code, understanding structure |
| **Plan** | Architect | Designing implementation approaches |
| **general-purpose** | Autonomous worker | Multi-step tasks, research, complex searches |

**When to use subagents vs Codex CLI:**
- **Subagents**: Internal Claude Code work (exploration, planning, research)
- **Codex CLI**: Independent review/analysis (fresh perspective, multi-AI validation)

### Task Tracking Tools (Optional)

For complex multi-step work, native task tracking is available:

| Tool | Purpose |
|------|---------|
| `TaskCreate` | Create a tracked task with description |
| `TaskUpdate` | Update status (pending → in_progress → completed) |
| `TaskList` | View all tasks and their status |
| `TaskGet` | Get full task details |

**When to use**:
- Complex features with 3+ distinct steps
- Work that benefits from visible progress tracking
- Supplement to PROJECT.md, not replacement

### Plan Mode

Claude Code has native plan mode for non-trivial implementation tasks:

- `EnterPlanMode` - Start structured planning with user approval workflow
- `ExitPlanMode` - Present plan for user approval

**Use plan mode when**:
- Multiple valid approaches exist
- Architectural decisions required
- Multi-file changes planned
- User preferences matter

## Delegation Framework

### When to Delegate to Codex

| ✅ Delegate | ❌ Keep in Claude Code |
|-------------|----------------------|
| Single-file implementations | Multi-file refactors |
| Boilerplate generation | Architecture decisions |
| Code review (second opinion) | Root cause analysis |
| Test generation (from spec) | Test strategy design |
| Mechanical transforms | Security-sensitive code |
| Documentation formatting | Investigation/debugging |

### Decision Tree
```
Exploration/understanding codebase?  → Task (Explore subagent)
Planning/architecture design?        → EnterPlanMode or Task (Plan subagent)
Multi-step autonomous research?      → Task (general-purpose subagent)
Planning/investigation/architecture? → Claude Code
Multi-file or cross-cutting?         → Claude Code
Security-sensitive?                  → Claude Code
Single-file with clear spec?         → Codex CLI
Mechanical transformation?           → Codex CLI
Need fresh perspective/validation?   → Codex CLI
```

## Task Specification

When delegating, provide:
```markdown
## Task: [Name]

### Context
- File(s): [paths]
- Constraints: [what NOT to change]

### Input
[Current state]

### Expected Output
[What success looks like]

### Patterns to Follow
[Code example]

### Validation
- [ ] [Check 1]
- [ ] [Check 2]
```

## Verification Checklist

Before accepting delegated work:
- [ ] Syntax/lint passes
- [ ] Only changed requested scope
- [ ] Matches project patterns
- [ ] No hallucinated imports
- [ ] Tests pass
- [ ] Integrates correctly

### Rejection Criteria
- Changes outside scope
- New dependencies without approval
- Pattern mismatch
- Breaks tests
- Hallucinated APIs

## Workflows Summary

| Workflow | Lead Tool | Codex Role | Primary Files |
|----------|-----------|------------|---------------|
| **New Feature** | Claude Code | Review plans, review code | planning → implementation → testing |
| **Bug Fix** | Claude Code | **Verify RCA (required)**, review fix | investigation → implementation |
| **Code Review** | Claude Code | Independent review | code-review |
| **Root Cause** | Claude Code | **Verify RCA (required)** | investigation → troubleshooting |
| **Refactoring** | Claude Code | Mechanical transforms | refactor |
| **Cherry-Pick** | Claude Code | Review assessment | cherry-picking |

## Workflow Pattern

All workflows follow this pattern:
```
1. [CC] Plan in PROJECT.md
2. [CC] Investigate/analyze
3. [CX] Verify RCA (REQUIRED for bug fixes/investigations)
4. [CC] Design solution
5. [CX] Review solution
6. [CC|CX] Implement (based on complexity)
7. [CX] Code review
8. [CC] Address feedback
9. [CC] Validate & commit
10. [CC] Update PROJECT.md
```

**Legend**: [CC] = Claude Code, [CX] = Codex CLI

## When Delegation Fails

1. **Don't retry blindly** - Understand why
2. **Simplify** - Break into smaller pieces
3. **Add context** - Missing information?
4. **Take it back** - Some tasks shouldn't be delegated

## Anti-Patterns

| ❌ Don't | ✅ Do Instead |
|----------|---------------|
| Delegate architecture | Keep complex reasoning in CC |
| Accept without testing | Verify before accepting |
| Lose context | Update PROJECT.md |
| Use wrong tool | Match tool to task type |
| Retry failures blindly | Understand and simplify |
