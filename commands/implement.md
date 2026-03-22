# /implement - Implementation Workflow

@/Users/joeli/opt/code/ai-toolkit/rules/implementation.md

> **When**: Ready to implement a planned change.
> **Produces**: Committed, tested code following project conventions.

## Steps

1. **Pre-Implementation Checks (Parallel Agents)**

   Read PROJECT.md for the approved plan, then spawn parallel Task subagents:

   **Agent 1: Environment Verification**
   - Verify correct branch and clean working tree
   - Check `node_modules` / virtualenv / dependencies are installed
   - If missing: install them (`npm install`, `pip install -r requirements.txt`, etc.)
   - Verify build outputs are fresh (no stale `.d.ts`, compiled JS, etc.)
   - If stale: rebuild affected packages

   **Agent 2: Local Environment Setup** (if PROJECT.md or project config specifies how)
   - Check if a local stack is needed for testing (Docker, dev server, etc.)
   - If instructions exist: spin it up (respecting resource-management rules — check `docker ps` first)
   - If no instructions: skip, note that testing will be unit/integration only

   **Agent 3: Dependency Audit**
   - Verify imports/packages referenced in the plan actually exist in the project
   - Check for version conflicts or missing peer dependencies
   - Flag anything that needs manual resolution

   **These agents run in the background** — do NOT wait for them before starting TDD.
   - If an agent encounters issues, it should try to resolve them autonomously (install deps, rebuild, etc.)
   - Only surface to the user at the end (in the summary) or if resolution fails and blocks testing
   - Implementation proceeds in parallel with environment setup

2. **Write Tests (RED)**
   - Generate tests based on the plan's testing strategy
   - Run tests — they should FAIL (confirms they test the right thing)

3. **Review Tests**

   Invoke `/review-code` on the test files.
   (`/review-code` handles its own loop internally — review, fix, re-review until clean.)

   Commit passing test structure: `test: add tests for [feature]`

4. **Write Implementation (GREEN)**
   - Implement the minimum code to make tests pass
   - Follow existing patterns, keep changes focused

5. **Review Implementation**

   Invoke `/review-code` on the implementation files.
   (`/review-code` handles its own loop internally.)

6. **Refactor (if needed)**
   - Clean up only if there are clear improvements
   - Run tests after refactoring

7. **Commit**
   - Commit working implementation
   - Pre-flight checks: build, type-check, hooks (per implementation.md rules)

8. **Summary**
   ```markdown
   ## Implementation Complete

   ### Tests Written
   - [List of test files and what they cover]

   ### Code Changes
   - [List of implementation files and what changed]

   ### Review-Code Rounds
   - Tests: X rounds, Y issues fixed
   - Implementation: X rounds, Y issues fixed

   ### Remaining Nitpicks (not fixed)
   - [Any items noted but not addressed]

   ### Ambiguities Surfaced (needs user input)
   - [Any items where review-code couldn't decide]
   ```

## Review-Code Loop Termination Rules
- **Stop** when only `[nitpick]` items remain
- **Stop** when there's ambiguity that needs user input (present the question)
- **Continue** as long as `[major]` or `[minor]` items exist

## Implementation Standards
- Functions ≤20 lines (guideline)
- Files ≤300 lines
- Nesting ≤2 levels
- Match existing patterns
- YAGNI - only what's needed now

## Commit Message Format
```
type: brief description

- Specific change 1
- Specific change 2

[Fixes #issue]
```
Types: feat, fix, docs, style, refactor, test, chore

## Notes
- Working solution first, then optimize
- Commit working states before refactoring
- Test as you go, not at the end
