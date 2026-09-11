@echo off
::
:: XAPK Repacker - WSAPackagingTool
:: Repacks modified XAPK files with multiple APK support
:: Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org> All Rights Reserved.
::
title Repack XAPK - WSAPackagingTool
echo Repack XAPK - WSAPackagingTool v1.0 By MlgmXyysd
echo https://github.com/WSA-Community/WSAPackagingTool
echo *********************************************
echo.
echo [-] Initializing...

cd /d "%~dp0"

setlocal ENABLEDELAYEDEXPANSION

:: Check PowerShell availability
pwsh -v >nul 2>nul
if not "%errorlevel%" == "9009" (
    set PS=pwsh -Command
) else (
    powershell -v >nul 2>nul
    if not "!errorlevel!" == "9009" (
        set PS=powershell -Command
    ) else (
        echo [#] Error: PowerShell not found.
        goto :EXIT
    )
)

setlocal DISABLEDELAYEDEXPANSION

:: Validate temp folder
if not exist ".\temp_xapk" (
    echo [#] Error: XAPK unpack project not found. Please run xapk_unpack.cmd first.
    goto :EXIT
)

echo [-] Cleaning output directory...
rd /s /q ".\out" >nul 2>nul
mkdir ".\out" >nul 2>nul

echo [-] Creating XAPK package...
%PS% "Add-Type -AssemblyName System.IO.Compression.FileSystem; $src = Resolve-Path '.\temp_xapk'; $dest = Resolve-Path '.\out'; $zip = [System.IO.Compression.ZipFile]::Open('.\out\app_repack.xapk', 'Create'); Get-ChildItem $src -Recurse -Exclude '*.xapk' | ForEach-Object { if (-not $_.PSIsContainer) { $entry = $zip.CreateEntry($_.FullName.Substring($src.Path.Length + 1)); $stream = $entry.Open(); [System.IO.File]::OpenRead($_.FullName) | Copy-Object -DestinationPath ([System.IO.Stream]$stream); $stream.Close() } }; $zip.Dispose()"

if not exist ".\out\app_repack.xapk" (
    echo [#] Error: Failed to create XAPK package.
    echo [*] Trying alternative method...
    
    :: Try using PowerShell Compress-Archive
    %PS% "Compress-Archive -Path (Get-ChildItem '.\temp_xapk' -Exclude '*.xapk' | ForEach-Object {$_.FullName}) -DestinationPath '.\out\app_repack.xapk' -Force"
    
    if not exist ".\out\app_repack.xapk" (
        goto :LATE_CLEAN
    )
)

:: Parse package name from manifest if available
if exist ".\temp_xapk\manifest.json" (
    for /F "delims=" %%i in ('%PS% "Try {$json = Get-Content '.\temp_xapk\manifest.json' | ConvertFrom-Json; Write-Output $json.package_name} Catch {Write-Output 'app'}"') do (set PKG_NAME=%%i)
) else (
    set PKG_NAME=app
)

if "%PKG_NAME%" == "" (
    set PKG_NAME=app
)

set FINAL_NAME=!PKG_NAME:*\=!_repack.xapk
set FINAL_NAME=%FINAL_NAME:/=_-%

if "%~1" == "" (
    echo [-] Moving XAPK to output folder...
    move /y ".\out\app_repack.xapk" ".\out\%FINAL_NAME%" >nul 2>nul
    echo [*] Done. New XAPK package is created: out\%FINAL_NAME%
) else (
    move /y ".\out\app_repack.xapk" "%~1" >nul 2>nul
    echo [*] Done. New XAPK package is created: %~1
)

goto :EXIT

:LATE_CLEAN
echo [#] Error: Failed to repack XAPK.
pause
rd /s /q ".\out" >nul 2>nul
goto :EOF

:EXIT
pause
goto :EOF
