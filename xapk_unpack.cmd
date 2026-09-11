@echo off
::
:: XAPK Unpacker - WSAPackagingTool
:: Unpacks Android XAPK (Extended APK) files for modification
:: XAPK files contain multiple APK files for different architectures
:: Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org> All Rights Reserved.
::
title Unpack XAPK - WSAPackagingTool
echo Unpack XAPK - WSAPackagingTool v1.0 By MlgmXyysd
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
    echo [#] Error: You need to specify a valid XAPK file.
    goto :EXIT
)

if /i not "%~x1" == ".xapk" (
    echo [#] Error: File is not an XAPK package.
    goto :EXIT
)

echo [-] Cleaning temp directory...
rd /s /q ".\temp_xapk" >nul 2>nul
mkdir ".\temp_xapk" >nul 2>nul

echo [-] Extracting XAPK...
%PS% "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%~1', '.\temp_xapk')"

if not exist ".\temp_xapk" (
    echo [#] Error: Failed to extract XAPK.
    goto :LATE_CLEAN
)

:: Check for manifest or APK files
if not exist ".\temp_xapk\manifest.json" (
    if not exist ".\temp_xapk\*.apk" (
        echo [*] Warning: Could not find manifest.json or APK files.
    )
)

:: Organize APKs by architecture
echo [-] Organizing APK files by architecture...
mkdir ".\temp_xapk\apks\arm64-v8a" >nul 2>nul
mkdir ".\temp_xapk\apks\armeabi-v7a" >nul 2>nul
mkdir ".\temp_xapk\apks\x86" >nul 2>nul
mkdir ".\temp_xapk\apks\x86_64" >nul 2>nul

for /r ".\temp_xapk" %%f in (*.apk) do (
    set "filename=%%~nxf"
    if "!filename:arm64=!" neq "!filename!" (
        move /y "%%f" ".\temp_xapk\apks\arm64-v8a\" >nul 2>nul
    ) else if "!filename:armeabi=!" neq "!filename!" (
        move /y "%%f" ".\temp_xapk\apks\armeabi-v7a\" >nul 2>nul
    ) else if "!filename:x86_64=!" neq "!filename!" (
        move /y "%%f" ".\temp_xapk\apks\x86_64\" >nul 2>nul
    ) else if "!filename:x86=!" neq "!filename!" (
        move /y "%%f" ".\temp_xapk\apks\x86\" >nul 2>nul
    ) else (
        move /y "%%f" ".\temp_xapk\apks\" >nul 2>nul
    )
)

echo [*] Successfully extracted XAPK to temp_xapk folder.
echo [*] APK files are organized by architecture in apks subfolder.
echo [*] You can now modify the contents in "temp_xapk" folder.
echo [*] When done, run xapk_repack.cmd to repackage the XAPK.
goto :EXIT

:LATE_CLEAN
pause
rd /s /q ".\temp_xapk" >nul 2>nul
goto :EOF

:EXIT
pause
goto :EOF
