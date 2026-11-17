@echo off
:: Click-to-run launcher for Antigravity Updater on Windows
title Updating Antigravity IDE...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-antigravity.ps1" %*
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Update encountered an issue. See above output.
    pause
)
