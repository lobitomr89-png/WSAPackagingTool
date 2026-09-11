@echo off
::
:: APK Repacker - WSAPackagingTool
:: Repacks modified APK files
:: Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org> All Rights Reserved.
::
title Repack APK - WSAPackagingTool
echo Repack APK - WSAPackagingTool v1.0 By MlgmXyysd
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
if not exist ".\temp_apk\AndroidManifest.xml" (
    echo [#] Error: APK unpack project not found. Please run apk_unpack.cmd first.
    goto :EXIT
)

echo [-] Cleaning output directory...
rd /s /q ".\out" >nul 2>nul
mkdir ".\out" >nul 2>nul

echo [-] Creating APK package...
%PS% "Add-Type -AssemblyName System.IO.Compression.FileSystem; $src = Resolve-Path '.\temp_apk'; $dest = Resolve-Path '.\out'; $zip = [System.IO.Compression.ZipFile]::Open('.\out\app_repack.apk', 'Create'); Get-ChildItem $src -Recurse | ForEach-Object { if (-not $_.PSIsContainer) { $entry = $zip.CreateEntry($_.FullName.Substring($src.Path.Length + 1)); $stream = $entry.Open(); [System.IO.File]::OpenRead($_.FullName) | Copy-Object -DestinationPath ([System.IO.Stream]$stream); $stream.Close() } }; $zip.Dispose()"

if not exist ".\out\app_repack.apk" (
    echo [#] Error: Failed to create APK package.
    echo [*] Trying alternative method...
    
    :: Try using PowerShell Compress-Archive if 7-Zip not available
    %PS% "Compress-Archive -Path (Get-ChildItem '.\temp_apk' | ForEach-Object {$_.FullName}) -DestinationPath '.\out\app_repack.apk' -Force"
    
    if not exist ".\out\app_repack.apk" (
        goto :LATE_CLEAN
    )
)

:: Parse package name from manifest
for /F "delims=" %%i in ('%PS% "Try {$xml = [xml](Get-Content '.\temp_apk\AndroidManifest.xml' -Raw); Write-Output $xml.manifest.package} Catch {Write-Output 'app'}"') do (set PKG_NAME=%%i)

:: Get version info if available
for /F "delims=" %%i in ('%PS% "Try {$xml = [xml](Get-Content '.\temp_apk\AndroidManifest.xml' -Raw); Write-Output $xml.manifest.'android:versionName'} Catch {Write-Output '1.0'}"') do (set VERSION=%%i)

set FINAL_NAME=!PKG_NAME:*\=!_!VERSION:*\=!_repack.apk
set FINAL_NAME=%FINAL_NAME:/=_-%

if "%~1" == "" (
    echo [-] Moving APK to output folder...
    move /y ".\out\app_repack.apk" ".\out\%FINAL_NAME%" >nul 2>nul
    echo [*] Done. New APK package is created: out\%FINAL_NAME%
) else (
    move /y ".\out\app_repack.apk" "%~1" >nul 2>nul
    echo [*] Done. New APK package is created: %~1
)

goto :EXIT

:LATE_CLEAN
echo [#] Error: Failed to repack APK.
pause
rd /s /q ".\out" >nul 2>nul
goto :EOF

:EXIT
pause
goto :EOF
