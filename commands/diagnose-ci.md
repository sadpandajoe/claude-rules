# /diagnose-ci - Diagnose CI Failures

@/Users/joeli/opt/code/ai-toolkit/rules/implementation.md

> **When**: A CI build has failed and you need to diagnose and fix it.
> **Produces**: Diagnosis of failures, auto-fixes for known patterns, recommendations for novel failures.

## Usage
```
/diagnose-ci <run-url>          # Diagnose a specific CI run
/diagnose-ci <pr-number>        # Diagnose latest CI run for a PR
/diagnose-ci                    # Diagnose latest CI run for current branch
```

## Steps

1. **Gather CI Logs**
   ```bash
   # Get failed run
   gh run list --branch <branch> --status failure --limit 1
   gh run view <run-id> --log-failed

   # Or from PR
   gh pr checks <number>
   gh run view <run-id> --log-failed
   ```

2. **Classify Failures**

   Read `skills/diagnose-ci/SKILL.md` for the known failure pattern table.

   Spawn parallel Task subagents — one per failure category detected:
   - **Build failures**: type errors, missing imports, syntax errors
   - **Test failures**: assertion failures, timeouts, flaky tests
   - **Lint/format failures**: ESLint, prettier, ruff
   - **Environment failures**: missing deps, Docker issues, CI config

   Each agent:
   - Matches the failure against known patterns from the skill
   - Reads the relevant source files
   - Assigns a confidence level: **HIGH** / **MEDIUM** / **LOW**

3. **Act Based on Confidence**

   **HIGH confidence** (matches a known pattern exactly):
   - Fix it directly
   - Run tests locally to verify the fix
   - Commit: `fix: resolve CI failure — [description]`

   **MEDIUM confidence** (likely matches a pattern but has ambiguity):
   - Present diagnosis to user with proposed fix
   - Wait for approval before applying

   **LOW confidence** (novel failure, unclear cause):
   - Present full diagnosis with log excerpts
   - Suggest investigation steps
   - Do NOT auto-fix

4. **Summary**
   ```markdown
   ## CI Diagnosis

   ### Run: [run-id / url]
   ### Branch: [branch]

   ### Auto-Fixed (HIGH confidence)
   - [What was fixed and why]

   ### Proposed Fixes (MEDIUM confidence)
   - [Diagnosis + proposed fix, awaiting approval]

   ### Needs Investigation (LOW confidence)
   - [Diagnosis + suggested next steps]

   ### Verification
   - [ ] Local tests pass after fixes
   - [ ] Build succeeds locally
   ```

## Notes
- Always read the actual failing log output — don't guess from job names alone
- Known patterns are in `skills/diagnose-ci/SKILL.md` — update that file when you encounter new recurring patterns
- Only auto-fix HIGH confidence matches; everything else goes through the user
- Run local verification before committing any fix
