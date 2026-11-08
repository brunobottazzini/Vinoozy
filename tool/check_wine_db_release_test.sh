#!/usr/bin/env bash
# Test of tool/check_wine_db_release.sh (label-recognition BR2.4; review
# R-02): the check must pass on a real-looking manifest and refuse the
# sample of the app, so a broken check never lets the sample reach
# production in silence.
#
#   tool/fixtures/wine_db_release/ok.json            12345 wines, Open Food Facts (passes)
#   tool/fixtures/wine_db_release/floor.json         exactly 5000 wines (passes)
#   tool/fixtures/wine_db_release/small.json         4999 wines (fails)
#   tool/fixtures/wine_db_release/sample_large.json  20000 wines but "sample" (fails)
#   tool/fixtures/wine_db_release/other_source.json  an unknown source (fails)
#   tool/fixtures/wine_db_release/broken.json        not valid JSON (fails)
#   tool/fixtures/wine_db_release/sample.json        the sample as built today (fails)
#
# The manifest of the app is not used here: it is the sample until the
# release, and this test must stay green once the real database is built.
#
# Usage: tool/check_wine_db_release_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_wine_db_release.sh"
fixtures="tool/fixtures/wine_db_release"

failures=0

expect_pass() {
  local file="$1" output
  if output="$("$check" "$file" 2>&1)"; then
    echo "$file: passes (expected)"
  else
    echo "check_wine_db_release_test: $file should pass but failed:"$'\n'"$output" >&2
    failures=$((failures + 1))
  fi
}

# $1 the manifest, $2 the exit code expected, then the messages expected.
expect_fail() {
  local file="$1" expected_status="$2" output status message
  shift 2
  set +e
  output="$("$check" "$file" 2>&1)"
  status=$?
  set -e
  if [[ $status -ne $expected_status ]]; then
    echo "check_wine_db_release_test: $file should fail with exit $expected_status, got $status:"$'\n'"$output" >&2
    failures=$((failures + 1))
    return
  fi
  for message in "$@"; do
    if [[ "$output" != *"$message"* ]]; then
      echo "check_wine_db_release_test: $file should report '$message':"$'\n'"$output" >&2
      failures=$((failures + 1))
      return
    fi
  done
  echo "$file: refused (expected)"
}

expect_pass "$fixtures/ok.json"
expect_pass "$fixtures/floor.json"
expect_fail "$fixtures/small.json" 1 'only 4999 wines, at least 5000 expected'
expect_fail "$fixtures/sample_large.json" 1 'source is "sample"'
expect_fail "$fixtures/other_source.json" 1 'source is "somewhere else"'
expect_fail "$fixtures/broken.json" 1 'not a manifest with a whole wineCount'
expect_fail "$fixtures/missing.json" 2 'not found'
# What tool/build_wine_db.dart --allow-small-sample writes for the sample.
expect_fail "$fixtures/sample.json" 1 'only 45 wines' 'source is "sample"'

if [[ $failures -gt 0 ]]; then
  echo "check_wine_db_release_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_wine_db_release_test: OK"
