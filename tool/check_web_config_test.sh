#!/usr/bin/env bash
# Test of tool/check_web_config.mjs (u8-account review R-04): it must pass on
# a filled configuration and fail, naming each problem, on the others, so a
# broken check never lets pages.yml publish an unconfigured page.
#
#   tool/fixtures/web_config/ok.js                  passes
#   tool/fixtures/web_config/todo_double_quotes.js  TODO in double quotes
#   tool/fixtures/web_config/emulators.js           emulators set, empty
#                                                   reCAPTCHA site key
#   tool/fixtures/web_config/placeholders.js       the unfilled configuration;
#                                                   independent of real setup
#
# Usage: tool/check_web_config_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check=(node tool/check_web_config.mjs)
fixtures="tool/fixtures/web_config"

failures=0

expect_fail() {
  local file="$1"
  shift
  local output status
  set +e
  output="$("${check[@]}" "$file" 2>&1)"
  status=$?
  set -e
  if [[ $status -ne 1 ]]; then
    echo "check_web_config_test: $file should fail with exit 1, got $status:"$'\n'"$output" >&2
    failures=$((failures + 1))
    return
  fi
  local expected
  for expected in "$@"; do
    if [[ "$output" == *"$expected"* ]]; then
      echo "$file: reports \"$expected\" (expected)"
    else
      echo "check_web_config_test: $file does not report \"$expected\":"$'\n'"$output" >&2
      failures=$((failures + 1))
    fi
  done
}

if output="$("${check[@]}" "$fixtures/ok.js" 2>&1)"; then
  echo "ok.js: passes (expected)"
else
  echo "check_web_config_test: ok.js should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

expect_fail "$fixtures/todo_double_quotes.js" "firebaseConfig.apiKey is empty or still TODO"
expect_fail "$fixtures/emulators.js" "emulators must be null" "recaptchaSiteKey is empty or still TODO"
expect_fail "$fixtures/placeholders.js" \
  "firebaseConfig.apiKey is empty or still TODO" \
  "firebaseConfig.appId is empty or still TODO" \
  "recaptchaSiteKey is empty or still TODO"

if "${check[@]}" "$fixtures/absent.js" >/dev/null 2>&1; then
  echo "check_web_config_test: a missing file should not pass" >&2
  failures=$((failures + 1))
else
  echo "missing file: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_web_config_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_web_config_test: OK"
