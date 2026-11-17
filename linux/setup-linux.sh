#!/usr/bin/env bash
# ==============================================================================
# Antigravity IDE Updater - Linux Setup Installer
# Part of https://github.com/monujat/antigravity-updater
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/Desktop"
APP_DIR="$HOME/.local/share/applications"
DROPZONE_DIR="$HOME/Antigravity-Update-Box"

echo "=== Installing Antigravity IDE Updater for Linux ==="

# 1. Ensure ~/.local/bin exists and is in PATH
mkdir -p "$BIN_DIR"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Notice: $BIN_DIR is not yet in your PATH. Adding to ~/.bashrc and ~/.profile..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    [ -f "$HOME/.profile" ] && echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
fi

# 2. Install binaries
echo "Installing updater scripts to $BIN_DIR..."
install -m 755 "$SCRIPT_DIR/antigravity-updater" "$BIN_DIR/antigravity-updater"
install -m 755 "$SCRIPT_DIR/antigravity-update-engine" "$BIN_DIR/antigravity-update-engine"
ln -sf "$BIN_DIR/antigravity-updater" "$BIN_DIR/update-antigravity"

# 3. Create Dropzone Folder
echo "Setting up Dropzone folder at $DROPZONE_DIR..."
mkdir -p "$DROPZONE_DIR"
if [ -d "$SCRIPT_DIR/../dropzone" ]; then
    cp -f "$SCRIPT_DIR/../dropzone/README.txt" "$DROPZONE_DIR/README.txt" 2>/dev/null || true
fi

# 4. Install Desktop Entries
mkdir -p "$APP_DIR"
cat > "$APP_DIR/antigravity-updater.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Update Antigravity IDE
Comment=Update Antigravity IDE to the latest version
Exec=$BIN_DIR/antigravity-updater
Icon=/usr/share/pixmaps/antigravity.png
Terminal=false
Categories=Development;Utility;
StartupNotify=true
Keywords=antigravity;ide;update;upgrade;
EOF
chmod 644 "$APP_DIR/antigravity-updater.desktop"

# Install Dropzone update shortcut
cat > "$DROPZONE_DIR/Update-Now.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Update Antigravity IDE Now
Comment=Update Antigravity IDE from this folder or Downloads
Exec=$BIN_DIR/antigravity-updater
Icon=/usr/share/pixmaps/antigravity.png
Terminal=false
Categories=Utility;Development;
StartupNotify=true
EOF
chmod 755 "$DROPZONE_DIR/Update-Now.desktop"

# Optional Desktop shortcut
if [ -d "$DESKTOP_DIR" ]; then
    cp -f "$APP_DIR/antigravity-updater.desktop" "$DESKTOP_DIR/Update-Antigravity.desktop"
    chmod 755 "$DESKTOP_DIR/Update-Antigravity.desktop"
fi

echo "=== Linux Installation Complete! ==="
echo "You can now run 'update-antigravity' in your terminal or use the desktop shortcut."
