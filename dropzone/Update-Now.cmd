@echo off
:: Windows Dropzone Quick-Update
title Updating Antigravity IDE...
if exist "%LOCALAPPDATA%\AntigravityUpdater\Update-Antigravity.cmd" (
    call "%LOCALAPPDATA%\AntigravityUpdater\Update-Antigravity.cmd"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Please run windows/setup-windows.ps1 first.' -ForegroundColor Red; pause"
)
