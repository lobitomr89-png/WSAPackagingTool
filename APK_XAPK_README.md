# APK/XAPK Support for WSAPackagingTool

This document describes the APK and XAPK support added to WSAPackagingTool, enabling you to unpack, modify, and repack Android application packages alongside Windows Subsystem for Android (WSA) packages.

## Overview

### What is APK?
**APK** (Android Package) is the standard container format for Android applications. It's essentially a ZIP archive containing the application code, resources, and metadata.

### What is XAPK?
**XAPK** (Extended APK) is an advanced format that contains multiple APK files targeting different device architectures (arm, arm64, x86, x86_64), along with optional expansion files and configuration metadata. This enables universal compatibility across various Android devices.

### Universal Architecture Support
The APK/XAPK tools now support:
- **ARM** (armeabi-v7a) - 32-bit ARM processors
- **ARM64** (arm64-v8a) - 64-bit ARM processors
- **x86** - 32-bit Intel processors
- **x86_64** - 64-bit Intel processors

## Available Commands

### 1. Universal Unpacker
**File:** `unpack_universal.cmd`

Automatically detects the package format and unpacks accordingly.

```
Drag your package to unpack_universal.cmd
or
unpack_universal <package_file>
```

**Supported formats:**
- `.apk` - Android Package
- `.xapk` - Extended Android Package
- `.msixbundle` - Windows Subsystem for Android Bundle

### 2. APK-Specific Commands

#### APK Unpacker
**File:** `apk_unpack.cmd`

Extracts an APK file for modification.

```
Drag APK file to apk_unpack.cmd
or
apk_unpack <file.apk>
```

**Output:** Files are extracted to `temp_apk` folder

#### APK Repacker
**File:** `apk_repack.cmd`

Repacks a modified APK project back into an APK file.

```
apk_repack.cmd
or
apk_repack <output_path>
```

**Input:** Reads from `temp_apk` folder
**Output:** Creates `app_repack.apk` in `out` folder

### 3. XAPK-Specific Commands

#### XAPK Unpacker
**File:** `xapk_unpack.cmd`

Extracts an XAPK file with organized architecture support.

```
Drag XAPK file to xapk_unpack.cmd
or
xapk_unpack <file.xapk>
```

**Output:** 
- Main files extracted to `temp_xapk` folder
- APK files organized by architecture in `temp_xapk/apks/` subfolder

#### XAPK Repacker
**File:** `xapk_repack.cmd`

Repacks a modified XAPK project with multi-architecture support.

```
xapk_repack.cmd
or
xapk_repack <output_path>
```

**Input:** Reads from `temp_xapk` folder
**Output:** Creates `app_repack.xapk` in `out` folder

## Workflow Examples

### Example 1: Modify a Single APK

1. **Unpack the APK:**
   ```
   Drag your-app.apk to apk_unpack.cmd
   ```
   The APK is extracted to `temp_apk` folder.

2. **Modify Contents:**
   - Edit AndroidManifest.xml for permission changes
   - Modify resources in `temp_apk/res/` folder
   - Update DEX files in `temp_apk/` for code changes
   - Add or modify other files as needed

3. **Repack the APK:**
   ```
   apk_repack.cmd
   ```
   The modified APK is created as `your-app_1.0_repack.apk` in the `out` folder.

### Example 2: Modify a Multi-Architecture XAPK

1. **Unpack the XAPK:**
   ```
   Drag your-app.xapk to xapk_unpack.cmd
   ```
   The XAPK is extracted to `temp_xapk` folder with APKs organized by architecture:
   ```
   temp_xapk/
   ├── manifest.json
   ├── icon.png
   └── apks/
       ├── arm64-v8a/
       ├── armeabi-v7a/
       ├── x86/
       └── x86_64/
   ```

2. **Modify Contents:**
   - Edit `manifest.json` for package metadata
   - Modify individual APK files for each architecture in `temp_xapk/apks/` subfolder
   - Each architecture APK can be modified independently

3. **Repack the XAPK:**
   ```
   xapk_repack.cmd
   ```
   The modified XAPK is created as `com.example.app_repack.xapk` in the `out` folder.

### Example 3: Convert Between Formats

You can use the unpacking and repacking commands to convert between formats:

**APK → Extract and Repack:**
- Unpack with `apk_unpack.cmd`
- Repack with `apk_repack.cmd`

**XAPK → Extract and Repack:**
- Unpack with `xapk_unpack.cmd`
- Repack with `xapk_repack.cmd`

## File Structure Reference

