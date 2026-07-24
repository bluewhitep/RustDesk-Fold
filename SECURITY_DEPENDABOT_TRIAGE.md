# Dependabot Alert Triage

Current remediation date: 2026-07-24
Current release target: `v_1.4.9_batch_2`
Current fix branch: `hotfix/dependency-security-1-4-9-batch-2`
Current 1.4.9 baseline: `89b4651c5940a73b9c655e5a932a8aa05c477a8c`

## Batch 2 Security Reapplication

The RustDesk 1.4.9 source update replaced the dependency files that had carried
the earlier downstream security fixes. Batch 2 reapplies those fixes on the
current 1.4.9 source without changing Fold input behavior or Android runtime
features.

Applied changes:

- Raised the declared Rust baseline to `1.88` because the patched
  `time 0.3.47` dependency requires Rust 1.88.
- Restored the local `pam` and `keepawake-rs` patches, removing the vulnerable
  `users 0.10.0` and `git2 -> libgit2-sys` paths.
- Added a minimal local `users 0.11.1` compatibility adapter that re-exports
  maintained `uzers 0.12.2` for the pinned `hbb_common` build dependency.
- Updated compatible root lockfile dependencies, including `openssl 0.10.80`,
  `rustls-webpki 0.103.13`, `quinn-proto 0.11.15`, `bytes 1.12.0`,
  `crossbeam-channel 0.5.15`, `tracing-subscriber 0.3.20`, `rand 0.9.4`,
  `time 0.3.47`, `idna 1.0.3`, `crossbeam-epoch 0.9.20`, `anyhow 1.0.103`,
  and `memmap2 0.9.11`.
- Updated Linux-only `fuser` to `0.16`.
- Removed the stale workspace-member lockfile
  `libs/virtual_display/Cargo.lock`.
- Removed the unused `quest -> rpassword 2.1.0` example dependency and replaced
  its terminal input calls with the Rust standard library.

Local dependency evidence:

- The Android arm64 dependency graph selects `users 0.11.1`,
  `openssl 0.10.80`, `rustls-webpki 0.103.13`, and `time 0.3.47`.
- `users 0.10.0`, `users 0.11.0`, `git2`, `libgit2-sys`, `quest`, and
  `rpassword` are absent from the locked Android arm64 graph.
- `cargo check --locked --target aarch64-linux-android --features
  flutter,hwcodec` passed with Rust 1.88.
- Focused checks for the `users` adapter and the modified `record-screen`
  example passed.

Local Android release validation:

- `flutter analyze` passed with no issues.
- All 9 focused modifier-key regression tests passed.
- The Rust Android arm64 release library and signed Flutter release APK built
  successfully.
- APK verification passed for application ID `com.rustdesk.fold`, application
  label `RustDesk Fold`, version `1.4.9` (`versionCode 69`), target SDK `35`,
  and native ABI `arm64-v8a`.
- The signing certificate SHA-256 digest matches the Batch 1 release:
  `b25b5a0e0f8ec78bb47274ea23c78987bf3a97c68a6b99bda9a154abb6b37714`.
- The pre-publication APK SHA-256 is
  `f1a88c761bc006f0a4e36aa003c649879c02a6cf223d81eea1eaae4028ad54f9`.

Fresh `cargo-audit` database results also report advisories that were not part
of the earlier GitHub alert set:

- `quick-xml 0.30.0`, `0.31.0`, and `0.37.5` require `>=0.41.0`. The first two
  versions are outside the Android graph; `0.37.5` is an Android build-time path
  through pinned upstream build dependencies. Resolving it requires coordinated
  parent dependency upgrades rather than a compatible lockfile update.
- `time 0.1.45` remains in the macOS-only `fruitbasket` path and is not selected
  for Android arm64.
- Unmaintained or unsound `atty 0.2.14` and `glib 0.18.5` remain in upstream
  build/desktop paths and require broader upstream dependency migration.

These residual items are recorded explicitly; this document does not claim a
repository-wide zero-advisory result. The Batch 2 release gate remains:

1. Flutter analysis and focused input tests pass.
2. The signed Android arm64 release APK builds and passes package verification.
3. The fix is merged to the GitHub default branch.
4. GitHub Dependabot completes its rescan and the result is reviewed before the
   release tag is created.

