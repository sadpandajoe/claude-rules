# /review-plan - Domain Expert Plan Review

@/Users/joeli/opt/code/claude-rules/rules/planning.md

> **When**: A plan exists in PROJECT.md and needs expert review before implementation.
> **Produces**: Synthesized multi-perspective feedback, iterated plan scoring 8/10+.

## Usage
```
/review-plan                    # Auto-detect relevant reviewers
/review-plan --frontend         # Force include frontend reviewer
/review-plan --backend          # Force include backend reviewer
/review-plan --all              # Run all reviewers
/review-plan ./docs/PLAN.md     # Review specific file
```

## Steps

1. **Load Plan**

   Read PROJECT.md (or specified path). If no plan exists, stop and suggest `/create-plan`.

2. **Detect Applicable Reviewers**

   **Always eligible** (spawn these every time):
   - `skills/review-architecture/SKILL.md`
   - `skills/review-implementation/SKILL.md`
   - `skills/review-testplan/SKILL.md`

   **Auto-detected** by scanning plan content for keywords:
   - **Frontend**: UI, React, component, CSS, styled, theme, modal, form, page, layout, UX, accessibility, a11y → `skills/review-frontend/SKILL.md`
   - **Backend**: API, endpoint, database, model, migration, SQL, query, auth, middleware, REST, GraphQL, schema → `skills/review-backend/SKILL.md`

   **Override via flags**: `--frontend`, `--backend`, `--all`

3. **Spawn Parallel Reviewers**

   For each applicable reviewer:
   1. Read the skill's `SKILL.md` for its review instructions
   2. Spawn a Task subagent (subagent_type: "general-purpose") passing:
      - The full plan content
      - The skill's review instructions
      - Instruction to output in the skill's specified format

   **Spawn all reviewers in parallel** using multiple Task tool calls in a single message.

4. **Synthesize Feedback**

   Collect all reviewer results and present a unified report:

   ```markdown
   ## Plan Review Results

   ### Reviewer Scores
   | Reviewer | Score | Key Concern |
   |----------|-------|-------------|
   | Architecture | X/10 | [Top issue] |
   | Implementation | X/10 | [Top issue] |
   | Testing | X/10 | [Top issue] |
   | Frontend | X/10 | [Top issue] |
   | Backend | X/10 | [Top issue] |

   ### Consensus Issues (flagged by 2+ reviewers)
   These are highest priority — multiple perspectives agree:
   - [Issue + which reviewers flagged it]

   ### All Issues by Priority
   #### High
   - [Issue] — [Reviewer]
   #### Medium
   - [Issue] — [Reviewer]
   #### Low
   - [Issue] — [Reviewer]

   ### Reviewer Conflicts
   Where reviewers disagree, with Claude's resolution:
   - [Conflict description + resolution]
   ```

5. **User Decision**

   Present options:
   - **Iterate**: Claude improves the plan (consensus first, then High, then Medium), updates PROJECT.md, re-runs review
   - **Finalize**: Plan is good enough → suggest `/finalize-plan`
   - **Accept**: Skip finalization, go straight to `/implement`
   - **Manual**: User will address feedback themselves

6. **Iteration Loop** (if user chooses "Iterate")

   1. Claude improves plan content directly in PROJECT.md (not as comments)
      - Address consensus issues first
      - Then High priority issues
      - Then Medium if time permits
   2. Re-run from step 2 with improved plan
   3. Max **3 rounds**, then suggest `/finalize-plan`

7. **Final Report**
   ```markdown
   ## Review Complete

   ### Rounds: [N]
   | Round | Avg Score | Key Improvements |
   |-------|-----------|------------------|
   | 1 | 5.5 | Missing risk assessment |
   | 2 | 7.8 | Added testing strategy |

   ### Next Steps
   - Run `/finalize-plan` for fresh-eyes final check
   - Or `/implement` to begin implementation
   ```

## Notes
- Defaults to PROJECT.md
- All reviewers run in parallel for speed
- Consensus issues (2+ reviewers) get highest priority
- Claude improves plan content directly — never writes review comments into PROJECT.md
- Max 3 iteration rounds, then suggest finalization
