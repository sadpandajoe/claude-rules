# /learn - Memory Management

@{{TOOLKIT_DIR}}/rules/rule-maintenance.md

> **When**: Capturing workflow patterns, reviewing accumulated memories, pruning stale entries, or extracting rules from experience.
> **Produces**: Updated memory files, pruned index, or draft rules proposed for user confirmation.

## Usage

```
/learn                          # Add a new memory (interactive)
/learn add "pattern or insight" # Add with inline content
/learn list                     # Show all memories with staleness
/learn review                   # Assess memories for accuracy and relevance
/learn prune                    # Remove outdated or redundant memories
/learn propose-rule             # Extract a recurring pattern into a draft rule
```

## Steps

### 1. Parse Subcommand

Route based on the first argument:
- No argument or `add` → Add flow (step 2)
- `list` → List flow (step 3)
- `review` → Review flow (step 4)
- `prune` → Prune flow (step 5)
- `propose-rule` → Rule proposal flow (step 6)

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
- `reference_shortcut_api.md` — references `skills/shared/shortcut-fetch.md` (pre-Wave-3 path, now `shortcut-fetch.md`)

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

## Notes

- `/learn` works with the existing auto-memory system at `~/.claude/projects/<path>/memory/`. It does not create a parallel storage mechanism.
- Memory files use the same YAML frontmatter format as Claude Code's built-in auto-memory.
- The `MEMORY.md` index file is always kept in sync with the actual memory files.
- `/learn` is read-only for the codebase — it only writes to the memory directory and optionally to `rules/` (with confirmation).
- When called from `/start`, suggest `/learn review` if memories haven't been reviewed in > 30 days.
