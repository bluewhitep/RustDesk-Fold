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

## Release Gate

Do not publish a formal APK release while high-severity Android-path alerts
remain unresolved unless the release notes explicitly document the residual
risk and the maintainer accepts it.

For an experiment/test APK, use the development branch only and label the APK as
a test artifact, not a formal release.
