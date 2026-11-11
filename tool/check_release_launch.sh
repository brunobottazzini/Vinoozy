#!/usr/bin/env bash
# Release launch smoke check (freemium-plus, 2026-11-11): the release build is
# shrunk by R8, the debug and E2E builds are not. Version 0.2.0 (2) crashed at
# start on the phone because R8 had removed the constructor of WorkManager's
# Room database (brought by google_mobile_ads), and no test ran a release
# build. This script builds the release APK, signs it with a throwaway key
# (the real upload key never leaves the owner's machine), installs it on the
# running emulator, starts it and fails on any fatal exception or when the
# process is gone after the start.
#
# Prerequisites: one Android emulator or device running (adb), Android SDK
# build-tools (apksigner, zipalign) and a JDK (keytool).
#
# Usage: tool/check_release_launch.sh
set -euo pipefail
cd "$(dirname "$0")/.."

package="com.vinoozy.app"
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
build_tools="$(ls -d "$sdk"/build-tools/* | sort -V | tail -1)"
adb="$sdk/platform-tools/adb"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# The demo environment needs no production secret; R8 shrinks it the same way.
flutter build apk --release --dart-define=FIREBASE_ENV=demo
unsigned="build/app/outputs/flutter-apk/app-release.apk"

keytool -genkeypair -keystore "$work/throwaway.jks" -storepass throwaway \
  -keypass throwaway -alias throwaway -keyalg RSA -keysize 2048 \
  -validity 1 -dname "CN=release-launch-check" >/dev/null 2>&1
"$build_tools/zipalign" -f -p 4 "$unsigned" "$work/aligned.apk"
"$build_tools/apksigner" sign --ks "$work/throwaway.jks" \
  --ks-pass pass:throwaway --key-pass pass:throwaway \
  --out "$work/signed.apk" "$work/aligned.apk"

"$adb" uninstall "$package" >/dev/null 2>&1 || true
"$adb" install "$work/signed.apk" >/dev/null
"$adb" logcat -c
"$adb" shell monkey -p "$package" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
sleep 15

crash="$("$adb" logcat -d -b crash | grep -A12 "FATAL EXCEPTION" || true)"
if [[ -n "$crash" ]]; then
  echo "check_release_launch: FAILED, the release build crashed at start:" >&2
  echo "$crash" >&2
  exit 1
fi
if [[ -z "$("$adb" shell pidof "$package" | tr -d '\r')" ]]; then
  echo "check_release_launch: FAILED, $package is not running after the start" >&2
  exit 1
fi
"$adb" uninstall "$package" >/dev/null 2>&1 || true
echo "check_release_launch: OK (release build started without crashing)"
