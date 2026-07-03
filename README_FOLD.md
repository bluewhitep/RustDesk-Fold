# RustDesk Fold

RustDesk Fold, based on RustDesk, is an Android foldable-focused build. It
keeps the normal RustDesk mobile remote-control path intact, while adding a
Fold Input Pane for large-screen and foldable Android devices.

This is an independent customized build and is not an official RustDesk release.

This repository is intended to build a separate Android application:

| Item | Value |
| --- | --- |
| Android applicationId | `com.rustdesk.fold` |
| App name | `RustDesk Fold` |
| Target SDK | `35` |
| Primary target | Android arm64 foldable devices |
| Release APK | See `RELEASE_FOLD_MANUAL.md` |

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

## Project Documents

Fold-specific process, release, upgrade, and maintenance documents are kept as
root-level Markdown files in this repository. Add new Fold maintainer documents
at the project root and link them from this section.

- [RELEASE_FOLD_MANUAL.md](RELEASE_FOLD_MANUAL.md): single source for manual
  maintainer review, trusted local APK build, direct APK install, maintainer
  ADB testing, verification, tag, and GitHub Release process.
- [FOLD_PUBLIC_IMPORT_STRATEGY.md](FOLD_PUBLIC_IMPORT_STRATEGY.md): public
  baseline, clean-history import, and upstream submodule tradeoff plan.
- [UPGRADE_FOLD.md](UPGRADE_FOLD.md): manual upstream rebase and upgrade flow.

## Manual Build, Install, and Release Policy

This repository does not use GitHub Actions for release builds. Do not add
workflow files under `.github/workflows/`, and do not use a public repository
self-hosted runner for untrusted fork or pull request code.

The build uses the source tree already checked out in this repository; it does
not fetch RustDesk upstream code during compilation. Maintainers update the Fold
source from upstream first, then build and verify a release APK.

The active Fold branch is `foldable-split-keyboard-main`. See
[RELEASE_FOLD_MANUAL.md](RELEASE_FOLD_MANUAL.md) for manual maintainer review,
trusted local APK build, APK verification, direct APK install, maintainer ADB
testing, tag creation, APK naming, and GitHub Release publication.

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
