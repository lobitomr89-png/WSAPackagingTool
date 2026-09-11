@echo off
::
:: APK Unpacker - WSAPackagingTool
:: Unpacks Android APK files for modification
:: Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org> All Rights Reserved.
::
title Unpack APK - WSAPackagingTool
echo Unpack APK - WSAPackagingTool v1.0 By MlgmXyysd
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

:: Validate input
if not exist "%~1" (
    echo [#] Error: You need to specify a valid APK file.
    goto :EXIT
)

if /i not "%~x1" == ".apk" (
    echo [#] Error: File is not an APK package.
    goto :EXIT
)

echo [-] Cleaning temp directory...
rd /s /q ".\temp_apk" >nul 2>nul
mkdir ".\temp_apk" >nul 2>nul

echo [-] Extracting APK...
%PS% "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%~1', '.\temp_apk')"

if not exist ".\temp_apk\AndroidManifest.xml" (
    echo [#] Error: Malformed APK or not a valid Android package.
    goto :LATE_CLEAN
)

:: Extract APK metadata
%PS% "Try {$xml = [xml](Get-Content '.\temp_apk\AndroidManifest.xml' -Raw); Write-Output $xml.manifest.package} Catch {Write-Output 'UNKNOWN'}" > temp_pkg.txt
set /p APK_PACKAGE=<temp_pkg.txt
del /f /q temp_pkg.txt >nul 2>nul

echo [*] APK Package: %APK_PACKAGE%
echo [*] Successfully extracted APK to temp_apk folder.
echo [*] You can now modify the contents in "temp_apk" folder.
echo [*] When done, run apk_repack.cmd to repackage the APK.
goto :EXIT

:LATE_CLEAN
pause
rd /s /q ".\temp_apk" >nul 2>nul
goto :EOF

:EXIT
pause
goto :EOF
