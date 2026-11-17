#!/usr/bin/env bash
# macOS Dropzone Quick-Update
if command -v update-antigravity >/dev/null 2>&1; then
    update-antigravity
elif [ -f "$HOME/.local/bin/update-antigravity" ]; then
    bash "$HOME/.local/bin/update-antigravity"
else
    echo "Updater not found in PATH or ~/.local/bin."
fi
read -n 1 -s -r -p "Press any key to close..."
