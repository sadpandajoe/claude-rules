#!/bin/bash
#
# install-hooks.sh - Install Claude Code hooks
#
# Merges hook configurations into ~/.claude/settings.json.
# Separate from install.sh because hooks modify user-managed config.
#
# Usage: ./install-hooks.sh
#        ./install-hooks.sh --remove   # Remove toolkit hooks
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"

# Check prerequisites
if ! command -v jq &>/dev/null; then
    error "jq is required but not installed."
    echo "  Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

if [[ ! -f "$SETTINGS" ]]; then
    error "~/.claude/settings.json not found. Run Claude Code at least once first."
    exit 1
fi

# Validate existing settings.json is valid JSON
if ! jq empty "$SETTINGS" 2>/dev/null; then
    error "~/.claude/settings.json is not valid JSON. Fix it manually first."
    exit 1
fi

echo ""
echo "========================================"
echo "  Claude Code Hooks Installer"
echo "========================================"
echo ""

# Handle --remove
if [[ "${1:-}" == "--remove" ]]; then
    step "Removing toolkit hooks..."

    BACKUP="$SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$SETTINGS" "$BACKUP"
    info "Backed up to: $BACKUP"

    # Remove PreToolUse and Stop entries that reference our hooks directory
    jq --arg repo "$REPO_DIR" '
        (if .hooks.PreToolUse then
            .hooks.PreToolUse |= [.[] | select(
                (.hooks // []) | all(.command | test($repo) | not)
            )] |
            if .hooks.PreToolUse == [] then del(.hooks.PreToolUse) else . end
        else . end) |
        (if .hooks.Stop then
            .hooks.Stop |= [.[] | select(
                (.hooks // []) | all(.command | test($repo) | not)
            )] |
            if .hooks.Stop == [] then del(.hooks.Stop) else . end
        else . end) |
        if .hooks == {} then del(.hooks) else . end
    ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

    info "Toolkit hooks removed."
    exit 0
fi

# Install hooks
step "Installing hooks..."

# Backup
BACKUP="$SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
cp "$SETTINGS" "$BACKUP"
info "Backed up to: $BACKUP"

# Build the new hook entries as JSON
HOOK_ENTRIES=$(cat <<HOOKJSON
[
  {
    "matcher": "Bash",
    "if": "Bash(git commit*)",
    "hooks": [{"type": "command", "command": "bash $REPO_DIR/hooks/prevent-project-commit.sh"}]
  },
  {
    "matcher": "Bash",
    "if": "Bash(jest*|pytest*|npm test*|npx jest*|playwright*)",
    "hooks": [{"type": "command", "command": "bash $REPO_DIR/hooks/check-resources.sh"}]
  }
]
HOOKJSON
)

STOP_HOOK_ENTRIES=$(cat <<HOOKJSON
[
  {
    "hooks": [{"type": "command", "command": "bash $REPO_DIR/hooks/check-plan-drift.sh"}]
  }
]
HOOKJSON
)

# Merge: remove existing toolkit hooks (by repo path), then append new ones
# This makes the operation idempotent
jq --argjson new_hooks "$HOOK_ENTRIES" --argjson new_stop_hooks "$STOP_HOOK_ENTRIES" --arg repo "$REPO_DIR" '
    # Initialize hooks.PreToolUse if it does not exist
    .hooks //= {} |
    .hooks.PreToolUse //= [] |
    .hooks.Stop //= [] |
    # Remove any existing entries that reference our repo (idempotent re-run)
    .hooks.PreToolUse |= [.[] | select(
        (.hooks // []) | all(.command | test($repo) | not)
    )] |
    .hooks.Stop |= [.[] | select(
        (.hooks // []) | all(.command | test($repo) | not)
    )] |
    # Append new entries
    .hooks.PreToolUse += $new_hooks |
    .hooks.Stop += $new_stop_hooks |
    # Drop empty arrays for cleanliness
    if .hooks.Stop == [] then del(.hooks.Stop) else . end
' "$SETTINGS" > "$SETTINGS.tmp"

# Validate the output is valid JSON before replacing
if ! jq empty "$SETTINGS.tmp" 2>/dev/null; then
    error "Generated invalid JSON. Restoring from backup."
    cp "$BACKUP" "$SETTINGS"
    rm -f "$SETTINGS.tmp"
    exit 1
fi

mv "$SETTINGS.tmp" "$SETTINGS"

# Verify
step "Verifying..."

HOOK_COUNT=$(jq '.hooks.PreToolUse | length' "$SETTINGS" 2>/dev/null)
STOP_COUNT=$(jq '(.hooks.Stop // []) | length' "$SETTINGS" 2>/dev/null)
TOTAL_KEYS=$(jq 'keys | length' "$SETTINGS" 2>/dev/null)
BACKUP_KEYS=$(jq 'keys | length' "$BACKUP" 2>/dev/null)

info "Hooks installed: $HOOK_COUNT PreToolUse + $STOP_COUNT Stop entries"
info "Settings keys preserved: $TOTAL_KEYS (was $BACKUP_KEYS)"

if [[ "$TOTAL_KEYS" -lt "$BACKUP_KEYS" ]]; then
    warn "Settings keys decreased — check $BACKUP for the original."
fi

echo ""
echo "========================================"
echo "  Hooks Installed!"
echo "========================================"
echo ""
info "Hooks:"
echo "  prevent-project-commit — Blocks commit if PROJECT.md is staged"
echo "  check-resources        — Warns when tests run with constrained resources"
echo "  check-plan-drift       — Warns at turn end when PLAN.md outpaces PROJECT.md"
echo ""
info "To remove: ./install-hooks.sh --remove"
echo ""
