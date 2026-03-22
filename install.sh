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
CODEX_DIR="$HOME/.codex"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

info "Repository location: $REPO_DIR"
info "Claude config dir: $CLAUDE_DIR"
info "Codex config dir: $CODEX_DIR"

# Create config directories if they don't exist
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CODEX_DIR"

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

# Symlink repo-managed skills into an existing skills directory without
# replacing the entire directory. This preserves Codex system and third-party
# skills that are not managed by this repo.
sync_skill_links() {
    local source_root=$1
    local target_root=$2
    local label=$3

    mkdir -p "$target_root"

    for source in "$source_root"/*; do
        if [[ -e "$source" ]]; then
            local name=$(basename "$source")
            create_symlink "$source" "$target_root/$name"
        fi
    done

    info "Synced repo skills into $label"
}

echo ""
echo "========================================"
echo "  Claude Code Configuration Installer"
echo "========================================"
echo ""

# Step 1: Generate CLAUDE.md with correct paths
step "Generating CLAUDE.md with correct paths..."

# Keep CLAUDE.md intentionally thin. Workflow-specific rules load on demand
# from commands and skills.
{
    if [[ -f "$REPO_DIR/rules/universal.md" ]]; then
        echo "@$REPO_DIR/rules/universal.md"
    fi
    if [[ -f "$REPO_DIR/rules/resource-management.md" ]]; then
        echo "@$REPO_DIR/rules/resource-management.md"
    fi
} > "$REPO_DIR/config/CLAUDE.md"

info "Generated lightweight CLAUDE.md from:"
for rule in "$REPO_DIR/rules/universal.md" "$REPO_DIR/rules/resource-management.md"; do
    if [[ -f "$rule" ]]; then
        echo "  $rule"
    fi
done

# Step 2: Symlink universal configuration files
step "Symlinking configuration files..."

# Only symlink universal configs (CLAUDE.md)
# settings.json and mcp-global.json are personal - users manage their own
create_symlink "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Step 3: Symlink commands directory
step "Symlinking commands directory..."

create_symlink "$REPO_DIR/commands" "$CLAUDE_DIR/commands"

# Step 3b: Symlink skills directory
step "Symlinking skills directory..."

create_symlink "$REPO_DIR/skills" "$CLAUDE_DIR/skills"

# Step 3c: Symlink repo skills into Codex skills directory
step "Symlinking Codex skills..."

sync_skill_links "$REPO_DIR/skills" "$CODEX_DIR/skills" "Codex skills"

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
verify_link "$CLAUDE_DIR/commands"
verify_link "$CLAUDE_DIR/skills"
verify_link "$CODEX_DIR/skills/build-engineer"
verify_link "$CODEX_DIR/skills/core"
verify_link "$CODEX_DIR/skills/finalize-plan"
verify_link "$CODEX_DIR/skills/pgm"
verify_link "$CODEX_DIR/skills/review-architecture"
verify_link "$CODEX_DIR/skills/review-backend"
verify_link "$CODEX_DIR/skills/review-frontend"
verify_link "$CODEX_DIR/skills/review-implementation"
verify_link "$CODEX_DIR/skills/review-testplan"
verify_link "$CODEX_DIR/skills/review-tests"

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
SKILL_COUNT=$(find "$REPO_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
info "Available slash commands ($COMMAND_COUNT):"
ls "$REPO_DIR/commands"/*.md 2>/dev/null | xargs -I {} basename {} .md | sort | while read cmd; do
    echo "  /$cmd"
done
echo ""
info "Available skills ($SKILL_COUNT):"
find "$REPO_DIR/skills" -name "SKILL.md" -exec dirname {} \; 2>/dev/null | while read dir; do
    echo "  ${dir#$REPO_DIR/skills/}"
done | sort
echo ""
info "Codex skill links:"
find "$CODEX_DIR/skills" -maxdepth 1 -mindepth 1 -type l 2>/dev/null | xargs -I {} basename {} | sort | while read skill; do
    echo "  $skill"
done
echo ""
info "To start using Claude Code with your new config:"
echo "  claude"
echo ""
info "To update your config, just edit files in:"
echo "  $REPO_DIR"
echo ""
