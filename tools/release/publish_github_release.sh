#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TAG="${1:-}"
APK_PATH="${2:-$REPO_ROOT/flutter/build/app/outputs/flutter-apk/app-release.apk}"
REMOTE="${REMOTE:-github}"
GH_REPO="${GH_REPO:-}"

usage() {
  cat >&2 <<'USAGE'
Usage:
  tools/release/publish_github_release.sh <fold-vx.y.z-YYYYMMDD> [apk-path]

Environment:
  REMOTE=github                       Git remote used for tag push.
  GH_REPO=owner/name                  GitHub repository for gh release commands.
  EXPECTED_SIGNER_SHA256=<sha256>     Optional APK signer certificate pin.
USAGE
}

if [ -z "$TAG" ]; then
  usage
  exit 1
fi

case "$TAG" in
  fold-v*) ;;
  *)
    echo "release tag must start with fold-v: $TAG" >&2
    exit 1
    ;;
esac

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing command: $1" >&2
    exit 1
  fi
}

infer_github_repo() {
  remote_url="$1"
  ssh_prefix="git""@""github.com:"
  https_prefix="https://github.com/"
  case "$remote_url" in
    "$ssh_prefix"*.git)
      repo="${remote_url#$ssh_prefix}"
      printf '%s\n' "${repo%.git}"
      ;;
    "$https_prefix"*.git)
      repo="${remote_url#$https_prefix}"
      printf '%s\n' "${repo%.git}"
      ;;
    "$https_prefix"*)
      printf '%s\n' "${remote_url#$https_prefix}"
      ;;
    *)
      return 1
      ;;
  esac
}

require_cmd git
require_cmd gh
require_cmd sha256sum

cd "$REPO_ROOT"

if [ -n "$(git status --porcelain)" ]; then
  echo "worktree must be clean before publishing" >&2
  git status --short >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "local tag already exists: $TAG" >&2
  exit 1
fi

remote_url="$(git remote get-url "$REMOTE")"
if git ls-remote --exit-code --tags "$REMOTE" "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "remote tag already exists on $REMOTE: $TAG" >&2
  exit 1
fi

if [ -z "$GH_REPO" ]; then
  if ! GH_REPO="$(infer_github_repo "$remote_url")"; then
    echo "could not infer GH_REPO from remote $REMOTE: $remote_url" >&2
    exit 1
  fi
fi

if gh release view "$TAG" --repo "$GH_REPO" >/dev/null 2>&1; then
  echo "GitHub Release already exists: $GH_REPO $TAG" >&2
  exit 1
fi

"$REPO_ROOT/tools/release/verify_android_release_apk.sh" "$APK_PATH"

if [ ! -f "$APK_PATH.sha256" ]; then
  echo "checksum missing after verification: $APK_PATH.sha256" >&2
  exit 1
fi

release_dir="$REPO_ROOT/dist/release/$TAG"
asset_name="RustDesk-Fold-$TAG-arm64-v8a-release.apk"
release_apk="$release_dir/$asset_name"
release_sha="$release_apk.sha256"
notes_file="$release_dir/RELEASE_NOTES.md"

if [ -e "$release_dir" ]; then
  echo "release directory already exists: $release_dir" >&2
  exit 1
fi
mkdir -p "$release_dir"
cp "$APK_PATH" "$release_apk"
(
  cd "$release_dir"
  sha256sum "$asset_name" > "$asset_name.sha256"
)

commit_sha="$(git rev-parse HEAD)"
apk_sha="$(cut -d ' ' -f 1 "$release_sha")"

cat > "$notes_file" <<NOTES
RustDesk Fold $TAG

RustDesk Fold is an independent customized Android foldable-screen build and is
not an official RustDesk release.

- Commit: $commit_sha
- APK: $asset_name
- SHA-256: $apk_sha
- Application ID: com.rustdesk.fold
- Application label: RustDesk Fold
- Target SDK: 35
- Native ABI: arm64-v8a
NOTES

git tag -a "$TAG" -m "RustDesk Fold $TAG"
git push "$REMOTE" "refs/tags/$TAG"

gh release create "$TAG" \
  "$release_apk" \
  "$release_sha" \
  --repo "$GH_REPO" \
  --title "RustDesk Fold $TAG" \
  --notes-file "$notes_file"

printf 'Published GitHub Release: %s %s\n' "$GH_REPO" "$TAG"
printf 'APK: %s\n' "$release_apk"
printf 'SHA-256: %s\n' "$release_sha"
