# RCA Writeups

## Golden Rule
- **Separate incident root cause from latent bugs** — readers need to know exactly what caused the outage vs. what was opportunistically hardened.

## Structure

In PROJECT.md and PR descriptions for bug fixes:

1. **Incident Root Cause** — a single clear statement of what caused the user-visible failure.
2. **Latent Bug(s) / Hardening** — separate section for correctness issues found during investigation and fixed in the same change.
3. **Fix** — the implementation, enumerated by what it addresses.

## Why This Matters

Mixing incident cause with secondary findings:
- Overstates the outage's complexity
- Obscures the actual failure mode for oncall and postmortem review
- Makes reviewers uncertain which changes are blocking vs. hardening

## Example

**Good:**
> **Incident Root Cause:** Frontend omitted pagination params, causing backend timeout on large teams.
> **Latent Bug:** Query relied on positional alignment, risking mis-paired user/role data. Fixed in same PR.

**Bad:**
> Timeout was caused by missing pagination and a positional-alignment bug in the query logic.
