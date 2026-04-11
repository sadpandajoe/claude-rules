#!/bin/bash
#
# prevent-project-commit.sh — Claude Code PreToolUse hook
#
# Blocks git commit when PROJECT.md is staged.
# Fail-open: exits 0 on any unexpected state (never blocks on errors).
#
# Exit codes:
#   0 — allow (not a commit, or PROJECT.md not staged)
#   2 — block (PROJECT.md is staged for commit)
#

set -euo pipefail

# Fail open on any error
trap 'exit 0' ERR

# Read JSON from stdin
INPUT=$(cat)

# Extract fields (fail open if jq unavailable or fields missing)
if ! command -v jq &>/dev/null; then
    exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || exit 0

# Only check git commit commands
if [[ ! "$COMMAND" =~ git\ commit ]]; then
    exit 0
fi

# Change to the working directory
if [[ -z "$CWD" ]] || ! cd "$CWD" 2>/dev/null; then
    exit 0
fi

# Verify we're in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
    exit 0
fi

# Check if PROJECT.md is staged
if git diff --cached --name-only 2>/dev/null | grep -q 'PROJECT\.md$'; then
    cat >&2 <<'EOF'
PROJECT.md is staged for commit. This file contains session state and should not be checked in.

Unstage with: git reset HEAD PROJECT.md
EOF
    exit 2
fi

exit 0
