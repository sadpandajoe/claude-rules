# /finalize-plan - Fresh-Eyes Plan Finalization

@/Users/joeli/opt/code/claude-rules/rules/planning.md

> **When**: Plan has been reviewed and is ready for a final independent check.
> **Produces**: Go/no-go recommendation from a fresh expert perspective.

## Usage
```
/finalize-plan                  # Finalize PROJECT.md
/finalize-plan ./docs/PLAN.md   # Finalize specific file
```

## Steps

1. **Load Plan**

   Read PROJECT.md (or specified path). If no plan exists, stop and suggest `/create-plan`.

2. **Spawn Fresh Expert**

   Read `skills/finalize-plan/SKILL.md` for review instructions.

   Spawn a single Task subagent (subagent_type: "general-purpose") passing:
   - The full plan content
   - The finalize-plan skill instructions
   - **Critical framing**: "You are a principal engineer doing a cold read. You have NOT seen any prior reviews or iterations. Evaluate this plan purely on its own merits."

3. **Present Findings**

   Show the expert's full report to the user:
   - Summary
   - Score (1-10)
   - Blocking Issues
   - Risks
   - Go/No-Go Recommendation

4. **Decision**

   - **Go (score >= 8)**: "Plan finalized. Run `/implement` to begin."
   - **No-Go (score < 8)**: Show blocking issues, suggest `/review-plan` to address them.

## Notes
- The fresh expert has NO context from prior reviews — this is intentional
- Cold read catches groupthink and iteration bias
- Single pass, no iteration loop — this is a final gate
- Full flow: `/create-plan` → `/review-plan` → `/finalize-plan` → `/implement`
