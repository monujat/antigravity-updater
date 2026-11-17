#!/usr/bin/env bash
# ==============================================================================
# Universal Installer for Antigravity IDE Updater (Linux & macOS)
# https://github.com/monujat/antigravity-updater
#
# Usage (Online):
#   curl -fsSL https://raw.githubusercontent.com/monujat/antigravity-updater/main/install.sh | bash
#
# Usage (Local):
#   ./install.sh
# ==============================================================================

set -e

REPO_RAW_URL="https://raw.githubusercontent.com/monujat/antigravity-updater/main"
OS="$(uname -s)"

echo "=== Antigravity IDE Updater - Universal Installer ==="
echo "Detected Operating System: $OS"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

# Check if running from cloned repository
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/linux" ] && [ -d "$SCRIPT_DIR/macos" ]; then
    echo "Running from local repository: $SCRIPT_DIR"
    case "$OS" in
        Linux*)
            bash "$SCRIPT_DIR/linux/setup-linux.sh"
            ;;
        Darwin*)
            bash "$SCRIPT_DIR/macos/setup-mac.sh"
            ;;
        *)
            echo "Unsupported Unix platform: $OS" >&2
            exit 1
            ;;
    esac
else
    # Running via curl / piped bash
    echo "Downloading and installing latest updater files from GitHub..."
    TMP_DIR=$(mktemp -d /tmp/antigravity_installer_XXXXXX)
    cleanup() { rm -rf "$TMP_DIR"; }
    trap cleanup EXIT

    mkdir -p "$TMP_DIR/linux" "$TMP_DIR/macos" "$TMP_DIR/dropzone"

    case "$OS" in
        Linux*)
            curl -fsSL "$REPO_RAW_URL/linux/antigravity-updater" -o "$TMP_DIR/linux/antigravity-updater"
            curl -fsSL "$REPO_RAW_URL/linux/antigravity-update-engine" -o "$TMP_DIR/linux/antigravity-update-engine"
            curl -fsSL "$REPO_RAW_URL/linux/setup-linux.sh" -o "$TMP_DIR/linux/setup-linux.sh"
            curl -fsSL "$REPO_RAW_URL/dropzone/README.txt" -o "$TMP_DIR/dropzone/README.txt" 2>/dev/null || true
            chmod +x "$TMP_DIR/linux/"*
            bash "$TMP_DIR/linux/setup-linux.sh"
            ;;
        Darwin*)
            curl -fsSL "$REPO_RAW_URL/macos/update-antigravity.sh" -o "$TMP_DIR/macos/update-antigravity.sh"
            curl -fsSL "$REPO_RAW_URL/macos/Antigravity%20Updater.command" -o "$TMP_DIR/macos/Antigravity Updater.command"
            curl -fsSL "$REPO_RAW_URL/macos/setup-mac.sh" -o "$TMP_DIR/macos/setup-mac.sh"
            curl -fsSL "$REPO_RAW_URL/dropzone/README.txt" -o "$TMP_DIR/dropzone/README.txt" 2>/dev/null || true
            chmod +x "$TMP_DIR/macos/"*
            bash "$TMP_DIR/macos/setup-mac.sh"
            ;;
        *)
            echo "Unsupported Unix platform: $OS" >&2
            exit 1
            ;;
    esac
fi

echo "======================================================"
echo "Installation completed! Enjoy updating Antigravity IDE."
echo "======================================================"
