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
# The control build carries both defines (since freemium-plus also
# ENABLE_DEV_CHEATS, see below), so these are still two builds.
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
# Since freemium-plus (plan Step 19; FR5.1, FR5.7, D6):
#   - VINOOZY_DEV_CHEATS_PANEL, the marker of the developer panel, must be
#     absent from the plain release AND from the release built with
#     --dart-define=ENABLE_DEV_CHEATS=true by mistake (the second build above
#     carries the flag too: kDevCheatsAvailable is false in every release);
#   - a third build, --profile with ENABLE_DEV_CHEATS=true, is its positive
#     control: there the tools exist and the marker must be PRESENT;
#   - the merged release manifest must declare the Play Billing permission
#     (com.android.vending.BILLING, from in_app_purchase) and the AdMob App
#     ID meta-data, and must NOT declare the advertising id permission
#     (com.google.android.gms.permission.AD_ID) while the ads are off.
#
# Usage: tool/check_release_build.sh
set -euo pipefail

markers=("EmulatorGoogleAuthService" "VINOOZY_DASHBOARD_READY" "VINOOZY_E2E_LOCALE")
dev_marker="VINOOZY_DEV_CHEATS_PANEL"
profile_aab="build/app/outputs/bundle/profile/app-profile.aab"
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
  # freemium-plus D6: Play Billing is expected. The advertising id is removed
  # while the ads are off (Play declares "no advertising ID").
  if ! grep -Eq 'android:name="com\.android\.vending\.BILLING"' "$merged_manifest"; then
    echo "check_release_build: FAILED, the merged manifest does not declare com.android.vending.BILLING" >&2
    exit 1
  fi
  echo "merged manifest: com.android.vending.BILLING present (expected)"
  if grep -Eq 'android:name="com\.google\.android\.gms\.permission\.AD_ID"' "$merged_manifest"; then
    echo "check_release_build: FAILED, the merged manifest declares AD_ID while the ads are off" >&2
    exit 1
  fi
  echo "merged manifest: com.google.android.gms.permission.AD_ID absent (ok, ads off)"
  if ! grep -Eq 'android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"' "$merged_manifest"; then
    echo "check_release_build: FAILED, the AdMob APPLICATION_ID meta-data is missing" >&2
    exit 1
  fi
  echo "merged manifest: AdMob APPLICATION_ID meta-data present (ok)"
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
  local mode="$1"
  shift
  local defines=("$@")
  local bundle="$aab"
  [[ "$mode" == profile ]] && bundle="$profile_aab"
  flutter build appbundle "--$mode" --target-platform android-arm64 \
    --dart-define=FIREBASE_ENV=demo ${defines[@]+"${defines[@]}"} >/dev/null
  unzip -p "$bundle" base/lib/arm64-v8a/libapp.so > "$so"
  if [[ ! -s "$so" ]]; then
    echo "check_release_build: libapp.so not found in $bundle" >&2
    exit 2
  fi
}

build_snapshot release
check_merged_manifest
cp "$aab" "$plain_aab"
for marker in "${markers[@]}" "$dev_marker"; do
  if grep -a -q "$marker" "$so"; then
    echo "check_release_build: FAILED, the release build contains $marker" >&2
    exit 1
  fi
  echo "release build: $marker absent (ok)"
done

build_snapshot release --dart-define=E2E=true --dart-define=PERF=true \
  --dart-define=ENABLE_DEV_CHEATS=true
for marker in "${markers[@]}"; do
  if ! grep -a -q "$marker" "$so"; then
    echo "check_release_build: FAILED, positive control could not find $marker" >&2
    exit 1
  fi
  echo "E2E+PERF build: $marker present (positive control ok)"
done
# FR5.7: a release built with the flag by mistake still has no tools.
if grep -a -q "$dev_marker" "$so"; then
  echo "check_release_build: FAILED, a release built with ENABLE_DEV_CHEATS=true contains $dev_marker" >&2
  exit 1
fi
echo "release + ENABLE_DEV_CHEATS=true: $dev_marker absent (ok)"

# FR5.1: positive control of the developer panel marker, a profile build
# (not release) with the flag, where the tools exist.
build_snapshot profile --dart-define=ENABLE_DEV_CHEATS=true
if ! grep -a -q "$dev_marker" "$so"; then
  echo "check_release_build: FAILED, positive control could not find $dev_marker in the profile build" >&2
  exit 1
fi
echo "profile + ENABLE_DEV_CHEATS=true: $dev_marker present (positive control ok)"
