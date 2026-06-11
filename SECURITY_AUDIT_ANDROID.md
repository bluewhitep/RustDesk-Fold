# RustDesk Fold Android APK Security Audit

Generated: 2026-06-12

This report documents a local self-signed arm64 release APK build and a manifest/permission audit. Play Protect 的恶意程序提示不能通过本地构建完全保证消除；本报告只用于提高构建规范性和检查明显异常权限。

## Build Outputs

| Item | Value |
| --- | --- |
| Debug APK | `/media/bluewhite/750(1.2T)/codex-ws/RustDesk-Android-Fold/rustdesk/flutter/build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK | `/media/bluewhite/750(1.2T)/codex-ws/RustDesk-Android-Fold/rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk` |
| Release APK size | 28 MB |
| Release native ABI | `arm64-v8a` |
| Package | `com.rustdesk.fold` |
| App name | `RustDesk Fold` |
| versionCode | `65` |
| versionName | `1.4.7` |
| minSdkVersion | `22` |
| targetSdkVersion | `35` |
| compileSdkVersion | `35` |

## Signing

| Item | Value |
| --- | --- |
| Keystore | `/media/bluewhite/750(1.2T)/codex-ws/RustDesk-Android-Fold/.dev/keystores/rustdesk-fold-release.jks` |
| Local properties | `/media/bluewhite/750(1.2T)/codex-ws/RustDesk-Android-Fold/.dev/keystores/key.properties` |
| Alias | `rustdesk-fold` |
| Key algorithm | RSA 3072 |
| Certificate DN | `CN=RustDesk Fold Local Release, OU=Local Build, O=RustDesk Fold, L=Local, ST=Local, C=US` |
| SHA-256 fingerprint | `B2:5B:5A:0E:0F:8E:C7:8B:B4:72:74:EA:23:C7:89:87:BF:3A:97:C6:8A:6B:99:BD:A9:A1:54:AB:B6:B3:77:14` |
| APK signature schemes | v1: true, v2: true, v3: false, v3.1: false, v4: false |

Passwords are stored only in the local `.dev/keystores/key.properties` file and are not written into tracked Gradle files.

## APK Badging Summary

Command:

```bash
aapt dump badging rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```

Relevant output:

```text
package: name='com.rustdesk.fold' versionCode='65' versionName='1.4.7' platformBuildVersionName='15' platformBuildVersionCode='35' compileSdkVersion='35' compileSdkVersionCodename='15'
sdkVersion:'22'
targetSdkVersion:'35'
application-label:'RustDesk Fold'
launchable-activity: name='com.carriez.flutter_hbb.MainActivity'
native-code: 'arm64-v8a'
```

## APK Permissions

Command:

```bash
aapt dump permissions rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```

Output:

```text
package: com.rustdesk.fold
uses-permission: name='android.permission.MANAGE_EXTERNAL_STORAGE'
uses-permission: name='android.permission.POST_NOTIFICATIONS'
uses-permission: name='android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'
uses-permission: name='android.permission.READ_EXTERNAL_STORAGE'
uses-permission: name='android.permission.WRITE_EXTERNAL_STORAGE'
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
uses-permission: name='android.permission.FOREGROUND_SERVICE'
uses-permission: name='android.permission.RECORD_AUDIO'
uses-permission: name='android.permission.WAKE_LOCK'
uses-permission: name='android.permission.RECEIVE_BOOT_COMPLETED'
uses-permission: name='android.permission.SYSTEM_ALERT_WINDOW'
permission: com.rustdesk.fold.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='com.rustdesk.fold.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
uses-permission: name='android.permission.CAMERA'
```

## Manifest Component Summary

Command:

```bash
apkanalyzer manifest print rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```

Summary:

| Component type | Component | Exported / permission | Notes |
| --- | --- | --- | --- |
| Application | `com.carriez.flutter_hbb.MainApplication` | n/a | `requestLegacyExternalStorage=true` |
| Activity | `com.carriez.flutter_hbb.MainActivity` | `exported=true` | Launcher activity and `rustdesk://` deep link |
| Activity | `com.carriez.flutter_hbb.PermissionRequestTransparentActivity` | not explicitly exported | Transparent permission flow activity |
| Activity | `io.flutter.plugins.urllauncher.WebViewActivity` | `exported=false` | URL launcher WebView activity |
| Activity | `com.journeyapps.barcodescanner.CaptureActivity` | not explicitly exported | Barcode/QR scanner activity |
| Service | `com.carriez.flutter_hbb.InputService` | `exported=false`, `android.permission.BIND_ACCESSIBILITY_SERVICE` | Accessibility service used for input/control after user authorization |
| Service | `com.carriez.flutter_hbb.MainService` | not explicitly exported | `foregroundServiceType=mediaProjection` |
| Service | `com.carriez.flutter_hbb.FloatingWindowService` | not explicitly exported | Floating overlay service |
| Service | `com.google.android.gms.metadata.ModuleDependencies` | `exported=false` | Google Play services metadata |
| Receiver | `com.carriez.flutter_hbb.BootReceiver` | `exported=true` | Handles `BOOT_COMPLETED`, `QUICKBOOT_POWERON`, and `com.rustdesk.fold.DEBUG_BOOT_COMPLETED` |
| Receiver | `androidx.profileinstaller.ProfileInstallReceiver` | `exported=true`, `android.permission.DUMP` | AndroidX profile installer receiver |
| Provider | `io.flutter.plugins.imagepicker.ImagePickerFileProvider` | `exported=false` | Image picker file provider |
| Provider | `androidx.startup.InitializationProvider` | `exported=false` | AndroidX startup initializers |

