# RustDesk Fold Patched Third-Party Dependencies

This directory contains small vendored dependency patches used by the
Dependabot high-alert experiment branch.

The goal is to keep RustDesk Fold's public lockfile free of known high-severity
alerts without changing Android runtime behavior. These patches are downstream
maintenance deltas and must be reviewed again during future upstream RustDesk
rebases.

## Inventory

| Directory | Source | Baseline | License | Local change |
|---|---|---|---|---|
| `pam` | `https://github.com/rustdesk-org/pam` | `7bfd25510202cd269292cbdd7c71f3977a6fd762` | `MIT OR Apache-2.0` | Replaced optional `users` dependency with `uzers` while preserving the crate name used by source code; removed nested workspace metadata so the crate can be embedded in this workspace. |
| `keepawake-rs` | `https://github.com/rustdesk-org/keepawake-rs` | `64d568586dd16551d02120e19668d2b0fec8e3c9` | `MIT` | Removed unused `shadow-rs` build metadata generation to remove the `git2 -> libgit2-sys` alert chain. |

## Maintenance Rules

1. Keep each vendored directory minimal and source-compatible with the upstream
   crate API used by RustDesk.
2. Preserve upstream license files in each vendored directory.
3. Record the upstream source URL, baseline commit, license, and local changes
   in this file whenever a vendored patch is added or refreshed.
4. When upstream RustDesk or the upstream dependency fixes the same issue,
   prefer returning to the upstream dependency and removing the vendored patch.
5. Re-run the dependency tree checks and Android arm64 release build after any
   vendored patch change.
