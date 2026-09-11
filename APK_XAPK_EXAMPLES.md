# APK/XAPK Examples and Use Cases

Real-world examples for using WSAPackagingTool's APK and XAPK features.

## Example 1: Localizing an APK

**Goal:** Change app language and strings

### Steps

1. **Unpack the APK:**
   ```batch
   apk_unpack.cmd google-play-services.apk
   ```

2. **Modify Strings:**
   
   Navigate to `temp_apk/res/values-es/strings.xml` (for Spanish):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <resources>
       <string name="app_name">Mi Aplicación</string>
       <string name="hello">Hola, Mundo</string>
   </resources>
   ```

3. **Repack:**
   ```batch
   apk_repack.cmd
   ```

4. **Result:** `out/google-play-services_repack.apk` with Spanish strings

---

## Example 2: Removing an App's Metadata

**Goal:** Remove tracking or analytics before distribution

### Steps

1. **Unpack:**
   ```batch
   apk_unpack.cmd myapp.apk
   ```

2. **Edit Manifest:**

   Edit `temp_apk/AndroidManifest.xml` to remove tracking service:
   ```xml
   <!-- REMOVE THIS SECTION -->
   <!-- <service android:name=".analytics.AnalyticsService" /> -->
   
   <!-- KEEP APPLICATION LOGIC -->
   <activity android:name=".MainActivity">
       <intent-filter>
           <action android:name="android.intent.action.MAIN" />
           <category android:name="android.intent.category.LAUNCHER" />
       </intent-filter>
   </activity>
   ```

3. **Remove Resources:**
   
   Delete tracking-related resource files:
   ```
   temp_apk/res/raw/analytics_config.json
   temp_apk/lib/x86/libtracking.so
   ```

4. **Repack:**
   ```batch
   apk_repack.cmd
   ```

---

## Example 3: Creating a Universal APK from XAPK

**Goal:** Extract only ARM64 APK from XAPK for ARM64 devices

### Steps

1. **Unpack XAPK:**
   ```batch
   xapk_unpack.cmd app.xapk
   ```

2. **Extract ARM64 APK:**
   
   Copy `temp_xapk/apks/arm64-v8a/base.apk` as `app-arm64.apk`

3. **Rename:**
   ```batch
   copy temp_xapk\apks\arm64-v8a\base.apk app-arm64-only.apk
   ```

**Result:** Single APK for ARM64 devices only

---

## Example 4: Adding Firebase to an APK

**Goal:** Inject Firebase configuration into an existing APK

### Prerequisites
- `google-services.json` from Firebase Console
- Firebase client library APK overlay

### Steps

1. **Unpack:**
   ```batch
   apk_unpack.cmd myapp.apk
   ```

2. **Add Firebase Config:**
   
   Add to `temp_apk/res/values/strings.xml`:
   ```xml
   <string name="google_app_id">1:123456789:android:abcdef1234567890</string>
   <string name="google_api_key">AIza_SyBx1234567890abcdefg</string>
   <string name="firebase_database_url">https://myapp.firebaseio.com</string>
   ```

3. **Update Manifest:**
   
   Add to `temp_apk/AndroidManifest.xml`:
   ```xml
   <application>
       <service
           android:name="com.google.firebase.messaging.FirebaseMessagingService"
           android:exported="false">
           <intent-filter>
               <action android:name="com.google.firebase.MESSAGING_EVENT" />
           </intent-filter>
       </service>
   </application>
   ```

4. **Repack:**
   ```batch
   apk_repack.cmd
   ```

---

## Example 5: Creating Multi-Architecture XAPK

**Goal:** Package ARM and x86 versions together

### Steps

1. **Prepare Two APKs:**
   - `app-arm64.apk` - for ARM64 devices
   - `app-x86_64.apk` - for x86_64 devices

2. **Create XAPK Structure:**
   ```batch
   mkdir temp_xapk
   mkdir temp_xapk\apks\arm64-v8a
   mkdir temp_xapk\apks\x86_64
   copy app-arm64.apk temp_xapk\apks\arm64-v8a\base.apk
   copy app-x86_64.apk temp_xapk\apks\x86_64\base.apk
   ```

3. **Create manifest.json:**
   
   Create `temp_xapk/manifest.json`:
   ```json
   {
     "xapk_version": "1",
     "package_name": "com.example.myapp",
     "name": "My App",
     "version_code": 100,
     "version_name": "1.0",
     "min_android_version": 24,
     "target_android_version": 34,
     "architectures": ["arm64-v8a", "x86_64"],
     "permissions": ["android.permission.INTERNET"],
     "splits": [
       {
         "id": "base",
         "split_type": "language",
         "language": "en"
       }
     ]
   }
   ```

4. **Add Icon:**
   ```batch
   copy icon.png temp_xapk\icon.png
   ```

5. **Repack:**
   ```batch
   xapk_repack.cmd
   ```

**Result:** `out/com.example.myapp_repack.xapk` supporting both architectures

---

## Example 6: Batch Processing Multiple APKs

**Goal:** Apply same modifications to 10 APK files

### Script: `batch_modify.cmd`

```batch
@echo off
setlocal enabledelayedexpansion

:: Process each APK in current directory
for %%F in (*.apk) do (
    echo Processing %%F...
    
    :: Unpack
    call apk_unpack.cmd "%%F"
    
    :: Modify manifest (add permission)
    powershell -Command ^
        "$xml = [xml](Get-Content '.\temp_apk\AndroidManifest.xml'); " ^
        "$perm = $xml.CreateElement('uses-permission'); " ^
        "$perm.SetAttribute('android:name', 'android.permission.INTERNET'); " ^
        "$xml.manifest.AppendChild($perm); " ^
        "$xml.Save('.\temp_apk\AndroidManifest.xml')"
    
    :: Repack
    call apk_repack.cmd "%%~nF_modified.apk"
    
    echo.
)

