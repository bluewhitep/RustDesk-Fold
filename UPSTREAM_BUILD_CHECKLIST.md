# RustDesk Fold Upstream Build Checklist

适用对象：Maintainer
适用场景：RustDesk upstream tag 升级后重新构建 Android Fold release APK
状态：Active

## 背景

2026-07-09 的 `v1.4.9` 第一次测试包漏掉了最新 Fold 补丁。

原因不是官方 RustDesk `1.4.9` 删除了 Fold 功能，而是构建时用了本地旧的
`foldable-split-keyboard-main`。当时本地分支停在 `9a5c93993`，而 GitHub
Fold 主分支已经到 `00edb1e13`，本地落后 39 个提交。缺失提交里包含：

```text
76a1e9ab2 fix: refine fold touchpad input settings
```

这个提交包含设置页 `About RustDesk Fold`、Fold GitHub 链接、触控板触摸/长按
和 haptic 强度相关调整。下次升级前必须确认构建树包含 GitHub Fold 主分支的最新
补丁栈。

## 升级前必查

从仓库根目录执行：

```bash
git fetch origin master
git fetch origin tag <version>
git fetch github foldable-split-keyboard-main
```

确认本地 Fold 主分支和 GitHub Fold 主分支是否一致：

```bash
git rev-parse foldable-split-keyboard-main github/foldable-split-keyboard-main
git rev-list --left-right --count foldable-split-keyboard-main...github/foldable-split-keyboard-main
```

如果右侧计数不为 `0`，说明 GitHub Fold 主分支有本地未包含的提交。不要直接用本地
`foldable-split-keyboard-main` 构建 release APK。

重点查看缺失提交是否触及 Fold 功能文件：

```bash
git log --oneline foldable-split-keyboard-main..github/foldable-split-keyboard-main -- \
  flutter/lib/mobile/pages/remote_page.dart \
  flutter/lib/mobile/pages/settings_page.dart \
  flutter/lib/mobile/widgets/foldable_remote_ime.dart \
  flutter/lib/mobile/widgets/foldable_remote_input_pane.dart \
  flutter/android/app/src/main/AndroidManifest.xml \
  flutter/android/app/src/main/kotlin/com/carriez/flutter_hbb/MainActivity.kt \
  src/lang/template.rs \
  src/lang/cn.rs \
  src/lang/tw.rs
```

## 构建树要求

正确构建来源必须是：

```text
official RustDesk tag, for example 1.4.9
+ latest github/foldable-split-keyboard-main Fold patch stack
```

不要只使用 stale local `foldable-split-keyboard-main`。

如果为了快速修包只补缺失提交，也必须至少确认这些标记存在：

```bash
rg -n "About RustDesk Fold|_foldGitHubUrl|_rustDeskHomeUrl" flutter/lib/mobile/pages/settings_page.dart
rg -n "_foldHapticStrengthPercent|hapticStrengthPercent|_performFoldHapticFeedback" \
  flutter/lib/mobile/pages/remote_page.dart \
  flutter/lib/mobile/widgets/foldable_remote_input_pane.dart
rg -n "Trackpad Left|Trackpad Right" src/lang/template.rs src/lang/cn.rs src/lang/tw.rs
```

## Release APK 验证

构建前先生成 bridge 并跑 Flutter 静态检查：

```bash
flutter_rust_bridge_codegen --rust-input ./src/flutter_ffi.rs --dart-output ./flutter/lib/generated_bridge.dart
cd flutter
flutter pub get
flutter analyze
cd ..
```

构建 release APK：

```bash
bash tools/dev/build_android_arm64_release.sh
```

验证 APK：

```bash
bash tools/release/verify_android_release_apk.sh \
  flutter/build/app/outputs/flutter-apk/app-release.apk
```

必须确认：

- `applicationId` 是 `com.rustdesk.fold`
- label 是 `RustDesk Fold`
- `versionName` 是目标 RustDesk 版本
- `targetSdk` 是 `35`
- ABI 是 `arm64-v8a`
- release 签名与上一版测试包一致

## 设备安装规则

测试安装只使用 release APK：

```bash
adb install -r <release-apk>
```

不要安装 `app-debug.apk`。不要卸载 `com.rustdesk.fold`。不要清除 app data，除非明确
要做破坏性重置测试。

## 事故复盘要点

- 第一次 `v1.4.9` 包可构建、可安装、包名和签名也正确，但漏了 GitHub Fold 主分支的
  最新补丁。
- 包名和签名一致只能证明 Android 不会把它当成另一个 app；不能证明 Fold 功能补丁
  已进入构建树。
- 以后 release 前必须同时验证 upstream tag 和 Fold fork branch freshness。
