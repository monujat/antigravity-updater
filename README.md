# 🚀 Antigravity IDE Updater

<p align="center">
  <img src="dropzone/icon.png" alt="Antigravity IDE Updater Logo" width="110"/>
</p>

<p align="center">
  <b>Universal, atomic, cross-platform updater for Antigravity IDE.</b><br>
  Seamlessly upgrade Antigravity IDE on <b>Linux</b>, <b>macOS</b>, and <b>Windows</b> with a single click or command.
</p>

<p align="center">
  <a href="#-quick-start"><img src="https://img.shields.io/badge/install-one--liner-brightgreen" alt="Install" /></a>
  <a href="#-supported-platforms"><img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue" alt="Platforms" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License" /></a>
  <a href="https://github.com/monujat/antigravity-updater/actions"><img src="https://img.shields.io/badge/build-passing-brightgreen" alt="Build Status" /></a>
</p>

---

## ✨ Features

- **⚡ Zero Manual Extraction**: Automatically detects `.tar.gz`, `.tar.xz`, `.zip`, or `.dmg` archives.
- **📥 Smart Dropzone (`~/Antigravity-Update-Box`)**: Just drop downloaded release files into the box and double-click to update!
- **🛡️ Atomic Upgrades & Safe Rollback**: Backs up your current version before updating. If any error occurs, your previous install is instantly restored.
- **🖥️ Dual Interface**: 
  - **Visual GUI mode**: Zenity dialogs with progress bars (Linux), native AppleScript notifications (macOS), Windows dialogs.
  - **CLI mode**: Headless terminal support with colorized output.
- **🔧 System & Permission Repair**: Handles `chrome-sandbox` setuid flags on Linux, clears macOS Gatekeeper quarantine restrictions (`com.apple.quarantine`), and configures global PATH executables.

---

## ⚡ Quick Start

### 🐧 Linux (Ubuntu, Debian, Fedora, Arch, Pop!_OS)

#### One-Line Installation:
```bash
curl -fsSL https://raw.githubusercontent.com/monujat/antigravity-updater/main/install.sh | bash
```

#### How to Update:
1. **Dropzone Method (Easiest)**:
   - When you download a new version, drop the file into your `~/Antigravity-Update-Box` folder.
   - Double-click **Update-Now.desktop** in that folder (or click "Update Antigravity" on your Desktop).
2. **Terminal Command**:
   ```bash
   update-antigravity
   # Or specify an archive explicitly:
   update-antigravity ~/Downloads/antigravity-linux-x64.tar.gz
   ```

---

### 🍎 macOS (Apple Silicon M1/M2/M3/M4 & Intel)

#### One-Line Installation:
```bash
curl -fsSL https://raw.githubusercontent.com/monujat/antigravity-updater/main/install.sh | bash
```

#### How to Update:
1. **Dropzone Method (Easiest)**:
   - Download the latest `Antigravity.dmg` or `Antigravity.zip`.
   - Drop it into `~/Antigravity-Update-Box`.
   - Double-click **Update-Now.command**.
2. **Terminal Command**:
   ```bash
   update-antigravity
   # Or point directly to a DMG/ZIP:
   update-antigravity ~/Downloads/Antigravity-darwin-arm64.dmg
   ```
> **Note for macOS**: The updater automatically removes the Gatekeeper quarantine attribute (`xattr -dr com.apple.quarantine`) so you will never see the "App is damaged and cannot be opened" warning!

---

### 🪟 Windows (Windows 10 / 11)

#### One-Line Installation:
Open **PowerShell** and run:
```powershell
irm https://raw.githubusercontent.com/monujat/antigravity-updater/main/install.ps1 | iex
```

#### How to Update:
1. **Dropzone Method (Easiest)**:
   - Drop the downloaded `antigravity-win32-x64.zip` into `Antigravity-Update-Box` (located on your Desktop or User profile).
   - Double-click **Update-Now.cmd** or the **Update Antigravity** desktop shortcut.
2. **PowerShell Command**:
   ```powershell
   update-antigravity
   # Or specify the zip:
   update-antigravity "$HOME\Downloads\antigravity-win32-x64.zip"
   ```
> **Note for Windows**: The default installation is placed in `%LOCALAPPDATA%\Programs\Antigravity` (per-user install, identical to VS Code User setup), which requires **no Administrator privileges**! If you prefer a system-wide install in `C:\Program Files`, pass the `-SystemWide` switch.

