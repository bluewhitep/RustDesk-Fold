# RustDesk Fold Upstream Upgrade Guide

This branch carries a small Fold-specific patch stack on top of the official
RustDesk Android/Flutter code. Keep the official code path easy to rebase:
avoid broad refactors, keep Rust native/core changes out of the Fold work unless
there is no Flutter-side interface, and validate the normal phone path after
every upstream sync.

## Current Branch Shape

- Active Fold branch: `foldable-split-keyboard-main`
- Public repository remote: `origin` usually points to this RustDesk Fold
  repository.
- Official upstream remote: add `upstream`
  (`https://github.com/rustdesk/rustdesk.git`) in maintainer workspaces.
- Optional private backup remote: `backup`
- Stable Fold baseline tag: `fold-stable-20260613`

The release build does not fetch the latest upstream RustDesk source during
compilation. Maintainers must update the checked-out source first, validate it,
and then build the APK.

The Fold stack is expected to sit above the official upstream default branch.
Before rebasing, confirm the tree is clean and the upstream remote exists:

```bash
cd <workspace>/rustdesk-fold
git status
git branch --show-current
git remote -v
git ls-remote --heads upstream master
```

## One-Time Conflict Memory

This repository should keep `rerere` enabled so Git can remember repeated
conflict resolutions across future RustDesk upstream rebases:

```bash
git config rerere.enabled true
git config --get rerere.enabled
```

## Upgrade Procedure

Capture the current patch stack before updating from upstream:

```bash
cd <workspace>/rustdesk-fold
git status
git remote get-url upstream >/dev/null 2>&1 || \
  git remote add upstream https://github.com/rustdesk/rustdesk.git
git fetch upstream
old_base=$(git merge-base upstream/master HEAD)
old_head=$(git rev-parse HEAD)
```

Create an update branch and rebase the Fold snapshot onto the latest official
RustDesk `master`:

```bash
git fetch upstream
git switch -c chore/update-rustdesk-x-y-z
git rebase upstream/master
```

If you already created the update branch earlier, switch to it instead:

```bash
git switch chore/update-rustdesk-x-y-z
git rebase upstream/master
```

If conflicts occur:

1. Keep normal RustDesk phone behavior intact.
2. Preserve Fold-only hooks instead of moving logic into shared official paths.
3. Prefer the upstream implementation for unrelated official UI/input changes.
4. Reapply only the Fold-specific behavior needed for this branch.
5. Use `git status` and `git diff` before `git rebase --continue`.

After a successful rebase, compare the old patch stack with the new one:

```bash
git range-diff "$old_base..$old_head" "upstream/master..HEAD"
```

The range-diff should show the Fold commits as equivalent or explainable. If a
Fold commit appears heavily rewritten, inspect the relevant file before building.

## Validation

After a successful rebase, use
[RELEASE_FOLD_MANUAL.md](RELEASE_FOLD_MANUAL.md) as the single source of truth
for analysis, arm64 release build, APK verification, local test artifact copy,
and state-preserving ADB install.

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
- Release publication follows `RELEASE_FOLD_MANUAL.md`; do not use GitHub
  Actions or a self-hosted runner as the release gate.

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
