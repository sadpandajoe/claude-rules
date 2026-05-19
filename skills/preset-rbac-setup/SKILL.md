---
name: preset-rbac-setup
description: Seeding the canonical RBAC test users (workspace roles + data access roles) on a fresh Preset staging workspace via the Manager API, before RBAC-related QA. Do NOT use for changing roles on real customer workspaces, creating new test accounts (the seven test logins must already exist), or generic team administration.
user-invocable: false
---

# Preset RBAC Setup

Seeds the canonical seven test users with workspace roles and (where applicable) a default data access role on a target Preset workspace. The mapping originated in `preset-io/e2e-automation` cypress rbac tests; capture it here because that repo is going away.

## Inputs

- **Workspace URL or hostname** — e.g. `https://7b412530.us1a.app-stg.preset.io/` → host `7b412530.us1a.app-stg.preset.io`. Take this as the only positional arg.
- **Manager URL** — derive from workspace host: `app-stg` workspaces → `https://manage.app-stg.preset.io`, `app-dev` → `https://manage.app-dev.preset.io`, `app.preset.io` → `https://manage.app.preset.io`. Confirm with the user if the pattern doesn't match.
- **Bot creds** — `PRESET_STG_BOT_LOGIN` / `PRESET_STG_BOT_PASSWORD` (env vars; staging only). Bot must be a member of the team that owns the workspace, with sufficient privilege to update memberships and create permissions.

## Canonical user → role mapping

| Email | Workspace role | DAR? |
|-------|----------------|------|
| `test-primary-contributor@preset.zone` | `PresetAlpha` | yes |
| `test-limited-contributor@preset.zone` | `PresetGamma` | yes |
| `test-limited-contributor-no-access@preset.zone` | `PresetGamma` | **no** |
| `test-dashboard-viewer@preset.zone` | `PresetDashboardsOnly` | yes |
| `test-dashboard-viewer-no-access@preset.zone` | `PresetDashboardsOnly` | yes (test name "no access" refers to the dashboards exercised, not the DAR) |
| `test-viewer@preset.zone` | `PresetReportsOnly` | yes |
| `test-no-access@preset.zone` | `PresetNoAccess` | **no** |

