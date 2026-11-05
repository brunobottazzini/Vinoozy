#!/usr/bin/env bash
# Build test (Step 13, cicd-pipeline.md §1): the release build must not
# contain the E2E-only EmulatorGoogleAuthService, which is compiled in only
# with --dart-define=E2E=true.
#
# Two release app bundles (arm64 only, not obfuscated, so class names stay in
# the AOT snapshot):
#   1. plain release      -> the class name must be ABSENT (tree-shaken);
#   2. release + E2E=true -> the class name must be PRESENT (positive control,
#      proves the check can see the class at all).
#
# Usage: tool/check_release_build.sh
set -euo pipefail

marker="EmulatorGoogleAuthService"
aab="build/app/outputs/bundle/release/app-release.aab"
so="build/check_release/libapp.so"
# A previous `flutter test integration_test` leaves a plugin registrant that
# references the dev-only integration_test plugin, which release builds do not
# compile: start from a clean tree.
flutter clean >/dev/null
mkdir -p build/check_release

contains_marker() {
  local defines=("$@")
  flutter build appbundle --release --target-platform android-arm64 \
    --dart-define=FIREBASE_ENV=demo ${defines[@]+"${defines[@]}"} >/dev/null
  unzip -p "$aab" base/lib/arm64-v8a/libapp.so > "$so"
  if [[ ! -s "$so" ]]; then
    echo "check_release_build: libapp.so not found in $aab" >&2
    exit 2
  fi
  grep -a -q "$marker" "$so"
}

if contains_marker; then
  echo "check_release_build: FAILED, the release build contains $marker" >&2
  exit 1
fi
echo "release build: $marker absent (ok)"

if ! contains_marker --dart-define=E2E=true; then
  echo "check_release_build: FAILED, positive control could not find $marker" >&2
  exit 1
fi
echo "E2E build: $marker present (positive control ok)"