Future upstream source updates must preserve or deliberately reapply the
downstream dependency delta, followed by locked dependency checks, Android
release verification, and a new Dependabot scan.

Audit date: 2026-07-04
Scope: GitHub Dependabot open high, moderate, and low alerts for `bluewhitep/RustDesk-Fold`
Branch checked: `experiment/dependabot-high-alert-fixes`
Snapshot commit checked: `ec6007b7df60d9701cee167ae1484c7cf9691dda`
Official RustDesk baseline checked: `a2b79462ab63db2447a4f5c36e6257c74ae47230`

## Summary

The current high-severity Dependabot alerts are inherited from the imported
official RustDesk source baseline. They were not introduced by Fold-specific
Android, Flutter, packaging, or documentation changes.

Evidence:

- GitHub API reported 12 open high-severity alerts.
- The high alerts are limited to:
  - `Cargo.lock`
  - `libs/clipboard/Cargo.toml`
  - `libs/virtual_display/Cargo.lock`
- `git diff --name-status origin/master..HEAD -- Cargo.lock
  libs/clipboard/Cargo.toml libs/virtual_display/Cargo.lock` returned no
  changed files.
- The blob hashes for those three files are byte-for-byte identical between the
  official RustDesk baseline and the Fold snapshot:

| File | Official baseline blob | Fold snapshot blob |
|---|---|---|
| `Cargo.lock` | `8ec2d4a5327cbf7525b8dc7713b7613af002823c` | `8ec2d4a5327cbf7525b8dc7713b7613af002823c` |
| `libs/clipboard/Cargo.toml` | `afe2f2f3137af8561fd03e9bb1f3f6dcef4f1bab` | `afe2f2f3137af8561fd03e9bb1f3f6dcef4f1bab` |
| `libs/virtual_display/Cargo.lock` | `22fa681b23a3a1b29fadc041757a9de282f78284` | `22fa681b23a3a1b29fadc041757a9de282f78284` |

## Compatibility Position

Fixing these alerts should not prevent this repository from continuing to use
official RustDesk upstream source. It will, however, create a downstream
security-maintenance delta in lockfiles and possibly dependency constraints.

The `openssl` high-alert fix requires a minimum Rust toolchain increase for this
experiment branch. `openssl 0.10.79` is the lowest version that satisfies the
currently reported `rust-openssl` high alert requiring `>= 0.10.79`, and it
requires Rust 1.80. The public snapshot baseline declares Rust 1.75, so this is
an explicit compatibility tradeoff rather than a silent lockfile-only update.

Preferred fix strategy:

1. Keep fixes on a separate development branch first.
2. Prefer minimal dependency and lockfile updates.
3. Avoid changing RustDesk runtime code unless a dependency API change requires
   it.
4. Validate with `flutter analyze`, Android arm64 release build, and APK
   verification before merging.
5. During future upstream rebases, treat dependency-security lockfile conflicts
   as expected and re-run the same validation.

## High Alert Triage

