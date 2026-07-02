#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APK_PATH="${1:-$REPO_ROOT/flutter/build/app/outputs/flutter-apk/app-release.apk}"
EXPECTED_APP_ID="${EXPECTED_APP_ID:-com.rustdesk.fold}"
EXPECTED_LABEL="${EXPECTED_LABEL:-RustDesk Fold}"
EXPECTED_TARGET_SDK="${EXPECTED_TARGET_SDK:-35}"
EXPECTED_ABI="${EXPECTED_ABI:-arm64-v8a}"
EXPECTED_SIGNER_SHA256="${EXPECTED_SIGNER_SHA256:-}"

if [ ! -f "$APK_PATH" ]; then
  echo "APK not found: $APK_PATH" >&2
  exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "missing command: sha256sum" >&2
  exit 1
fi

find_android_tool() {
  tool_name="$1"
  if command -v "$tool_name" >/dev/null 2>&1; then
    command -v "$tool_name"
    return 0
  fi

  sdk_root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [ -n "$sdk_root" ] && [ -d "$sdk_root" ]; then
    found="$(find "$sdk_root" -type f -name "$tool_name" -print 2>/dev/null | sort -V | tail -n 1)"
    if [ -n "$found" ]; then
      printf '%s\n' "$found"
      return 0
    fi
  fi

  echo "missing Android tool: $tool_name" >&2
  exit 1
}

APKANALYZER="$(find_android_tool apkanalyzer)"
AAPT="$(find_android_tool aapt)"
APKSIGNER="$(find_android_tool apksigner)"

actual_app_id="$("$APKANALYZER" manifest application-id "$APK_PATH")"
if [ "$actual_app_id" != "$EXPECTED_APP_ID" ]; then
  echo "unexpected application ID: $actual_app_id" >&2
  exit 1
fi

actual_target_sdk="$("$APKANALYZER" manifest target-sdk "$APK_PATH")"
if [ "$actual_target_sdk" != "$EXPECTED_TARGET_SDK" ]; then
  echo "unexpected target SDK: $actual_target_sdk" >&2
  exit 1
fi

badging="$("$AAPT" dump badging "$APK_PATH")"
if ! printf '%s\n' "$badging" | grep -F "application-label:'$EXPECTED_LABEL'" >/dev/null; then
  echo "expected application label not found: $EXPECTED_LABEL" >&2
  exit 1
fi

if ! printf '%s\n' "$badging" | grep -F "native-code: '$EXPECTED_ABI'" >/dev/null; then
  echo "expected native ABI not found: $EXPECTED_ABI" >&2
  exit 1
fi

"$APKSIGNER" verify --verbose "$APK_PATH" >/dev/null

if [ -n "$EXPECTED_SIGNER_SHA256" ]; then
  signer_report="$("$APKSIGNER" verify --print-certs "$APK_PATH")"
  if ! printf '%s\n' "$signer_report" | grep -F "Signer #1 certificate SHA-256 digest: $EXPECTED_SIGNER_SHA256" >/dev/null; then
    echo "expected signer SHA-256 digest not found" >&2
    exit 1
  fi
fi

sha_path="${SHA256_PATH:-$APK_PATH.sha256}"
sha256sum "$APK_PATH" > "$sha_path"

printf 'Verified APK: %s\n' "$APK_PATH"
printf 'Application ID: %s\n' "$EXPECTED_APP_ID"
printf 'Application label: %s\n' "$EXPECTED_LABEL"
printf 'Target SDK: %s\n' "$EXPECTED_TARGET_SDK"
printf 'Native ABI: %s\n' "$EXPECTED_ABI"
printf 'SHA-256: %s\n' "$sha_path"
