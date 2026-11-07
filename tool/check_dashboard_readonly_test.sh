#!/usr/bin/env bash
# Test of tool/check_dashboard_readonly.sh (u5-dashboard security-design.md
# §1): the check must pass on a read-only folder and fail on one that
# imports a write repository, so a broken check never passes in silence.
#
#   tool/fixtures/dashboard_readonly/ok/   calculator with List.add and
#                                          Map.update, shared_preferences
#                                          only in dashboard_providers.dart
#   tool/fixtures/dashboard_readonly/bad/  imports wine_repository.dart
#
# The fixtures are not compiled: analysis_options.yaml excludes them.
#
# Usage: tool/check_dashboard_readonly_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_dashboard_readonly.sh"
fixtures="tool/fixtures/dashboard_readonly"

failures=0

if output="$("$check" "$fixtures/ok" 2>&1)"; then
  echo "ok/: passes (expected)"
else
  echo "check_dashboard_readonly_test: ok/ should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$fixtures/bad" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 && "$output" == *"wine_repository.dart"* ]]; then
  echo "bad/: fails on wine_repository.dart (expected)"
else
  echo "check_dashboard_readonly_test: bad/ should fail with exit 1 on wine_repository.dart, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

if "$check" "$fixtures/missing" >/dev/null 2>&1; then
  echo "check_dashboard_readonly_test: a missing folder should not pass" >&2
  failures=$((failures + 1))
else
  echo "missing folder: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_dashboard_readonly_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_dashboard_readonly_test: OK"
