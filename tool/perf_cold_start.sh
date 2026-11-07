#!/usr/bin/env bash
# Cold start of the Dashboard with 500 wines and no network, on the phone
# (u5-dashboard performance-design.md, "Misura dell'avvio a freddo sul
# telefono"; NFR2.1). Run by the owner once per version on the two phones,
# never in CI; the result goes in docs/release-checklist.md, §1-ter.
#
# Measured: from the start of the process (ActivityManager "Start proc") to
# the first frame of `dashboard-content` with the counts loaded, which the
# app signals with the logcat line `VINOOZY_DASHBOARD_READY bottles=<n>`
# only in builds made with --dart-define=PERF=true.
#
#   1. `adb reverse` opens the Auth (9099) and Firestore (8080) emulator
#      ports of this computer to the phone (EMULATOR_HOST=127.0.0.1: the
#      default 10.0.2.2 works only in the Android emulator).
#   2. integration_test_perf/dashboard_seed.dart (flutter drive --profile
#      --keep-app-running) signs in as userA, creates 500 wines and waits
#      until the Dashboard shows them, so the local cache is full.
#   3. The real app (lib/main.dart, same defines, profile) is installed over
#      it with `adb install -r`, which keeps the data and the session.
#   4. `adb reverse --remove-all` makes the emulators unreachable (airplane
#      mode would not cut the USB cable), and Wi-Fi and mobile data are
#      turned off with `svc`. A trap turns them back on, also on failure.
#   5. Five cold starts: force-stop, logcat -c, am start -W, wait for the
#      ready line; a run whose bottle count is not 500 is invalid.
#   6. Prints the five times and the median, and fails above the limit.
#
# Prerequisites: one phone connected by USB (`adb devices`), the Firebase
# emulators running here (`npx firebase emulators:start --only
# auth,firestore --project demo-vinoozy`). Never the production project.
#
# Usage: tool/perf_cold_start.sh [limit-ms]
#   limit-ms: 2000 on the reference phone (default), 1000 on the owner's.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v adb >/dev/null && [[ -x "${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb" ]]; then
  export PATH="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools:$PATH"
fi

readonly package=com.vinoozy.app
readonly activity=com.vinoozy.vinoozy.MainActivity
readonly expected_bottles=500
readonly runs=5
readonly limit_ms="${1:-2000}"
defines=(
  --dart-define=FIREBASE_ENV=demo
  --dart-define=E2E=true
  --dart-define=PERF=true
  --dart-define=EMULATOR_HOST=127.0.0.1
)

fail() {
  echo "perf_cold_start: FAILED: $*" >&2
  exit 1
}

if ! [[ "$limit_ms" =~ ^[0-9]+$ ]]; then
  echo "usage: $0 [limit-ms]" >&2
  exit 2
fi
if ! adb get-state >/dev/null 2>&1; then
  echo "perf_cold_start: no phone connected (adb devices)" >&2
  exit 2
fi

network_off=false
restore_network() {
  if [[ $network_off == true ]]; then
    adb shell svc wifi enable >/dev/null 2>&1 || true
    adb shell svc data enable >/dev/null 2>&1 || true
    echo "perf_cold_start: Wi-Fi and mobile data turned back on"
  fi
}
trap restore_network EXIT

echo '== 1/5: adb reverse of the emulator ports =='
adb reverse tcp:9099 tcp:9099
adb reverse tcp:8080 tcp:8080

echo '== 2/5: seed 500 wines (flutter drive --profile) =='
flutter drive --profile \
  --driver=test_driver/integration_test.dart \
  --target=integration_test_perf/dashboard_seed.dart \
  --keep-app-running \
  "${defines[@]}"

echo '== 3/5: install the real app over it (data and session kept) =='
flutter build apk --profile "${defines[@]}"
adb install -r build/app/outputs/flutter-apk/app-profile.apk

echo '== 4/5: no network: adb reverse --remove-all, Wi-Fi and data off =='
adb reverse --remove-all
network_off=true
adb shell svc wifi disable
adb shell svc data disable

# Milliseconds from "Start proc ... com.vinoozy.app" to the ready line, or
# nothing until the ready line is there. LC_ALL=C: with an Italian locale
# awk would read "1730890001.350" as 1730890001 (decimal comma).
measure_run() {
  adb logcat -d -v epoch | LC_ALL=C awk -v pkg="$package" -v want="$expected_bottles" '
    /ActivityManager/ && /Start proc/ && index($0, pkg) && start == "" { start = $1 }
    /VINOOZY_DASHBOARD_READY bottles=/ && ready == "" {
      ready = $1
      match($0, /bottles=[0-9]+/)
      bottles = substr($0, RSTART + 8, RLENGTH - 8)
    }
    END {
      if (start == "" || ready == "") exit 0
      if (bottles != want) { print "BOTTLES " bottles; exit 0 }
      printf "%d\n", (ready - start) * 1000 + 0.5
    }'
}

echo "== 5/5: $runs cold starts =="
times=()
for run in $(seq 1 "$runs"); do
  adb shell am force-stop "$package"
  sleep 1
  adb logcat -c
  adb shell am start -W -n "$package/$activity" >/dev/null
  result=''
  for _ in $(seq 1 60); do
    result="$(measure_run)"
    [[ -n "$result" ]] && break
    sleep 0.5
  done
  [[ -n "$result" ]] || fail "run $run: no VINOOZY_DASHBOARD_READY line within 30 s"
  [[ "$result" != BOTTLES* ]] ||
    fail "run $run: the Dashboard showed ${result#BOTTLES } bottles, not $expected_bottles"
  echo "run $run: ${result} ms"
  times+=("$result")
done

median="$(printf '%s\n' "${times[@]}" | sort -n | sed -n "$(((runs + 1) / 2))p")"
echo "perf_cold_start: times ${times[*]} ms, median ${median} ms (limit ${limit_ms} ms)"
if ((median > limit_ms)); then
  fail "median ${median} ms above ${limit_ms} ms"
fi
echo 'perf_cold_start: OK'
