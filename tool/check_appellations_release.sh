#!/usr/bin/env bash
# The generated appellation table may go to production (label-autofill-
# windows BR3.6, BR6.3, FR3.1). Fails when the manifest written by
# tool/build_appellations.dart:
#   1. is missing or is not a JSON object with a whole `appellationCount`;
#   2. counts fewer than 1500 appellations (FR3.1);
#   3. has `"source": "sample"`, or any source but the registers: the table
#      built with --allow-sample from tool/fixtures/eambrosia_sample.csv is
#      a sample and must never reach production, as the sample wine
#      database (tool/check_wine_db_release.sh);
#   4. does not describe the generated Dart file the app uses (code
#      generation review R-04): the `generatedAppellationsSource` constant
#      of the `.g.dart` must be the manifest's `source`, and its rows must be
#      the manifest's `generatedRows`. A manifest regenerated or edited by
#      hand apart from its table is refused.
#
# Run by .github/workflows/promote.yml on the manifest and the generated
# file of the build being promoted, before Google Play is asked anything.
# Not run on the internal testing track, where the sample is allowed.
#
# Usage: tool/check_appellations_release.sh [manifest] [generated.g.dart]
#   default manifest: packages/estimation/lib/src/generated/appellations_manifest.json
#   default generated file: appellations.g.dart next to the manifest
# Uses jq (present on ubuntu-latest and macOS).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
manifest="${1:-packages/estimation/lib/src/generated/appellations_manifest.json}"
generated="${2:-$(dirname "$manifest")/appellations.g.dart}"
min_appellations=1500
expected_source="eAmbrosia and official national registers"

if [[ ! -f "$manifest" ]]; then
  echo "check_appellations_release: '$manifest' not found" >&2
  exit 2
fi
if [[ ! -f "$generated" ]]; then
  echo "check_appellations_release: generated file '$generated' not found" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "check_appellations_release: jq is required" >&2
  exit 2
fi

if ! count="$(jq -er 'if type == "object" and (.appellationCount | type) == "number" and .appellationCount == (.appellationCount | floor) then .appellationCount else error("no whole appellationCount") end' "$manifest" 2>/dev/null)"; then
  echo "check_appellations_release: FAILED, '$manifest' is not a manifest with a whole appellationCount" >&2
  exit 1
fi
table_source="$(jq -r '.source // "missing"' "$manifest")"
manifest_rows="$(jq -r 'if (.generatedRows | type) == "number" then .generatedRows else "missing" end' "$manifest")"

# The constant may be on one line or split after `=` by dart format.
file_source="$(tr '\n' ' ' < "$generated" |
  sed -n "s/.*const String generatedAppellationsSource = *'\([^']*\)';.*/\1/p")"
file_rows="$(grep -c "^  '" "$generated" || true)"

failures=0
fail() {
  echo "check_appellations_release: $*" >&2
  failures=$((failures + 1))
}

if [[ "$count" -lt "$min_appellations" ]]; then
  fail "only $count appellations, at least $min_appellations expected: build the table from the real eAmbrosia export (docs/release-checklist.md)"
fi
if [[ "$table_source" == "sample" ]]; then
  fail "source is \"sample\": the table built with --allow-sample never goes to production"
elif [[ "$table_source" != "$expected_source" ]]; then
  fail "source is \"$table_source\", \"$expected_source\" expected"
fi
if [[ -z "$file_source" ]]; then
  fail "'$generated' has no generatedAppellationsSource constant"
elif [[ "$file_source" != "$table_source" ]]; then
  fail "the generated file says source \"$file_source\" but the manifest says \"$table_source\": manifest and table do not match"
fi
if [[ "$manifest_rows" == "missing" ]]; then
  fail "the manifest has no generatedRows"
elif [[ "$file_rows" != "$manifest_rows" ]]; then
  fail "the generated file has $file_rows rows but the manifest says $manifest_rows: manifest and table do not match"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_appellations_release: FAILED ($failures check(s)), the build must not be promoted" >&2
  exit 1
fi
echo "check_appellations_release: OK ($count appellations from the registers, $file_rows generated rows matching the manifest)"
