#!/usr/bin/env bash
# Test of tool/check_appellations_release.sh (label-autofill-windows BR3.6,
# BR6.3; code generation review R-04): the check must pass on a
# real-looking manifest that describes its generated file, and refuse the
# sample, a manifest that does not match its table and a broken manifest,
# so a broken check never lets the sample table reach production in
# silence.
#
#   tool/fixtures/appellations_release/ok.json            1650, registers, 2 rows (passes)
#   tool/fixtures/appellations_release/floor.json         exactly 1500 (passes)
#   tool/fixtures/appellations_release/small.json         1499 (fails)
#   tool/fixtures/appellations_release/sample_large.json  2000 but "sample" (fails)
#   tool/fixtures/appellations_release/other_source.json  an unknown source (fails)
#   tool/fixtures/appellations_release/broken.json        not valid JSON (fails)
#   tool/fixtures/appellations_release/no_rows.json       no generatedRows (fails)
#   ok.json with sample.g.dart       the file says "sample" (fails)
#   ok.json with three_rows.g.dart   3 rows, the manifest says 2 (fails)
#   ok.json with a missing .g.dart   (exit 2)
#   the manifest and the generated file of the package: passes once the
#   table is built from the registers, refused while it is the sample.
#
# The manifests of the folder are checked against its appellations.g.dart
# (registers, 2 rows), the default generated file next to a manifest.
#
# Usage: tool/check_appellations_release_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_appellations_release.sh"
fixtures="tool/fixtures/appellations_release"

failures=0

# $@ the arguments of the check.
expect_pass() {
  local output
  if output="$("$check" "$@" 2>&1)"; then
    echo "$*: passes (expected)"
  else
    echo "check_appellations_release_test: $* should pass but failed:"$'\n'"$output" >&2
    failures=$((failures + 1))
  fi
}

# $1 the exit code expected, $2 the message expected, then the arguments of
# the check.
expect_fail() {
  local expected_status="$1" message="$2" output status
  shift 2
  set +e
  output="$("$check" "$@" 2>&1)"
  status=$?
  set -e
  if [[ $status -ne $expected_status ]]; then
    echo "check_appellations_release_test: $* should fail with exit $expected_status, got $status:"$'\n'"$output" >&2
    failures=$((failures + 1))
    return
  fi
  if [[ "$output" != *"$message"* ]]; then
    echo "check_appellations_release_test: $* should report '$message':"$'\n'"$output" >&2
    failures=$((failures + 1))
    return
  fi
  echo "$*: refused (expected)"
}

expect_pass "$fixtures/ok.json"
expect_pass "$fixtures/floor.json"
expect_pass "$fixtures/ok.json" "$fixtures/appellations.g.dart"
expect_fail 1 'only 1499 appellations' "$fixtures/small.json"
expect_fail 1 'source is "sample"' "$fixtures/sample_large.json"
expect_fail 1 'source is "Somewhere"' "$fixtures/other_source.json"
expect_fail 1 'not a manifest' "$fixtures/broken.json"
expect_fail 1 'no generatedRows' "$fixtures/no_rows.json"
expect_fail 2 'not found' "$fixtures/missing.json"
expect_fail 1 'the generated file says source "sample"' \
  "$fixtures/ok.json" "$fixtures/sample.g.dart"
expect_fail 1 'has 3 rows but the manifest says 2' \
  "$fixtures/ok.json" "$fixtures/three_rows.g.dart"
expect_fail 2 'generated file' "$fixtures/ok.json" "$fixtures/missing.g.dart"

# The package table: refused while it is the sample, passes once it is
# built from the registers (and its manifest describes it).
package_manifest="packages/estimation/lib/src/generated/appellations_manifest.json"
if [[ "$(jq -r '.source' "$package_manifest")" == "sample" ]]; then
  expect_fail 1 'source is "sample"' "$package_manifest"
else
  expect_pass "$package_manifest"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_appellations_release_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_appellations_release_test: OK"
