# Preset Environments

Reference for Preset-specific environments and how to reach them during testing.

## Staging Credentials

When testing **Manager** or **Superset-shell** against a staging environment, use these env vars for authentication — never hardcode credentials:

| Env Var | Purpose |
|---------|---------|
| `PRESET_STG_BOT_LOGIN` | Login / username for staging bot account |
| `PRESET_STG_BOT_PASSWORD` | Password for staging bot account |

Read them at test time:

```bash
echo $PRESET_STG_BOT_LOGIN       # verify the var is set
echo $PRESET_STG_BOT_PASSWORD     # verify the var is set
```

If either is unset, stop and tell the user:

> "Staging credentials not found. Set `PRESET_STG_BOT_LOGIN` and `PRESET_STG_BOT_PASSWORD` in your shell environment, then retry."

Do not fall back to guessing common dev passwords for staging — the bot account credentials are required.

## Environment Detection

Identify which environment is under test by the app URL:

| URL Pattern | Environment | Credentials |
|-------------|-------------|-------------|
| `localhost:*` | Local dev | Try `admin`/`admin`, `admin`/`general` |
| `*.stg.preset.io` or `stg.` in hostname | Staging | `PRESET_STG_BOT_LOGIN` / `PRESET_STG_BOT_PASSWORD` |
| `*.preset.io` (no `stg`) | Production | Do not run automated tests |

**Never run automated browser tests against production.**

## Preset Products

| Product | Typical local port | Staging URL pattern |
|---------|-------------------|---------------------|
| Manager | 3000 | `manager.stg.preset.io` |
| Superset-shell | 8088 | `*.stg.preset.io` |
