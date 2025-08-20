# Investigation & Problem-Solving Workflow

## Root Cause Analysis Process

### 1. Document Everything in PROJECT.md First

**Critical Rule**: Before jumping to solutions, document the problem thoroughly in PROJECT.md

#### Investigation Documentation Pattern
```markdown
## Investigation: [Issue Name]

### The Problem
- **Error**: [Exact error message or symptoms]
- **Context**: [When it occurs, what triggers it]
- **Environment**: [Branch, version, setup details]
- **Impact**: [What functionality is affected]

### Bug Introduction (when identified)
- **Introducing Commit**: `commit-hash` - "commit message"
- **PR/Issue**: #123 - "title" (if available)
- **Author**: [Who made the change]
- **Date**: [When it was introduced]
- **Original Purpose**: [What the change was supposed to accomplish]
- **How Bug Was Introduced**: [Unintended side effect or oversight]

### Investigation Timeline
- [Timestamp]: Initial discovery - [what was found]
- [Timestamp]: Hypothesis tested - [approach and result]
- [Timestamp]: Key finding - [breakthrough or dead end]
- [Timestamp]: Root cause identified - [introducing commit/PR found]

### Analysis
[Write analysis of findings BEFORE proposing solutions]
[Include summary of what the introducing change did and why it caused the issue]

### Evidence Gathered
- [List concrete evidence: logs, diffs, test results]
- [Include relevant command outputs]
- [Note patterns or correlations discovered]
- [Git blame/log outputs showing bug introduction]
```

## Debugging Standards

### Root Cause Focus
- **Always perform root cause analysis** - Don't just patch symptoms
- **Identify the introducing commit/PR** - Use git blame, bisect, and history analysis
- **Document the why** - Explain not just what broke, but why the original change caused it
- **Trace the full impact** - Understand what else might be affected

### Evidence-Based Investigation
- **Gather concrete evidence** - Logs, stack traces, reproduction steps
- **Include full context** - Error messages, environment details, user actions
- **Document investigation timeline** - What was tried, what was learned
- **Preserve debugging artifacts** - Save logs, screenshots, relevant data

### Logging and Documentation Standards
- **Use targeted logging** - Log relevant context, not spam
- **Include stack traces** - Full error context for debugging
- **Structured error messages** - Include operation, input, expected vs actual
- **Never use silent catches** - Always log or handle errors appropriately

### Debugging DO/DON'T Reference

| ✅ DO | ❌ DON'T |
|-------|---------|
| Perform root cause analysis | Patch without understanding the cause |
| Identify commit/PR introducing bug | Guess without verifying history |
| Use targeted logging with context | Spam logs with irrelevant data |
| Include stack traces and error details | Log vague, generic error messages |
| Document investigation process | Jump to solutions without analysis |
| Test hypotheses systematically | Make random changes hoping to fix |
| Preserve debugging artifacts | Delete evidence before understanding |
| Follow systematic investigation process | Skip steps to save time |

#### Read Error Messages Carefully
- Look for specific module names, line numbers, stack traces
- Distinguish between syntax errors, type errors, and runtime errors
- Pay attention to the exact wording - often contains clues

#### Check Recent Changes First
```bash
git diff HEAD~1                    # What changed in last commit?
git log --oneline -10              # Recent commit history
git status                         # Current working directory state
git diff --stat HEAD~5             # Broader change overview
```

#### Verify Dependencies and Imports
```bash
# Check if imports are valid
grep -r "import.*SpecificModule" src/
ls -la path/to/expected/module
find . -name "*ModuleName*" -type f

# Check for typos in variable names and paths
# Use IDE search to find all usages of suspected variables
# Verify file paths are correct and case-sensitive
```

### 3. Multi-Branch Investigation Techniques

When dealing with cross-branch issues:

```bash
# Compare file existence between branches
git ls-tree branch1 -- path/to/file
git ls-tree branch2 -- path/to/file

# Compare file content between branches
git show branch1:path/to/file | grep "pattern"
git show branch2:path/to/file | grep "pattern"

# Check when files were moved or renamed
git log --follow --oneline -- path/to/file

# See differences between branches for specific files
git diff branch1..branch2 -- specific-file.tsx
```

### 4. Historical Analysis and Bug Introduction Tracking

#### Identifying the Introducing Commit/PR

```bash
# Find when specific functionality was introduced
git blame -- file.tsx | grep "specific-function"

# Track feature evolution
git log --oneline --follow -- specific-file.tsx

# Find commits related to specific keywords
git log --oneline --grep="keyword"
git log -S "specific-code-string"    # Pickaxe search

# Use git bisect for systematic bug introduction tracking
git bisect start
git bisect bad                      # Current commit has the bug
git bisect good <known-good-commit> # Known working commit
# Git will guide you through finding the exact introducing commit

# Find when a specific line was last modified
git blame -L <line-number>,<line-number> -- file.tsx

# Search for commits that modified specific patterns
git log --grep="component-name" --oneline
git log -p -S "problematic-code" --oneline
```

