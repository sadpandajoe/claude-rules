---
model: sonnet
---

# CI Gather Logs

Use at the start of `/fix-ci` after input normalization. The goal is to resolve real failing log output before any classification happens.

## Inputs

Accepted sources:
- GitHub Actions run URL
- PR number
- local log file
- local zip artifact bundle
- no argument: latest failed run on current branch

## GitHub Actions Retrieval

Try `gh` first:

```bash
gh run list --branch <branch> --status failure --limit 1
gh run view <run-id> --log-failed
```

From a PR:

```bash
gh pr checks <number>
gh run view <run-id> --log-failed
```

If `gh run list` returns no failures, check the check-runs endpoint:

```bash
gh api repos/{owner}/{repo}/commits/{sha}/check-runs \
  --jq '.check_runs[] | select(.conclusion == "failure")'
```

If `gh run view --log-failed` returns empty output, fall back to per-job logs:

```bash
gh api repos/{owner}/{repo}/actions/runs/{run-id}/jobs \
  --jq '.jobs[] | select(.conclusion == "failure") | {id, name}'
gh api repos/{owner}/{repo}/actions/jobs/{job-id}/logs
```

## Local Artifacts

If `gh` commands fail or CI is external:
- Use the provided local log file or artifact bundle when available.
- If no log source is available, ask for one. Do not classify without actual log output.

If the input is a zip bundle:
- unzip it automatically
- locate failing logs
- split multi-job bundles into per-failure units before classification

## Large CI Manifest

For 3+ failed jobs, artifact bundles, or logs large enough that raw output would dominate the session, create local `CI_FIX.md` using [../templates/ci-fix-manifest.md](../templates/ci-fix-manifest.md).

`CI_FIX.md` owns:
- run URL / artifact paths
- failed jobs and log file paths
- failure fingerprints
- grouped root causes
- fix status
- verification status

`PROJECT.md` should only point to the active CI fix run, current phase, and `CI_FIX.md` path. Do not paste full logs into chat or PROJECT.md unless a short excerpt is decisive evidence.

Keep `CI_FIX.md` local-only. Prefer `.git/info/exclude` for workspace-specific ignores; this toolkit also ignores and hook-protects `CI_FIX.md`.

## Output

Return:

```markdown
## CI Logs Resolved

Source: <run URL | PR | local path | artifact path>
Failures found: <N>
Manifest: CI_FIX.md | none

| Failure | Job | Step | Log path/source | Notes |
|---------|-----|------|-----------------|-------|
| 1 |  |  |  |  |
```
