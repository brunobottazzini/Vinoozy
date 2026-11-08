#!/usr/bin/env bash
# The offline wine database may go to production (label-recognition BR2.4,
# BR6.2; code-generation review R-02). Fails when the manifest:
#   1. is missing or is not a JSON object with a whole `wineCount`;
#   2. has fewer than 5000 wines (the plausibility floor of BR2.4);
#   3. has `"source": "sample"`, or any source but "Open Food Facts": the
#      hand-written sample of tool/fixtures/ (built with
#      --allow-small-sample) has invented barcodes and must never reach
#      production, nor be shown as Open Food Facts data.
#
# Run by .github/workflows/promote.yml on the manifest of the build being
# promoted, before Google Play is asked anything. Not run on the internal
# testing track, where the sample is allowed.
#
# Usage: tool/check_wine_db_release.sh [manifest]
#   default: assets/wine_db/manifest.json
# Uses jq (present on ubuntu-latest and macOS).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
manifest="${1:-assets/wine_db/manifest.json}"
min_wines=5000

if [[ ! -f "$manifest" ]]; then
  echo "check_wine_db_release: '$manifest' not found" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "check_wine_db_release: jq is required" >&2
  exit 2
fi

if ! count="$(jq -er 'if type == "object" and (.wineCount | type) == "number" and .wineCount == (.wineCount | floor) then .wineCount else error("no whole wineCount") end' "$manifest" 2>/dev/null)"; then
  echo "check_wine_db_release: FAILED, '$manifest' is not a manifest with a whole wineCount" >&2
  exit 1
fi
db_source="$(jq -r '.source // "missing"' "$manifest")"

failures=0
fail() {
  echo "check_wine_db_release: $*" >&2
  failures=$((failures + 1))
}

if [[ "$count" -lt "$min_wines" ]]; then
  fail "only $count wines, at least $min_wines expected: build the database from the real Open Food Facts export (docs/release-checklist.md §1-nonies)"
fi
if [[ "$db_source" == "sample" ]]; then
  fail "source is \"sample\": the hand-written sample of tool/fixtures/ never goes to production"
elif [[ "$db_source" != "Open Food Facts" ]]; then
  fail "source is \"$db_source\", \"Open Food Facts\" expected"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_wine_db_release: FAILED ($failures check(s)), the build must not be promoted" >&2
  exit 1
fi
echo "check_wine_db_release: OK ($count wines from Open Food Facts)"