#### Commit/PR Analysis

When you identify the introducing commit, document:

```markdown
### Bug Introduction Analysis

#### Introducing Commit/PR
- **Commit**: `commit-hash` - "commit message"
- **PR**: #123 - "PR title" (if available)
- **Date**: [When it was merged]
- **Author**: [Who authored it]

#### What the Commit/PR Did
- **Primary Purpose**: [Main goal of the change]
- **Files Modified**: [Key files changed]
- **Functional Changes**: [What business logic changed]
- **Technical Changes**: [What technical implementation changed]

#### Bug Introduction Context
- **Intended Behavior**: [What the PR was supposed to do]
- **Unintended Side Effect**: [How it introduced the bug]
- **Missing Considerations**: [What wasn't accounted for]
- **Test Coverage**: [Whether tests existed/caught this]
```

#### Deep Commit Investigation

```bash
# See what changed in the introducing commit
git show --stat commit-hash          # Files and change summary
git show commit-hash                 # Full diff
git show commit-hash -- specific-file.tsx  # Changes to specific file

# Check if there was a PR associated
git log --oneline --grep="Merge pull request.*#[0-9]" | grep -A 5 -B 5 commit-hash

# See the commit in context (what came before/after)
git log --oneline -10 commit-hash
git show commit-hash~1..commit-hash+1 --oneline

# Check if this was part of a larger feature
git log --oneline --since="date-before-commit" --until="date-after-commit" --grep="related-keyword"
```

### 5. Architecture and Component Investigation

#### Component Location and API Analysis
```bash
# Find components by name pattern
find . -name "*ComponentName*" -type f | head -10

# Compare interfaces/APIs between versions
git show branch1:path/to/Component.tsx | grep -A 5 "interface\|type\|Props"
git show branch2:path/to/Component.tsx | grep -A 5 "interface\|type\|Props"

# Check import/export availability
git show branch:path/to/index.ts | grep ComponentName
grep -r "export.*ComponentName" src/
```

#### Usage Pattern Analysis
```bash
# Find how components are used
grep -r "<ComponentName" src/
grep -r "ComponentName.*=" src/
grep -r "import.*ComponentName" src/

# Look for rendering patterns
grep -r "render.*Options\|render.*Items" src/
find . -name "*.tsx" | xargs grep -l "render.*function"
```

## Test-Driven Investigation

### Using Tests as Specifications

When tests fail, they provide precise specifications for expected behavior:

```bash
# Run specific failing test with verbose output
npm test -- TestFile.test.tsx -t "specific test name" --verbose

# For debugging, run single test in watch mode (if available)
npm test -- --watch TestFile.test.tsx
```

### Test Analysis Framework
1. **Read the test code**: Understand exactly what it's testing
2. **Examine test data**: What input does the test provide?
3. **Check assertions**: What specific output does it expect?
4. **Trace execution path**: Follow the code from input to assertion
5. **Identify the gap**: Where does reality diverge from expectation?

### Test Failure Investigation Pattern
```markdown
### Test Failure Analysis: [Test Name]

#### Expected Behavior
- [What the test expects to happen]
- [Specific assertions that fail]

#### Actual Behavior  
- [What actually happens]
- [Error messages or unexpected output]

#### Gap Analysis
- [Where the divergence occurs]
- [Potential causes identified]

#### Code Path Investigation
- [Functions/components involved]
- [Data transformations that occur]
- [Where the issue likely originates]
```

## Information Gathering Strategies

### Parallel Search Approach
Use multiple search methods simultaneously:

```bash
# Content search across files
grep -r "pattern" src/
find . -name "*.ts*" | xargs grep "pattern"

# File structure search
find . -name "*pattern*" -type f
ls -la **/*pattern* 2>/dev/null

# Git history search
git log --grep="pattern"
git log -S "pattern" --oneline
```

### Dependency Investigation
```bash
# Check package dependencies (Node.js)
cat package.json | grep -A 5 -B 5 "dependency-name"
npm list | grep dependency-name

# Check package dependencies (Python)
pip show package-name                           # Current installed version
grep "package-name" setup.py requirements.txt  # Expected version
pip list | grep package-name                    # Alternative check

# Compare dependency versions between branches
git show master:package.json | grep "library"  # Node.js
git show HEAD:package.json | grep "library"
git show master:setup.py | grep "library"      # Python
git show HEAD:setup.py | grep "library"

# Test imports in isolation (Python)
python -c "from module import ClassName; print('Import works')"
python -c "import module; print([x for x in dir(module) if not x.startswith('_')])"

# Check if packages are installed
ls -la node_modules/package-name/              # Node.js
pip show package-name                           # Python detailed info
```

