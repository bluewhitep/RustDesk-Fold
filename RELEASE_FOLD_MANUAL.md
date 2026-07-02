# RustDesk Fold Manual Build, Install, and Release

Applicable versions: `fold-vx.y.z-YYYYMMDD`
Audience: Maintainer
Status: Active

RustDesk Fold does not use GitHub Actions for release builds. Release APKs are
produced only from a trusted local maintainer environment after a manual review
of the current branch. This avoids exposing a self-hosted runner to public fork
or pull request code and avoids relying on GitHub-hosted runner capacity for the
heavy Android release build.

This is an independent customized Android foldable-screen build and is not an
official RustDesk release.

## No Actions Policy

- Do not add workflow files under `.github/workflows/`.
- Do not use a self-hosted runner for public repository events.
- Do not use GitHub-hosted runners as the release gate for APK publication.
- Use GitHub only for source hosting, tags, release records, and release assets.
- Run all release build, signing, and APK validation commands on a trusted local
  maintainer machine.

## Branches

- `foldable-split-keyboard-main`: long-lived Fold main branch and GitHub default
  branch.
- `chore/update-rustdesk-x-y-z`: temporary branch for manual upstream update
  work when needed.

Do not tag or publish from a temporary update branch unless it has first been
merged into the Fold main branch and reviewed as the intended release commit.

## Manual Review Gate

Before building a release APK, review the branch manually:

1. Confirm the worktree is clean.
2. Confirm the intended release commit and branch.
3. Review upstream or local diffs for code behavior, Android permissions,
   signing configuration, dependency changes, and sensitive data.
4. Confirm no debug APK, temporary signing material, local cache, runner state,
   or credential file is tracked.
5. Confirm `.github/workflows/` is absent or empty in tracked source.

Useful commands:

```bash
git status --short --branch
git log --oneline --decorate -n 20
git diff --stat master..HEAD
git diff --name-status master..HEAD
git ls-files .github/workflows
git ls-files | grep -E '(^|/)(key.properties|.*\.jks|.*\.keystore|\.env|\.ssh/)'
```

Treat any unexpected output from the sensitive-file check as release blocking
until it is explained and fixed.

## Local Maintainer Workspace

The local maintainer workspace used by this project keeps toolchains and APK
test artifacts outside tracked source:

```text
<workspace>/
  .dev/
  artifacts/
  rustdesk-fold/
```

Run workspace-level commands from `<workspace>`. Run repository-level commands
from `<workspace>/rustdesk-fold`.

## Build

Install Flutter, Rust, `cargo-ndk`, Android SDK, and Android NDK first.
`ANDROID_NDK_HOME` or `ANDROID_NDK_ROOT` must point to the installed NDK.

From the workspace root, load the repo-local environment and enter the source
checkout:

```bash
source .dev/env.sh
cd rustdesk-fold
```

Then build from the repository root:

```bash
cd flutter
flutter analyze
cd ..
bash tools/dev/build_android_arm64_release.sh
```

Expected release APK path:

```text
flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Verify APK

Run the APK verifier before publishing:

```bash
bash tools/release/verify_android_release_apk.sh \
  flutter/build/app/outputs/flutter-apk/app-release.apk
```

The verifier checks:

- application ID: `com.rustdesk.fold`
- application label: `RustDesk Fold`
- target SDK: `35`
- native ABI: `arm64-v8a`
- APK signing validity
- SHA-256 checksum generation

If the maintainer wants to pin the release signer certificate, set
`EXPECTED_SIGNER_SHA256` before running the verifier.

After APK verification passes, copy the build output to the workspace artifact
path for local device testing:

```bash
mkdir -p ../artifacts
cp -f flutter/build/app/outputs/flutter-apk/app-release.apk \
  ../artifacts/RustDesk-Fold-public-snapshot-arm64-v8a-release.apk
```

## Device Test Install

Install only the release APK. Do not install `app-debug.apk`, do not uninstall
`com.rustdesk.fold`, and do not clear app data during state-preserving device
testing.

From the workspace root:

```bash
source .dev/env.sh
adb pair <ip>:<port>
adb connect <ip>:<port>
adb install -r 'artifacts/RustDesk-Fold-public-snapshot-arm64-v8a-release.apk'
```

When multiple devices are connected:

```bash
adb -s <device_serial> install -r 'artifacts/RustDesk-Fold-public-snapshot-arm64-v8a-release.apk'
```

`adb pair` is only needed for the first wireless debugging pairing or when the
device rotates its pairing port.

## Publish

Publish only after manual review and APK verification pass.

Tag format:

```text
fold-vx.y.z-YYYYMMDD
```

Example:

```text
fold-v1.4.8-20260701
```

Publish from a clean worktree:

```bash
bash tools/release/publish_github_release.sh \
  fold-v1.4.8-20260701 \
  flutter/build/app/outputs/flutter-apk/app-release.apk
```

The publish script:

1. Fails if the worktree is dirty.
2. Fails if the tag already exists locally or on the release remote.
3. Runs the APK verifier.
4. Copies the APK to `dist/release/<tag>/`.
5. Renames the APK to `RustDesk-Fold-<tag>-arm64-v8a-release.apk`.
6. Generates `RustDesk-Fold-<tag>-arm64-v8a-release.apk.sha256`.
7. Creates an annotated Git tag on the current commit.
8. Pushes the tag to the configured release remote.
9. Creates a GitHub Release and uploads the APK plus checksum.

Default release remote: `github`.

Override it when needed:

```bash
REMOTE=github GH_REPO=bluewhitep/RustDesk-Fold \
  bash tools/release/publish_github_release.sh \
  fold-v1.4.8-20260701 \
  flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Failure Handling

- Manual review finding: do not build, tag, or publish until fixed.
- `flutter analyze` failure: do not build or publish.
- APK build failure: do not tag or publish.
- APK identity failure: do not tag or publish.
- APK signing failure: do not tag or publish.
- Missing checksum: do not tag or publish.
- Existing local or remote tag: do not overwrite; create a new explicit tag or
  resolve the existing release manually.
- GitHub Release upload failure after tag push: inspect the release state before
  retrying any publish command.

## Public Repository Cleanup Boundary

Before making the repository public, remove repository-visible Actions state
where possible:

- delete tracked workflow files from `.github/workflows/`;
- disable GitHub Actions in repository settings;
- unregister self-hosted runners from the repository;
- delete temporary benchmark or workflow test branches;
- delete visible workflow runs when GitHub allows it.

GitHub internal audit logs and historical commit status metadata may remain in
GitHub systems. Do not claim they are fully erased.
