<#
.SYNOPSIS
    Antigravity IDE - Windows Smart Updater
    Part of https://github.com/monujat/antigravity-updater

.DESCRIPTION
    Detects dropped or downloaded packages (.zip or extracted folders),
    performs atomic backup, updates Antigravity IDE, configures PATH,
    and creates Start Menu / Desktop shortcuts.
#>

param (
    [string]$SourcePath = "",
    [switch]$SystemWide = $false,
    [switch]$NonInteractive = $false
)

$ErrorActionPreference = "Stop"

# Paths
$UserInstallDir = "$env:LOCALAPPDATA\Programs\Antigravity"
$SystemInstallDir = "$env:ProgramFiles\Antigravity"
$InstallDir = if ($SystemWide -or (Test-Path $SystemInstallDir)) { $SystemInstallDir } else { $UserInstallDir }
$BackupDir = "$InstallDir.bak"
$DropzoneDir = "$env:USERPROFILE\Antigravity-Update-Box"
$DownloadsDir = "$env:USERPROFILE\Downloads"

function Show-Header {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "             Antigravity IDE Windows Updater               " -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Find-Candidate {
    $searchDirs = @($DropzoneDir, $DownloadsDir)
    foreach ($dir in $searchDirs) {
        if (Test-Path $dir) {
            # Find newest zip
            $zip = Get-ChildItem -Path $dir -Filter "*antigravity*.zip" -File -Recurse -Depth 1 -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($zip) { return $zip.FullName }

            # Find newest extracted directory
            $folder = Get-ChildItem -Path $dir -Filter "*antigravity*" -Directory -Recurse -Depth 1 -ErrorAction SilentlyContinue |
                      Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($folder) { return $folder.FullName }
        }
    }
    return $null
}

Show-Header

# Locate Candidate
if (-not $SourcePath) {
    $SourcePath = Find-Candidate
}

if (-not $SourcePath -or -not (Test-Path $SourcePath)) {
    Write-Host "No update candidate automatically found in Dropzone or Downloads." -ForegroundColor Yellow
    if ($NonInteractive) {
        Write-Error "No valid source package provided."
        exit 1
    }
    $SourcePath = Read-Host "Enter the full path to the Antigravity update ZIP or folder"
}

if (-not (Test-Path $SourcePath)) {
    Write-Host "Error: Path '$SourcePath' does not exist." -ForegroundColor Red
    exit 1
}

Write-Host "Selected update source: $SourcePath" -ForegroundColor Green

# If system wide and not elevated, prompt for elevation
if ($InstallDir -eq $SystemInstallDir -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating administrator privileges for system installation..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -SourcePath `"$SourcePath`" -SystemWide"
    exit
}

# 1. Close running Antigravity processes
Write-Host "Checking for running Antigravity processes..." -ForegroundColor Cyan
$procs = Get-Process -Name "antigravity*" -ErrorAction SilentlyContinue
if ($procs) {
    Write-Host "Closing active Antigravity processes..." -ForegroundColor Yellow
    $procs | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# 2. Extract / Inspect
$TempWorkspace = Join-Path $env:TEMP ("antigravity_upd_" + [System.Guid]::NewGuid().ToString().Substring(0,8))
New-Item -ItemType Directory -Path $TempWorkspace -Force | Out-Null

try {
    $ExtractedRoot = ""
    if ((Get-Item $SourcePath) -is [System.IO.DirectoryInfo]) {
        $ExtractedRoot = $SourcePath
    } else {
        Write-Host "Extracting archive..." -ForegroundColor Cyan
        Expand-Archive -Path $SourcePath -DestinationPath $TempWorkspace -Force
        $ExtractedRoot = $TempWorkspace
    }

    # Locate executable
    $exe = Get-ChildItem -Path $ExtractedRoot -Filter "antigravity*.exe" -File -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $exe) {
        throw "Could not locate Antigravity executable inside package '$SourcePath'."
    }
    $SourceDir = $exe.DirectoryName

    # 3. Backup previous version
    if (Test-Path $InstallDir) {
        Write-Host "Backing up existing installation to $BackupDir..." -ForegroundColor Cyan
        if (Test-Path $BackupDir) {
            Remove-Item -Path $BackupDir -Recurse -Force
        }
        Move-Item -Path $InstallDir -Destination $BackupDir -Force
    }

    # 4. Copy new version
    Write-Host "Installing new version to $InstallDir..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Copy-Item -Path "$SourceDir\*" -Destination $InstallDir -Recurse -Force

    # 5. Add to User PATH
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $BinPath = Join-Path $InstallDir "bin"
    $TargetInPath = if (Test-Path $BinPath) { $BinPath } else { $InstallDir }

    if ($UserPath -notlike "*$TargetInPath*") {
        Write-Host "Adding $TargetInPath to User PATH..." -ForegroundColor Cyan
        [Environment]::SetEnvironmentVariable("Path", "$UserPath;$TargetInPath", "User")
    }

    # 6. Create Desktop & Start Menu Shortcuts
    $WshShell = New-Object -ComObject WScript.Shell
    $TargetExePath = $exe.FullName.Replace($SourceDir, $InstallDir)
    if (-not (Test-Path $TargetExePath)) {
        $TargetExePath = Join-Path $InstallDir "antigravity.exe"
    }

    $DesktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) "Antigravity IDE.lnk"
    $Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
    $Shortcut.TargetPath = $TargetExePath
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "Launch Antigravity IDE"
    $Shortcut.Save()

    $StartMenuDir = Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs"
    $StartShortcut = Join-Path $StartMenuDir "Antigravity IDE.lnk"
    $Shortcut2 = $WshShell.CreateShortcut($StartShortcut)
    $Shortcut2.TargetPath = $TargetExePath
    $Shortcut2.WorkingDirectory = $InstallDir
    $Shortcut2.Save()

    Write-Host "`nAntigravity IDE updated successfully!" -ForegroundColor Green
    Write-Host "Installed location: $InstallDir" -ForegroundColor Gray

    if (-not $NonInteractive) {
        $launch = Read-Host "Launch Antigravity IDE now? [Y/n]"
        if ($launch -eq "" -or $launch -match "^[Yy]") {
            Start-Process $TargetExePath
        }
    }
}
catch {
    Write-Host "Error occurred during update: $_" -ForegroundColor Red
    if (Test-Path $BackupDir) {
        Write-Host "Rolling back to previous installation..." -ForegroundColor Yellow
        if (Test-Path $InstallDir) { Remove-Item -Path $InstallDir -Recurse -Force }
        Move-Item -Path $BackupDir -Destination $InstallDir -Force
        Write-Host "Rollback complete." -ForegroundColor Green
    }
    exit 1
}
finally {
    if (Test-Path $TempWorkspace) {
        Remove-Item -Path $TempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
    }
}
