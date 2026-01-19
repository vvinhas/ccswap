#!/usr/bin/env bash
set -euo pipefail

# ccswap installer
# Usage: curl -fsSL https://raw.githubusercontent.com/vvinhas/ccswap/main/scripts/install.sh | bash

REPO_URL="https://raw.githubusercontent.com/vvinhas/ccswap/main"
INSTALL_DIR="$HOME/.ccswap"

echo "Installing ccswap..."
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo ""
    echo "Install jq first:"
    echo "  macOS:         brew install jq"
    echo "  Ubuntu/Debian: sudo apt install jq"
    echo "  Fedora:        sudo dnf install jq"
    echo ""
    exit 1
fi

# Check for claude
if ! command -v claude &> /dev/null; then
    echo "Warning: Claude Code CLI not found in PATH."
    echo "Make sure it's installed and run at least once before using ccswap."
    echo ""
fi

# Create directories
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/accounts"

# Download scripts
echo "Downloading ccswap..."
curl -fsSL "$REPO_URL/bin/ccswap" -o "$INSTALL_DIR/bin/ccswap"
chmod +x "$INSTALL_DIR/bin/ccswap"

echo "Downloading ccs..."
curl -fsSL "$REPO_URL/bin/ccs" -o "$INSTALL_DIR/bin/ccs"
chmod +x "$INSTALL_DIR/bin/ccs"

echo ""
echo "ccswap installed successfully!"
echo ""

# Check if already in PATH
if echo "$PATH" | grep -q "$INSTALL_DIR/bin"; then
    echo "PATH is already configured."
else
    echo "Add to your shell profile (~/.zshrc or ~/.bashrc):"
    echo ""
    echo "    export PATH=\"\$HOME/.ccswap/bin:\$PATH\""
    echo ""
    echo "Then reload your shell:"
    echo ""
    echo "    source ~/.zshrc  # or source ~/.bashrc"
    echo ""
fi

echo "Next steps:"
echo ""
echo "    ccswap init           # Link ~/.claude as 'main' account"
echo "    ccswap add work       # Create additional accounts"
echo "    ccswap use work       # Switch accounts"
echo "    ccs                   # Launch Claude"
echo ""
