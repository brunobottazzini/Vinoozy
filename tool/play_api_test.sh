#!/usr/bin/env bash
# Test of tool/play_api.sh error handling (actions-release-fix FR2, FR3.1,
# FR3.3, NFR1). gcloud and curl are replaced by the stubs in
# tool/fixtures/play_api/bin/, so nothing reaches Google and no real
# credential is needed. Every case checks the exit code, the message on
# stderr, that stdout stays usable as a number, and that no fragment of the
# fake key or token is ever printed.
#
# Usage: tool/play_api_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
script="tool/play_api.sh"
fixtures="tool/fixtures/release_inputs"
stubs="tool/fixtures/play_api/bin"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

valid_key="$fixtures/service_account.json"
empty_key="$work/empty.json"
: >"$empty_key"
broken_key="$work/broken.json"
printf '{"type": "service_account",' >"$broken_key"
wrong_type_key="$work/wrong_type.json"
jq '.type = "authorized_user"' "$valid_key" >"$wrong_type_key"

secrets=("fakekeyfakekeyfakekey" "ya29.faketoken" "BEGIN PRIVATE KEY")
tracks='{"tracks":[{"track":"internal","releases":[{"versionCodes":["3","41"]}]},{"track":"production","releases":[{"versionCodes":["2"]}]}]}'

failures=0
stdout=""
stderr=""
status=0

# Runs the script with the stubs first on PATH; extra NAME=value pairs go to
# its environment. Sets $stdout, $stderr and $status.
run() {
  set +e
  stdout="$(env PATH="$root/$stubs:$PATH" FAKE_TRACKS_JSON="$tracks" "$@" 2>"$work/stderr")"
  status=$?
  set -e
  stderr="$(cat "$work/stderr")"
}

fail_case() {
  echo "play_api_test: $1"$'\n'"  exit: $status"$'\n'"  stdout: $stdout"$'\n'"  stderr: $stderr" >&2
  failures=$((failures + 1))
}

# $1 case name, $2 exit code expected, $3 message expected on stderr, then
# the command (environment pairs and script arguments).
expect_error() {
  local name="$1" expected_status="$2" message="$3" secret
  shift 3
  run "$@"
  if [[ $status -ne $expected_status ]]; then
    fail_case "$name: exit $expected_status expected"
    return
  fi
  if [[ "$stderr" != *"$message"* ]]; then
    fail_case "$name: stderr should contain '$message'"
    return
  fi
  if [[ -n "$stdout" ]]; then
    fail_case "$name: stdout must stay empty on failure"
    return
  fi
  for secret in "${secrets[@]}"; do
    if [[ "$stderr" == *"$secret"* ]]; then
      fail_case "$name: stderr leaks '$secret'"
      return
    fi
  done
  echo "$name: refused (expected)"
}

expect_error "variable not set" 3 "PLAY_SA_JSON_FILE is not set" \
  PLAY_SA_JSON_FILE= "$script" next-version-code
expect_error "file missing" 3 "does not exist or is not readable" \
  PLAY_SA_JSON_FILE="$work/missing.json" "$script" next-version-code
expect_error "file empty" 3 "is empty: is the secret configured" \
  PLAY_SA_JSON_FILE="$empty_key" "$script" next-version-code
expect_error "invalid JSON" 3 "is not a valid JSON object" \
  PLAY_SA_JSON_FILE="$broken_key" "$script" next-version-code
expect_error "not a service account" 3 "is not a service account key" \
  PLAY_SA_JSON_FILE="$wrong_type_key" "$script" next-version-code
expect_error "authentication failed" 4 "Google Play authentication failed" \
  PLAY_SA_JSON_FILE="$valid_key" FAKE_GCLOUD_AUTH=fail "$script" next-version-code
expect_error "authentication reason kept" 4 "invalid_grant: Invalid JWT Signature" \
  PLAY_SA_JSON_FILE="$valid_key" FAKE_GCLOUD_AUTH=fail "$script" next-version-code
expect_error "token refused" 4 "did not issue an access token" \
  PLAY_SA_JSON_FILE="$valid_key" FAKE_GCLOUD_TOKEN=fail "$script" next-version-code
expect_error "API call failed" 5 "Play API GET /edits/fake-edit-1/tracks failed with HTTP 403" \
  PLAY_SA_JSON_FILE="$valid_key" FAKE_FAIL_METHOD=GET FAKE_FAIL_STATUS=403 \
  FAKE_FAIL_BODY='{"error":{"message":"The caller does not have permission"}}' \
  "$script" next-version-code
expect_error "API error body kept" 5 "The caller does not have permission" \
  PLAY_SA_JSON_FILE="$valid_key" FAKE_FAIL_METHOD=GET FAKE_FAIL_STATUS=403 \
  FAKE_FAIL_BODY='{"error":{"message":"The caller does not have permission"}}' \
  "$script" next-version-code
expect_error "invalid promotion fraction" 2 "fraction must be 0.2 or 1.0" \
  PLAY_SA_JSON_FILE="$valid_key" "$script" promote 42 0.5

# FR2.4: on success stdout is exactly the number, ready for $(...).
run PLAY_SA_JSON_FILE="$valid_key" "$script" next-version-code
if [[ $status -ne 0 || "$stdout" != "42" ]]; then
  fail_case "next-version-code: stdout must be exactly 42 (highest 41 + 1)"
else
  echo "next-version-code: prints only 42 (expected)"
fi

# A failed DELETE of the read-only edit is best effort: still the number.
run PLAY_SA_JSON_FILE="$valid_key" FAKE_FAIL_METHOD=DELETE FAKE_FAIL_STATUS=500 "$script" next-version-code
if [[ $status -ne 0 || "$stdout" != "42" ]]; then
  fail_case "next-version-code with a failed edit cleanup: stdout must still be 42"
else
  echo "next-version-code with a failed edit cleanup: prints only 42 (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "play_api_test: $failures failure(s)" >&2
  exit 1
fi
echo "play_api_test: OK"
