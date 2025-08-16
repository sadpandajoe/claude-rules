# Cherry-Pick Safety and Cross-Branch Patterns

This document provides general strategies for safely cherry-picking commits between branches, especially when dealing with dependency and architectural differences.

## General Principles

1. **Understand before changing** - Always analyze the full scope first
2. **Preserve working functionality** - Don't break existing features
3. **Adapt rather than force** - Work with target branch architecture
4. **Document decisions** - Future maintainers need context
5. **Test incrementally** - Validate changes step by step
6. **Be conservative** - When in doubt, choose lower-risk options
7. **Use tests as specifications** - When available, failing tests reveal exact requirements

## Pre-Cherry-Pick Analysis

### Understanding the Full Scope
```bash
# Always run these before cherry-picking
git show <commit-hash>                          # Understand ALL changes
git show --stat <commit-hash>                   # See what files are modified
git show <commit-hash> -- <specific-file>       # See specific file changes
```

### Dependency and Architecture Gap Analysis
```bash
# Compare dependency versions between branches
git show master:package.json | grep "library-name"
git show HEAD:package.json | grep "library-name"

# Check for import/component availability (adapt commands to your language)
find . -name "*.ext" | xargs grep "new-import"
grep -r "ComponentName\|APIMethod" src/
```

### Identify Change Types
1. **Functional changes**: Business logic, data processing, algorithms
2. **Structural changes**: Component APIs, import paths, architectural patterns
3. **Dependency changes**: New libraries, version upgrades, API changes

## Import Path Validation

### Universal Import Checking Pattern
```bash
# Before accepting import changes
ls -la path/to/expected/component/              # Verify path exists
grep -r "new-import-path" src/                  # Check existing usage patterns
git log --oneline <branch> -- <import-path>    # See when it was added

# Check import alias patterns between branches
git show master:path/to/file | grep "^from\|^import"
git show HEAD:path/to/file | grep "^from\|^import"
# Look for differences: module vs module as alias
```

### Safe Import Strategy
- **Rule**: Never accept import changes without verifying modules exist in target branch
- **Rule**: When in doubt, keep existing import patterns and adapt functionality
- **Rule**: Check both old and new import locations before making changes
- **Rule**: Verify import alias patterns match between branches (e.g., `from flask import current_app` vs `from flask import current_app as app`)

## Architecture Compatibility Analysis

### Compatibility Assessment
- [ ] Identify if cherry-pick involves architectural changes (component APIs, data structures)
- [ ] Check for version differences in key dependencies between branches
- [ ] Look for adaptation patterns in existing codebase (bridge functions, transformation helpers)
- [ ] Determine if target branch can support new patterns or needs adaptation

### Architectural Pattern Investigation
```bash
# Compare architectural patterns between branches
git show master:path/to/component | grep -A 5 "key-pattern"
git show HEAD:path/to/component | grep -A 5 "key-pattern"

# Look for rendering/processing approach differences
grep -r "pattern-a" src/                       # One approach
grep -r "pattern-b" src/                       # Alternative approach

# Analyze data structure differences
grep -A 10 -B 5 "interface\|struct\|class" src/   # Find type definitions
grep -A 5 "data.*=" test/                         # Look at test data structures
```

**Investigation questions**:
- How does the source branch structure data vs the target branch?
- Are there different approaches to the same functionality?
- What changed in the API between versions?
- Is there an existing layer that could adapt between these patterns?

## Functional vs. Structural Change Separation

### Cherry-Pick Strategy
1. **Extract functional improvements**: Business logic that adds value
2. **Adapt to existing structure**: Don't force new architectural patterns
3. **Update bridge functions**: Modify helper functions, not usage patterns everywhere

### Identify Adaptation Points During Investigation

When reviewing cherry-pick conflicts, look for intermediate layers:

```bash
# Study the diff carefully
git diff HEAD~1                           # See what the cherry-pick changed
git show --stat <commit-hash>              # Files modified in original commit
```

**Pattern recognition questions**:
- Are there helper/utility functions in the modified files?
- Do you see functions that transform data before it reaches the final destination?
- Are there intermediate layers between raw data and presentation?
- Look for function names suggesting transformation: `render*`, `map*`, `transform*`, `convert*`, `handle*`, `process*`

### Adaptation Strategy Framework
1. **Identify the structural change**: What format change occurred?
2. **Find transformation points**: Where does data get processed before reaching destination?
3. **Preserve existing interfaces**: Update transformation logic, not usage patterns
4. **Test incrementally**: Verify each adaptation step works before moving to the next

**Adaptation strategy**:
1. Avoid forcing new architectural patterns onto older branches
2. Look for existing adaptation layers that can be enhanced
3. Update transformation functions rather than changing usage patterns everywhere
4. Preserve the target branch's architectural approach while adding new functionality

## Conservative Resolution Strategy

### Decision Framework
When facing merge conflicts or compatibility issues:

1. **Option 1**: Quick revert
   - Pros: Fast, no risk
   - Cons: Lose functionality
   - When: Major architectural incompatibility

2. **Option 2**: Functional adaptation  
   - Pros: Keep functionality, low risk
   - Cons: Some technical debt
   - When: Structure differs but functionality can be adapted

3. **Option 3**: Full architectural update
   - Pros: Perfect alignment with source
   - Cons: High risk, major changes required
   - When: Target branch ready for upgrade

