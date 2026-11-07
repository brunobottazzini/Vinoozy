#!/usr/bin/env bash
# Test of tool/check_rule_ids.sh (u4-cellar NFR7.2): the check must pass on a
# folder that names every rule and fail on one where BR1.1 appears only as
# part of BR1.10 or outside test names, so a broken check never passes in
# silence.
#
#   tool/fixtures/rule_ids/ok/             BR1.1-BR1.3 in Dart and JS names
#   tool/fixtures/rule_ids/missing_br1_1/  BR1.10, BR1.2, BR1.3; BR1.1 only
#                                          in comments and bodies
#
# The fixtures are not compiled: analysis_options.yaml excludes them.
#
# Usage: tool/check_rule_ids_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_rule_ids.sh"
fixtures="tool/fixtures/rule_ids"

failures=0

if output="$("$check" BR1. 3 "$fixtures/ok" 2>&1)"; then
  echo "ok/: passes (expected)"
else
  echo "check_rule_ids_test: ok/ should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" BR1. 3 "$fixtures/missing_br1_1" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 && "$output" == *"no test names BR1.1 in"* ]]; then
  echo "missing_br1_1/: fails on BR1.1 only (expected)"
else
  echo "check_rule_ids_test: missing_br1_1/ should fail with exit 1 on BR1.1, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

if "$check" BR1. 3 "$fixtures/absent" >/dev/null 2>&1; then
  echo "check_rule_ids_test: a missing folder should not pass" >&2
  failures=$((failures + 1))
else
  echo "missing folder: refused (expected)"
fi

if "$check" BR1. zero "$fixtures/ok" >/dev/null 2>&1; then
  echo "check_rule_ids_test: a bad maximum should not pass" >&2
  failures=$((failures + 1))
else
  echo "bad maximum: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_rule_ids_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_rule_ids_test: OK"
