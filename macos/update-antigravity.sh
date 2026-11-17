#!/usr/bin/env bash
# ==============================================================================
# Antigravity IDE - macOS Smart Updater (GUI & CLI)
# Part of https://github.com/monujat/antigravity-updater
#
# Supports .dmg, .zip, .tar.gz, and app bundles.
# Handles Gatekeeper quarantine flags, atomic backup, symlinks, and notifications.
# ==============================================================================

set -e
set -o pipefail

TARGET_APP="/Applications/Antigravity.app"
USER_APP="$HOME/Applications/Antigravity.app"
BACKUP_APP="/Applications/Antigravity.app.bak"
DROPZONE_DIR="$HOME/Antigravity-Update-Box"
DOWNLOADS_DIR="$HOME/Downloads"
TEMP_DIR=""

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

cleanup() {
    if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
        hdiutil detach "$MOUNT_POINT" -force >/dev/null 2>&1 || true
    fi
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT INT TERM

# ------------------------------------------------------------------------------
# Locate latest Antigravity update candidate on macOS
# ------------------------------------------------------------------------------
find_candidate() {
    local candidate=""

    # 1. Dropzone search
    if [ -d "$DROPZONE_DIR" ]; then
        candidate=$(find "$DROPZONE_DIR" -maxdepth 2 \( -iname "*antigravity*.dmg" -o -iname "*antigravity*.zip" -o -iname "*antigravity*.tar.gz" -o -iname "*antigravity*.app" \) 2>/dev/null | head -n 1)
        if [ -n "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    fi

    # 2. Downloads search
    if [ -d "$DOWNLOADS_DIR" ]; then
        candidate=$(find "$DOWNLOADS_DIR" -maxdepth 2 \( -iname "*antigravity*.dmg" -o -iname "*antigravity*.zip" -o -iname "*antigravity*.tar.gz" -o -iname "*antigravity*.app" \) 2>/dev/null | head -n 1)
        if [ -n "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    fi

    return 1
}

# ------------------------------------------------------------------------------
# Notify user via macOS notification system
# ------------------------------------------------------------------------------
notify_mac() {
    local title="$1"
    local message="$2"
    osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
}

# ------------------------------------------------------------------------------
# Core macOS installation routine
# ------------------------------------------------------------------------------
perform_update() {
    local source="$1"
    local extracted_app=""

    echo -e "${BLUE}${BOLD}=== Antigravity IDE Updater (macOS) ===${NC}"
    echo -e "Update source: ${YELLOW}$source${NC}"

    TEMP_DIR=$(mktemp -d /tmp/antigravity_mac_XXXXXX)

    # 1. Inspect and extract package
    case "$source" in
        *.dmg)
            echo "Mounting disk image ($source)..."
            MOUNT_POINT=$(mktemp -d /tmp/antigravity_mount_XXXXXX)
            hdiutil attach "$source" -mountpoint "$MOUNT_POINT" -nobrowse -quiet
            extracted_app=$(find "$MOUNT_POINT" -maxdepth 2 -type d -name "*Antigravity*.app" 2>/dev/null | head -n 1)
            if [ -z "$extracted_app" ]; then
                echo -e "${RED}Error: No .app bundle found inside DMG!${NC}" >&2
                exit 1
            fi
            echo "Found application bundle: $extracted_app"
            ;;
        *.zip)
            echo "Unzipping archive ($source)..."
            unzip -q "$source" -d "$TEMP_DIR"
            extracted_app=$(find "$TEMP_DIR" -maxdepth 2 -type d -name "*Antigravity*.app" 2>/dev/null | head -n 1)
            ;;
        *.tar.gz|*.tgz)
            echo "Extracting tarball ($source)..."
            tar -xzf "$source" -C "$TEMP_DIR"
            extracted_app=$(find "$TEMP_DIR" -maxdepth 2 -type d -name "*Antigravity*.app" 2>/dev/null | head -n 1)
            ;;
        *.app)
            extracted_app="$source"
            ;;
        *)
            if [ -d "$source" ]; then
                extracted_app=$(find "$source" -maxdepth 2 -type d -name "*Antigravity*.app" 2>/dev/null | head -n 1)
            fi
            ;;
    esac

    if [ -z "$extracted_app" ] || [ ! -d "$extracted_app" ]; then
        echo -e "${RED}Error: Failed to locate Antigravity.app in the package.${NC}" >&2
        exit 1
    fi

    # 2. Check and gracefully close running Antigravity instance
    echo "Checking for running Antigravity instances..."
    osascript -e 'tell application "Antigravity" to quit' 2>/dev/null || true
    osascript -e 'tell application "Antigravity IDE" to quit' 2>/dev/null || true
    sleep 1

    # 3. Determine installation destination
    local dest="$TARGET_APP"
    if [ ! -w "/Applications" ]; then
        # Needs sudo or fallback to user ~/Applications
        if [ "$EUID" -ne 0 ]; then
            echo "Administrator permission required to install to /Applications."
            if ! sudo -v 2>/dev/null; then
                echo "Administrator elevation not granted; installing to user directory ($USER_APP)..."
                dest="$USER_APP"
                mkdir -p "$HOME/Applications"
            fi
        fi
    fi

    # 4. Safe backup
    if [ -d "$dest" ]; then
        echo "Creating backup of current version at $BACKUP_APP..."
        if [ "$EUID" -eq 0 ] || [ -w "/Applications" ]; then
            rm -rf "$BACKUP_APP" 2>/dev/null || true
            cp -R "$dest" "$BACKUP_APP"
            rm -rf "$dest"
        else
            sudo rm -rf "$BACKUP_APP" 2>/dev/null || true
            sudo cp -R "$dest" "$BACKUP_APP"
            sudo rm -rf "$dest"
        fi
    fi

    # 5. Copy new bundle to /Applications
    echo "Installing updated Antigravity.app to $dest..."
    if [ "$EUID" -eq 0 ] || [ -w "/Applications" ]; then
        cp -R "$extracted_app" "$dest"
    else
        sudo cp -R "$extracted_app" "$dest"
    fi

    # 6. Gatekeeper Quarantine Removal
    echo "Clearing macOS Gatekeeper quarantine attributes..."
    if [ "$EUID" -eq 0 ] || [ -w "$dest" ]; then
        xattr -dr com.apple.quarantine "$dest" 2>/dev/null || true
    else
        sudo xattr -dr com.apple.quarantine "$dest" 2>/dev/null || true
    fi

    # 7. Configure command-line symlink
    echo "Configuring terminal command ('antigravity')..."
    local cli_bin=""
    if [ -f "$dest/Contents/Resources/app/bin/antigravity" ]; then
        cli_bin="$dest/Contents/Resources/app/bin/antigravity"
    elif [ -f "$dest/Contents/MacOS/Electron" ]; then
        cli_bin="$dest/Contents/MacOS/Electron"
    fi

    if [ -n "$cli_bin" ]; then
        for bindir in "/usr/local/bin" "/opt/homebrew/bin" "$HOME/.local/bin"; do
            if [ -d "$bindir" ]; then
                if [ -w "$bindir" ]; then
                    ln -sf "$cli_bin" "$bindir/antigravity"
                    break
                elif sudo -n true 2>/dev/null; then
                    sudo ln -sf "$cli_bin" "$bindir/antigravity"
                    break
                fi
            fi
        done
    fi

    echo -e "${GREEN}${BOLD}✓ Antigravity IDE updated successfully on macOS!${NC}"
    notify_mac "Antigravity IDE Updated" "Successfully updated to the latest version!"

    # Ask user if they wish to open it
    read -r -p "Launch Antigravity now? [Y/n] " run_now
    run_now=${run_now:-Y}
    if [[ "$run_now" =~ ^[Yy]$ ]]; then
        open "$dest"
    fi
}

# ------------------------------------------------------------------------------
# Entry Point
# ------------------------------------------------------------------------------
SOURCE_ARG="$1"
if [ -z "$SOURCE_ARG" ]; then
    SOURCE_ARG=$(find_candidate || true)
fi

if [ -z "$SOURCE_ARG" ]; then
    echo -e "${YELLOW}No update candidate detected in $DROPZONE_DIR or $DOWNLOADS_DIR.${NC}"
    read -r -p "Enter path to Antigravity .dmg, .zip, or folder: " SOURCE_ARG
fi

if [ ! -e "$SOURCE_ARG" ]; then
    echo -e "${RED}Error: File '$SOURCE_ARG' does not exist.${NC}"
    exit 1
fi

perform_update "$SOURCE_ARG"
