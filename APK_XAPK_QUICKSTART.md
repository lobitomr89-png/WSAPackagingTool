# APK/XAPK Quick Start Guide

A quick reference guide for getting started with APK and XAPK packaging in WSAPackagingTool.

## 30-Second Quick Start

### For APK Files
1. Drag your `app.apk` onto `apk_unpack.cmd`
2. Edit files in the `temp_apk` folder
3. Run `apk_repack.cmd`
4. Your new APK is in the `out` folder

### For XAPK Files
1. Drag your `app.xapk` onto `xapk_unpack.cmd`
2. Edit files in the `temp_xapk` folder
3. Run `xapk_repack.cmd`
4. Your new XAPK is in the `out` folder

### Auto-Detect Format
```
Drag your-package.apk/xapk/msixbundle onto unpack_universal.cmd
```

## Common Tasks

### Task: Change App Icon

**For APK:**
1. Unpack: `apk_unpack.cmd your-app.apk`
2. Replace image files in `temp_apk/res/drawable-*` folders
3. Repack: `apk_repack.cmd`

**For XAPK:**
1. Unpack: `xapk_unpack.cmd your-app.xapk`
2. Replace `temp_xapk/icon.png`
3. Also replace in each APK's resources
4. Repack: `xapk_repack.cmd`

### Task: Add a Permission

**For APK:**
1. Unpack: `apk_unpack.cmd your-app.apk`
2. Edit `temp_apk/AndroidManifest.xml`
3. Add permission line:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   ```
4. Save and run: `apk_repack.cmd`

**For XAPK:**
1. Unpack: `xapk_unpack.cmd your-app.xapk`
2. Modify AndroidManifest.xml in each APK folder
3. Run: `xapk_repack.cmd`

### Task: Extract for Analysis

Just unpack and browse the contents:
```
apk_unpack.cmd your-app.apk
# Contents now in temp_apk/
```

All text files are human-readable (XML, JSON, resources, etc.).

## File Locations

### After Unpacking APK
```
your-working-directory/
└── temp_apk/
    ├── AndroidManifest.xml     ← Edit here for permissions
    ├── classes.dex             ← App code (compiled)
    ├── lib/                    ← Native libraries
    ├── res/                    ← Images, layouts, strings
    └── META-INF/               ← Signatures
```

### After Unpacking XAPK
```
your-working-directory/
└── temp_xapk/
    ├── manifest.json           ← Package info
    ├── icon.png
    ├── apks/                   ← APKs by architecture
    │   ├── arm64-v8a/
    │   ├── armeabi-v7a/
    │   ├── x86/
    │   └── x86_64/
    └── [other metadata files]
```

### After Repacking
```
your-working-directory/
└── out/
    └── app_repack.apk  (or .xapk)
```

## Troubleshooting

### "Malformed APK" Error
- The file might be corrupted
- Try downloading it again
- Ensure it's actually an APK/XAPK file

### APK Won't Unpack
- Make sure APK is closed by any other applications
- Try using `unpack_universal.cmd` instead
- Check file permissions

### Repacking Takes Too Long
- This is normal for large files
- Install 7-Zip for faster compression: https://www.7-zip.org/
- The tool will use 7-Zip automatically if available

### Modified APK Won't Install
- APKs need to be signed to install on most devices
- For testing, enable "Unknown Sources" in device settings
- Or sign with your own keystore

### Different Architecture APKs Not Created
- XAPK must have APKs for all architectures
- If missing, the APK won't work on that device
- Keep all architecture APKs in the XAPK

## Advanced Tips

### Batch Processing Multiple Files

Create a `batch_unpack.cmd`:
```batch
@echo off
for %%f in (*.apk) do (
    call apk_unpack.cmd "%%f"
    echo Done: %%f
    pause
)
```

### Comparing Versions

Unpack both versions into different folders:
```
apk_unpack_v1.cmd app-v1.apk     → temp_apk_v1
apk_unpack_v2.cmd app-v2.apk     → temp_apk_v2
```

Then use a file comparison tool (like WinMerge) to compare the extracted files.

### Modifying Multiple APKs in XAPK

XAPK files contain multiple APKs. Edit them individually:
```
temp_xapk/apks/arm64-v8a/base.apk
temp_xapk/apks/armeabi-v7a/base.apk
temp_xapk/apks/x86/base.apk
temp_xapk/apks/x86_64/base.apk
```

### Checking File Structure

After unpacking, you can inspect the files:
- **AndroidManifest.xml** - Application manifest (XML)
- **classes.dex** - Java bytecode (binary)
- **resources.arsc** - Compiled resources (binary)
- **res/** - Raw resources (images, layouts, etc.)

## PowerShell Advanced Usage

For scripting, use the `apk_utils.ps1` module:

```powershell
# Load the module
Import-Module .\apk_utils.ps1

# Detect file type
$type = Get-PackageType -FilePath "app.apk"
Write-Host "Package type: $type"

# Extract APK
Expand-APKPackage -FilePath "app.apk" -OutputPath "C:\Extracted"

# Get metadata
$meta = Get-APKMetadata -FilePath "app.apk"
$meta | ConvertTo-Json
```

## Frequently Asked Questions

**Q: Can I modify an APK on a Mac or Linux?**
A: This tool is Windows-only. Alternatives: Apktool, JADX, or Android Studio.

**Q: Will modified APKs work without resigning?**
A: Many Android devices (especially rooted or development devices) allow unsigned APKs. Commercial distribution requires signing.

**Q: How do I sign an APK?**
A: Use Android SDK tools or jarsigner. See Android documentation.

**Q: Can I modify APK code directly?**
A: The bytecode is in `classes.dex`. You need a decompiler/recompiler like Apktool.

**Q: What if the APK has multiple dex files?**
A: All DEX files are in the root of `temp_apk/`: `classes.dex`, `classes2.dex`, etc.

**Q: Can I remove ads from an APK?**
A: Technically possible but difficult - requires decompiling, analyzing, and recompiling code.

## Getting Help

- **Full Documentation:** See [APK_XAPK_README.md](APK_XAPK_README.md)
- **GitHub Issues:** Report bugs at https://github.com/MlgmXyysd/WSAPackagingTool
- **Telegram Community:** [@WSA_Community](https://t.me/wsa_community)

## Command Reference

| Command | Use Case | Input | Output |
|---------|----------|-------|--------|
| `apk_unpack.cmd` | Extract APK | `file.apk` | `temp_apk/` |
| `apk_repack.cmd` | Rebuild APK | `temp_apk/` | `out/app_repack.apk` |
| `xapk_unpack.cmd` | Extract XAPK | `file.xapk` | `temp_xapk/` |
| `xapk_repack.cmd` | Rebuild XAPK | `temp_xapk/` | `out/app_repack.xapk` |
| `unpack_universal.cmd` | Auto-detect & unpack | `file.*` | `temp_apk/` or `temp_xapk/` |

---

**Enjoy packaging!** 📦
