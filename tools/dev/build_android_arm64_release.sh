#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ANDROID_ABI="arm64-v8a"
RUST_TARGET="aarch64-linux-android"
NDK_TARGET="aarch64-linux-android"
JNI_LIB_DIR="$REPO_ROOT/flutter/android/app/src/main/jniLibs/$ANDROID_ABI"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing command: $1" >&2
    exit 1
  fi
}

require_cmd cargo
require_cmd flutter

if ! cargo ndk --version >/dev/null 2>&1; then
  echo "missing cargo-ndk: install it with 'cargo install cargo-ndk'" >&2
  exit 1
fi

ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}"
if [ -z "$ANDROID_NDK_HOME" ] || [ ! -d "$ANDROID_NDK_HOME" ]; then
  echo "ANDROID_NDK_HOME or ANDROID_NDK_ROOT must point to an installed Android NDK" >&2
  exit 1
fi

LLVM_PREBUILT="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
LIBCXX_SO="$LLVM_PREBUILT/sysroot/usr/lib/$NDK_TARGET/libc++_shared.so"
if [ ! -f "$LIBCXX_SO" ]; then
  LIBCXX_SO="$(find "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt" \
    -path "*/sysroot/usr/lib/$NDK_TARGET/libc++_shared.so" \
    -print -quit)"
fi
if [ ! -f "$LIBCXX_SO" ]; then
  echo "libc++_shared.so not found under $ANDROID_NDK_HOME" >&2
  exit 1
fi

cd "$REPO_ROOT"

cargo ndk \
  --platform 21 \
  --target "$RUST_TARGET" \
  --bindgen \
  build \
  --locked \
  --release \
  --features flutter,hwcodec

NATIVE_SO="${CARGO_TARGET_DIR:-$REPO_ROOT/target}/$RUST_TARGET/release/liblibrustdesk.so"
if [ ! -f "$NATIVE_SO" ]; then
  NATIVE_SO="$REPO_ROOT/target/$RUST_TARGET/release/liblibrustdesk.so"
fi
if [ ! -f "$NATIVE_SO" ]; then
  echo "native library not found for $RUST_TARGET" >&2
  exit 1
fi

mkdir -p "$JNI_LIB_DIR"
cp -f "$NATIVE_SO" "$JNI_LIB_DIR/librustdesk.so"
cp -f "$LIBCXX_SO" "$JNI_LIB_DIR/libc++_shared.so"

cd "$REPO_ROOT/flutter"
flutter build apk --release --target-platform android-arm64

echo "APK: $REPO_ROOT/flutter/build/app/outputs/flutter-apk/app-release.apk"
