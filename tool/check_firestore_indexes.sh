#!/usr/bin/env bash
# Index check of the queries that need an index in production (cicd-pipeline.md
# §1, job `rules`). The Firestore emulator needs no index, so a missing one
# would fail only in production. Each index has its own message:
#
# - u7-sharing NFR4.7: the invitations query
#   `collectionGroup('members').where('inviteeEmail', ==)` needs a
#   fieldOverride of collection group `members`, field `inviteeEmail`, with an
#   index of queryScope COLLECTION_GROUP, ascending;
# - u4-cellar NFR4.8: the History `drinkingRecords` ordered by `drankOn` and
#   `createdAt`, both descending, needs a composite index of collection group
#   `drinkingRecords`, queryScope COLLECTION, with exactly those two fields.
#
# Usage: tool/check_firestore_indexes.sh [indexes-file]
#   (default: firestore.indexes.json at the repository root)
# Needs jq (present on ubuntu-latest and macOS with Homebrew).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
file="${1:-$root/firestore.indexes.json}"

if ! command -v jq >/dev/null 2>&1; then
  echo "check_firestore_indexes: jq is required" >&2
  exit 2
fi
if [[ ! -s "$file" ]]; then
  echo "check_firestore_indexes: '$file' is missing or empty" >&2
  exit 2
fi

if ! jq -e '.' "$file" >/dev/null 2>&1; then
  echo "check_firestore_indexes: '$file' is not valid JSON" >&2
  exit 1
fi

failures=0

if jq -e '
  [.fieldOverrides[]?
    | select(.collectionGroup == "members" and .fieldPath == "inviteeEmail")
    | .indexes[]?
    | select(.queryScope == "COLLECTION_GROUP" and .order == "ASCENDING")]
  | length > 0
' "$file" >/dev/null; then
  echo "check_firestore_indexes: OK (members.inviteeEmail, COLLECTION_GROUP, ascending)"
else
  echo "check_firestore_indexes: FAILED, '$file' lacks the fieldOverride of members.inviteeEmail with queryScope COLLECTION_GROUP and order ASCENDING" >&2
  failures=$((failures + 1))
fi

if jq -e '
  [.indexes[]?
    | select(.collectionGroup == "drinkingRecords" and .queryScope == "COLLECTION")
    | select([.fields[]? | {fieldPath, order}] == [
        {"fieldPath": "drankOn", "order": "DESCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ])]
  | length > 0
' "$file" >/dev/null; then
  echo "check_firestore_indexes: OK (drinkingRecords drankOn DESC, createdAt DESC, COLLECTION)"
else
  echo "check_firestore_indexes: FAILED, '$file' lacks the composite index of drinkingRecords (drankOn DESCENDING, createdAt DESCENDING, queryScope COLLECTION) of the History" >&2
  failures=$((failures + 1))
fi

if [[ $failures -gt 0 ]]; then
  exit 1
fi