echo All APKs processed!
```

**Usage:**
```batch
batch_modify.cmd
```

---

## Example 7: Deep-Linking Support

**Goal:** Add deep-linking to app for custom URL handling

### Steps

1. **Unpack:**
   ```batch
   apk_unpack.cmd app.apk
   ```

2. **Update Manifest:**

   Edit `temp_apk/AndroidManifest.xml`:
   ```xml
   <activity android:name=".MainActivity">
       <intent-filter>
           <action android:name="android.intent.action.MAIN" />
           <category android:name="android.intent.category.LAUNCHER" />
       </intent-filter>
       
       <!-- Add deep-linking support -->
       <intent-filter>
           <action android:name="android.intent.action.VIEW" />
           <category android:name="android.intent.category.DEFAULT" />
           <category android:name="android.intent.category.BROWSABLE" />
           <data
               android:scheme="https"
               android:host="example.com"
               android:pathPattern="/app/.*" />
       </intent-filter>
   </activity>
   ```

3. **Repack:**
   ```batch
   apk_repack.cmd
   ```

**Result:** App responds to `https://example.com/app/page` URLs

---

## Example 8: PowerShell Automation

**Goal:** Extract and analyze 50 APKs programmatically

### Script: `analyze_apks.ps1`

```powershell
# Import utilities
Import-Module .\apk_utils.ps1

# Get all APKs
$apks = Get-ChildItem -Path "C:\APKs" -Filter "*.apk"

# Process each
foreach ($apk in $apks) {
    Write-Host "Analyzing: $($apk.Name)"
    
    $type = Get-PackageType -FilePath $apk.FullName
    $metadata = Get-APKMetadata -FilePath $apk.FullName
    
    # Extract
    $outputPath = Join-Path "C:\Extracted" $apk.BaseName
    Expand-APKPackage -FilePath $apk.FullName -OutputPath $outputPath
    
    # Read manifest
    $manifestPath = Join-Path $outputPath "AndroidManifest.xml"
    $xml = [xml](Get-Content $manifestPath)
    $packageName = $xml.manifest.package
    
    # Output results
    [PSCustomObject]@{
        Filename = $apk.Name
        PackageName = $packageName
        Type = $type
        Metadata = $metadata
    } | Export-Csv -Path "C:\Results\analysis.csv" -Append
}

Write-Host "Analysis complete!"
```

**Usage:**
```powershell
./analyze_apks.ps1
```

---

## Example 9: Version Upgrade Workflow

**Goal:** Update app from v1 to v2 while preserving custom data

### Steps

1. **Extract Both Versions:**
   ```batch
   apk_unpack.cmd app-v1.apk      :: Creates temp_apk/
   xcopy /E temp_apk temp_apk_v1  :: Backup
   
   apk_unpack.cmd app-v2.apk      :: Creates new temp_apk/
   ```

2. **Compare Using WinMerge:**
   ```batch
   "C:\Program Files\WinMerge\WinMergeU.exe" temp_apk_v1 temp_apk
   ```

3. **Merge Custom Changes:**
   - Copy custom resources from v1 to v2
   - Update manifest permissions from v1
   - Preserve modified assets

4. **Repack:**
   ```batch
   apk_repack.cmd app-v2-upgraded.apk
   ```

---

## Example 10: Signing (Post-Processing)

**Goal:** Sign a repacked APK for distribution

### Steps

1. **After Repacking:**
   ```batch
   apk_repack.cmd
   :: Creates: out/app_repack.apk
   ```

2. **Sign with jarsigner (Android SDK):**
   ```batch
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 ^
     -keystore my-release-key.keystore ^
     out/app_repack.apk alias_name
   ```

3. **Verify Signature:**
   ```batch
   jarsigner -verify -verbose out/app_repack.apk
   ```

**Result:** `out/app_repack.apk` ready for Google Play Store

---

## Tips & Tricks

### 1. Fastest XAPK Processing
Install 7-Zip for automatic optimization:
```
https://www.7-zip.org/download.html
```

### 2. Backup Before Modifying
```batch
xcopy /E temp_apk temp_apk.backup
```

### 3. Test Modifications
Always test on device or emulator before final release.

### 4. Keep Version Tracking
Name output files with version info:
```batch
ren out\app_repack.apk app-v1.2.3-modified.apk
```

### 5. Clean Up Temp Files
```batch
rd /s /q temp_apk
rd /s /q temp_xapk
```

---

## Troubleshooting Examples

### Issue: "Invalid XML in Manifest"

**Symptom:** Error when repacking

**Fix:**
1. Open `temp_apk/AndroidManifest.xml` in XML editor
2. Look for syntax errors (missing quotes, unclosed tags)
3. Use VS Code with XML extension for validation
4. Compare with backup using diff tool

### Issue: Missing Architecture APKs

**Symptom:** XAPK works on some devices but not others

**Fix:**
1. Check which APKs are in `temp_xapk/apks/`
2. Add missing architectures if available
3. Or document limitations in app description

### Issue: Resource Files Not Found

**Symptom:** App crashes after modification

**Fix:**
1. Verify files weren't accidentally deleted
2. Check file paths match case-sensitivity
3. Restore from backup and retry carefully

---

**Happy modifying!** 🚀

For more help, see [APK_XAPK_README.md](APK_XAPK_README.md) or [APK_XAPK_QUICKSTART.md](APK_XAPK_QUICKSTART.md)