Workspace role identifiers are Preset-specific names (not Superset's `Admin`/`Alpha`/`Gamma`). Use exactly these strings.

## DAR grant shapes

A DAR's `acl[dar:<name>].grants` array holds one or more `{resource, action}` objects. The cypress tests use these variants:

**Default per-datasource grants** — the `setupRbacTests({ createAccessRole: true })` default. Four datasources on the `examples` DB:

```json
[
  {"resource": "database:examples:schema:public:datasource:Sample Geodata",                    "action": "datasource_access"},
  {"resource": "database:examples:schema:public:datasource:Flights",                           "action": "datasource_access"},
  {"resource": "database:examples:schema:public:datasource:San Francisco BART Lines",          "action": "datasource_access"},
  {"resource": "database:examples:schema:public:datasource:San Francisco Population Polygons", "action": "datasource_access"}
]
```

**Whole-database grant** — used by primary/limited-contributor tests that create their own DB and grant access to everything in it (`setupRbacTests({ dataAccessGrants: [...] })`):

```json
[{"resource": "database:<dbName>", "action": "database_access"}]
```

**Resource string conventions:**
- Database: `database:<dbName>`
- Datasource (table): `database:<dbName>:schema:<schemaName>:datasource:<tableName>`
- Schema: `database:<dbName>:schema:<schemaName>` (with `schema_access` action — exists in the API but no rbac test currently uses it)

If the user asks for narrower/wider grants, substitute the array — the rest of the procedure is unchanged.

## Manager API contract

All RBAC writes go to **Manager** (NOT the workspace's Superset API). All paths are relative to `MANAGER_URL`.

| Step | Method | Path | Body / query |
|------|--------|------|--------------|
| List teams the bot belongs to | GET | `/api/v1/teams/` | — |
| List a team's workspaces | GET | `/api/v1/teams/{teamSlug}/workspaces/` | — |
| List team memberships (email → user_id, username) | GET | `/api/v1/teams/{teamSlug}/memberships/` | — |
| Set workspace role | PUT | `/api/v1/teams/{teamSlug}/workspaces/{workspaceId}/membership` | `{role_identifier, user_id}` |
| List permissions on a workspace | GET | `/api/v1/teams/{teamSlug}/permissions/` | qs: `workspace_name`, `permission_type` (`data_access_role` / `row_level_security`), `grantee_identifier` |
| Get one permission | GET | `/api/v1/teams/{teamSlug}/permissions/{permissionName}` | — |
| Create data access role | POST | `/api/v1/teams/{teamSlug}/permissions/` | DAR body (see below) |
| Update data access role | PUT | `/api/v1/teams/{teamSlug}/permissions/{permissionName}` | DAR body |
| Delete data access role | DELETE | `/api/v1/teams/{teamSlug}/permissions/{permissionName}` | — |

DAR body shape (`type: "data_access_role"`):

```json
{
  "workspace_name": "<workspace.name>",
  "type": "data_access_role",
  "grantees": [{"type": "USER", "identifier": "<user.username>"}],
  "acl": {
    "dar:ROLES <random>": { "config": {}, "grants": [ ...GRANTS ] }
  }
}
```

The `dar:` prefix and the `acl` shape are required. The role name (`ROLES <random>`) is arbitrary but should be unique per call; the random suffix avoids collisions on rerun.

**Empty DAR variant** — `grantees: []` and `grants: []`. Used by `createEmptyDataAccessRoleByTeamNameAndHostApi` as a placeholder paired with a separately-created RLS rule. Don't create one for plain seeding; only relevant if the request specifically pairs an empty DAR with RLS.

**Permission install is async** — after POST/PUT, the permission goes through `SYNCING` → `APPLIED` (or `FAILED`/`TIMEOUT`). Poll `GET /permissions/{name}` until `status === "APPLIED"` if the next step depends on the permission being live (e.g. then immediately logging in as that user and asserting access). For pure seeding it's usually fine to fire-and-forget. Cypress polls every ~5s up to 12 retries.

## Auth model (the gotcha)

Manager auth = **session cookies + a single short token used in two headers**. The token can be read from either:

- `localStorage.access_token` (older builds — what the cypress code expects)
- The `csrf_access_token` cookie (newer Manager builds — observed 2026-05 on app-stg)

Try `localStorage.access_token` first; fall back to the cookie. The same token goes into:

- `Authorization: Bearer <token>`
- `X-CSRF-Token: <token>` (only on writes)

For writes also send `Referer: <workspace URL>` (any workspace URL on the same Manager works, e.g. the target one).

## Login flow (Playwright)

The login page is two-step (email → "Next" → password → "Log in"), not a single form. Use `page.getByRole('button', { name: /next/i })` then `page.getByRole('button', { name: /log in/i })`. `chromium.launch({ headless: true })` is fine — login is a no-op on rerun if `storageState` is reused.

Persist `storageState` at `~/.qa-runner/storage/manage.<env>.preset.io.json` so reruns skip login.

## Procedure

1. Launch Chromium with `storageState` (reuse if exists, else fresh login flow above). Save state after login.
2. `page.evaluate` to read `localStorage.access_token`. If null, read the `csrf_access_token` cookie via `context.cookies()`. Abort if neither exists.
3. GET `/api/v1/teams/`. For each team, GET `/api/v1/teams/{slug}/workspaces/` and search the payload for `hostname === <target host>`. The first match is `targetTeamSlug` + `workspace`.
4. GET `/api/v1/teams/{targetTeamSlug}/memberships/`. Build `Map<emailLowercase, user>`.
5. For each user in the canonical mapping:
   - Skip with a `NOT_A_MEMBER` log line if email isn't in memberships (user must be invited to the team first; this skill doesn't invite).
   - **Pre-clean** (recommended on reseed): GET `/api/v1/teams/{slug}/permissions/?workspace_name={ws.name}&grantee_identifier={user.username}` and DELETE every returned permission. Mirrors the cypress `deletePermissionsByEmail` helper that `setupRbacTests` always runs first. Skip on a true first-time seed.
   - PUT membership with `{role_identifier, user_id: user.id}`.
   - If `dar: true`, POST `/api/v1/teams/{slug}/permissions/` with the DAR body using `user.username` as grantee identifier.
6. Print a summary table with status per user (`OK`, `OK_NO_DAR`, `NOT_A_MEMBER`, `ROLE_FAILED`, `DAR_FAILED`).

## Idempotency notes

- **PUT membership** is idempotent — safe to rerun without cleanup.
- **POST permissions** is *not* idempotent — every call creates a new DAR. Without the pre-clean step, reruns leave orphan DARs piled up on each user (working but messy in the Manager UI). Default to pre-cleaning unless the user explicitly says "first-time seed".
- **PUT permissions** can also update an existing DAR by name if you want to mutate grants in place rather than recreating.

## Where to put the runnable script

Drop the standalone Node script at `~/.qa-runner/setup-rbac.mjs` (works across all worktrees, no repo coupling, sits next to existing QA recording scripts). Use `import { chromium } from 'playwright'` — `~/.qa-runner/node_modules` already has Playwright.

Invocation: `node ~/.qa-runner/setup-rbac.mjs <workspace-host-or-url>`.

## Out of scope

- **Row Level Security (RLS) rules** live on the *workspace's Superset API* at `/api/v1/rowlevelsecurity/`, not Manager. They use a separate session (logged into the workspace, not Manager) and don't share auth with the Manager APIs above. Manager does have a `row_level_security` permission type in the same `/permissions/` endpoint, but it's a metadata wrapper that pairs with a Superset RLS rule — the actual rule still has to be POSTed to the workspace. If a request needs RLS, scope it as a separate skill or extend this one with a workspace-API section.
- **Inviting users to a team** — this skill assumes the seven test accounts are already team members. If `NOT_A_MEMBER` shows up in the summary, the user must invite them via the Manager UI (or extend this with `/api/v1/teams/{slug}/memberships/` POST).
- **Workspace creation** — assumed to exist. Don't build workspaces here.

## Sanity check before running

- Is the workspace genuinely a *test* workspace (e.g. ends with `app-stg.preset.io` and has a hex-style slug)? Refuse to run against `app.preset.io` (production) without explicit confirmation.
- Does the user list match what the user asked for, or are they asking for a custom subset? The seven canonical users are the default — if they only want some, take a list.
