#!/bin/bash
#
# extensions/pgm/install.sh - Install PGM extension commands
#
# This script adds PGM reporting commands to the toolkit.
# Run from the repo root: ./extensions/pgm/install.sh
# Or via the main installer: ./install.sh --with-pgm
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Determine paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${1:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
BUILD_DIR="$REPO_DIR/build"

# Verify core toolkit is installed
if [[ ! -d "$BUILD_DIR/commands" ]]; then
    error "Core toolkit not installed. Run ./install.sh first."
    exit 1
fi

info "Installing PGM extension..."
info "Extension location: $SCRIPT_DIR"

# Resolve {{TOOLKIT_DIR}} in extension commands and copy to build
for cmd in "$SCRIPT_DIR/commands"/*.md; do
    if [[ -f "$cmd" ]]; then
        sed "s|{{TOOLKIT_DIR}}|$REPO_DIR|g" "$cmd" > "$BUILD_DIR/commands/$(basename "$cmd")"
        info "Resolved: $(basename "$cmd")"
    fi
done

COMMAND_COUNT=$(ls "$SCRIPT_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
info "PGM extension installed: $COMMAND_COUNT commands added"
info "Commands: /create-status-report, /create-velocity-report"
