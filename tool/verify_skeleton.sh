#!/usr/bin/env bash
# Proposed Construction verification command of the walking skeleton
# (cicd-pipeline.md §1: the same steps as the CI jobs `rules` and `e2e`).
#
# Starts the Firebase Emulator Suite (Auth + Firestore, demo-vinoozy), runs the
# security rules tests, the Firestore restart probe, the end-to-end skeleton
# test and the force-stop check (tool/e2e_force_stop.sh: `adb shell am
# force-stop`, `adb shell am start`) on the running Android emulator, and stops
# at the first failure.
#
# Prerequisites: `npm ci` done, an Android emulator running (`adb devices`),
# no credentials (everything is local).
#
# Usage: tool/verify_skeleton.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v adb >/dev/null && [[ -x "${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb" ]]; then
  export PATH="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools:$PATH"
fi
if ! adb devices | grep -qE 'emulator-[0-9]+\s+device'; then
  echo "verify_skeleton: no Android emulator running (start one, e.g." >&2
  echo "  flutter emulators --launch <id>)" >&2
  exit 2
fi

defines=(--dart-define=FIREBASE_ENV=demo --dart-define=E2E=true)

npx firebase emulators:exec --only auth,firestore --project demo-vinoozy "
  set -e
  echo '== Firestore security rules =='
  npm --prefix test/rules test -- u1.rules.test.mjs compat/
  echo '== Firestore restart probe =='
  flutter test integration_test/firestore_restart_probe_test.dart ${defines[*]}
  echo '== End-to-end skeleton =='
  flutter test integration_test/u1_skeleton_test.dart ${defines[*]}
  echo '== Force-stop and restart (adb) =='
  tool/e2e_force_stop.sh
"
echo "verify_skeleton: all checks passed"
