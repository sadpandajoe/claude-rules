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

    # Prune stale repo-managed symlinks whose source no longer exists
    for link in "$target_root"/*; do
        if [[ -L "$link" ]]; then
            local link_target=$(readlink "$link")
            # Only prune symlinks that point into our repo
            if [[ "$link_target" == "$source_root"/* ]]; then
                if [[ ! -e "$link_target" ]]; then
                    local stale_name=$(basename "$link")
                    warn "Removing stale link: $stale_name -> $link_target"
                    rm "$link"
                fi
            fi
        fi
    done

    info "Synced repo skills into $label"
}

echo ""
echo "========================================"
echo "  Claude Code Configuration Installer"
echo "========================================"
echo ""

# Step 1: Build resolved files from templates
# Source files use {{TOOLKIT_DIR}} as a portable placeholder.
# This step replaces it with the actual repo path for the local install.
step "Building resolved config and commands..."

BUILD_DIR="$REPO_DIR/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/config" "$BUILD_DIR/commands"

# Resolve config/CLAUDE.md
sed "s|{{TOOLKIT_DIR}}|$REPO_DIR|g" "$REPO_DIR/config/CLAUDE.md" > "$BUILD_DIR/config/CLAUDE.md"
info "Resolved config/CLAUDE.md"

# Resolve all command files
for cmd in "$REPO_DIR/commands"/*.md; do
    if [[ -f "$cmd" ]]; then
        sed "s|{{TOOLKIT_DIR}}|$REPO_DIR|g" "$cmd" > "$BUILD_DIR/commands/$(basename "$cmd")"
    fi
done
info "Resolved $(ls "$BUILD_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ') command files"

# Step 2: Symlink universal configuration files
step "Symlinking configuration files..."

# Only symlink universal configs (CLAUDE.md)
# settings.json and mcp-global.json are personal - users manage their own
create_symlink "$BUILD_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Step 3: Symlink commands directory (from build output)
step "Symlinking commands directory..."

create_symlink "$BUILD_DIR/commands" "$CLAUDE_DIR/commands"

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
# Verify a sample of Codex skill links (flat .md files)
CODEX_LINK_COUNT=0
for link in "$CODEX_DIR/skills"/*.md; do
    if [[ -L "$link" ]]; then
        CODEX_LINK_COUNT=$((CODEX_LINK_COUNT + 1))
    fi
done
echo -e "  ${GREEN}✓${NC} Codex skills: $CODEX_LINK_COUNT linked"

echo ""

# Step 5: Install PGM extension (optional)
if [[ -d "$REPO_DIR/extensions/pgm" ]]; then
    if [[ "${1:-}" == "--with-pgm" ]]; then
        step "Installing PGM extension..."
        "$REPO_DIR/extensions/pgm/install.sh" "$REPO_DIR"
    else
        info "PGM extension available. Run with --with-pgm to install."
    fi
fi

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
COMMAND_COUNT=$(ls "$BUILD_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "$REPO_DIR/skills" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
info "Available slash commands ($COMMAND_COUNT):"
ls "$BUILD_DIR/commands"/*.md 2>/dev/null | xargs -I {} basename {} .md | sort | while read cmd; do
    echo "  /$cmd"
done
echo ""
info "Available skills ($SKILL_COUNT):"
find "$REPO_DIR/skills" -maxdepth 1 -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | while read skill; do
    echo "  $skill"
done
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
