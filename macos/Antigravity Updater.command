#!/usr/bin/env bash
# Double-clickable macOS launcher for Antigravity Updater
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$DIR/update-antigravity.sh" ]; then
    bash "$DIR/update-antigravity.sh"
elif [ -f "$HOME/.local/bin/update-antigravity" ]; then
    bash "$HOME/.local/bin/update-antigravity"
else
    echo "Could not find update-antigravity.sh"
fi
read -n 1 -s -r -p "Press any key to close this window..."
