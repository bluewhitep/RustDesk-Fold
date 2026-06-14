# RustDesk Fold Upstream Upgrade Guide

This branch carries a small Fold-specific patch stack on top of the official
RustDesk Android/Flutter code. Keep the official code path easy to rebase:
avoid broad refactors, keep Rust native/core changes out of the Fold work unless
there is no Flutter-side interface, and validate the normal phone path after
every upstream sync.

## Current Branch Shape

- Active Fold branch: `foldable-split-keyboard-dev`
- Official upstream remote: `origin` (`https://github.com/rustdesk/rustdesk.git`)
- Personal push remote: `github`
- Manual backup remote: `backup`
- Stable Fold baseline tag: `fold-stable-20260613`

The Fold stack is currently expected to sit above `master` / `origin/master`.
Before rebasing, confirm the tree is clean:

```bash
cd /media/bluewhite/750\(1.2T\)/codex-ws/RustDesk-Android-Fold/rustdesk-fold
git status
git branch --show-current
git log --oneline --decorate master..HEAD
git log --oneline --decorate origin/master..HEAD
git diff --name-status master..HEAD
```

## One-Time Conflict Memory

This repository should keep `rerere` enabled so Git can remember repeated
conflict resolutions across future RustDesk upstream rebases:

```bash
git config rerere.enabled true
git config --get rerere.enabled
```

## Upgrade Procedure

Capture the old patch stack before updating `master`:

```bash
cd /media/bluewhite/750\(1.2T\)/codex-ws/RustDesk-Android-Fold/rustdesk-fold
git status
old_base=$(git merge-base master HEAD)
old_head=$(git rev-parse HEAD)
```

Fetch official upstream and update the local `master` with a fast-forward only:

```bash
git fetch origin
git checkout master
git merge --ff-only origin/master
```

Rebase the Fold branch onto the new official base:

```bash
git checkout foldable-split-keyboard-dev
git rebase master
```

If conflicts occur:

1. Keep normal RustDesk phone behavior intact.
2. Preserve Fold-only hooks instead of moving logic into shared official paths.
3. Prefer the upstream implementation for unrelated official UI/input changes.
4. Reapply only the Fold-specific behavior needed for this branch.
5. Use `git status` and `git diff` before `git rebase --continue`.

After a successful rebase, compare the old patch stack with the new one:

```bash
git range-diff "$old_base..$old_head" "master..HEAD"
```

The range-diff should show the Fold commits as equivalent or explainable. If a
Fold commit appears heavily rewritten, inspect the relevant file before building.

## Validation Commands

Run analysis and the arm64 release build from the repository root:

```bash
cd /media/bluewhite/750\(1.2T\)/codex-ws/RustDesk-Android-Fold/rustdesk-fold
cd flutter
flutter analyze
cd ..
bash tools/dev/build_android_arm64_release.sh
```

Release APK path:

```bash
flutter/build/app/outputs/flutter-apk/app-release.apk
```

State-preserving device install command:

```bash
adb install -r flutter/build/app/outputs/flutter-apk/app-release.apk
```

Do not install a debug APK, do not uninstall `com.rustdesk.fold`, and do not
clear app data during upgrade validation.

## Required Acceptance Checks

- Normal phone remote-control path still uses the official RustDesk behavior.
- Fold landscape layout still shows the Remote Pane and Input Pane correctly.
- Fold portrait layout still forces top/bottom panes.
- Fold Remote Pane still receives original touch operations.
- Fold Input Pane still shows toolbar plus keyboard; mouse mode also shows the
  trackpad.
- Remote IME / Key Events remains the default Fold virtual keyboard input mode.
- Text Injection remains available from `Target OS`.
- Language switching shortcuts release all modifiers after sending.
- After language switching, typing letters such as `n i h a o` still reaches the
  remote IME as key events.
- Toolbar settings entry still opens Fold Target OS/input settings.
- Pane ratio editing still shows the temporary small drag handle and preview.
- Release APK remains signed with the same Fold release keystore so
  `adb install -r` can update the existing app.

## High-Risk Files During Rebases

The current Fold implementation is intentionally localized, but much of it still
lives in:

- `flutter/lib/mobile/pages/remote_page.dart`
- `flutter/lib/models/input_model.dart`
- `flutter/lib/models/model.dart`
- `src/lang/en.rs`
- `src/lang/cn.rs`
- `src/lang/tw.rs`

`remote_page.dart` contains both official remote-page behavior and the Fold
Input Pane additions. This makes rebases more likely to conflict when upstream
changes mobile remote UI or input handling.

## Future Low-Risk Split Recommendations

Do not split these during an upstream conflict unless the conflict itself makes
it necessary. For a dedicated cleanup pass, consider moving only pure or
callback-driven Fold pieces first:

- Fold enums, shortcut data, and key-label helpers into a small Fold input model
  helper file.
- Stateless Fold widgets such as the Input Pane toolbar into a Fold UI helper
  file, with callbacks still owned by `RemotePage`.
- Trackpad widget code into a Fold input widget file if its dependencies remain
  limited to `ffi` and callbacks.

Keep the following in `RemotePage` until there is a safer boundary:

- Session lifecycle hooks.
- Canvas viewport override setup/cleanup.
- Official toolbar/options integration.
- Remote IME key event queue and modifier release state.
- Any logic that directly touches `inputModel`, `ffi`, `bind`, or `sessionId`.