## Solution Analysis Framework

### Multiple Option Analysis

Before implementing any fix, document multiple approaches in PROJECT.md:

```markdown
### Solution Options

#### Option 1: [Quick Fix Name]
- **Approach**: [Brief description]
- **Pros**: Fast resolution, minimal risk
- **Cons**: May not address root cause
- **Risk Level**: Low
- **Impact**: Minimal
- **Time**: [Estimate]

#### Option 2: [Proper Fix Name]  
- **Approach**: [Brief description]
- **Pros**: Addresses root cause, maintainable
- **Cons**: More complex implementation
- **Risk Level**: Medium
- **Impact**: Localized to affected components
- **Time**: [Estimate]

#### Option 3: [Complete Solution Name]
- **Approach**: [Brief description]  
- **Pros**: Comprehensive fix, future-proof
- **Cons**: High effort, broad impact
- **Risk Level**: High
- **Impact**: Multiple systems/components
- **Time**: [Estimate]

#### Recommendation
[Chosen approach with clear reasoning based on current context, timeline, and risk tolerance]
```

### Option Evaluation Criteria
- **Risk Level**: How likely is it to break existing functionality?
- **Impact Scope**: How many systems/files need changes?
- **Maintenance Cost**: How will this affect future development?
- **Time Investment**: How long will implementation take?
- **Reversibility**: How easily can this be undone if needed?

## Advanced Investigation Techniques

### Cross-Version Component Analysis
When debugging version compatibility issues:

```bash
# Compare entire component directories
diff -r <(git show master:src/components/Component) <(git show HEAD:src/components/Component)

# Check API evolution
git log --oneline -p -- path/to/Component.tsx | grep -A 5 -B 5 "interface\|Props"

# Find bridge/adapter functions
grep -r "render.*\|map.*\|transform.*\|convert.*" src/components/
```

### Incremental Testing Strategy
- Make small changes and verify each step
- Use temporary logging for debugging (remove before committing)
- Comment out sections to isolate issues
- Test one hypothesis at a time

### Environment and Configuration Debugging
```bash
# Check configuration files
cat tsconfig.json | grep -A 5 -B 5 "relevant-setting"
cat .env* | grep RELEVANT_VAR

# Verify build tools and scripts
cat package.json | grep -A 10 "scripts"
npm run build 2>&1 | head -20    # Check build output
```

## Common Investigation Patterns

### Import/Export Issues
1. Verify the module exists at the expected path
2. Check export/import syntax matches
3. Verify case sensitivity in paths
4. Check for circular dependencies

### Component Rendering Issues  
1. Check if component receives expected props
2. Verify prop types/interfaces match
3. Look for conditional rendering logic
4. Check for data transformation issues

### Cross-Branch Compatibility
1. Compare dependency versions
2. Check for API changes between versions
3. Look for moved/renamed files
4. Verify import paths are still valid

## Documentation and Knowledge Building

### Capturing Investigation Outcomes

Always document key learnings in PROJECT.md:

```markdown
### Investigation Results

#### Root Cause
[What was the fundamental issue?]

#### Detection Method  
[How was it identified? What techniques worked?]

#### Resolution Strategy
[What approach was taken and why?]

#### Prevention
[How to avoid this issue in the future?]

#### Patterns Learned
[What patterns emerged that apply to other situations?]
```

### Building Investigation Skills
- Track debugging commands that prove useful for your projects
- Note common failure patterns in your codebase
- Document architectural quirks that cause recurring issues
- Record effective investigation sequences for different problem types

## Lessons Learned

### Common Patterns
- **Dependency masquerading as breaking changes**: Import errors often stem from wrong package versions, not removed functionality
- **Version mismatch diagnosis**: Always check `pip show <package>` vs expected version before concluding API changes
- **False correlation with recent commits**: Timeline correlation doesn't prove causation - verify the actual change impact

### Best Practices  
- **Package version verification first**: Before investigating "missing" imports, verify installed vs expected package versions
- **Simple import isolation**: Test problematic imports in isolation to separate dependency from code issues
- **Document correction process**: When initial analysis is wrong, document the correction timeline in PROJECT.md
- **Evidence-based debugging**: Use concrete evidence (version numbers, import tests) rather than assumptions

### Pitfalls to Avoid
- **Assuming correlation equals causation**: Recent commits near failure don't automatically cause the failure
- **Jumping to "code was removed" conclusions**: Check if dependency versions changed before concluding functionality was removed
- **Quick fixes over root cause**: Creating workarounds (local enums) instead of fixing underlying issues (dependency versions)
- **Single hypothesis tunnel vision**: Test multiple theories rather than confirming first impression

