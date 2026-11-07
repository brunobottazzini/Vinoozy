#!/usr/bin/env bash
# Test of tool/check_label_imports.sh (u6-label-recognition cicd-pipeline.md
# §1): the check must pass on a clean folder and fail on one that imports
# Firestore, so a broken check never passes in silence.
#
#   tool/fixtures/label_imports/ok/                label code without the cloud
#   tool/fixtures/label_imports/firestore_import/  imports cloud_firestore
#
# The fixtures are not compiled: analysis_options.yaml excludes them.
#
# Usage: tool/check_label_imports_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_label_imports.sh"
fixtures="tool/fixtures/label_imports"

failures=0

if output="$("$check" "$fixtures/ok" 2>&1)"; then
  echo "ok/: passes (expected)"
else
  echo "check_label_imports_test: ok/ should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$fixtures/firestore_import" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 && "$output" == *"cloud_firestore"* ]]; then
  echo "firestore_import/: fails on cloud_firestore (expected)"
else
  echo "check_label_imports_test: firestore_import/ should fail with exit 1 on cloud_firestore, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

if "$check" "$fixtures/missing" >/dev/null 2>&1; then
  echo "check_label_imports_test: a missing folder should not pass" >&2
  failures=$((failures + 1))
else
  echo "missing folder: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_label_imports_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_label_imports_test: OK"