### Safe Resolution Rules
- **Rule**: When unsure, favor the working target branch structure
- **Rule**: Only accept changes you can verify work in target environment
- **Rule**: Add new functionality incrementally rather than wholesale replacement
- **Rule**: Document all rejected changes with clear reasoning

## Validation Strategy

### Post-Cherry-Pick Validation
- [ ] Check if project has automated validation tools (tests, linting, type checking)
- [ ] Run available validation commands after cherry-pick
- [ ] Verify no conflict markers remain in files
- [ ] Test functionality manually if automated tools unavailable

### Using Tests as Investigation Tools
When available, tests can reveal exact specification gaps:
- What does the test expect to find?
- What is actually happening?
- Where is the gap between expectation and reality?
- What changed in the cherry-pick that could cause this?

### Essential Conflict Resolution Checks
```bash
# Ensure no conflict markers remain
grep -E "<<<|===|>>>" <files>

# Check for obvious syntax issues (language-dependent)
# Use appropriate syntax checkers for your language/framework
```

## Documentation and Communication

### Cherry-Pick Documentation

Document cherry-pick decisions in PROJECT.md using the standard investigation format:

```markdown
## Cherry-Pick Resolution: [Feature Name]

### Commit Cherry-Picked
- **Commit**: `commit-hash` - "commit message"
- **Target Branch**: branch-name
- **Source**: source-branch

### What We Successfully Cherry-Picked
- [List functional improvements that were preserved]

### What We Correctly Rejected
- [List structural changes that were rejected]
- **Reason**: [Clear explanation why]

### Adaptation Strategy
- [Explain how functionality was adapted to existing architecture]

### Risk Assessment
- **Risk Level**: Low/Medium/High
- **Breaking Changes**: None/List any
- **Compatibility**: Maintained/Partial/Requires testing
```

### Documentation Guidelines
- Document reasoning for rejected changes in PROJECT.md
- Explain adaptation strategies used within the investigation section
- Note any technical debt created during adaptation
- Record lessons learned for future cherry-picks in PROJECT.md
- Update Development Log with cherry-pick timeline and decisions

## Advanced Analysis Techniques

### Multi-File Dependency Tracking
```bash
# When cherry-pick affects multiple files
git show <commit> --name-only | xargs -I {} git log --oneline <target-branch> -- {}

# Check interdependencies (adapt to your language)
grep -r "import\|require\|include" src/ | cut -d: -f1 | sort | uniq
```

### Branch Feature Detection
```bash
# Detect if features exist in target branch
git log --oneline <target-branch> --grep="feature-keyword"
git log --oneline <target-branch> -- path/to/component | grep -i "feature"
```

### Historical Context
```bash
# Understand when functionality was introduced
git blame -- file.ext | grep "specific-function"
git log --follow --oneline -- src/components/Component/
```

## Lessons Learned

### Cherry-Pick Strategies That Work
- **Conservative resolution** preserves target branch stability
- **Functional vs structural separation** allows safe feature extraction
- **Bridge function updates** enable new functionality without architectural changes
- **Import path validation** prevents runtime failures after cherry-pick
- **Import alias pattern checking** catches subtle compatibility issues between branches

### Common Cherry-Pick Pitfalls
- Forcing new architectural patterns onto incompatible branches
- Accepting import changes without verifying module existence
- **Missing import alias differences** - assuming same module imported with same alias in both branches
- Cherry-picking structural changes that break existing patterns
- Skipping validation after conflict resolution

### Adaptation Patterns
- **Extract business logic** while preserving presentation patterns
- **Update transformation functions** rather than changing usage everywhere
- **Document rejected changes** with clear architectural reasoning
- **Test incrementally** after each adaptation step

### Infrastructure Validation When Tools Fail (Emerging Pattern)
**Note**: Developing approaches for cherry-picking when project tooling is unreliable

#### When Standard Validation Fails
If project validation commands fail (npm test, npm run lint, etc):

1. **Infrastructure Assessment**:
   - Distinguish between configuration issues vs actual code issues
   - Try dependency refresh (npm ci) before assuming code problems
   - Check if validation failure is environmental or cherry-pick related

2. **Risk-Based Decision Making**:
   - **Low-risk changes** (data additions, conservative adaptations): Proceed with manual validation
   - **High-risk changes** (API modifications, architectural changes): Stop and fix tooling first
   - **Document decision reasoning** and confidence level in PROJECT.md

3. **Manual Validation Checklist**:
   ```bash
   # Essential manual checks when automation fails
   grep -E "<<<|===|>>>" **/*           # Conflict markers removed
   ls -la path/to/expected/imports       # Import paths exist
   # Visual inspection of modified areas for syntax issues
   ```

#### Reduced Validation Confidence Strategy
- **More conservative cherry-picks** when tooling unreliable
- **Smaller, incremental changes** easier to validate manually
- **Document validation limitations** for future maintainers
- **Plan validation debt** - note what needs proper testing later

### Cross-Version Architecture Patterns (Emerging Pattern)
**Note**: Based on experience with UI library version differences, may apply to other dependency migrations

#### Architecture Evolution Recognition
- **Identify migration patterns** in target vs source branches (props vs children, config changes)
- **Find adaptation points** - functions that can bridge architectural differences
- **Preserve working patterns** in target branch while adding new functionality
- **Document architectural decisions** for future cherry-picks

#### Bridge Function Development
- **Enhance existing helpers** rather than creating new patterns
- **Maintain backward compatibility** with existing usage
- **Add new functionality incrementally** within existing architectural constraints
- **Test both old and new usage patterns** to ensure no regressions