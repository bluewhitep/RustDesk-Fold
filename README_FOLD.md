# RustDesk Fold

RustDesk Fold is an Android foldable-focused fork of RustDesk. It keeps the
normal RustDesk mobile remote-control path intact, while adding a Fold Input
Pane for large-screen and foldable Android devices.

This repository is intended to build a separate Android application:

| Item | Value |
| --- | --- |
| Android applicationId | `com.rustdesk.fold` |
| App name | `RustDesk Fold` |
| Target SDK | `35` |
| Primary target | Android arm64 foldable devices |
| Release APK | `flutter/build/app/outputs/flutter-apk/app-release.apk` |

## Main Fold Features

- Fold Remote Pane plus Input Pane split layout.
- Portrait Fold layout forces top/bottom panes.
- Landscape Fold layout follows hinge/orientation rules.
- Remote Pane keeps RustDesk's original touch behavior.
- Input Pane includes a Fold toolbar, trackpad, and virtual keyboard.
- Remote IME / Key Events is the default Fold virtual keyboard input mode.
- Text Injection remains available as a compatibility input mode.
- Three-layer Fold keyboard:
  - system keys
  - standard English/numeric keys
  - symbols
- Target OS setting for Mac, Windows, and Linux modifier labels/shortcuts.
- Trackpad wheel mode:
  - tap wheel area for middle click
  - long-press wheel area to enter wheel-scroll mode
  - drag the trackpad to send vertical/horizontal scroll
  - tap wheel area again to exit wheel-scroll mode

## Build

Install Flutter, Rust, `cargo-ndk`, and Android NDK first. `ANDROID_NDK_HOME`
or `ANDROID_NDK_ROOT` must point to the installed NDK.

From this repository root:

```bash
cd flutter
flutter analyze
cd ..
bash tools/dev/build_android_arm64_release.sh
```

The release APK is generated at:

```text
flutter/build/app/outputs/flutter-apk/app-release.apk
```

## GitHub Auto Update

The default branch includes `.github/workflows/fold-upstream-auto-update.yml`.
It checks official RustDesk tags on a daily schedule and can also be started
manually from GitHub Actions. When a newer tag is found, the workflow rebases
the Fold branch, builds the Android arm64 release APK, uploads the APK artifact,
and opens or updates an upstream-sync pull request.

The active Fold branch is `foldable-split-keyboard-main`. See
[UPSTREAM_RELEASE_WORKFLOW.md](UPSTREAM_RELEASE_WORKFLOW.md) for the maintained
upstream update, self-hosted runner validation, merge, tag, and GitHub Release
process.

Configure these repository secrets before expecting the workflow to complete a
signed release build:

```text
FOLD_ANDROID_KEYSTORE_BASE64
FOLD_ANDROID_KEY_ALIAS
FOLD_ANDROID_STORE_PASSWORD
FOLD_ANDROID_KEY_PASSWORD
```

The workflow intentionally fails fast when any signing secret is missing. This
keeps cloud builds aligned with the release-only install policy below instead
of silently falling back to debug signing.

## Device Install Policy

Do not install debug APKs for this fork. For device testing, keep app data and
install only the release APK:

```bash
adb install -r flutter/build/app/outputs/flutter-apk/app-release.apk
```

Do not use:

- `app-debug.apk`
- `adb uninstall com.rustdesk.fold`
- commands that clear app data

The release APK must be signed with the same local Fold release keystore to
support state-preserving updates.

## Upstream Sync

This fork is kept as a small patch stack above official RustDesk. See
[UPGRADE_FOLD.md](UPGRADE_FOLD.md) for the recommended upstream rebase flow,
including `git range-diff`, `flutter analyze`, and arm64 release build checks.

High-risk areas during upstream rebases:

- `flutter/lib/mobile/pages/remote_page.dart`
- `flutter/lib/mobile/widgets/foldable_remote_*.dart`
- `flutter/lib/models/input_model.dart`
- `flutter/lib/models/model.dart`
- `src/lang/en.rs`
- `src/lang/cn.rs`
- `src/lang/tw.rs`

## Notes

- This fork does not remove RustDesk's user-facing remote-control prompts or
  authorization behavior.
- Android signing material and local keystore files should stay outside tracked
  source files.
- Rust native/core code should remain untouched unless a Fold feature cannot be
  implemented through existing Flutter/RustDesk interfaces.
