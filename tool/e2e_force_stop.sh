#!/usr/bin/env bash
# Force-stop check of the walking skeleton (cicd-pipeline.md §1, "Riavvio
# dell'app"; NFR6.1, NFR6.3): a change made offline survives a real kill of
# the app process and reaches the cloud after the restart.
#
#   1. `flutter drive --keep-app-running` runs integration_test/
#      force_stop_queue.dart: sign-in, network off, one wine added. The app is
#      left running with the write still queued.
#   2. The cloud does not have the wine yet.
#   3. `adb shell am force-stop` kills the process; the script checks it is
#      gone.
#   4. The real app (lib/main.dart, E2E build) is installed over it with
#      `adb install -r`, which keeps the app data, and started with
#      `adb shell am start`.
#   5. The wine is on the screen again (uiautomator dump, after a tap on the
#      "Cantina" tab: the app opens on the Dashboard since u5-dashboard) and
#      reaches the Firestore emulator.
#
# Prerequisites: the Firebase emulators (Auth + Firestore, demo-vinoozy)
# running on this machine, one Android emulator running (`adb devices`).
# Used by tool/verify_skeleton.sh and by the `e2e` job of ci.yml.
#
# Usage: tool/e2e_force_stop.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v adb >/dev/null && [[ -x "${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb" ]]; then
  export PATH="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools:$PATH"
fi

readonly package=com.vinoozy.app
readonly activity=com.vinoozy.vinoozy.MainActivity
readonly wine=Sangiovese
readonly host=${E2E_HOST_EMULATORS:-127.0.0.1}
readonly documents="http://$host:8080/v1/projects/demo-vinoozy/databases/(default)/documents"
readonly ui_dump=/sdcard/vinoozy-force-stop.xml
defines=(--dart-define=FIREBASE_ENV=demo --dart-define=E2E=true)

fail() {
  echo "e2e_force_stop: FAILED: $*" >&2
  exit 1
}

# Names of the wines of every cellar in the Firestore emulator ("Bearer
# owner" is the emulator's admin token and bypasses the rules).
cloud_wine_names() {
  local cellar
  for cellar in $(curl -sf -H 'Authorization: Bearer owner' "$documents/cellars" |
    python3 -c 'import json,sys
for d in json.load(sys.stdin).get("documents", []):
    print(d["name"].rsplit("/", 1)[1])'); do
    curl -sf -H 'Authorization: Bearer owner' "$documents/cellars/$cellar/wines" |
      python3 -c 'import json,sys
for d in json.load(sys.stdin).get("documents", []):
    print(d["fields"]["name"]["stringValue"])'
  done
}

cloud_has_wine() { cloud_wine_names | grep -qx "$wine"; }

screen_shows_wine() {
  adb shell uiautomator dump "$ui_dump" >/dev/null 2>&1 || return 1
  adb shell cat "$ui_dump" 2>/dev/null | grep -q "$wine"
}

# Since u5-dashboard the app opens on the Dashboard: tap the "Cantina" tab
# (Cellar / Adega in the other languages) of the navigation bar, found in a
# uiautomator dump by its label, at the centre of its bounds.
open_cellar_tab() {
  local centre
  adb shell uiautomator dump "$ui_dump" >/dev/null 2>&1 || return 1
  centre="$(adb shell cat "$ui_dump" 2>/dev/null | python3 -c 'import html,re,sys
xml = sys.stdin.read()
for node in re.findall(r"<node [^>]*>", xml):
    label = html.unescape(" ".join(re.findall(r"(?:text|content-desc)=\"([^\"]*)\"", node)))
    if re.search(r"(^|\s)(Cantina|Cellar|Adega)(\s|$)", label):
        b = re.search(r"bounds=\"\[(\d+),(\d+)\]\[(\d+),(\d+)\]\"", node)
        if b:
            x1, y1, x2, y2 = map(int, b.groups())
            print((x1 + x2) // 2, (y1 + y2) // 2)
            break')"
  [[ -n "$centre" ]] || return 1
  # shellcheck disable=SC2086 # "x y" are two arguments on purpose.
  adb shell input tap $centre
}

echo '== force-stop 1/5: queue a wine offline (flutter drive) =='
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/force_stop_queue.dart \
  --keep-app-running \
  "${defines[@]}"

echo '== force-stop 2/5: the cloud does not have it yet =='
adb shell pidof "$package" >/dev/null || fail 'the app is not running after phase 1'
if cloud_has_wine; then fail "\"$wine\" reached the cloud before the kill"; fi

echo '== force-stop 3/5: adb shell am force-stop =='
adb shell am force-stop "$package"
sleep 1
if adb shell pidof "$package" >/dev/null; then fail 'the process is still alive'; fi
if cloud_has_wine; then fail "\"$wine\" reached the cloud before the restart"; fi

echo '== force-stop 4/5: install the real app over it and adb shell am start =='
flutter build apk --debug "${defines[@]}"
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -W -n "$package/$activity"

echo '== force-stop 5/5: the wine is back on screen and reaches the cloud =='
on_screen=false
in_cloud=false
for _ in $(seq 1 45); do
  [[ $on_screen == true ]] || { screen_shows_wine && on_screen=true; } ||
    open_cellar_tab || true
  [[ $in_cloud == true ]] || { cloud_has_wine && in_cloud=true; } || true
  [[ $on_screen == true && $in_cloud == true ]] && break
  sleep 2
done
adb shell rm -f "$ui_dump" >/dev/null 2>&1 || true
[[ $on_screen == true ]] || fail "\"$wine\" is not on the screen after the restart"
[[ $in_cloud == true ]] || fail "\"$wine\" did not reach the cloud after the restart"
adb shell am force-stop "$package"
echo "e2e_force_stop: \"$wine\" survived the kill and reached the cloud"
