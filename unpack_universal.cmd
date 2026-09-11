@echo off
::
:: Universal Unpacker - WSAPackagingTool
:: Automatically detects and unpacks APK, XAPK, or MSIXBUNDLE files
:: Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org> All Rights Reserved.
::
title Universal Unpack - WSAPackagingTool
echo Universal Unpacker - WSAPackagingTool v1.0 By MlgmXyysd
echo https://github.com/WSA-Community/WSAPackagingTool
echo *********************************************
echo.
echo [-] Initializing...

cd /d "%~dp0"

if not exist "%~1" (
    echo [#] Error: You need to specify a valid package file.
    echo [*] Supported formats: .apk, .xapk, .msixbundle
    goto :EXIT
)

set FILE_EXT=%~x1

if /i "%FILE_EXT%" == ".apk" (
    echo [-] Detected APK file format
    call apk_unpack.cmd "%~1"
    goto :EOF
) else if /i "%FILE_EXT%" == ".xapk" (
    echo [-] Detected XAPK file format
    call xapk_unpack.cmd "%~1"
    goto :EOF
) else if /i "%FILE_EXT%" == ".msixbundle" (
    echo [-] Detected MSIXBUNDLE file format
    call unpack.cmd "%~1"
    goto :EOF
) else (
    echo [#] Error: Unknown file format: %FILE_EXT%
    echo [*] Supported formats: .apk, .xapk, .msixbundle
    goto :EXIT
)

:EXIT
pause
goto :EOF
