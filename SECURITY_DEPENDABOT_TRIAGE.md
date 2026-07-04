# Dependabot High Alert Triage

Audit date: 2026-07-04
Scope: GitHub Dependabot open high-severity alerts for `bluewhitep/RustDesk-Fold`
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
risk and the maintainer accepts it.

For this experiment branch, the checked lockfile no longer contains the
previously reported high-alert packages listed above, and the Android arm64
release APK build and verifier passed. A formal public release still requires a
GitHub Dependabot rescan after pushing or merging this branch, plus maintainer
review of the downstream vendored dependency patches.

For an experiment/test APK, use the development branch only and label the APK as
a test artifact, not a formal release.
