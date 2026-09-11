# WSAPackagingTool

**WIP Project / Public Test**

A comprehensive tool to unpack, modify, and repack Windows Subsystem for Android (WSA) Msixbundle files, as well as Android APK and XAPK packages.

## Supported Formats

- **MSIXBUNDLE** - Windows Subsystem for Android bundles
- **APK** - Android Package files
- **XAPK** - Extended Android Package files (with multi-architecture support)

## Requirements

- **Windows 10+**
- **Windows Software Development Kit** (Tools included - see [libraries](libraries/README.md))
- **Git for Windows** (Tools included)
- **PowerShell 5.1+** (PowerShell 6+ for repacking WSA/MSIXBUNDLE)
- **7-Zip (optional)** - For better compression (C:\Program Files\7-Zip\7z.exe)

## How to use

### WSA (MSIXBUNDLE) Packaging

1. Drag WSA Msixbundle to `unpack.cmd` (or use `unpack <msixbundle>` command) to unpack.
2. Feel free modify package in `temp` folder. (Such as GappsScript or MagiskScript, or you can do something cooler.)
3. Check your architecture. If your architecture is "x64", you should replace the "libraries" folder's content with "libraries_64" folder's content. (Temporary)
4. Run `repack.cmd`.
5. The output files are in `out` folder.

### APK/XAPK Packaging

#### Universal Unpacker (Auto-Detects Format)
```
unpack_universal <package_file>
```
Supports `.apk`, `.xapk`, and `.msixbundle` formats.

#### APK-Specific Commands
```
apk_unpack.cmd <file.apk>     # Extract APK
apk_repack.cmd                # Repack APK from temp_apk folder
```

#### XAPK-Specific Commands
```
xapk_unpack.cmd <file.xapk>   # Extract XAPK with multi-architecture support
xapk_repack.cmd               # Repack XAPK from temp_xapk folder
```

**For detailed APK/XAPK documentation, see [APK_XAPK_README.md](APK_XAPK_README.md)**

## How to install

- Just drag Msixbundle file to `install.cmd` (or use `install <msixbundle>` command).

## Tutorial Video

- [Youtube](https://www.youtube.com/watch?v=54hpiwFQ20A)

## Feedback

- Telegram: [@WSA_Community](https://t.me/wsa_community)
- GitHub: [Issues](https://github.com/WSA-Community/WSAPackageTool/issues)

## TO-DOs

- [x] ~~Repack: Better way to generate installation utility instead of using Git Split~~
- [x] ~~Libraries: Add multi architecture support~~
- [x] ~~Repack: Don't remove work folder (`temp`)~~
- [x] ~~PackagingTool: Add APK support~~
- [x] ~~PackagingTool: Add XAPK support~~
- [ ] PackagingTool: Automatically identify Msix and Msixbundle
- [ ] PackagingTool: Add support for multi installation #7
- [ ] PackagingTool: GUI
- [ ] APK/XAPK: Signing support
- [ ] APK/XAPK: Alignment optimization

## Changelog

- 2.0:
	- Add APK (Android Package) support
	- Add XAPK (Extended Android Package) support
	- Add universal unpacker with auto-format detection
	- Add multi-architecture APK/XAPK support (arm, arm64, x86, x86_64)
	- Add APK/XAPK utility PowerShell module
	- New dedicated documentation for APK/XAPK workflow
- 1.3:
	- Keep unpack work folder after repack
- 1.2:
	- Add multi architecture support
	- Update prebuilt libraries
- 1.1:
	- Better way to generate installation utility instead of using Git Split
- 1.0:
	- First ver
- 1.1:
	- Better way to generate installation utility instead of using Git Split
- 1.0:
	- First ver

## Credits

- [MlgmXyysd](https://github.com/MlgmXyysd)
- [XiaoMengXinX](https://github.com/XiaomengxinX)

## License

No license. All rights are reserved.