## Sensitive Permission Review

| Permission / declaration | Present | Possible use | Looks necessary | Further review |
| --- | --- | --- | --- | --- |
| `android.permission.RECORD_AUDIO` | Yes | Remote audio, audio capture, session communication | Likely yes for remote desktop/audio features | Confirm UX shows runtime permission prompt and feature copy is explicit |
| `android.permission.CAMERA` | Yes | QR/barcode scanning via `CaptureActivity`; possible camera workflows | Likely yes if QR scanning is retained | Confirm camera is only requested when scanner/camera feature is used |
| `android.permission.SYSTEM_ALERT_WINDOW` | Yes | Floating controls/window overlay for remote session/service UX | Likely yes | Keep explicit user authorization; do not hide overlay behavior |
| `android.permission.FOREGROUND_SERVICE` | Yes | Keeps screen capture/control service visible and running | Likely yes | For Android 14/15 runtime behavior, review whether a specific foreground service type permission such as media projection is required |
| `android.permission.MANAGE_EXTERNAL_STORAGE` | Yes | Broad file management / transfer workflows | Possibly necessary for full file manager behavior | High-sensitivity permission; review whether narrower Storage Access Framework flows can cover any subset |
| `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Yes | Long-running remote access/session service reliability | Possibly necessary | Keep user-facing authorization and document why it is requested |
| `android.permission.REQUEST_INSTALL_PACKAGES` | No | n/a | n/a | No issue found |
| `android.permission.QUERY_ALL_PACKAGES` | No | n/a | n/a | No issue found |
| `android.permission.READ_MEDIA_*` | No | n/a | n/a | No issue found |
| `android.permission.BIND_ACCESSIBILITY_SERVICE` | Yes, as service permission on `InputService` | Accessibility-based input/control service | Likely yes for controlled remote input | Very sensitive; ensure user opt-in is explicit and not bypassed |
| `android.permission.READ_EXTERNAL_STORAGE` | Yes | Legacy storage read support | Possibly needed on older Android versions | Review alongside `MANAGE_EXTERNAL_STORAGE` |
| `android.permission.WRITE_EXTERNAL_STORAGE` | Yes | Legacy storage write support | Possibly needed on older Android versions | Review alongside `MANAGE_EXTERNAL_STORAGE` |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Yes | Optional start-on-boot behavior | Possibly needed if start-on-boot is a supported feature | Verify default is off and user setting gates startup |
| `android.permission.POST_NOTIFICATIONS` | Yes | Foreground service/session notifications on Android 13+ | Likely yes | Ensure notification permission prompt is user-visible |
| `android.permission.WAKE_LOCK` | Yes | Keep session/service active during remote operations | Possibly needed | Review power behavior and user settings |

## Notable Findings

1. The release APK package is `com.rustdesk.fold`, target SDK is `35`, app label is `RustDesk Fold`, and native code is limited to `arm64-v8a`.
2. No `REQUEST_INSTALL_PACKAGES`, `QUERY_ALL_PACKAGES`, or `READ_MEDIA_*` permission was found.
3. The APK contains expected remote desktop sensitive capabilities: audio capture, camera, overlay, foreground service, accessibility service, boot receiver, network access, and broad storage.
4. `BootReceiver` is exported and includes the custom action `com.rustdesk.fold.DEBUG_BOOT_COMPLETED` in the release manifest. The receiver code gates startup on the start-on-boot preference and overlay/battery grants, but the exported custom action should still be reviewed.
5. `MainService` declares `foregroundServiceType=mediaProjection`. With target SDK 35, test startup on Android 14/15 devices and review whether additional foreground service type declarations are required for runtime compatibility.
6. No Play Protect bypass, system-app impersonation, hidden remote-control behavior, removal of user authorization prompts, or new high-risk permission was added as part of this build/signing work.

## Verification Performed

```bash
git status --short
source .dev/env.sh
bash tools/dev/doctor_android_env.sh
aapt dump badging rustdesk/flutter/build/app/outputs/flutter-apk/app-debug.apk
bash tools/dev/build_android_arm64_debug.sh
flutter build apk --release --target-platform android-arm64
flutter analyze
aapt dump badging rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
aapt dump permissions rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
apkanalyzer manifest print rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
apksigner verify --verbose --print-certs rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```

`flutter analyze` completed with no issues.

## Low-permission Client-only Variant

Generated: 2026-06-12

This section documents the latest low-permission test APK. It overwrites the same release output path and is intended to test whether Play Protect's warning is primarily driven by sensitive Android host-side permissions and components. This is not a Play Protect bypass; it removes Android-controlled/host capability declarations and keeps the app identity unchanged.

### APK Identity

| Item | Value |
| --- | --- |
| Release APK | `/media/bluewhite/750(1.2T)/codex-ws/RustDesk-Android-Fold/rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk` |
| Package | `com.rustdesk.fold` |
| App name | `RustDesk Fold` |
| versionCode | `65` |
| versionName | `1.4.7` |
| minSdkVersion | `22` |
| targetSdkVersion | `35` |
| compileSdkVersion | `35` |
| Native ABI | `arm64-v8a` |
| Signing cert SHA-256 | `B2:5B:5A:0E:0F:8E:C7:8B:B4:72:74:EA:23:C7:89:87:BF:3A:97:C6:8A:6B:99:BD:A9:A1:54:AB:B6:B3:77:14` |

### Low-permission Badging Summary

```text
package: name='com.rustdesk.fold' versionCode='65' versionName='1.4.7' platformBuildVersionName='15' platformBuildVersionCode='35' compileSdkVersion='35' compileSdkVersionCodename='15'
sdkVersion:'22'
targetSdkVersion:'35'
application-label:'RustDesk Fold'
native-code: 'arm64-v8a'
```

### Low-permission APK Permissions

Command:

```bash
aapt dump permissions rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```

Output:

```text
package: com.rustdesk.fold
uses-permission: name='android.permission.POST_NOTIFICATIONS'
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
uses-permission: name='android.permission.WAKE_LOCK'
permission: com.rustdesk.fold.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='com.rustdesk.fold.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```

