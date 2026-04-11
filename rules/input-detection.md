# Input Detection

When a command receives a ticket or issue reference as an argument, detect the source type and fetch accordingly:

| Input Pattern | Source | Action |
|---------------|--------|--------|
| `sc-12345` or `SC-12345` | Shortcut story | Query Shortcut REST API `/stories/12345` |
| `https://app.shortcut.com/...` | Shortcut URL | Extract story/epic ID, query REST API |
| `#12345` or `12345` (with repo context) | GitHub issue/PR | `gh issue view` or `gh pr view` |
| `owner/repo#12345` | GitHub issue/PR | `gh issue view 12345 -R owner/repo` |
| `https://github.com/...` | GitHub URL | `gh issue view <url>` or `gh pr view <url>` |

For Shortcut REST calls, follow `rules/shortcut-api.md` (retry wrapper, JSON parsing, field shapes) and use `skills/shortcut-fetch.md` for implementation.
