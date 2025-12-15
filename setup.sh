#!/bin/bash
#
# setup.sh - Install AI coding tools and dependencies
#
# Usage: ./setup.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin*) OS_TYPE="macos" ;;
    Linux*)  OS_TYPE="linux" ;;
    *)       error "Unsupported OS: $OS"; exit 1 ;;
esac

info "Detected OS: $OS_TYPE"

# Check for Homebrew (macOS) or apt (Linux)
install_package() {
    local package=$1
    if [[ "$OS_TYPE" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            warn "Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for Apple Silicon
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        brew install "$package"
    elif [[ "$OS_TYPE" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y "$package"
        elif command -v yum &> /dev/null; then
            sudo yum install -y "$package"
        else
            error "No supported package manager found"
            exit 1
        fi
    fi
}

# Check and install Node.js
install_node() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        info "Node.js already installed: $NODE_VERSION"
    else
        warn "Node.js not found. Installing..."
        if [[ "$OS_TYPE" == "macos" ]]; then
            brew install node
        elif command -v apt-get &> /dev/null; then
            # Debian/Ubuntu - use NodeSource
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            # RHEL/CentOS/Fedora - use NodeSource
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo yum install -y nodejs
        else
            error "No supported package manager found for Node.js"
            exit 1
        fi
        info "Node.js installed: $(node --version)"
    fi

    # Verify npm is available
    if ! command -v npm &> /dev/null; then
        error "npm not found after Node.js installation"
        exit 1
    fi
    info "npm available: $(npm --version)"
}

# Check and install tmux
install_tmux() {
    if command -v tmux &> /dev/null; then
        info "tmux already installed: $(tmux -V)"
    else
        warn "tmux not found. Installing..."
        install_package tmux
        info "tmux installed: $(tmux -V)"
    fi
}

# Check and install Claude Code
install_claude_code() {
    if command -v claude &> /dev/null; then
        info "Claude Code already installed"
    else
        warn "Claude Code not found. Installing..."
        npm install -g @anthropic-ai/claude-code
        info "Claude Code installed"
    fi
}

# Check and install Codex CLI
install_codex() {
    if command -v codex &> /dev/null; then
        info "Codex CLI already installed"
    else
        warn "Codex CLI not found. Installing..."
        npm install -g @openai/codex
        info "Codex CLI installed"
    fi
}

# Check and install git (usually pre-installed)
install_git() {
    if command -v git &> /dev/null; then
        info "git already installed: $(git --version)"
    else
        warn "git not found. Installing..."
        install_package git
        info "git installed: $(git --version)"
    fi
}

# Main installation
main() {
    echo ""
    echo "========================================"
    echo "  AI Coding Environment Setup"
    echo "========================================"
    echo ""

    # Core dependencies
    info "Checking core dependencies..."
    install_git
    install_node
    install_tmux

    echo ""

    # AI tools
    info "Installing AI coding tools..."
    install_claude_code
    install_codex

    echo ""
    echo "========================================"
    echo "  Installation Complete!"
    echo "========================================"
    echo ""
    info "Installed tools:"
    echo "  - git:    $(git --version 2>/dev/null || echo 'not found')"
    echo "  - node:   $(node --version 2>/dev/null || echo 'not found')"
    echo "  - npm:    $(npm --version 2>/dev/null || echo 'not found')"
    echo "  - tmux:   $(tmux -V 2>/dev/null || echo 'not found')"
    echo "  - claude: $(command -v claude &>/dev/null && echo 'installed' || echo 'not found')"
    echo "  - codex:  $(command -v codex &>/dev/null && echo 'installed' || echo 'not found')"
    echo ""
    info "API Key Setup:"
    echo "  - Claude: Run 'claude' and follow authentication prompts"
    echo "  - Codex:  export OPENAI_API_KEY=your-key-here"
    echo ""
    info "Next step: Run ./install.sh to set up Claude Code configuration"
    echo ""
}

main "$@"