### Removed Permissions and Components

Removed from the final merged APK:

| Removed item | Method | Expected impact |
| --- | --- | --- |
| `android.permission.MANAGE_EXTERNAL_STORAGE` | Manifest merger `tools:node="remove"` | Broad local file manager / full file transfer workflows may be limited |
| `android.permission.READ_EXTERNAL_STORAGE` | Manifest merger `tools:node="remove"` | Legacy local file reads may be limited |
| `android.permission.WRITE_EXTERNAL_STORAGE` | Manifest merger `tools:node="remove"` | Legacy local file writes may be limited |
| `android.permission.SYSTEM_ALERT_WINDOW` | Manifest merger `tools:node="remove"` | Floating host controls/window overlay disabled |
| `android.permission.RECORD_AUDIO` | Manifest merger `tools:node="remove"` | Android-device microphone capture / host voice capture disabled |
| `android.permission.CAMERA` | Manifest merger `tools:node="remove"` | Camera/QR scanner flows may be unavailable |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Manifest merger `tools:node="remove"` | Start-on-boot disabled |
| `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Manifest merger `tools:node="remove"` | Battery optimization exemption request disabled |
| `android.permission.FOREGROUND_SERVICE` | Manifest merger `tools:node="remove"` | Android host screen-capture foreground service is not expected to work |
| `android.permission.BIND_ACCESSIBILITY_SERVICE` service declaration | Removed `InputService` manifest entry | Android controlled-side input service disabled |
| `.BootReceiver` | Removed receiver manifest entry | Boot and debug boot actions disabled |
| `MainService` `foregroundServiceType="mediaProjection"` | Removed attribute | Host-side media projection service type no longer declared |
| `android:requestLegacyExternalStorage="true"` | Removed application attribute | Legacy broad storage behavior disabled |

### Low-permission Manifest Component Summary

| Component type | Component | Exported / permission | Notes |
| --- | --- | --- | --- |
| Application | `com.carriez.flutter_hbb.MainApplication` | n/a | No `requestLegacyExternalStorage` |
| Activity | `com.carriez.flutter_hbb.MainActivity` | `exported=true` | Launcher activity and `rustdesk://` deep link |
| Activity | `com.carriez.flutter_hbb.PermissionRequestTransparentActivity` | not explicitly exported | Retained, but host media projection permissions are removed |
| Service | `com.carriez.flutter_hbb.MainService` | not explicitly exported | Retained without `foregroundServiceType`; Android host mode is expected to be impaired |
| Service | `com.carriez.flutter_hbb.FloatingWindowService` | not explicitly exported | Retained, but overlay permission is removed |
| Provider | `io.flutter.plugins.imagepicker.ImagePickerFileProvider` | `exported=false` | Plugin file provider retained |
| Service | `com.google.android.gms.metadata.ModuleDependencies` | `exported=false` | Google Play services metadata |
| Activity | `io.flutter.plugins.urllauncher.WebViewActivity` | `exported=false` | URL launcher WebView activity |
| Provider | `androidx.startup.InitializationProvider` | `exported=false` | AndroidX startup initializers |
| Receiver | `androidx.profileinstaller.ProfileInstallReceiver` | `exported=true`, `android.permission.DUMP` | AndroidX profile installer receiver |
| Activity | `com.journeyapps.barcodescanner.CaptureActivity` | not explicitly exported | QR scanner activity remains, but `CAMERA` permission is removed |

