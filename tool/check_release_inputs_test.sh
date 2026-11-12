#!/usr/bin/env bash
# Test of tool/check_release_inputs.sh (actions-release-fix FR1.1-FR1.4,
# FR3.2, FR3.3, FR4.1, NFR1). The inputs are the fake documents of
# tool/fixtures/release_inputs/, Base64-encoded here; no real credential is
# read and nothing goes over the network. Every case checks the exit code,
# the names reported and that no value of the fixtures is ever printed.
#
# Usage: tool/check_release_inputs_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_release_inputs.sh"
fixtures="tool/fixtures/release_inputs"

b64() { base64 <"$1" | tr -d '\n'; }
b64_text() { printf '%s' "$1" | base64 | tr -d '\n'; }

sa_json="$(cat "$fixtures/service_account.json")"
google_services_b64="$(b64 "$fixtures/google_services.json")"
defines_b64="$(b64 "$fixtures/defines.json")"
keystore_b64="$(b64_text 'FAKE-KEYSTORE-BYTES-FOR-TESTS-ONLY')"

# Values that must never appear in the output.
secrets=(
  "fakekeyfakekeyfakekey" "fakeapikeyfakeapikey"
  "fakestorepassword" "fakekeypassword" "fake-alias"
  "$keystore_b64" "fake-client-id.apps.googleusercontent.com"
)

valid_internal=(
  PLAY_INTERNAL_SA_JSON="$sa_json"
  ANDROID_UPLOAD_KEYSTORE_B64="$keystore_b64"
  ANDROID_UPLOAD_KEYSTORE_PASSWORD=fakestorepassword
  ANDROID_UPLOAD_KEY_ALIAS=fake-alias
  ANDROID_UPLOAD_KEY_PASSWORD=fakekeypassword
  FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64="$google_services_b64"
  FIREBASE_PROD_DEFINES_JSON_B64="$defines_b64"
  GOOGLE_SERVER_CLIENT_ID=fake-client-id.apps.googleusercontent.com
)

failures=0
output=""
status=0

# Runs the check with a clean environment plus the given NAME=value pairs.
run() {
  local profile="$1"
  shift
  set +e
  output="$(env -i PATH="$PATH" "$@" "$check" --profile "$profile" 2>&1)"
  status=$?
  set -e
}

report() {
  echo "check_release_inputs_test: $1"$'\n'"  exit: $status"$'\n'"$output" >&2
  failures=$((failures + 1))
}

leaks() {
  local secret
  for secret in "${secrets[@]}"; do
    if [[ "$output" == *"$secret"* ]]; then
      report "$1: the output leaks a value"
      return 0
    fi
  done
  return 1
}

expect_pass() {
  local name="$1" profile="$2"
  shift 2
  run "$profile" "$@"
  if [[ $status -ne 0 ]]; then
    report "$name: should pass"
  elif ! leaks "$name"; then
    echo "$name: passes (expected)"
  fi
}

# $1 case name, $2 profile, $3 the number of problems expected, then the
# messages expected, then -- and the environment pairs.
expect_fail() {
  local name="$1" profile="$2" count="$3" message
  shift 3
  local messages=()
  while [[ "$1" != "--" ]]; do messages+=("$1"); shift; done
  shift
  run "$profile" "$@"
  if [[ $status -ne 1 ]]; then
    report "$name: should fail with exit 1"
    return
  fi
  if [[ "$output" != *"($count problem(s))"* ]]; then
    report "$name: should report $count problem(s)"
    return
  fi
  for message in "${messages[@]}"; do
    if [[ "$output" != *"$message"* ]]; then
      report "$name: should report '$message'"
      return
    fi
  done
  leaks "$name" || echo "$name: refused (expected)"
}

# Replaces one NAME=value pair of valid_internal (an empty value unsets it).
internal_with() {
  local name="$1" value="$2" pair
  with=()
  for pair in "${valid_internal[@]}"; do
    if [[ "${pair%%=*}" == "$name" ]]; then
      [[ -z "$value" ]] || with+=("$name=$value")
    else
      with+=("$pair")
    fi
  done
}

expect_pass "internal: every input valid" internal "${valid_internal[@]}"

