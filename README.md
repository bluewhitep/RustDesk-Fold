# RustDesk Fold

RustDesk Fold is an Android foldable-focused build based on RustDesk. It keeps
RustDesk mobile remote-control behavior as the base and adds a Fold Input Pane
for large-screen and foldable Android devices.

This is an independent customized build. It is not an official RustDesk release.

## Package Identity

| Item | Value |
| --- | --- |
| Android applicationId | `com.rustdesk.fold` |
| App name | `RustDesk Fold` |
| Target SDK | `35` |
| Primary target | Android arm64 foldable devices |
| Release APK path | `flutter/build/app/outputs/flutter-apk/app-release.apk` |

## Fold Features

- Fold Remote Pane plus Input Pane split layout.
- Portrait Fold layout uses top and bottom panes.
- Landscape Fold layout follows hinge and orientation rules.
- Remote Pane preserves RustDesk's normal mobile touch behavior.
- Input Pane includes a Fold toolbar, trackpad, and virtual keyboard.
- Remote IME / Key Events is the default Fold virtual keyboard input mode.
- Text Injection remains available as a compatibility input mode.
- Three-layer Fold keyboard: system keys, standard keys, and symbols.
- Target OS setting for Mac, Windows, and Linux modifier labels.
- Trackpad wheel mode for middle click and wheel-style scrolling.

## Build

Release builds are produced manually from a trusted local maintainer
environment. GitHub Actions are not used as the release gate.

Use a real build path without shell-sensitive characters such as parentheses
when preparing native Android dependencies.

```bash
cd flutter
flutter analyze
cd ..
bash tools/dev/build_android_arm64_release.sh
```

Verify the release APK before installing or publishing it:

```bash
bash tools/release/verify_android_release_apk.sh \
  flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Install

Install only the release APK for device testing:

```bash
adb install -r flutter/build/app/outputs/flutter-apk/app-release.apk
```

Do not install debug APKs, uninstall `com.rustdesk.fold`, or clear app data
during normal update testing.

## Documentation

- [README_FOLD.md](README_FOLD.md): Fold feature, build, install, and
  maintenance overview.
- [RELEASE_FOLD_MANUAL.md](RELEASE_FOLD_MANUAL.md): manual review, trusted
  local build, APK verification, tag, and GitHub Release process.
- [UPGRADE_FOLD.md](UPGRADE_FOLD.md): manual upstream update and validation
  flow.
- [FOLD_PUBLIC_IMPORT_STRATEGY.md](FOLD_PUBLIC_IMPORT_STRATEGY.md): clean public
  snapshot and future upstream-submodule experiment plan.
- [UPSTREAM.md](UPSTREAM.md): upstream RustDesk attribution and baseline notes.

## Release Policy

RustDesk Fold release artifacts should be published only from this repository's
GitHub Releases after manual review, local release build, APK verification, and
tag creation pass.

The repository intentionally does not track `.github/workflows/` for release
builds and must not attach a public self-hosted runner.

## Upstream

RustDesk Fold is based on official RustDesk source code. See
[UPSTREAM.md](UPSTREAM.md) for attribution, baseline, and update notes.

## License

RustDesk Fold follows the upstream RustDesk license. See [LICENCE](LICENCE).
