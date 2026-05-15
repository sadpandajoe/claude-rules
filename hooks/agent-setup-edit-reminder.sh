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

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0

case "$TOOL_NAME" in
    Edit|Write|MultiEdit|NotebookEdit) ;;
    *) exit 0 ;;
esac

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

MATCH=0
case "$FILE_PATH" in
    */ai-toolkit/skills/*/SKILL.md) MATCH=1 ;;
    */ai-toolkit/skills/*/lessons.md) MATCH=1 ;;
    */ai-toolkit/skills/*/rules.md) MATCH=1 ;;
    */ai-toolkit/skills/*/gotchas.md) MATCH=1 ;;
    */ai-toolkit/skills/*/references/*) MATCH=1 ;;
    */ai-toolkit/commands/*.md) MATCH=1 ;;
    */ai-toolkit/rules/*.md) MATCH=1 ;;
    */ai-toolkit/config/CLAUDE.md) MATCH=1 ;;
    */ai-toolkit/hooks/*) MATCH=1 ;;
    /Users/joeli/.claude/CLAUDE.md) MATCH=1 ;;
esac

if [[ $MATCH -eq 0 ]]; then
    exit 0
fi

cat <<'EOF'
{"systemMessage": "You just edited a Claude Code agent-setup file. Load the agent-setup-maintainer skill (skills/agent-setup-maintainer/SKILL.md) and apply its principles — skill descriptions are classifiers, rules stay short, commands expand prompts, prefer surgical edits over rewrites — to this change before continuing."}
EOF

exit 0