### Process Improvements
- **Dependency debugging checklist**: Add standard commands (`pip show`, simple import tests) to investigation workflow
- **Correction documentation pattern**: When analysis is wrong, mark timeline entries as "INCORRECT" and add corrected findings
- **Multiple solution evaluation**: Always present 2-3 options (quick fix, proper fix, complete solution) with risk analysis
- **Version verification step**: Make package version checking a standard first step for import-related failures

### Multi-Layer API Breaking Changes (Universal Pattern)

When debugging after major version updates, be aware that **multiple issues can be introduced simultaneously**:

#### Investigation Strategy
```bash
# Don't stop at the first fix - version updates often have layered issues
git show <breaking-commit> --stat              # Check scope of changes
grep -r "changed_api_method" src/               # Find all usage patterns

# Test incrementally after each fix
pytest specific_failing_test.py -v             # Verify each fix isolates the problem
```

#### Common Multi-Layer Scenarios
1. **Surface-level changes** (parameter types, method signatures) - Fix with parameter conversion
2. **Implementation bugs** in the new API - Fix requires modifying the API implementation
3. **Both issues simultaneously** - Requires multiple rounds of investigation

#### Investigation Process
1. **Fix obvious API usage issues** (parameter types, method signatures)
2. **Test incrementally** - if still failing, investigate implementation of the changed API
3. **Check both usage patterns AND implementation** of changed APIs
4. **Fix implementation bugs** if found
5. **Test again** to ensure both layers are resolved

#### Documentation Requirements
- **Document each layer separately** in PROJECT.md investigation timeline
- **Mark which fixes address which layer** (usage vs implementation)
- **Note if additional investigation rounds were required**

**Key Learning**: Don't assume the first fix will resolve everything - major version updates can introduce both usage incompatibilities and implementation bugs that compound each other.

### Test Failure Investigation Pattern

When tests fail in CI but pass locally, or when new tests fail unexpectedly:

#### Step 1: Analyze Test Data First
**Before assuming code is broken, check if test data matches API expectations:**

```bash
# Check function signatures and type hints
grep -A 5 "def function_name" path/to/file.py
# Look for parameter types and return types

# Check test data types
python3 -c "
import test_module
print(type(test_data))
print(hasattr(test_data, 'expected_attribute'))
"
```

#### Step 2: Validate Test Inputs
**Common test data mismatches:**
- UUID objects vs UUID strings
- Integer IDs vs string representations  
- None/null vs empty string/list
- Object attributes that may not exist

#### Step 3: Investigation Priority
1. **Test data validation** - Check types match function expectations
2. **Environment differences** - Local vs CI setup variations
3. **Recent changes impact** - But don't assume correlation = causation  
4. **Production code issues** - Only after validating test data

#### Test Data Investigation Commands
```bash
# Check object types in test
python3 -c "
from test_file import test_object
print(f'Type: {type(test_object.attribute)}')
print(f'Value: {test_object.attribute}')
print(f'String repr: {str(test_object.attribute)}')
"

# Verify function expects strings
grep -B 2 -A 5 "def function.*str" source_file.py
```

#### Documentation Pattern for Test Failures
```markdown
### Test Failure Analysis: [Test Name]

#### Failure Symptoms
- [Exact error message]
- [When it occurs: CI only, locally, etc.]

#### Root Cause Analysis
1. **Test data validation**: [What types were passed vs expected]
2. **API contract check**: [Function signature vs test inputs]  
3. **Environment factors**: [Differences between local/CI]

#### Resolution
- [What was actually wrong: usually test data, not code]
- [Changes made to fix the issue]

#### Prevention  
- [How to avoid this pattern in future tests]
```

### Test Data Contract Debugging

#### Quick Validation Script
```python
def validate_test_data(function, test_input):
    """Helper to validate test data matches function expectations."""
    import inspect
    
    # Get function signature
    sig = inspect.signature(function)
    params = list(sig.parameters.items())
    
    if len(params) > 0:
        param_name, param_info = params[0]  # First parameter
        expected_type = param_info.annotation
        actual_type = type(test_input)
        
        print(f"Function: {function.__name__}")
        print(f"Parameter: {param_name}")  
        print(f"Expected type: {expected_type}")
        print(f"Actual type: {actual_type}")
        print(f"Match: {actual_type == expected_type}")
        
        if hasattr(test_input, '__class__'):
            print(f"Test input: {test_input}")
        
        return actual_type == expected_type
    return True

# Usage example:
# validate_test_data(Slice.get, chart.uuid)  # Will show UUID vs str mismatch
```
