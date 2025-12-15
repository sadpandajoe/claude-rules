# Claude Code + Codex MCP Orchestration

## 🎯 Orchestration Golden Rules
- [ ] **Claude Code owns planning and verification**
- [ ] **Delegate bounded, well-specified tasks** to Codex
- [ ] **Verify before accepting** delegated work
- [ ] **PROJECT.md is shared truth**
- [ ] **Right tool for right job**

## Tool Roles

| Tool | Role | Strengths |
|------|------|-----------|
| **Claude Code** | Tech Lead | Planning, investigation, complex reasoning, verification, commits |
| **Codex MCP** | Implementer | Bounded tasks, code review, boilerplate, mechanical transforms |

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
Planning/investigation/architecture? → Claude Code
Multi-file or cross-cutting?         → Claude Code  
Security-sensitive?                  → Claude Code
Single-file with clear spec?         → Codex MCP
Mechanical transformation?           → Codex MCP
Need fresh perspective?              → Codex MCP
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
| **Bug Fix** | Claude Code | Sanity check RCA, review fix | investigation → implementation |
| **Code Review** | Claude Code | Independent review | code-review |
| **Root Cause** | Claude Code | Alternative analysis | investigation → troubleshooting |
| **Refactoring** | Claude Code | Mechanical transforms | refactor |
| **Cherry-Pick** | Claude Code | Review assessment | cherry-picking |

## Workflow Pattern

All workflows follow this pattern:
```
1. [CC] Plan in PROJECT.md
2. [CC] Investigate/analyze
3. [CX] Review analysis (optional)
4. [CC] Design solution
5. [CX] Review solution
6. [CC|CX] Implement (based on complexity)
7. [CX] Code review
8. [CC] Address feedback
9. [CC] Validate & commit
10. [CC] Update PROJECT.md
```

**Legend**: [CC] = Claude Code, [CX] = Codex MCP

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
