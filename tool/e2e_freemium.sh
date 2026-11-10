#!/usr/bin/env bash
# End-to-end tests of Freemium and Plus (freemium-plus plan Step 18):
# integration_test/freemium_test.dart in a build with the developer tools
# (ENABLE_DEV_CHEATS=true, FR5.1), plus the host side of the gift (FR4.1):
#
#   1. In the background, the owner's tool/admin/grant_plus.mjs in --emulator
#      mode is retried every 2 s until the account gift@example.com exists in
#      the Auth emulator (the test signs it in), then gifts it Plus with no
#      expiry. The test waits on the Profile for "Plus (gift)" with no action
#      in the app (FR4.3).
#   2. `flutter test integration_test/freemium_test.dart` with the developer
#      tools compiled in.
#   3. The script fails when the tests fail or when the grant never happened.
#
# Prerequisites: the Firebase emulators (Auth, Firestore and Functions,
# demo-vinoozy) running on this machine, `npm ci --prefix tool/admin` and
# `npm ci --prefix functions` done, one Android emulator running. Only the
# demo-vinoozy emulators are touched: grant_plus.mjs refuses any other
# project or a non-local host in --emulator mode.
#
# Usage: tool/e2e_freemium.sh [extra flutter test arguments, e.g. -d <id>]
set -euo pipefail

cd "$(dirname "$0")/.."

readonly gift_email="gift@example.com"
readonly grant_timeout_seconds="${E2E_GRANT_TIMEOUT_SECONDS:-1200}"

grant_when_signed_in() {
  local end=$((SECONDS + grant_timeout_seconds))
  local output=""
  while ((SECONDS < end)); do
    if output="$(node tool/admin/grant_plus.mjs grant --email "$gift_email" \
      --no-expiry --reason gift --emulator 2>&1)"; then
      echo "e2e_freemium: $output"
      return 0
    fi
    sleep 2
  done
  echo "e2e_freemium: grant_plus.mjs never found $gift_email: $output" >&2
  return 1
}

grant_when_signed_in &
grant_pid=$!
trap 'kill "$grant_pid" 2>/dev/null || true' EXIT

flutter test integration_test/freemium_test.dart \
  --dart-define=FIREBASE_ENV=demo \
  --dart-define=E2E=true \
  --dart-define=ENABLE_DEV_CHEATS=true \
  "$@"

# The tests passed; the gift must also have been written by the script.
wait "$grant_pid"
trap - EXIT