| Package | Alert(s) | Manifest | Current version evidence | Android APK relevance | Triage conclusion | Preferred action |
|---|---|---|---|---|---|---|
| `openssl` | GHSA-8c75-8mhr-p7r9, GHSA-ghm9-cr32-g9qj, GHSA-hppc-g8h3-xhp3, GHSA-pqf5-4pqq-29f5, GHSA-xp3w-r5p5-63rr | `Cargo.lock` | `openssl 0.10.68` | Relevant. `cargo tree --target aarch64-linux-android --features flutter,hwcodec -i openssl` shows paths through `native-tls`, `tokio-native-tls`, `reqwest`, `tungstenite`, `hbb_common`, and `rustdesk`. | Upstream inherited and APK-path relevant. Treat as first-priority fix before formal release. | Update to a non-vulnerable `0.10.x` release, then rebuild APK. |
| `rustls-webpki` | GHSA-82j2-j2ch-gfr8 | `Cargo.lock` | `rustls-webpki 0.103.3` | Relevant. `cargo tree --target aarch64-linux-android --features flutter,hwcodec -i rustls-webpki` shows paths through `rustls`, `tokio-rustls`, `reqwest`, `rustls-platform-verifier`, `hbb_common`, and `rustdesk`. | Upstream inherited and APK-path relevant. Treat as first-priority fix before formal release. | Update to `0.103.13` or newer compatible patch, then rebuild APK. |
| `users` | GHSA-m65q-v92h-cm7q | `Cargo.lock` | `users 0.10.0` and `users 0.11.0` | Mixed. `users@0.11.0` appears in Android target build-dependency output through `hbb_common`; `users@0.10.0` appears in all-target output through Linux `pam`. | Upstream inherited. Android release risk appears build-time rather than APK runtime, but it is still present in the Android build graph. | Check whether a non-vulnerable crate version exists. If no patched version exists, document the limitation and monitor upstream/advisory state. |
| `fuser` | GHSA-cvmj-47v9-35m9 | `Cargo.lock`, `libs/clipboard/Cargo.toml` | `fuser 0.15.1`; `libs/clipboard/Cargo.toml` declares optional Linux-only `fuser = { version = "0.15", default-features = false, optional = true }` | Not Android APK runtime. Android target cargo tree did not match `fuser`; manifest limits it to `target_os = "linux"`. | Upstream inherited, Linux clipboard/file-copy path. Not a blocker for an Android-only test APK, but still a public-repo alert. | Try `fuser 0.16` on the experiment branch. Validate Linux clipboard code separately before claiming desktop support. |
| `libgit2-sys` | GHSA-22q8-ghmq-63vf | `Cargo.lock` | `libgit2-sys 0.14.2+1.5.1` | Build-time path, not APK runtime. `cargo tree --target all --features flutter,hwcodec -i libgit2-sys` shows `libgit2-sys -> git2 -> shadow-rs -> keepawake -> rustdesk`. | Upstream inherited build-dependency chain. Not expected to affect Android runtime behavior, but can affect build metadata tooling. | Try a compatible `git2` / `libgit2-sys` update. Stop if it requires broad upstream source changes. |
| `quinn-proto` | GHSA-6xvm-j4wr-6v98 | `Cargo.lock` | `quinn-proto 0.11.13` | Not selected in the checked Android target graph. `cargo tree --target aarch64-linux-android --features flutter,hwcodec -i quinn-proto` printed nothing. | Upstream inherited and currently appears to be stale or non-selected for the Android build target checked here. | Refresh the relevant lockfile/dependency graph if possible. If still unused, document as non-APK-path before dismissing. |
| `mio` | GHSA-r8w9-5wcg-vfj7 | `libs/virtual_display/Cargo.lock` | nested lockfile contains `mio 0.8.5`; current `cargo tree --manifest-path libs/virtual_display/Cargo.toml -i mio` resolves `mio 1.0.3`. | Not Android APK runtime; `virtual_display` is Windows-focused in the root manifest. | Upstream inherited nested lockfile alert. Current manifest resolution suggests the nested lockfile may be stale relative to current dependency resolution. | Refresh or update `libs/virtual_display/Cargo.lock`, then confirm the alert clears. |

## Experiment Branch Result

Branch: `experiment/dependabot-high-alert-fixes`

Applied changes:

- Raised root `Cargo.toml` `rust-version` from `1.75` to `1.80`.
- Updated `openssl` to `0.10.79`.
- Updated `openssl-sys` to `0.9.115`; newer `0.9.116` and `0.9.117` require
  Rust 1.80, and `0.9.115` works with the selected `openssl 0.10.79` lockfile.
- Updated `rustls-webpki` to `0.103.13`.
- Updated `rustls-pki-types` to `1.15.0`.
- Updated `tokio-rustls` to `0.26.4`.
- Updated `quinn-proto` to `0.11.15`.
- Updated Linux-only `fuser` from `0.15` to `0.16`.
- Replaced the direct Linux-only `hbb_common` dependency on `users` with
  `uzers 0.12.2` while preserving the crate name `users` in source.
- Removed stale `libs/virtual_display/Cargo.lock`; `libs/virtual_display` is a
  workspace member, so the root `Cargo.lock` is the lockfile used by normal
  workspace builds.
- Added local patched dependencies under
  `third_party/rustdesk-fold-patches/`.
