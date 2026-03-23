# Claude Code Setup & Workflow Rules

One-stop setup repo for AI-assisted coding with Claude Code and Codex CLI.

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/ai-toolkit.git ~/opt/code/ai-toolkit
cd ~/opt/code/ai-toolkit

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
ai-toolkit/
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
│   ├── orchestration.md    # Multi-agent workflow rules
│   ├── planning.md         # Project planning
│   ├── investigation.md    # Debugging & root cause
│   ├── implementation.md   # Code development
│   ├── testing.md          # Test strategy
│   ├── troubleshooting.md  # Emergency recovery
│   ├── resource-management.md  # Worktrees, Docker, heavy tasks
│   ├── cherry-picking.md   # Cross-branch work
│   ├── code-review.md      # Review guidelines
│   ├── api.md              # GitHub / Shortcut / external API reference
│   └── pgm.md              # Program reporting rules
├── skills/
│   ├── build-engineer/     # CI diagnosis and remediation persona
│   ├── core/               # Shared reviewers and helpers like review-rca and existing-fix checks
│   ├── developer/          # Investigation, implementation, review, and adaptation persona
│   ├── pm/                 # Feature scoping, acceptance criteria, and milestone persona
│   ├── qa/                 # Bug triage, scenario expansion, and validation persona
│   ├── release-engineer/   # Cherry-pick and branch-movement persona
│   └── shared/             # Reusable execution gates and shared workflow helpers
└── commands/
    ├── start.md            # Start or resume session
    ├── fix-bug.md          # End-to-end bug workflow
    ├── create-feature.md   # End-to-end feature workflow
    ├── investigate.md      # Standalone RCA
    ├── implement.md        # Manual implementation workflow
    ├── create-tests.md     # Create automated tests
    ├── fix-ci.md           # Diagnose and safely fix CI failures
    ├── review-code.md      # Local review + autofix loop
    ├── review-pr.md        # Review GitHub PRs
    ├── address-feedback.md # Address PR feedback
    ├── cherry-pick.md      # Cross-branch work
    ├── create-status-report.md   # Live program health report
    ├── create-velocity-report.md # Historical velocity report
    ├── update-project-file.md    # Sync or checkpoint PROJECT.md
    └── archive-project-file.md  # Archive completed work
```

## Slash Commands

### Core Workflow
| Command | Purpose |
|---------|---------|
| `/start` | Start session - load rules, check PROJECT.md |
| `/fix-bug` | End-to-end bug workflow with QA triage, RCA, implementation, and validation |
| `/create-feature` | End-to-end feature and planned refactor workflow with PM and developer planning |
| `/investigate` | Standalone RCA and evidence gathering |
| `/implement` | Manual implementation entrypoint → uses `/review-code` for local review/fix loops |

### Quality & Testing
| Command | Purpose |
|---------|---------|
| `/create-tests` | Manual/transitional command for creating or improving automated tests |
| `/fix-ci` | Diagnose CI failures, apply safe fixes, and stop before commit |
| `/review-code` | Public wrapper over the developer review/fix loop |

### Review & Branch Workflows
| Command | Purpose |
|---------|---------|
| `/review-pr` | Review third-party GitHub PRs with scoring framework |
| `/address-feedback` | Triage PR review comments, fix valid items, draft replies |
| `/cherry-pick` | Plan, order, and safely apply one or more cross-branch cherry-picks |

### Project State
| Command | Purpose |
|---------|---------|
| `/update-project-file` | Manually sync PROJECT.md or write a continuation checkpoint |
| `/archive-project-file` | Move completed phases to PROJECT_ARCHIVE.md |

### Reporting
| Command | Purpose |
|---------|---------|
| `/create-status-report` | Create a live program health report, optionally formatted for a target audience |
| `/create-velocity-report` | Create a historical velocity report, optionally formatted for a target audience |

Claude's built-in `/review` is still available for review-only output; `/review-code` is the repo-standard wrapper when you want fix + verify loops.

## Review Workflows

### Code Reviews
```bash
/review                     # Claude built-in review for uncommitted changes
/review --branch main       # Review changes against main
/review --commit abc123     # Review specific commit
/review-code                # Wrap built-in /review with local fix + verify loop
```

Use `/review` when you want review output only.
Use `/review-code` when you want the repo-standard wrapper: review, fix, validate, and re-review until clean.

### Feature Planning
```bash
/create-feature "bulk edit dashboards"
/create-feature sc-12345
/create-feature https://github.com/owner/repo/issues/123
```

`/create-feature` owns the full planning loop:
- PM planning is conditional and iterates to 8/10 when scope or milestones need it
- Developer planning iterates to 8/10 with shared reviewers from `skills/core`
- The internal finalize-plan skill is the last cold-read before implementation continues automatically

### PR Feedback Analysis
```bash
/address-feedback 123       # Address review comments for PR 123
/address-feedback <pr-url>  # Address review comments by URL
```

`/address-feedback` is action-first: investigate comments, fix valid issues, draft replies, then wait for user approval before push/post.

### GitHub PR Reviews
```bash
/review-pr 123              # Review PR by number
/review-pr https://github.com/owner/repo/pull/123  # Review by URL
```

## Workflow Rules

| File | When to Read |
|------|--------------|
| `rules/universal.md` | Always (core principles) |
| `rules/orchestration.md` | When coordinating helpers, reviewers, or parallel agents |
| `rules/planning.md` | `/create-feature`, `/update-project-file` |
| `rules/investigation.md` | `/fix-bug`, `/investigate` |
| `rules/implementation.md` | `/fix-bug`, `/create-feature`, `/implement`, `/fix-ci` |
| `rules/testing.md` | `/create-tests` |
| `rules/troubleshooting.md` | Emergency recovery |
| `rules/cherry-picking.md` | `/cherry-pick`, `/fix-bug` when it routes into cherry-pick |
| `rules/code-review.md` | `/review-code`, `/review-pr`, `/address-feedback` |
| `rules/api.md` | Commands that query GitHub, Shortcut, or other external systems |
| `rules/pgm.md` | `/create-status-report`, `/create-velocity-report` |

## Updating

After pulling updates, re-run install to refresh configs:

```bash
cd ~/opt/code/ai-toolkit
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
User: /create-feature

Claude Code:
1. Rules auto-loaded via CLAUDE.md @-includes
2. Reads commands/create-feature.md for workflow steps
3. Builds PM and developer plans in PROJECT.md
4. Uses shared reviewers in skills/core to iterate planning to 8/10
5. Runs the internal finalize-plan skill, then continues into implementation unless a decision matters
```

**Claude Code** = workflow orchestrator, planner, and implementer
**Persona skills** = focused helper roles for QA, development, branch work, and reporting
