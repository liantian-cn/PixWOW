@echo off
setlocal
title PixProtection
pushd "%~dp0.."
if errorlevel 1 (
    echo Failed to open the repository directory.
    pause
    exit /b 1
)

where uv >nul 2>&1
if errorlevel 1 (
    echo uv was not found. Install uv and add it to PATH, then try again.
    popd
    pause
    exit /b 1
)

powershell.exe -NoProfile -Command "try { Start-Process -FilePath 'uv' -ArgumentList 'run','--locked','--directory','PixProtection','pythonw','-m','pix' -WorkingDirectory (Get-Location).Path -WindowStyle Hidden -ErrorAction Stop | Out-Null; exit 0 } catch { Write-Host $_.Exception.Message; exit 1 }"
set "launch_exit_code=%errorlevel%"
popd
if not "%launch_exit_code%"=="0" (
    echo Failed to start PixProtection.
    pause
)
exit /b %launch_exit_code%
