#!/bin/bash
#
# install.sh - Install Claude Code configuration files
#
# This script symlinks the config files from this repo to ~/.claude/
# It will backup existing configs before overwriting.
#
# Usage: ./install.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Get the directory where this script is located (the repo root)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

info "Repository location: $REPO_DIR"
info "Claude config dir: $CLAUDE_DIR"

# Create ~/.claude if it doesn't exist
mkdir -p "$CLAUDE_DIR"

# Backup function
backup_if_exists() {
    local target=$1
    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        local basename=$(basename "$target")
        warn "Backing up existing $basename to $BACKUP_DIR/"
        mv "$target" "$BACKUP_DIR/$basename"
    fi
}

# Symlink function
create_symlink() {
    local source=$1
    local target=$2
    local name=$(basename "$target")

    backup_if_exists "$target"

    ln -sf "$source" "$target"
    info "Linked: $name -> $source"
}

echo ""
echo "========================================"
echo "  Claude Code Configuration Installer"
echo "========================================"
echo ""

# Step 1: Generate CLAUDE.md with correct paths
step "Generating CLAUDE.md with correct paths..."

# Dynamically include all rules from rules/ directory
# universal.md first, then alphabetically
{
    # Universal first (core principles)
    if [[ -f "$REPO_DIR/rules/universal.md" ]]; then
        echo "@$REPO_DIR/rules/universal.md"
    fi
    # Then all other rules alphabetically (excluding README.md)
    for rule in "$REPO_DIR/rules/"*.md; do
        if [[ -f "$rule" && "$(basename "$rule")" != "universal.md" && "$(basename "$rule")" != "README.md" ]]; then
            echo "@$rule"
        fi
    done
    # Add PROJECT_TEMPLATE.md reference
    if [[ -f "$REPO_DIR/PROJECT_TEMPLATE.md" ]]; then
        echo "@$REPO_DIR/PROJECT_TEMPLATE.md"
    fi
} > "$REPO_DIR/config/CLAUDE.md"

rule_count=$(ls "$REPO_DIR/rules/"*.md 2>/dev/null | grep -v README.md | wc -l | tr -d ' ')
info "Generated CLAUDE.md with $rule_count rules from: $REPO_DIR/rules/"

# Step 2: Symlink configuration files
step "Symlinking configuration files..."

create_symlink "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
create_symlink "$REPO_DIR/config/settings.json" "$CLAUDE_DIR/settings.json"
create_symlink "$REPO_DIR/config/mcp-global.json" "$CLAUDE_DIR/mcp-global.json"

# Step 3: Symlink commands directory
step "Symlinking commands directory..."

create_symlink "$REPO_DIR/commands" "$CLAUDE_DIR/commands"

# Step 4: Verify installation
step "Verifying installation..."

echo ""
info "Installed configuration:"
echo ""

verify_link() {
    local link=$1
    local name=$(basename "$link")
    if [[ -L "$link" ]]; then
        local target=$(readlink "$link")
        echo -e "  ${GREEN}✓${NC} $name -> $target"
    elif [[ -e "$link" ]]; then
        echo -e "  ${YELLOW}!${NC} $name (exists but not a symlink)"
    else
        echo -e "  ${RED}✗${NC} $name (missing)"
    fi
}

verify_link "$CLAUDE_DIR/CLAUDE.md"
verify_link "$CLAUDE_DIR/settings.json"
verify_link "$CLAUDE_DIR/mcp-global.json"
verify_link "$CLAUDE_DIR/commands"

echo ""

# Show backup info if backups were created
if [[ -d "$BACKUP_DIR" ]]; then
    warn "Previous configs backed up to: $BACKUP_DIR"
    echo "  Contents:"
    ls -la "$BACKUP_DIR" | tail -n +2 | while read line; do
        echo "    $line"
    done
    echo ""
fi

echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
COMMAND_COUNT=$(ls "$REPO_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
info "Available slash commands ($COMMAND_COUNT):"
ls "$REPO_DIR/commands"/*.md 2>/dev/null | xargs -I {} basename {} .md | sort | while read cmd; do
    echo "  /$cmd"
done
echo ""
info "To start using Claude Code with your new config:"
echo "  claude"
echo ""
info "To update your config, just edit files in:"
echo "  $REPO_DIR"
echo ""
