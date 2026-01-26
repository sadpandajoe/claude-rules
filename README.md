# Claude Code Setup & Workflow Rules

One-stop setup repo for AI-assisted coding with Claude Code and Codex CLI.

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/claude-rules.git ~/opt/code/claude-rules
cd ~/opt/code/claude-rules

# 2. Install dependencies (claude, codex, tmux, node)
./setup.sh

# 3. Link configs to ~/.claude/
./install.sh

# 4. Start coding
claude
```

## What Gets Installed

### Tools (via setup.sh)
| Tool | Purpose |
|------|---------|
| Node.js | Runtime for CLI tools |
| Claude Code | Anthropic's AI coding assistant |
| Codex CLI | OpenAI's AI coding tool |
| tmux | Terminal multiplexer |
| git | Version control |

### Configuration (via install.sh)
| File | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global instructions (auto-generated from rules/) |
| `~/.claude/commands/` | Custom slash commands |
| `~/.claude/settings.json` | Claude Code settings |
| `~/.claude/mcp-global.json` | MCP server configuration |

### Claude Code 2.1.x Features Used
| Feature | Purpose |
|---------|---------|
| Task subagents | Explore, Plan, general-purpose for specialized work |
| Task tracking | TaskCreate/Update/List for progress visibility (optional) |
| Plan mode | EnterPlanMode/ExitPlanMode for structured planning |
| Native tools | Read, Grep, Glob instead of bash equivalents |

## Repository Structure

```
claude-rules/
├── setup.sh                # Install tools (run once)
├── install.sh              # Link configs to ~/.claude/
├── PROJECT_TEMPLATE.md     # Template for project documentation
├── config/
│   ├── CLAUDE.md           # Auto-generated (includes all rules)
│   ├── settings.json       # Claude Code settings
│   └── mcp-global.json     # MCP server configs
├── rules/
│   ├── README.md           # Rules index
│   ├── universal.md        # Core principles (loaded first)
│   ├── orchestration.md    # Claude + Codex workflows
│   ├── planning.md         # Project planning
│   ├── investigation.md    # Debugging & root cause
│   ├── implementation.md   # Code development
│   ├── refactor.md         # Refactoring safely
│   ├── testing.md          # Test strategy
│   ├── troubleshooting.md  # Emergency recovery
│   ├── cherry-picking.md   # Cross-branch work
│   └── code-review.md      # Review guidelines
└── commands/
    ├── init.md             # Start session
    ├── plan.md             # Create plan
    ├── investigate.md      # Debug issues
    ├── implement.md        # Write code (TDD)
    ├── test.md             # Write tests
    ├── refactor.md         # Refactor code
    ├── refactor-tests.md   # Move tests to correct layers
    ├── review.md           # Code review (iterate to 8/10)
    ├── review-plan.md      # Plan review (iterate to 8/10)
    ├── review-pr.md        # Review GitHub PRs
    ├── review-feedback.md  # Process PR feedback
    ├── suggest-tests.md    # Generate test cases
    ├── explain.md          # Explain code
    ├── update-project-file.md  # Sync PROJECT.md
    ├── cherry-pick.md      # Cross-branch work
    └── archive.md          # Archive completed work
