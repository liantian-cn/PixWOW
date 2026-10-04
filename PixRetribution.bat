@echo off
setlocal
title PixRetribution
pushd "%~dp0"
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

uv run --locked --directory PixRetribution python -m pix
set "launch_exit_code=%errorlevel%"
popd
echo.
echo PixRetribution exited with code %launch_exit_code%.
pause
exit /b %launch_exit_code%