- Replaced root Linux/macOS `keepawake` and Linux `pam` dependencies with local
  path dependencies:
  - `third_party/rustdesk-fold-patches/keepawake-rs`
  - `third_party/rustdesk-fold-patches/pam`

Vendored patch result:

- `pam` is vendored from `rustdesk-org/pam` at
  `7bfd25510202cd269292cbdd7c71f3977a6fd762`. The local patch replaces the
  optional `users` dependency with `uzers` while preserving the crate name used
  by source code.
- `keepawake-rs` is vendored from `rustdesk-org/keepawake-rs` at
  `64d568586dd16551d02120e19668d2b0fec8e3c9`. The local patch removes
  unused `shadow-rs` build metadata generation, which removes the
  `git2 -> libgit2-sys` alert chain.
- `cargo tree --locked --target all --features flutter,hwcodec -i users`
  returned no matching package.
- `cargo tree --locked --target all --features flutter,hwcodec -i libgit2-sys`
  returned no matching package.
- `cargo tree --locked --target all --features flutter,hwcodec -i git2`
  returned no matching package.
- `cargo tree --locked --target all --features flutter,hwcodec -i shadow-rs`
  returned no matching package.
- `rg -n 'name = "(users|libgit2-sys|git2|shadow-rs)"' Cargo.lock` returned
  no matches.

Local patch validation:

- `cargo check -p keepawake --locked --target x86_64-unknown-linux-gnu`
  passed.
- `cargo check -p pam --locked --features client --target
  x86_64-unknown-linux-gnu` could not complete on this machine because the
  system PAM development header `security/pam_appl.h` is not installed. The
  failure occurred in `pam-sys` bindgen before compiling the local `pam`
  wrapper code.

Android APK validation:

- Build command: `bash tools/dev/build_android_arm64_release.sh`
- Build environment override:
  - `VCPKG_ROOT=/tmp/rustdesk-fold-vcpkg.YuEc04/vcpkg`
  - `CARGO_TARGET_DIR=/tmp/rustdesk-fold-target-dependabot-high`
  - `TMPDIR=/tmp/rustdesk-fold-tmp-dependabot-high`
- Rust toolchain used: `rustc 1.80.0`
- Build result: passed.
- Build time: `11.296s` after cache reuse.
- APK verifier result: passed.
- Verified APK identity:
  - application ID: `com.rustdesk.fold`
  - application label: `RustDesk Fold`
  - target SDK: `35`
  - native ABI: `arm64-v8a`
- Test artifact:
  `artifacts/RustDesk-Fold-dependabot-high-alert-fixes-arm64-v8a-release-test.apk`
- Test artifact SHA-256:
  `b83cda20e99bdbefe16d6f61519d202f2a229230d4cb0592fa9cfc3b03190a9a`

## Release Gate

Do not publish a formal APK release while high-severity Android-path alerts
remain unresolved unless the release notes explicitly document the residual
risk and the maintainer accepts it. For public source release, also review the
moderate and low limitations below because GitHub reports alerts from the whole
lockfile, not only the Android APK target graph.

For this experiment branch, the checked lockfile no longer contains the
previously reported high-alert packages listed above, and the Android arm64
release APK build and verifier passed. A formal public release still requires a
GitHub Dependabot rescan after pushing or merging this branch, plus maintainer
review of the downstream vendored dependency patches and the remaining
non-Android or upstream-git dependency limitations.

For an experiment/test APK, use the development branch only and label the APK as
a test artifact, not a formal release.

## Moderate And Low Screenshot Triage

Source evidence:

- User-provided GitHub Dependabot UI screenshots on 2026-07-04 for:
  - `is:open severity:moderate`
  - `is:open severity:low`
- GitHub UI dependency check source: commit
  `7cdf3dbd251e83d2ca06fa1a4e1ee2614af82986`.
- Screenshot counts:
  - 16 open moderate alerts.
  - 14 open low alerts.
- GitHub API verification was not available in this environment because the
  active `gh` token did not expose the `security_events` scope. This section
  therefore uses the screenshots plus local Cargo evidence.

Important rescan note:

The local branch can only change source and lockfiles. GitHub Dependabot alert
counts will not change until this branch is pushed or merged into the branch
GitHub scans, and GitHub reruns dependency analysis.