```

## Slash Commands

### Core Workflow
| Command | Purpose |
|---------|---------|
| `/start` | Start session - load rules, check PROJECT.md |
| `/plan` | Create implementation plan → triggers `/review-plan` |
| `/implement` | Write code with TDD → triggers `/review` |
| `/test` | Write and organize tests |
| `/investigate` | Debug issues, find root causes |
| `/refactor` | Improve code structure safely |

### Reviews (Iterate to 8/10)
| Command | Purpose |
|---------|---------|
| `/review` | Code review - Codex reviews, Claude fixes, iterate until 8/10 |
| `/review-plan` | Plan review - Codex reviews, Claude improves, iterate until 8/10 |
| `/review-pr` | Review third-party GitHub PRs with scoring framework |
| `/review-feedback` | Process PR feedback - Claude+Codex consensus on validity |

### Codex Tools
| Command | Purpose |
|---------|---------|
| `/explain` | Have Codex explain code sections |
| `/suggest-tests` | Have Codex generate test cases |
| `/refactor-tests` | Analyze and move tests to correct layers |

### Documentation
| Command | Purpose |
|---------|---------|
| `/update-project-file` | Sync PROJECT.md with current progress |
| `/archive` | Move completed phases to PROJECT_ARCHIVE.md |

### Specialized
| Command | Purpose |
|---------|---------|
| `/cherry-pick` | Safe cross-branch cherry-picking |

## Multi-AI Review System

Claude Code orchestrates Codex for reviews, iterating until score ≥ 8/10.

### Code Reviews
```bash
/review                     # Review uncommitted changes (default)
/review --branch main       # Review changes against main
/review --commit abc123     # Review specific commit
```

Codex reviews with **full context** but only **comments on changed code**:
- ✅ Reads full files to understand usage, types, integration
- ✅ Checks if functions called correctly, return values handled
- ❌ Does NOT comment on unchanged code or pre-existing issues

### Plan Reviews
```bash
/review-plan                # Review PROJECT.md (default)
/review-plan ./docs/PLAN.md # Review specific file
```

### GitHub PR Reviews
```bash
/review-pr 123              # Review PR by number
/review-pr https://github.com/owner/repo/pull/123  # Review by URL
```

Claude reviews with scoring framework, then Codex provides independent review (required per orchestration rules).

### PR Feedback Analysis
```bash
/review-feedback            # Analyze PR comments
/review-feedback --pr 123   # Specific PR number
```

Claude and Codex independently evaluate each feedback item:
| Claude | Codex | Action |
|--------|-------|--------|
| Fix | Fix | ✅ Add to fix plan |
| Skip | Skip | ✅ Document why skipped |
| Fix | Skip | ⚠️ Resolve disagreement |
| Skip | Fix | ⚠️ Resolve disagreement |

## Workflow Rules

| File | When to Read |
|------|--------------|
| `rules/universal.md` | Always (core principles) |
| `rules/orchestration.md` | When using Claude + Codex together |
| `rules/planning.md` | `/plan`, `/review-plan` |
| `rules/investigation.md` | `/investigate` |
| `rules/implementation.md` | `/implement` |
| `rules/refactor.md` | `/refactor` |
| `rules/testing.md` | `/test`, `/suggest-tests`, `/refactor-tests` |
| `rules/troubleshooting.md` | Emergency recovery |
| `rules/cherry-picking.md` | `/cherry-pick` |
| `rules/code-review.md` | `/review`, `/review-pr`, `/review-feedback` |

## Updating

After pulling updates, re-run install to refresh configs:

```bash
cd ~/opt/code/claude-rules
git pull
./install.sh
```

## Customization

Edit files directly in this repo - changes take effect immediately since configs are symlinked:

- **Add commands**: Create `.md` files in `commands/`
- **Modify rules**: Edit files in `rules/`
- **Add new rules**: Add `.md` files to `rules/`, re-run `./install.sh`
- **Change settings**: Edit `config/settings.json`
- **Add MCP servers**: Edit `config/mcp-global.json`

## Environment Variables

Some MCP servers require tokens. Set these in your shell profile:

```bash
export GITHUB_TOKEN="your-github-token"
export OPENAI_API_KEY="your-openai-key"  # For Codex CLI
```

## Backup

The `install.sh` script automatically backs up existing configs to:
```
~/.claude/backup-YYYYMMDD-HHMMSS/
```

## How It Works

```
User: /plan

Claude Code:
1. Rules auto-loaded via CLAUDE.md @-includes
2. Reads commands/plan.md for workflow steps
3. Executes planning workflow
4. Calls Codex via `codex exec` for review
5. Iterates until plan scores 8/10
```

**Claude Code** = Tech Lead (planning, complex reasoning, fixes)
**Codex CLI** = Reviewer (analysis, scoring, suggestions)