### Typical APK Structure (temp_apk)
```
temp_apk/
├── AndroidManifest.xml        (Application manifest)
├── classes.dex                (Java bytecode)
├── META-INF/                  (Certificates and signatures)
├── lib/                       (Native libraries)
│   ├── arm64-v8a/
│   ├── armeabi-v7a/
│   ├── x86/
│   └── x86_64/
├── res/                       (Resources)
│   ├── drawable/
│   ├── layout/
│   ├── values/
│   └── ...
└── resources.arsc             (Compiled resources)
```

### Typical XAPK Structure (temp_xapk)
```
temp_xapk/
├── manifest.json              (XAPK metadata)
├── icon.png                   (App icon)
└── apks/                      (Multiple APK files for different architectures)
    ├── arm64-v8a/
    │   ├── base.apk
    │   ├── config.arm64_v8a.apk
    │   └── ...
    ├── armeabi-v7a/
    │   ├── base.apk
    │   ├── config.armeabi_v7a.apk
    │   └── ...
    ├── x86/
    │   └── ...
    └── x86_64/
        └── ...
```

## Requirements

- **Windows 10+**
- **PowerShell 5.1+** (for most operations)
- **7-Zip (optional)** - For better compression (C:\Program Files\7-Zip\7z.exe)
  - Falls back to Windows built-in compression if 7-Zip is not available

## Important Notes

### Security Considerations
- **Unsigned APKs:** Repacked APKs will not be signed by default. You'll need to sign them with your own keystore before distribution.
- **Manifest Validation:** Ensure AndroidManifest.xml remains valid XML after modifications.
- **Architecture Compatibility:** Always include APKs for the target architectures.

### Common Modifications

**Adding Permissions:**
Edit `AndroidManifest.xml` and add permission tags:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**Modifying Resources:**
Resources are in the `res/` folder. Common modifications:
- Strings: `res/values/strings.xml`
- Layouts: `res/layout/*.xml`
- Drawables: `res/drawable/`

**Modifying Code:**
- DEX files (Java bytecode): Requires APK signing tools
- Native libraries: In `lib/` subdirectories by architecture

### Troubleshooting

**"Malformed APK" Error:**
- Ensure the file is a valid ZIP archive
- Check AndroidManifest.xml is present and valid

**"Failed to extract" Error:**
- Check file permissions
- Ensure the file is not corrupt
- Try the universal unpacker instead

**Large File Sizes:**
- Compression may not be optimal without 7-Zip
- Install 7-Zip for better compression results

**Architecture Mismatch:**
- Ensure XAPK has APKs for all required architectures
- ARM64 devices may not run ARM-only APKs on newer Android versions

## Advanced Usage

### Working with APK Utilities Module
For advanced scripting, use the `apk_utils.ps1` PowerShell module:

```powershell
# Import the module
Import-Module .\apk_utils.ps1

# Detect package type
Get-PackageType -FilePath "app.apk"  # Returns "APK"
Get-PackageType -FilePath "app.xapk" # Returns "XAPK"

# Extract packages
Expand-APKPackage -FilePath "app.apk" -OutputPath ".\extracted"
Expand-XAPKPackage -FilePath "app.xapk" -OutputPath ".\extracted"

# Get metadata
Get-APKMetadata -FilePath "app.apk"

# Create packages
New-APKPackage -SourcePath ".\extracted" -OutputPath "app_new.apk"
New-XAPKPackage -SourcePath ".\extracted" -OutputPath "app_new.xapk"
```

## FAQ

**Q: Can I modify both APK and XAPK with the same workflow?**
A: Yes! Use `unpack_universal.cmd` to automatically detect the format.

**Q: What about code obfuscation/de-obfuscation?**
A: The tool handles APK structure. For code analysis, you'll need additional tools like Apktool or Jadx.

**Q: Can I add new permissions?**
A: Yes, edit AndroidManifest.xml directly.

**Q: Will the repacked APK work without signing?**
A: For side-loading on a device, you'll need to sign it with your own certificate or disable signature verification on the device.

**Q: How do I handle large files in XAPK?**
A: The tool supports the full XAPK specification including obb (Opaque Binary Blob) files.

## Version History

### v1.0
- Initial APK support
- Initial XAPK support
- Universal unpacker with auto-detection
- PowerShell utility module
- Multi-architecture support

## Support and Contribution

For issues, questions, or contributions:
- **GitHub Issues:** [WSAPackagingTool Issues](https://github.com/MlgmXyysd/WSAPackagingTool/issues)
- **Telegram:** [@WSA_Community](https://t.me/wsa_community)

## License

Copyright (C) 2002-2024 Jaida Wu (MlgmXyysd) <mlgmxyysd@meowcat.org>

This tool is provided as-is for educational and personal use.

---

**Happy Packaging!** 🚀
