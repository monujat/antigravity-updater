<#
.SYNOPSIS
    Antigravity IDE Updater - Windows Environment Installer
    Part of https://github.com/monujat/antigravity-updater
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallDir = "$env:LOCALAPPDATA\AntigravityUpdater"
$DropzoneDir = "$env:USERPROFILE\Antigravity-Update-Box"
$DesktopDir = [Environment]::GetFolderPath("Desktop")

Write-Host "=== Setting up Antigravity IDE Updater on Windows ===" -ForegroundColor Cyan

# 1. Create install directory and copy updater files
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Copy-Item -Path "$ScriptDir\update-antigravity.ps1" -Destination $InstallDir -Force
Copy-Item -Path "$ScriptDir\Update-Antigravity.cmd" -Destination $InstallDir -Force

# 2. Add install dir to User PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "Adding $InstallDir to User PATH..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
}

# 3. Create Dropzone folder
New-Item -ItemType Directory -Path $DropzoneDir -Force | Out-Null
$dropReadme = Join-Path $ScriptDir "..\dropzone\README.txt"
if (Test-Path $dropReadme) {
    Copy-Item -Path $dropReadme -Destination $DropzoneDir -Force
}
Copy-Item -Path "$ScriptDir\Update-Antigravity.cmd" -Destination (Join-Path $DropzoneDir "Update-Now.cmd") -Force

# 4. Create Desktop shortcut
$WshShell = New-Object -ComObject WScript.Shell
$DesktopShortcut = Join-Path $DesktopDir "Update Antigravity.lnk"
$Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
$Shortcut.TargetPath = (Join-Path $InstallDir "Update-Antigravity.cmd")
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Description = "Update Antigravity IDE to the latest version"
$Shortcut.Save()

Write-Host "=== Windows Setup Complete! ===" -ForegroundColor Green
Write-Host "You can now drop update zips into '$DropzoneDir' and run 'Update-Now.cmd'." -ForegroundColor Yellow