| Package / source | Screenshot alert(s) | Local evidence after this pass | Triage conclusion |
|---|---|---|---|
| `openssl` | moderate `#7`, `#8`, `#30`, `#31`; low `#25` | `Cargo.lock` contains `openssl 0.10.79` and `openssl-sys 0.9.115`. | Already handled by the high-alert fix pass. Requires GitHub rescan to close alerts. |
| `rustls-webpki` | moderate `#17`; low `#18`, `#19` | `Cargo.lock` contains `rustls-webpki 0.103.13`. | Already handled by the high-alert fix pass. Requires GitHub rescan to close alerts. |
| `users` | moderate `#3` | `Cargo.lock` no longer contains a `users` package; Linux user lookup was moved to `uzers 0.12.2`. | Already handled by the high-alert fix pass. Requires GitHub rescan to close alerts. |
| `git2` | low `#14` | `Cargo.lock` no longer contains `git2` or `libgit2-sys` after vendoring `keepawake-rs` without `shadow-rs` build metadata. | Already handled by the high-alert fix pass. Requires GitHub rescan to close alert. |
| `libs/virtual_display/Cargo.lock` stale nested lockfile | moderate `#33`, `#36`, `#39`, `#41`; low `#34`, `#35`, `#37`, `#40`, `#42` | `libs/virtual_display/Cargo.lock` was removed. `libs/virtual_display` is a workspace member, so the root `Cargo.lock` is the normal workspace lockfile. | Expected to disappear after GitHub rescans the default branch. |
| `rpassword` | low `#29` | Old `rpassword 2.1.0` and `rpassword 5.0.1` were removed. `Cargo.lock` now contains only `rpassword 7.3.1`. | Expected fixed locally. Requires GitHub rescan. |
| `bytes` | moderate `#13`; moderate `#41` in removed nested lockfile | Root `Cargo.lock` contains `bytes 1.12.0`. | Expected fixed locally for the root lockfile; nested-lockfile alert depends on GitHub recognizing the file removal. |
| `crossbeam-channel` | moderate `#12` | `Cargo.lock` contains `crossbeam-channel 0.5.15`. | Expected fixed locally. Requires GitHub rescan. |
| `idna` | moderate `#5` | `Cargo.lock` contains `idna 1.0.3` and `idna_adapter 1.0.0`. `idna_adapter` was held at `1.0.0` to preserve Cargo/Rust 1.80 compatibility. | Expected fixed locally. Requires GitHub rescan. |
| `time` | moderate `#1`, `#15`; moderate `#36` in removed nested lockfile | Root `Cargo.lock` contains `time 0.3.41`; `time 0.1.45` still remains through macOS-only `fruitbasket 0.10.0`. `cargo tree --target aarch64-linux-android --features flutter,hwcodec -i time@0.1.45` printed nothing. | The Android APK path is not affected by `time 0.1.45`, but GitHub may keep a root `time` alert until the macOS `fruitbasket` chain is upgraded, replaced, removed, or the alert is dismissed as not used for this Android release. |
| `tokio` | moderate `#33` in removed nested lockfile; low `#34`, `#40` in removed nested lockfile | Root `Cargo.lock` contains `tokio 1.46.1`. | Expected fixed for the stale nested lockfile after rescan. |
| `tracing-subscriber` | low `#10` | Root `Cargo.lock` contains `tracing-subscriber 0.3.20`. | Expected fixed locally. Requires GitHub rescan. |
| `rand` | low `#20`, `#21`; low `#42` in removed nested lockfile | Root `Cargo.lock` contains `rand 0.9.4`. Older `rand 0.6.5` and `rand 0.8.5` remain, but the screenshot alert text references `rand::rng()`, which is a `rand 0.9` API. | Expected fixed for the reported `rand::rng()` advisory after rescan, but verify in GitHub because multiple `rand` major versions remain in the lockfile. |
| `glib` | moderate `#6` | `glib 0.10.3` remains through the Linux GStreamer `0.16` stack. `cargo tree --target aarch64-linux-android --features flutter,hwcodec -i glib@0.10.3` printed nothing. | Not in the Android arm64 APK dependency graph. Clearing the GitHub alert requires a desktop/Linux GStreamer stack upgrade or dismissing the alert as not used for the Android release. |
| `atty` | low `#2`; low `#37` in removed nested lockfile | `atty 0.2.14` remains through `bindgen 0.59.2` build-dependencies in upstream git crates (`hwcodec`, `machine-uid`, `magnum-opus`, `pam-sys`). | The nested-lockfile alert should disappear after rescan. The root `Cargo.lock` alert remains unless those upstream git crates are patched or replaced with versions using newer `bindgen`. |

