<#
.SYNOPSIS
    Universal Windows Installer for Antigravity IDE Updater
    https://github.com/monujat/antigravity-updater

.DESCRIPTION
    Can be run locally or streamed via:
    irm https://raw.githubusercontent.com/monujat/antigravity-updater/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

$RepoRawUrl = "https://raw.githubusercontent.com/monujat/antigravity-updater/main"
$InstallDir = "$env:LOCALAPPDATA\AntigravityUpdater"
$DropzoneDir = "$env:USERPROFILE\Antigravity-Update-Box"
$DesktopDir = [Environment]::GetFolderPath("Desktop")

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       Installing Antigravity IDE Updater (Windows)         " -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# Check if running locally inside repo or via web stream
$ScriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $null }

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
New-Item -ItemType Directory -Path $DropzoneDir -Force | Out-Null

if ($ScriptDir -and (Test-Path "$ScriptDir\windows\update-antigravity.ps1")) {
    Write-Host "Installing from local repository files..." -ForegroundColor Cyan
    Copy-Item -Path "$ScriptDir\windows\update-antigravity.ps1" -Destination $InstallDir -Force
    Copy-Item -Path "$ScriptDir\windows\Update-Antigravity.cmd" -Destination $InstallDir -Force
    if (Test-Path "$ScriptDir\dropzone\README.txt") {
        Copy-Item -Path "$ScriptDir\dropzone\README.txt" -Destination $DropzoneDir -Force
    }
} else {
    Write-Host "Downloading updater components from GitHub..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "$RepoRawUrl/windows/update-antigravity.ps1" -OutFile "$InstallDir\update-antigravity.ps1" -UseBasicParsing
    Invoke-WebRequest -Uri "$RepoRawUrl/windows/Update-Antigravity.cmd" -OutFile "$InstallDir\Update-Antigravity.cmd" -UseBasicParsing
    try {
        Invoke-WebRequest -Uri "$RepoRawUrl/dropzone/README.txt" -OutFile "$DropzoneDir\README.txt" -UseBasicParsing
    } catch {}
}

# Copy quick update launcher to Dropzone
Copy-Item -Path "$InstallDir\Update-Antigravity.cmd" -Destination (Join-Path $DropzoneDir "Update-Now.cmd") -Force

# Add to PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "Configuring User PATH..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
}

# Create Desktop Shortcut
$WshShell = New-Object -ComObject WScript.Shell
$DesktopShortcut = Join-Path $DesktopDir "Update Antigravity.lnk"
$Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
$Shortcut.TargetPath = (Join-Path $InstallDir "Update-Antigravity.cmd")
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Description = "Update Antigravity IDE to the latest version"
$Shortcut.Save()

Write-Host "`n✓ Installation complete!" -ForegroundColor Green
Write-Host "Dropzone folder: $DropzoneDir" -ForegroundColor Gray
Write-Host "Desktop shortcut created: $DesktopShortcut" -ForegroundColor Gray
