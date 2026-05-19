#!/bin/bash
#
# agent-setup-edit-reminder.sh — Claude Code PostToolUse hook
#
# Injects a system reminder when Claude edits Claude Code agent-setup
# files (skills, commands, rules, CLAUDE.md, hooks). Reminds the model to
# load and apply the agent-setup-maintainer skill's principles before
# continuing.
#
# Fail-open: exits 0 on any unexpected state.
#

set -euo pipefail
trap 'exit 0' ERR

INPUT=$(cat)

if ! command -v jq &>/dev/null; then
    exit 0
fi

# The `set -e` + `trap ... ERR` above is the fail-open safety net; jq
# soft-fails to empty via `// empty`, handled by the matchers below.
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

case "$TOOL_NAME" in
    Edit|Write|MultiEdit|NotebookEdit) ;;
    *) exit 0 ;;
esac

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Path-suffix matchers: no hardcoded toolkit dir name or user home, so
# the hook is portable across clones and also fires on installed
# symlink paths (~/.claude/skills -> repo skills, etc.).
MATCH=0
case "$FILE_PATH" in
    */skills/*/SKILL.md) MATCH=1 ;;
    */skills/*/lessons.md) MATCH=1 ;;
    */skills/*/rules.md) MATCH=1 ;;
    */skills/*/gotchas.md) MATCH=1 ;;
    */skills/*/references/*) MATCH=1 ;;
    */commands/*.md) MATCH=1 ;;
    */rules/*.md) MATCH=1 ;;
    */config/CLAUDE.md) MATCH=1 ;;
    */hooks/*) MATCH=1 ;;
    "$HOME/.claude/CLAUDE.md") MATCH=1 ;;
esac

if [[ $MATCH -eq 0 ]]; then
    exit 0
fi

cat <<'EOF'
{"systemMessage": "You just edited a Claude Code agent-setup file. Load the agent-setup-maintainer skill (skills/agent-setup-maintainer/SKILL.md) and apply its principles — skill descriptions are classifiers, rules stay short, commands expand prompts, prefer surgical edits over rewrites — to this change before continuing."}
EOF

exit 0
