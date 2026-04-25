# /learn - Memory Management

@{{TOOLKIT_DIR}}/rules/rule-maintenance.md

> **When**: Capturing workflow patterns, reviewing accumulated memories, pruning stale entries, extracting rules from experience, recording failures, or promoting learnings to global rules.
> **Produces**: Updated memory files, pruned index, draft rules, structured postmortems, or promoted rules.

## Usage

```
/learn                          # Add a new memory (interactive)
/learn add "pattern or insight" # Add with inline content
/learn list                     # Show all memories with staleness
/learn review                   # Assess memories for accuracy and relevance
/learn prune                    # Remove outdated or redundant memories
/learn propose-rule             # Extract a recurring pattern into a draft rule
/learn failure                  # Record a structured postmortem
/learn promote <filename>       # Move a project memory to a global rule
```

## Steps

### 1. Parse Subcommand

Route based on the first argument:
- No argument or `add` → Add flow (step 2)
- `list` → List flow (step 3)
- `review` → Review flow (step 4)
- `prune` → Prune flow (step 5)
- `propose-rule` → Rule proposal flow (step 6)
- `failure` → Failure postmortem flow (step 7)
- `promote` → Memory promotion flow (step 8)

### 2. Add Flow (`/learn` or `/learn add`)

**a.** If no inline content provided, ask the user what they want remembered.

**b.** Classify the memory type:
- `feedback` — behavioral correction or confirmed approach (how Claude should work)
- `reference` — pointer to external resources or operational patterns
- `project` — project-specific context, deadlines, team decisions
- `user` — personal role, preferences, knowledge level

**c.** Determine the filename: `{type}_{snake_case_topic}.md`
Follow the existing naming pattern (e.g., `feedback_no_projectmd_checkin.md`, `reference_shortcut_api.md`).

**d.** Check for duplicates: read `MEMORY.md` and scan existing memory files for overlapping content. If overlap found, ask whether to update the existing memory or create a new one.

**e.** Write the memory file with YAML frontmatter and structured body:

```markdown
---
name: {descriptive name}
description: {one-line description — used for relevance matching}
type: {feedback|reference|project|user}
---

{Statement of the pattern, fact, or preference}

**Why:** {Rationale — what prompted this, what went wrong/right}

**How to apply:** {Concrete guidance for when and how to use this}
```

**f.** Update `MEMORY.md` index with a new entry linking to the file.

### 3. List Flow (`/learn list`)

**a.** Read `MEMORY.md` for the index.

**b.** Read each linked memory file. For each, compute staleness from file modification time:
- **Fresh** (< 7 days since modified)
- **Aging** (7–30 days)
- **Stale** (> 30 days)

**c.** Display a table:

```markdown
| File | Type | Description | Age | Status |
|------|------|-------------|-----|--------|
| feedback_no_projectmd_checkin.md | feedback | PROJECT.md must never be committed | 12d | Aging |
```

**d.** Read-only — no changes made.

### 4. Review Flow (`/learn review`)

**a.** Read all memory files.

**b.** For each memory, assess:
- Is it still accurate given current rules and codebase state?
- Does it duplicate or contradict a rule in `rules/`?
- Has it been superseded by a newer memory?
- Is the referenced file/path/resource still valid? (Check if named files exist)

**c.** Present findings with recommendations:

```markdown
## Memory Review

### Keep
- `feedback_summary_style.md` — still relevant, no conflicts

### Update
- `reference_shortcut_api.md` — references an obsolete Shortcut fetch helper path (current path: `skills/shortcut/references/fetch.md`)

### Prune candidates
- [none found, or list with reasons]
```

**d.** Ask user to confirm changes before applying any updates or deletions.

### 5. Prune Flow (`/learn prune`)

**a.** Read all memory files.

**b.** Identify candidates:
- Stale entries (> 30 days without update)
- Duplicates (content overlap with another memory or a rule)
- Contradictions with current rules
- References to files/paths that no longer exist

**c.** Present the prune list with reasons. Ask user to confirm each deletion.

**d.** For confirmed deletions: delete the file and remove its entry from `MEMORY.md`.

### 6. Propose Rule Flow (`/learn propose-rule`)

**a.** Scan recent conversation and memory files for recurring patterns. Look for:
- Feedback memories that repeat the same theme
- Workarounds that have been applied multiple times
- Behavioral patterns that should be universal (not just project-specific)

