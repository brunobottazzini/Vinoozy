#!/usr/bin/env bash
# Build test (Step 13, cicd-pipeline.md §1): the release build must not
# contain the test-only code compiled in with dart-defines:
#   - EmulatorGoogleAuthService, only with --dart-define=E2E=true;
#   - VINOOZY_DASHBOARD_READY, the Dashboard "ready" signal of the on-phone
#     measurements, only with --dart-define=PERF=true (u5-dashboard
#     performance-design.md, cicd-pipeline.md §1);
#   - VINOOZY_E2E_LOCALE, the Italian language forced in E2E builds only
#     (lib/e2e/e2e_locale.dart, u8-account review R-01).
#
# Two release app bundles (arm64 only, not obfuscated, so class names stay in
# the AOT snapshot):
#   1. plain release                 -> every marker must be ABSENT;
#   2. release + E2E=true, PERF=true -> every marker must be PRESENT
#      (positive control, proves the check can see them at all).
# The control build carries both defines, so there are still two builds.
#
# Since u6-label-recognition (security-design.md §2, cicd-pipeline.md §1),
# after the plain build it also reads the merged release manifest in clear
# text (not the binary one inside the AAB):
#   - negative check: no CAMERA, READ_MEDIA_IMAGES, READ_EXTERNAL_STORAGE;
#   - positive check: MainActivity has the share filter, with only
#     ACTION_SEND / ACTION_SEND_MULTIPLE and image/*, plus (since
#     label-autofill-windows NFR3.3) ACTION_SEND of text/plain, and no other
#     action besides MAIN.
# It fails when the merged manifest is missing. The plain AAB is kept as
# build/check_release/app-release.aab for tool/check_app_size.sh.
#
# Usage: tool/check_release_build.sh
set -euo pipefail

markers=("EmulatorGoogleAuthService" "VINOOZY_DASHBOARD_READY" "VINOOZY_E2E_LOCALE")
aab="build/app/outputs/bundle/release/app-release.aab"
so="build/check_release/libapp.so"
merged_manifest="build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml"
plain_aab="build/check_release/app-release.aab"

check_merged_manifest() {
  if [[ ! -s "$merged_manifest" ]]; then
    echo "check_release_build: merged manifest not found at $merged_manifest" >&2
    exit 2
  fi
  local permission
  for permission in CAMERA READ_MEDIA_IMAGES READ_EXTERNAL_STORAGE; do
    if grep -Eq "android:name=\"android\.permission\.${permission}\"" "$merged_manifest"; then
      echo "check_release_build: FAILED, the merged manifest declares $permission" >&2
      exit 1
    fi
    echo "merged manifest: $permission absent (ok)"
  done
  # The MainActivity block, from its <activity> to the next </activity>.
  local activity
  activity="$(awk '
    /<activity/ { inside = 0; buffer = "" }
    /<activity/ || inside { buffer = buffer $0 "\n" }
    /android:name="com\.vinoozy\.vinoozy\.MainActivity"/ { inside = 1 }
    /<\/activity>/ && inside { printf "%s", buffer; exit }
  ' "$merged_manifest")"
  if [[ -z "$activity" ]]; then
    echo "check_release_build: FAILED, MainActivity not found in the merged manifest" >&2
    exit 1
  fi
  local actions mimes
  actions="$(grep -oE '<action android:name="[^"]+"' <<<"$activity" | sed -E 's/.*name="([^"]+)"/\1/' | sort -u)"
  mimes="$(grep -oE 'android:mimeType="[^"]+"' <<<"$activity" | sed -E 's/.*="([^"]+)"/\1/' | sort -u)"
  local expected_actions
  expected_actions="$(printf '%s\n' android.intent.action.MAIN android.intent.action.SEND android.intent.action.SEND_MULTIPLE | sort -u)"
  if [[ "$actions" != "$expected_actions" ]]; then
    echo "check_release_build: FAILED, MainActivity actions are:"$'\n'"$actions" >&2
    exit 1
  fi
  # label-autofill-windows NFR3.3: the text shared by Google Lens
  # (ACTION_SEND text/plain) is the only other type.
  local expected_mimes
  expected_mimes="$(printf '%s\n' 'image/*' 'text/plain' | sort -u)"
  if [[ "$mimes" != "$expected_mimes" ]]; then
    echo "check_release_build: FAILED, MainActivity share types are:"$'\n'"$mimes" >&2
    exit 1
  fi
  echo "merged manifest: share filters SEND/SEND_MULTIPLE image/* and SEND text/plain only (ok)"
}
# A previous `flutter test integration_test` leaves a plugin registrant that
# references the dev-only integration_test plugin, which release builds do not
# compile: start from a clean tree.
flutter clean >/dev/null
mkdir -p build/check_release

build_snapshot() {
  local defines=("$@")
  flutter build appbundle --release --target-platform android-arm64 \
    --dart-define=FIREBASE_ENV=demo ${defines[@]+"${defines[@]}"} >/dev/null
  unzip -p "$aab" base/lib/arm64-v8a/libapp.so > "$so"
  if [[ ! -s "$so" ]]; then
    echo "check_release_build: libapp.so not found in $aab" >&2
    exit 2
  fi
}

build_snapshot
check_merged_manifest
cp "$aab" "$plain_aab"
for marker in "${markers[@]}"; do
  if grep -a -q "$marker" "$so"; then
    echo "check_release_build: FAILED, the release build contains $marker" >&2
    exit 1
  fi
  echo "release build: $marker absent (ok)"
done

build_snapshot --dart-define=E2E=true --dart-define=PERF=true
for marker in "${markers[@]}"; do
  if ! grep -a -q "$marker" "$so"; then
    echo "check_release_build: FAILED, positive control could not find $marker" >&2
    exit 1
  fi
  echo "E2E+PERF build: $marker present (positive control ok)"
done