Expected local improvements from this pass:

- Removed stale `libs/virtual_display/Cargo.lock` alerts from the current tree.
- Removed old `rpassword 2.1.0` and `rpassword 5.0.1`.
- Updated root vulnerable dependency lines where compatible with Rust 1.80:
  - `bytes 1.12.0`
  - `crossbeam-channel 0.5.15`
  - `idna 1.0.3`
  - `time 0.3.41`
  - `tokio 1.46.1`
  - `tracing-subscriber 0.3.20`
  - `rand 0.9.4`

Validation for this pass:

- Build command: `bash tools/dev/build_android_arm64_release.sh`
- Build environment override:
  - `VCPKG_ROOT=/tmp/rustdesk-fold-vcpkg.YuEc04/vcpkg`
  - `CARGO_TARGET_DIR=/tmp/rustdesk-fold-target-dependabot-high`
  - `TMPDIR=/tmp/rustdesk-fold-tmp-dependabot-high`
- Build result: passed.
- Build time: `2m15.616s` after partial dependency recompilation.
- APK verifier result: passed.
- Verified APK identity:
  - application ID: `com.rustdesk.fold`
  - application label: `RustDesk Fold`
  - target SDK: `35`
  - native ABI: `arm64-v8a`
- Test artifact:
  `artifacts/RustDesk-Fold-dependabot-medium-low-fixes-arm64-v8a-release-test.apk`
- Test artifact SHA-256:
  `9792fab1bd89ee657e865f2f76e1940a13dfe9976a730f913e4870dd19f9849f`

Remaining non-high known limitations:

- `time 0.1.45` remains via macOS-only `fruitbasket 0.10.0`; it is not selected
  for the checked Android arm64 target.
- `glib 0.10.3` remains via Linux-only GStreamer `0.16`; it is not selected for
  the checked Android arm64 target.
- `atty 0.2.14` remains through upstream git dependency build scripts pinned to
  `bindgen 0.59`. Fixing this requires vendoring or upstreaming changes to
  `hwcodec`, `machine-uid`, `magnum-opus`, and `pam-sys`, so it is intentionally
  not folded into this minimal Android release dependency pass.

## Deferred Non-Android Or Upstream-Dependency Items

These items are intentionally recorded for follow-up instead of being fixed in
the current Android APK test pass.

| Item | Current source | Android arm64 APK scope | Follow-up path |
|---|---|---|---|
| `atty 0.2.14` | Upstream git dependency build scripts pinned to `bindgen 0.59` in `hwcodec`, `machine-uid`, `magnum-opus`, and `pam-sys`. | Build-dependency path only; not an app runtime crate. It still appears in the Android target build graph. | Create a separate dependency-maintenance branch to vendor or upstream patches that move those crates off `bindgen 0.59`, then rebuild the APK. |
| `glib 0.10.3` | Linux-only GStreamer `0.16` stack under `scrap` Wayland support. | Not selected by `cargo tree --target aarch64-linux-android --features flutter,hwcodec`. | Treat as a desktop/Linux dependency-maintenance task. Clearing it likely requires a larger GStreamer stack upgrade. |
| `time 0.1.45` | macOS-only `fruitbasket 0.10.0`. | Not selected by `cargo tree --target aarch64-linux-android --features flutter,hwcodec`. | Treat as a macOS desktop dependency-maintenance task. Clearing it requires replacing or upgrading the `fruitbasket` chain. |

Public-release handling:

- Android test APKs may proceed with these three items documented because the
  checked app runtime path is not affected.
- A formal public source release should keep this section visible until GitHub
  Dependabot is rescanned after push/merge and the maintainer decides whether
  non-Android alerts should be fixed, dismissed as out-of-scope, or tracked as
  desktop follow-up work.