**b.** Decision criteria — rules vs. memories:
- **Rule**: Pattern applies across all projects and sessions, is structural, constrains behavior
- **Memory**: Pattern is project-specific, personal preference, or operational context
- **Skill lesson/gotcha**: Pattern applies only when a specific skill is active; append it to that skill's `lessons.md` or `gotchas.md` instead of promoting it globally

**c.** Check `rules/` for partial coverage (update existing rule vs. new rule).

**d.** Draft rule content following conventions from `rules/rule-maintenance.md`:
- 20–40 lines, one concern per file
- Same heading style as other rules
- Kebab-case filename derived from the main concern (e.g., `rules/pre-flight-gate.md`)

**e.** Present the draft in a fenced code block:

```markdown
## Proposed Rule

**Target:** `rules/{proposed-name}.md`

\```markdown
{draft rule content}
\```

Write this rule?
```

**f.** On user confirmation:
1. Write the rule file
2. Remind user to run `./install.sh` to rebuild path-resolved copies
3. Suggest which commands might benefit from importing the new rule

### 7. Failure Postmortem Flow (`/learn failure`)

Record a structured postmortem after a workflow fails or produces a bad outcome. This creates a feedback memory with enough context to prevent recurrence.

**a.** Ask the user (or accept inline) what happened. Gather:
- Which command or workflow failed
- What the expected outcome was
- What actually happened
- Whether it was a tooling issue, a process gap, or a knowledge gap

**b.** Investigate the current state for evidence:
- Check recent git log for what was committed or reverted
- Check PROJECT.md for the last recorded status
- Check conversation for gate decisions, review scores, or error messages

**c.** Write the postmortem memory file:

```markdown
---
name: {descriptive name}
description: {one-line summary of what went wrong}
type: feedback
---

## What happened
{Factual description: command, inputs, expected vs actual outcome}

## What the system decided
{Which gate, skill, or step made the wrong call — with evidence}

## What it should have decided
{The correct action and why}

## Prevention
**Why:** {Root cause — process gap, missing signal, wrong threshold, etc.}
**How to apply:** {Specific rule, gate, or skill to adjust — reference by file path}
```

Filename: `feedback_failure_{snake_case_topic}.md`

**d.** Update `MEMORY.md` index.

**e.** If the postmortem points to a clear rule or skill fix, suggest the specific change. Do not auto-apply — present it for user confirmation.

### 8. Memory Promotion Flow (`/learn promote`)

Move a project-level memory to a global rule when the same pattern has proven universal.

**a.** Accept a memory filename argument (e.g., `feedback_no_cherry_pick_no_commit.md`). If no argument, display `/learn list` output and ask the user to select.

**b.** Read the memory file. Assess universality:
- Does this pattern apply across projects, or only to this one?
- Is it structural (constrains behavior) or contextual (describes a situation)?
- Has a similar pattern appeared in other projects or conversations?

If the pattern is project-specific, explain why and suggest keeping it as a memory. Stop.

**c.** Check `rules/` for existing coverage:
- Does an existing rule already cover this? → suggest updating that rule instead
- Is there partial coverage? → suggest extending the existing rule

**d.** Draft the rule file following conventions from `rules/rule-maintenance.md`:
- 20–40 lines, one concern per file
- Kebab-case filename (e.g., `rules/no-commit-flag-safety.md`)
- Same heading style as other rules

**e.** Present the draft:

```markdown
## Proposed Rule Promotion

**Source memory:** `{memory-filename}`
**Target rule:** `rules/{proposed-name}.md`

\```markdown
{draft rule content}
\```

Promote this memory to a rule? This will:
1. Write the rule file
2. Delete the source memory file
3. Update MEMORY.md index
```

**f.** On user confirmation:
1. Write the rule file
2. Delete the source memory file
3. Remove the entry from `MEMORY.md`
4. Remind user to run `./install.sh` to rebuild path-resolved copies
5. Suggest which commands might benefit from importing the new rule

## Notes

- `/learn` works with the existing auto-memory system at `~/.claude/projects/<path>/memory/`. It does not create a parallel storage mechanism.
- Memory files use the same YAML frontmatter format as Claude Code's built-in auto-memory.
- The `MEMORY.md` index file is always kept in sync with the actual memory files.
- `/learn` is read-only for the codebase — it only writes to the memory directory and optionally to `rules/` (with confirmation).
- When called from `/start`, suggest `/learn review` if memories haven't been reviewed in > 30 days.
- `/learn failure` is best used immediately after a failure while context is fresh.
- `/learn promote` requires cross-project evidence — a pattern seen once is a memory, a pattern seen across projects is a rule candidate.