expect_fail "internal: nothing configured" internal 8 \
  "secret PLAY_INTERNAL_SA_JSON (environment play-internal): missing or empty" \
  "secret FIREBASE_PROD_DEFINES_JSON_B64 (environment play-internal): missing or empty" \
  "variable GOOGLE_SERVER_CLIENT_ID (environment play-internal): missing or empty" \
  "Settings > Environments > play-internal" --

with=()
for pair in "${valid_internal[@]}"; do
  case "${pair%%=*}" in ANDROID_UPLOAD_KEY_ALIAS | ANDROID_UPLOAD_KEY_PASSWORD) ;; *) with+=("$pair") ;; esac
done
expect_fail "internal: two secrets missing together" internal 2 \
  "secret ANDROID_UPLOAD_KEY_ALIAS (environment play-internal): missing or empty" \
  "secret ANDROID_UPLOAD_KEY_PASSWORD (environment play-internal): missing or empty" -- "${with[@]}"

internal_with GOOGLE_SERVER_CLIENT_ID "   "
expect_fail "internal: variable blank" internal 1 \
  "variable GOOGLE_SERVER_CLIENT_ID (environment play-internal): missing or empty" -- "${with[@]}"

internal_with ANDROID_UPLOAD_KEYSTORE_B64 'not*base64!'
expect_fail "internal: keystore not Base64" internal 1 \
  "secret ANDROID_UPLOAD_KEYSTORE_B64 (environment play-internal): not valid Base64" -- "${with[@]}"

internal_with FIREBASE_PROD_DEFINES_JSON_B64 "===="
expect_fail "internal: defines only Base64 padding (nothing to decode)" internal 1 \
  "FIREBASE_PROD_DEFINES_JSON_B64 (environment play-internal): not valid Base64" -- "${with[@]}"

internal_with FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64 "$(b64_text '{"project_info":')"
expect_fail "internal: google-services not JSON" internal 1 \
  "secret FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64 (environment play-internal): not a valid JSON object" -- "${with[@]}"

internal_with FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64 \
  "$(jq -c '.client[0].client_info.android_client_info.package_name = "com.example.other"' "$fixtures/google_services.json" | base64 | tr -d '\n')"
expect_fail "internal: google-services for another package" internal 1 \
  "no client for the package com.vinoozy.app" -- "${with[@]}"

internal_with FIREBASE_PROD_DEFINES_JSON_B64 \
  "$(jq -c 'del(.FIREBASE_APP_ID) | .FIREBASE_PROJECT_ID = ""' "$fixtures/defines.json" | base64 | tr -d '\n')"
expect_fail "internal: defines incomplete" internal 1 \
  "missing define FIREBASE_APP_ID, FIREBASE_PROJECT_ID" -- "${with[@]}"

internal_with PLAY_INTERNAL_SA_JSON "$(jq -c '.type = "authorized_user"' "$fixtures/service_account.json")"
expect_fail "internal: not a service account" internal 1 \
  "secret PLAY_INTERNAL_SA_JSON (environment play-internal): field type is not service_account" -- "${with[@]}"

internal_with PLAY_INTERNAL_SA_JSON "$(b64 "$fixtures/service_account.json")"
expect_fail "internal: service account given in Base64" internal 1 \
  "secret PLAY_INTERNAL_SA_JSON (environment play-internal): not a valid JSON object" -- "${with[@]}"

internal_with PLAY_INTERNAL_SA_JSON "$(jq -c 'del(.private_key)' "$fixtures/service_account.json")"
expect_fail "internal: service account without key" internal 1 \
  "missing field private_key" -- "${with[@]}"

expect_pass "production: service account valid" production PLAY_PRODUCTION_SA_JSON="$sa_json"

expect_fail "production: nothing configured" production 1 \
  "secret PLAY_PRODUCTION_SA_JSON (environment play-production): missing or empty" \
  "Settings > Environments > play-production" --

set +e
output="$("$check" --profile staging 2>&1)"
status=$?
set -e
if [[ $status -ne 2 ]]; then report "unknown profile: should exit 2"; else echo "unknown profile: refused (expected)"; fi

if [[ $failures -gt 0 ]]; then
  echo "check_release_inputs_test: $failures failure(s)" >&2
  exit 1
fi
echo "check_release_inputs_test: OK"
