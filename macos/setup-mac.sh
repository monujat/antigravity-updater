#!/usr/bin/env bash
# ==============================================================================
# Antigravity IDE Updater - macOS Setup Installer
# Part of https://github.com/monujat/antigravity-updater
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DROPZONE_DIR="$HOME/Antigravity-Update-Box"
DESKTOP_DIR="$HOME/Desktop"

echo "=== Installing Antigravity IDE Updater for macOS ==="

# 1. Setup local bin directory
mkdir -p "$BIN_DIR"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Adding $BIN_DIR to ~/.zshrc..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bash_profile" 2>/dev/null || true
fi

# 2. Install scripts
echo "Installing updater script..."
install -m 755 "$SCRIPT_DIR/update-antigravity.sh" "$BIN_DIR/update-antigravity"
install -m 755 "$SCRIPT_DIR/update-antigravity.sh" "$BIN_DIR/antigravity-updater"

# 3. Create Dropzone Folder
echo "Setting up Dropzone folder at $DROPZONE_DIR..."
mkdir -p "$DROPZONE_DIR"
if [ -d "$SCRIPT_DIR/../dropzone" ]; then
    cp -f "$SCRIPT_DIR/../dropzone/README.txt" "$DROPZONE_DIR/README.txt" 2>/dev/null || true
fi

# 4. Create Desktop / Dropzone clickable launchers
if [ -f "$SCRIPT_DIR/Antigravity Updater.command" ]; then
    cp -f "$SCRIPT_DIR/Antigravity Updater.command" "$DROPZONE_DIR/Update-Now.command"
    chmod +x "$DROPZONE_DIR/Update-Now.command"

    if [ -d "$DESKTOP_DIR" ]; then
        cp -f "$SCRIPT_DIR/Antigravity Updater.command" "$DESKTOP_DIR/Update Antigravity.command"
        chmod +x "$DESKTOP_DIR/Update Antigravity.command"
    fi
fi

echo "=== macOS Installation Complete! ==="
echo "You can now drop packages in ~/Antigravity-Update-Box or run 'update-antigravity' in Terminal."
