#
# APK/XAPK Utility Module for WSAPackagingTool
# Handles extraction and repacking of Android APK and XAPK files
# Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org> All Rights Reserved.
#

# Function to detect file type
function Get-PackageType {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return $null
    }
    
    $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    if ($ext -eq ".apk") {
        return "APK"
    } elseif ($ext -eq ".xapk") {
        return "XAPK"
    } elseif ($ext -eq ".msixbundle") {
        return "MSIXBUNDLE"
    } else {
        return "UNKNOWN"
    }
}

# Function to extract APK
function Expand-APKPackage {
    param(
        [string]$FilePath,
        [string]$OutputPath
    )
    
    try {
        if (-not (Test-Path $FilePath)) {
            throw "APK file not found: $FilePath"
        }
        
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        # Extract APK as ZIP
        $shell = New-Object -ComObject Shell.Application
        $zip = $shell.NameSpace((Convert-Path $FilePath))
        $dest = $shell.NameSpace((Convert-Path $OutputPath))
        
        # Copy all items from zip to destination
        $dest.CopyHere($zip.Items(), 0x14)  # 0x14 = no dialogs + overwrite
        
        Write-Output "Successfully extracted APK to $OutputPath"
        return $true
    }
    catch {
        Write-Error "Failed to extract APK: $_"
        return $false
    }
}

# Function to extract XAPK
function Expand-XAPKPackage {
    param(
        [string]$FilePath,
        [string]$OutputPath
    )
    
    try {
        if (-not (Test-Path $FilePath)) {
            throw "XAPK file not found: $FilePath"
        }
        
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        # XAPK is a ZIP containing APKs and metadata
        $shell = New-Object -ComObject Shell.Application
        $zip = $shell.NameSpace((Convert-Path $FilePath))
        $dest = $shell.NameSpace((Convert-Path $OutputPath))
        
        # Extract main XAPK content
        $dest.CopyHere($zip.Items(), 0x14)
        
        # Create separate directories for different architectures
        $apkDir = Join-Path $OutputPath "apks"
        if (-not (Test-Path $apkDir)) {
            New-Item -ItemType Directory -Path $apkDir -Force | Out-Null
        }
        
        # Move APK files to apks subdirectory
        Get-ChildItem -Path $OutputPath -Filter "*.apk" -Recurse | ForEach-Object {
            Move-Item -Path $_.FullName -Destination (Join-Path $apkDir $_.Name) -Force
        }
        
        Write-Output "Successfully extracted XAPK to $OutputPath"
        return $true
    }
    catch {
        Write-Error "Failed to extract XAPK: $_"
        return $false
    }
}

# Function to get APK metadata
function Get-APKMetadata {
    param([string]$FilePath)
    
    try {
        $metadata = @{}
        
        # Create a temporary extraction path
        $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("apk_" + [System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
        
        # Extract APK
        $shell = New-Object -ComObject Shell.Application
        $zip = $shell.NameSpace((Convert-Path $FilePath))
        $dest = $shell.NameSpace((Convert-Path $tempPath))
        $dest.CopyHere($zip.Items(), 0x14)
        
        # Check for AndroidManifest.xml
        if (Test-Path (Join-Path $tempPath "AndroidManifest.xml")) {
            $metadata["HasManifest"] = $true
            $metadata["Type"] = "APK"
        } else {
            $metadata["Type"] = "UNKNOWN"
        }
        
        # Check for different architecture APKs
        $architectures = @()
        Get-ChildItem -Path $tempPath -Filter "*.apk" | ForEach-Object {
            if ($_.Name -match "arm64") { $architectures += "arm64" }
            elseif ($_.Name -match "x86_64") { $architectures += "x86_64" }
            elseif ($_.Name -match "armeabi") { $architectures += "armeabi" }
            elseif ($_.Name -match "x86") { $architectures += "x86" }
        }
        
        if ($architectures.Count -gt 0) {
            $metadata["Architectures"] = $architectures
        }
        
        # Cleanup
        Remove-Item -Path $tempPath -Recurse -Force
        
        return $metadata
    }
    catch {
        Write-Error "Failed to get APK metadata: $_"
        return $null
    }
}

# Function to repack APK
function New-APKPackage {
    param(
        [string]$SourcePath,
        [string]$OutputPath,
        [string]$OutputFileName = "app.apk"
    )
    
    try {
        if (-not (Test-Path $SourcePath)) {
            throw "Source directory not found: $SourcePath"
        }
        
        $outputDir = Split-Path -Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        # Use 7-Zip if available, otherwise use Windows compression
        $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
        
        if (Test-Path $sevenZipPath) {
            # Use 7-Zip for better compression
            & $sevenZipPath a -tzip -mx9 $OutputPath $SourcePath | Out-Null
        } else {
            # Fallback to Compress-Archive
            Compress-Archive -Path (Join-Path $SourcePath "*") -DestinationPath $OutputPath -Force
        }
        
        if (Test-Path $OutputPath) {
            Write-Output "Successfully created APK: $OutputPath"
            return $true
        } else {
            throw "Failed to create APK package"
        }
    }
    catch {
        Write-Error "Failed to repack APK: $_"
        return $false
    }
}

# Function to repack XAPK
function New-XAPKPackage {
    param(
        [string]$SourcePath,
        [string]$OutputPath
    )
    
    try {
        if (-not (Test-Path $SourcePath)) {
            throw "Source directory not found: $SourcePath"
        }
        
        $outputDir = Split-Path -Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        # Create XAPK as ZIP with proper structure
        $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
        
        if (Test-Path $sevenZipPath) {
            & $sevenZipPath a -tzip -mx9 $OutputPath (Join-Path $SourcePath "*") | Out-Null
        } else {
            Compress-Archive -Path (Join-Path $SourcePath "*") -DestinationPath $OutputPath -Force
        }
        
        # Rename to .xapk if not already
        if (-not ($OutputPath -match "\.xapk$")) {
            $xapkPath = [System.IO.Path]::ChangeExtension($OutputPath, ".xapk")
            Move-Item -Path $OutputPath -Destination $xapkPath -Force
            Write-Output "Successfully created XAPK: $xapkPath"
            return $true
        }
        
        Write-Output "Successfully created XAPK: $OutputPath"
        return $true
    }
    catch {
        Write-Error "Failed to repack XAPK: $_"
        return $false
    }
}

Export-ModuleMember -Function @(
    "Get-PackageType",
    "Expand-APKPackage",
    "Expand-XAPKPackage",
    "Get-APKMetadata",
    "New-APKPackage",
    "New-XAPKPackage"
)
