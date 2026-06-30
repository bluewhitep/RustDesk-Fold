# Upstream Release Workflow

Applicable versions: `v_x.y.z`
Audience: Maintainer
Status: Active

This document is the maintained release workflow for RustDesk Fold upstream
updates. It uses `x.y.z` for the official RustDesk upstream version, `v_x.y.z`
for the RustDesk Fold release tag, and `rustdesk_fold_v_x_y_z.apk` for the
release APK asset name.

## Branches

- `foldable-split-keyboard-main`: long-lived Fold main branch and GitHub default branch.
- `chore/update-rustdesk-x-y-z`: temporary upstream update branch for RustDesk `x.y.z`.

Do not merge an upstream update branch until the self-hosted runner has built
and verified the Android arm64 release APK.

## Automated Upstream Update

The `Fold Upstream Auto Update` GitHub Actions workflow runs on the
self-hosted runner. It can run on the daily schedule or by manual
`workflow_dispatch`.

For an upstream RustDesk version `x.y.z`, the workflow should:

1. Fetch official RustDesk tags.
2. Compare the current Fold baseline with the selected upstream tag.
3. Create or update `chore/update-rustdesk-x-y-z`.
4. Rebase the Fold patch stack onto RustDesk `x.y.z`.
5. Build the Android arm64 release APK on the self-hosted runner.
6. Run the release validation checks.
7. Upload the APK as a workflow artifact.
8. Open or update the upstream update pull request against `foldable-split-keyboard-main`.

If the rebase has source conflicts, the workflow must fail and leave the
conflict for manual resolution. If signing secrets are missing, the workflow
must fail instead of falling back to debug signing.

## Required Validation

Before merging the upstream update branch, confirm the self-hosted runner has
completed these checks for the update branch commit:

- `flutter pub get`
- Flutter Rust bridge generation
- `flutter analyze`
- Android native dependency build
- arm64 release APK build
- APK identity checks:
  - application ID: `com.rustdesk.fold`
  - target SDK: `35`
  - application label: `RustDesk Fold`
  - native code: `arm64-v8a`
- `apksigner verify`

The expected build output before renaming is:

```text
flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Merge

After validation passes:

1. Merge the upstream update pull request into `foldable-split-keyboard-main`.
2. Record the merge commit SHA.
3. Do not create a release from the temporary update branch after the merge.

## Tag

Create the formal RustDesk Fold tag on the merge commit. The tag must match the
upstream RustDesk version using this format:

```text
v_x.y.z
```

Example:

```text
v_1.4.8
```

## GitHub Release

Create a non-draft, non-prerelease GitHub Release from `v_x.y.z`.

Rename the verified release APK to:

```text
rustdesk_fold_v_x_y_z.apk
```

Example:

```text
rustdesk_fold_v_1_4_8.apk
```

Upload only the verified release APK asset for the formal release. Include the
merge pull request, validation summary, and APK SHA-256 in the release notes.

## Cleanup

After the formal release is published:

1. Delete `chore/update-rustdesk-x-y-z`.
2. Remove or mark any older development prerelease for the same upstream
   version as superseded.
3. Keep `foldable-split-keyboard-main` as the only long-lived Fold source
   branch unless a temporary update or validation branch is actively needed.

## Failure Handling

- Rebase conflict: stop, resolve manually, and rerun validation.
- APK build failure: do not merge, tag, or release.
- APK identity or signing failure: do not merge, tag, or release.
- Missing self-hosted runner: leave the update branch open until validation can run.
- Incorrect release asset name: replace the release asset before announcing the release.