---

## 📖 Step-by-Step Usage Guide

### Method 1: The Drag-and-Drop Workflow (Beginner Friendly)

1. Download the newest release archive of Antigravity IDE for your operating system.
2. Move or copy the downloaded file into your **`Antigravity-Update-Box`** folder (created during setup in your home folder or desktop).
3. Run the updater shortcut located inside the folder:
   - **Linux**: Double-click `Update-Now.desktop`
   - **macOS**: Double-click `Update-Now.command`
   - **Windows**: Double-click `Update-Now.cmd`
4. Confirm the update prompt. The updater will extract files, back up the previous version, configure the binary launcher, and launch the new version!

```
[ Download Archive ] ───► [ Drop into Antigravity-Update-Box ] ───► [ Double-Click Update-Now ] ───► [ Ready! ]
```

---

### Method 2: Command Line (Developers & Power Users)

You can run `update-antigravity` from anywhere in your terminal or command prompt:

```bash
# Auto-detects the newest archive in ~/Antigravity-Update-Box or ~/Downloads
update-antigravity

# Force CLI interactive prompt (no graphical popup)
update-antigravity --cli

# Specify the path to an archive or unzipped folder directly
update-antigravity /path/to/archive.tar.gz
```

---

## 🛠️ Architecture & Under the Hood

| Operating System | Default Install Directory | Backup Location | Elevation Method |
| :--- | :--- | :--- | :--- |
| **Linux** | `/usr/share/antigravity` | `/usr/share/antigravity.bak` | `pkexec` / `sudo` |
| **macOS** | `/Applications/Antigravity.app` | `/Applications/Antigravity.app.bak` | User / `sudo` |
| **Windows** | `%LOCALAPPDATA%\Programs\Antigravity` | `...\Antigravity.bak` | User (No elevation required) |

### Automatic Rollback
If extraction fails, an archive is corrupted, or permissions cannot be set, the update engine halts immediately and executes an atomic rollback restoring the `.bak` copy to ensure your IDE is never left broken.

---

## 🗂️ Repository Structure

```
antigravity-updater/
├── README.md                          # Documentation and guides
├── LICENSE                            # MIT License
├── CONTRIBUTING.md                    # Guidelines for contributing
├── install.sh                         # Universal curl installer for Linux & macOS
├── install.ps1                        # Universal PowerShell installer for Windows
├── linux/
│   ├── antigravity-updater            # Frontend GUI & CLI scanner
│   ├── antigravity-update-engine      # Core atomic installation engine
│   ├── antigravity-updater.desktop    # Application menu entry
│   └── setup-linux.sh                 # Linux installer
├── macos/
│   ├── update-antigravity.sh          # macOS update script (.dmg / .zip / .app)
│   ├── Antigravity Updater.command    # Double-clickable macOS launcher
│   └── setup-mac.sh                   # macOS installer
├── windows/
│   ├── update-antigravity.ps1         # PowerShell updater engine & UI
│   ├── Update-Antigravity.cmd         # Double-clickable batch launcher
│   └── setup-windows.ps1              # Windows installer
└── dropzone/
    ├── README.txt                     # Dropzone instructions
    ├── Update-Now.desktop             # Linux dropzone shortcut
    ├── Update-Now.command             # macOS dropzone shortcut
    └── Update-Now.cmd                 # Windows dropzone shortcut
```

---

## ❓ Frequently Asked Questions (FAQ)

<details>
<summary><b>Does updating erase my settings, extensions, or open tabs?</b></summary>
<b>No.</b> User settings, extensions, keybindings, and workspaces are stored separately in your user profile directories (e.g. <code>~/.config/Antigravity</code> or <code>%APPDATA%\Antigravity</code>), not in the application binary folder. All your data remains completely intact.
</details>

<details>
<summary><b>Can I update while Antigravity IDE is currently running?</b></summary>
<b>Yes.</b> The updater detects any active Antigravity instances, asks to close them safely, applies the update, and offers to relaunch the IDE immediately.
</details>

<details>
<summary><b>What if my update gets interrupted?</b></summary>
The update engine features an automatic rollback trap. If an error is detected midway through an update, it restores the backup from the <code>.bak</code> directory.
</details>

---

## 🤝 Contributing

Contributions, bug reports, and suggestions are welcome!
Feel free to open an issue or submit a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) © 2026 Monu Choudhary.
