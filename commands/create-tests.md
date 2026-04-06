# /create-tests - Create the First Meaningful Tests

@{{TOOLKIT_DIR}}/skills/review-tests.md

> **When**: You want standalone test-only work for an area that does not yet have a meaningful suite, or `/update-tests` has handed off because there is nothing real to update.
> **Produces**: A first meaningful test suite or net-new high-signal coverage, validation results, and a summary of remaining gaps.

## Usage
```
/create-tests                         # First meaningful tests for current uncommitted work
/create-tests <file>                  # First meaningful tests for a specific file
/create-tests --function <name>       # First meaningful tests for a specific function
```

## Steps

1. **Determine Scope**

   Identify the code to test:
   - Uncommitted changes: `git diff --name-only`
   - Specific file or function: as provided
   - Read the code thoroughly before writing any tests

2. **Create Initial Tests**

   Use `create-tests.md`. This helper owns:
   - running `review-tests` before writing tests
   - choosing the right test layer
   - creating the first meaningful tests for the target area
   - targeted verification

3. **Review Changed Test Files**

   Run `/review-code` on the changed repo-tracked files as an internal loop.
   Keep iterating until only nitpicks remain or a real blocker/user decision appears.

4. **Summary**
   ```markdown
## Create-Tests Complete

   ### Outcome
   - [Created first meaningful suite / stopped on blocker]

   ### Scope
   - [What behavior or files were covered]

   ### Behavioral Coverage
   - [What regressions or behaviors are now covered]

   ### Review / Quality
   - [Review rounds and final review outcome]

   ### Verification
   - [Checks run]

   ### Risks / Blockers
   - [Anything still unverified or out of scope]

   ### Remaining Gaps
   - [Anything still not covered]

   ### Next Decision
   - [Ready for manual commit / needs more work]
   ```

   Record lifecycle: `command-complete` { command: "create-tests", status: `<outcome>`, complexity: `<tier>`, rounds: `<N>`, models_used: `{opus: N, sonnet: N, haiku: N}` }

## PROJECT.md Update Discipline

Update `PROJECT.md` at these points:
- after the target scope is locked
- after the main test-writing pass
- at final completion with the validation result and remaining gaps

## Continuation Checkpoint

```markdown
## Continuation Checkpoint — [timestamp]
### Workflow
- Top-level command: /create-tests <arguments>
- Phase: scope / review-tests / write-tests / verify / review / summarize
- Resume target: <files, function, or behavior under test>
- Completed items: <finished steps>
### State
- Current scope: <what is being tested>
- Review status: <clean / blocked / pending>
- Tests added so far: <files or none>
- Verification status: <passed / partial / blocked>
```

## Notes
- `/create-tests` is a test-only command, not the normal entrypoint for feature or bug workflows
- Favor the smallest set of high-signal tests over broad test quantity
- `/review-code` is an internal phase here, not the expected next top-level user step
