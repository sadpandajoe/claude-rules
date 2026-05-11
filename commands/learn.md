# /learn - Memory Management


> **When**: Capturing workflow patterns, reviewing accumulated memories, pruning stale entries, extracting rules from experience, recording failures, or promoting learnings to global rules.
> **Produces**: Updated memory files, pruned index, draft rules, structured postmortems, or promoted rules.

## Usage

```
/learn                          # Add a new memory interactively
/learn add "pattern or insight" # Add with inline content
/learn list                     # Show all memories with staleness
/learn review                   # Assess memories for accuracy and relevance
/learn prune                    # Remove outdated or redundant memories
/learn propose-rule             # Extract a recurring pattern into a draft rule
/learn failure                  # Record a structured postmortem
/learn promote <filename>       # Move a project memory to a global rule
```

## Route

Parse the first argument:

| Subcommand | Reference |
|------------|-----------|
| none / `add` | [skills/learning/references/memory-basics.md](../skills/learning/references/memory-basics.md) |
| `list` | [skills/learning/references/memory-basics.md](../skills/learning/references/memory-basics.md) |
| `review` | [skills/learning/references/memory-review.md](../skills/learning/references/memory-review.md) |
| `prune` | [skills/learning/references/memory-review.md](../skills/learning/references/memory-review.md) |
| `propose-rule` | [skills/learning/references/rule-promotion.md](../skills/learning/references/rule-promotion.md) |
| `failure` | [skills/learning/references/failure-postmortem.md](../skills/learning/references/failure-postmortem.md) |
| `promote` | [skills/learning/references/rule-promotion.md](../skills/learning/references/rule-promotion.md) |

## Contract

- Use Claude Code's existing auto-memory directory at `~/.claude/projects/<path>/memory/`.
- Keep `MEMORY.md` in sync with memory files.
- Ask before deleting memories or promoting them to rules.
- A pattern seen once is a memory; a pattern seen across projects can become a rule candidate.
- Rule changes follow `rules/rule-maintenance.md` and require confirmation.

## Notes

- `/learn` is read-only for the codebase unless the user confirms a rule promotion or rule proposal.
- When called from `/start`, suggest `/learn review` if memories have not been reviewed in > 30 days.
- `/learn failure` is best used immediately after a failure while context is fresh.
