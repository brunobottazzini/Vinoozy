#!/usr/bin/env bash
# Test of tool/check_firestore_indexes.sh (u7-sharing security-design.md §1,
# u4-cellar NFR4.8): the check must pass on a file with both indexes and fail
# on one without each of them, with the message of the missing index, so a
# broken check never passes in silence.
#
#   tool/fixtures/firestore_indexes/ok.json               both indexes
#   tool/fixtures/firestore_indexes/missing.json          invitations index
#                                                         with a COLLECTION
#                                                         scope only
#   tool/fixtures/firestore_indexes/missing_history.json  History index with
#                                                         createdAt ascending
#
# Usage: tool/check_firestore_indexes_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_firestore_indexes.sh"
fixtures="tool/fixtures/firestore_indexes"

failures=0

if output="$("$check" "$fixtures/ok.json" 2>&1)"; then
  echo "ok.json: passes (expected)"
else
  echo "check_firestore_indexes_test: ok.json should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$fixtures/missing.json" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 && "$output" == *"FAILED, '$fixtures/missing.json' lacks the fieldOverride of members.inviteeEmail"* ]]; then
  echo "missing.json: fails on members.inviteeEmail (expected)"
else
  echo "check_firestore_indexes_test: missing.json should fail with exit 1 on members.inviteeEmail, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$fixtures/missing_history.json" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 &&
  "$output" == *"lacks the composite index of drinkingRecords"* &&
  "$output" != *"lacks the fieldOverride of members.inviteeEmail"* ]]; then
  echo "missing_history.json: fails on the drinkingRecords index only (expected)"
else
  echo "check_firestore_indexes_test: missing_history.json should fail with exit 1 on the drinkingRecords index only, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

if "$check" "$fixtures/absent.json" >/dev/null 2>&1; then
  echo "check_firestore_indexes_test: an absent file should not pass" >&2
  failures=$((failures + 1))
else
  echo "absent file: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_firestore_indexes_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_firestore_indexes_test: OK"
