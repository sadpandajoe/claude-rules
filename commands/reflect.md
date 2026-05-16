# /reflect - Memory Management


> **When**: Capturing workflow patterns, reviewing accumulated memories, pruning stale entries, extracting rules from experience, recording failures, or promoting learnings to global rules.
> **Produces**: Updated memory files, pruned index, draft rules, structured postmortems, or promoted rules.

## Usage

```
/reflect                          # Add a new memory interactively
/reflect add "pattern or insight" # Add with inline content
/reflect list                     # Show all memories with staleness
/reflect review                   # Assess memories for accuracy and relevance
/reflect prune                    # Remove outdated or redundant memories
/reflect propose-rule             # Extract a recurring pattern into a draft rule
/reflect failure                  # Record a structured postmortem
/reflect promote <filename>       # Move a project memory to a global rule
```

## Route

Parse the first argument:

| Subcommand | Reference |
|------------|-----------|
| none / `add` | [skills/reflection/references/memory-basics.md](../skills/reflection/references/memory-basics.md) |
| `list` | [skills/reflection/references/memory-basics.md](../skills/reflection/references/memory-basics.md) |
| `review` | [skills/reflection/references/memory-review.md](../skills/reflection/references/memory-review.md) |
| `prune` | [skills/reflection/references/memory-review.md](../skills/reflection/references/memory-review.md) |
| `propose-rule` | [skills/reflection/references/rule-promotion.md](../skills/reflection/references/rule-promotion.md) |
| `failure` | [skills/reflection/references/failure-postmortem.md](../skills/reflection/references/failure-postmortem.md) |
| `promote` | [skills/reflection/references/rule-promotion.md](../skills/reflection/references/rule-promotion.md) |

## Contract

- Use the configured agent memory directory. For Claude Code installs, this is usually `~/.claude/projects/<path>/memory/`.
- Keep `MEMORY.md` in sync with memory files.
- Ask before deleting memories or promoting them to rules.
- A pattern seen once is a memory; a pattern seen across projects can become a rule candidate.
- Rule changes follow `rules/rule-maintenance.md` and require confirmation.

## Notes

- `/reflect` is read-only for the codebase unless the user confirms a rule promotion or rule proposal.
- When called from `/start`, suggest `/reflect review` if memories have not been reviewed in > 30 days.
- `/reflect failure` is best used immediately after a failure while context is fresh.
