---
name: diagnose-ci
description: Known CI failure patterns, classification rules, and fix strategies for automated CI diagnosis.
---

# CI Failure Diagnosis

You are diagnosing a CI failure. Match the failure against known patterns below, then classify your confidence and propose a fix.

## Known Failure Patterns

| Pattern | Symptoms | Fix | Confidence |
|---------|----------|-----|------------|
| **Stale TypeScript declarations** | `TS2305: Module has no exported member` after rename/move | Rebuild: `npm run build` or delete `dist/` and rebuild | HIGH |
| **Missing dependencies** | `Cannot find module 'X'` in CI but works locally | Add to `package.json` / `requirements.txt`, run install | HIGH |
| **Import path case mismatch** | Works on macOS (case-insensitive), fails on Linux CI | Fix the import path casing to match the actual filename | HIGH |
| **Lint/format drift** | `eslint` or `prettier` failures on lines you didn't change | Run formatter (`npm run lint:fix`, `ruff format`), commit | HIGH |
| **Flaky test — timing** | Test passes locally, fails in CI with timeout | Increase timeout or add `waitFor`/retry logic | MEDIUM |
| **Flaky test — order-dependent** | Test fails only when run with full suite, passes alone | Find shared state (global, DB, env var), isolate it | MEDIUM |
| **Cherry-pick residue** | Conflict markers (`<<<<<<<`) in committed files | Search and resolve remaining markers | HIGH |
| **Missing env vars** | `undefined` or `KeyError` for config values | Add to CI config (`.github/workflows/`, `.env.ci`) | MEDIUM |
| **Node version mismatch** | Syntax errors or API differences | Check `.nvmrc` / `engines` field vs CI node version | MEDIUM |
| **Out-of-memory** | `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed` | Reduce `maxWorkers`, add `--max-old-space-size` | HIGH |
| **Lock file conflict** | `npm ci` fails with lockfile mismatch | Regenerate lockfile: `npm install`, commit `package-lock.json` | HIGH |

## Analysis Steps

1. **Read the full error output** — not just the first line
2. **Identify the failing step** — build, test, lint, deploy?
3. **Match against known patterns** above
4. **If no match**: read the source files referenced in the error, check recent commits for relevant changes
5. **Classify confidence**: HIGH (exact match), MEDIUM (likely match), LOW (novel)

## Output Format

For each failure:

```markdown
### Failure: [step name]

**Error**: [key error message]
**Pattern**: [matched pattern name, or "Novel"]
**Confidence**: HIGH / MEDIUM / LOW
**Root Cause**: [explanation]
**Proposed Fix**: [specific fix with commands/code changes]
**Verification**: [how to verify the fix locally]
```