`BootReceiver` and `InputService` are not present in the low-permission merged manifest. `BIND_ACCESSIBILITY_SERVICE`, `MANAGE_EXTERNAL_STORAGE`, `SYSTEM_ALERT_WINDOW`, `RECEIVE_BOOT_COMPLETED`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, `RECORD_AUDIO`, and `CAMERA` are not present in the final APK permission output.

### Likely Lost Functionality

- Android device acting as a controlled host: screen capture, remote input, accessibility input, and service startup are expected to be disabled or fail.
- Start on boot and battery-optimization exemption are disabled.
- Floating overlay controls are disabled.
- Android microphone capture / voice capture from the Android device is disabled.
- QR scanning/camera flows may fail because `CAMERA` is removed.
- Broad local file management through legacy/all-files storage may be limited.

Expected to remain buildable for this test variant:

- Android client connecting to remote computers.
- Fold/split-screen keyboard UI and client-side Flutter workflows.
- Network connectivity and app notifications.

### Low-permission Verification Performed

```bash
source .dev/env.sh
flutter analyze
bash tools/dev/build_android_arm64_debug.sh
flutter build apk --release --target-platform android-arm64
aapt dump badging rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
aapt dump permissions rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
apkanalyzer manifest print rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
apksigner verify --verbose --print-certs rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```

`flutter analyze`, the arm64 native/debug build, and the arm64 release build completed successfully.

### Install Command

```bash
adb install -r /media/bluewhite/750\(1.2T\)/codex-ws/RustDesk-Android-Fold/rustdesk/flutter/build/app/outputs/flutter-apk/app-release.apk
```
