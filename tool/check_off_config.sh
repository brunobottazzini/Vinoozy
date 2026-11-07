#!/usr/bin/env bash
# Configuration gate of the wine catalog (u3-wine-catalog security-design.md
# §2, performance-design.md; NFR4.3, NFR5.1). Fails when:
#   1. a file of the repository (tracked, or new and not ignored) gives the
#      Open Food Facts contact a value: the name followed by `=` or `:` and a
#      non-empty text. Project documents in aidlc/ and docs/ and this script
#      are excluded. In .github/workflows/ the name may not appear at all:
#      the contact lives only in the production configuration secret;
#   2. a .dart file of lib/ (generated translations in lib/l10n/ excluded)
#      contains an email address;
#   3. a file of lib/catalog/ imports cloud_firestore or cloud_functions;
#   4. a file of lib/catalog/core/ imports Flutter, path_provider or Firebase
#      (the pure core runs with `dart run` for the benchmark).
#
# Usage: tool/check_off_config.sh   (from any directory)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
self="tool/check_off_config.sh"
name="OFF_CONTACT"

failures=0
fail() {
  echo "check_off_config: $*" >&2
  failures=$((failures + 1))
}

# 1. Contact committed with a value, or named in a workflow.
files=()
while IFS= read -r file; do
  case "$file" in
    "$self" | aidlc/* | docs/*) continue ;;
  esac
  [[ -f "$file" ]] && files+=("$file")
done < <(git ls-files --cached --others --exclude-standard | LC_ALL=C sort -u)

if [[ ${#files[@]} -gt 0 ]]; then
  valued="$(grep -InE "${name}[\"']?[[:space:]]*[=:][[:space:]]*[\"']?[^[:space:]\"']" "${files[@]}" || true)"
  if [[ -n "$valued" ]]; then
    fail "the Open Food Facts contact has a committed value:"$'\n'"$valued"
  fi
fi
if [[ -d .github/workflows ]]; then
  in_workflows="$(grep -RIn "$name" .github/workflows || true)"
  if [[ -n "$in_workflows" ]]; then
    fail "workflows must not name the contact (production secret only):"$'\n'"$in_workflows"
  fi
fi

# 2. No email address in the Dart code of lib/.
emails="$(grep -RInE --include='*.dart' --exclude-dir=l10n \
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' lib || true)"
if [[ -n "$emails" ]]; then
  fail "email address in lib/:"$'\n'"$emails"
fi

# 3. No Firestore or Cloud Functions in the catalog (cost 0, NFR5.1).
if [[ -d lib/catalog ]]; then
  cloud="$(grep -RInE --include='*.dart' \
    "^[[:space:]]*(import|export)[[:space:]]+['\"]package:(cloud_firestore|cloud_functions)/" \
    lib/catalog || true)"
  if [[ -n "$cloud" ]]; then
    fail "lib/catalog/ must not use Firestore or Cloud Functions:"$'\n'"$cloud"
  fi
fi

# 4. The core stays pure Dart.
if [[ -d lib/catalog/core ]]; then
  impure="$(grep -RInE --include='*.dart' \
    "^[[:space:]]*(import|export)[[:space:]]+['\"](package:(flutter|flutter_riverpod|path_provider|firebase_[a-z_]*|cloud_[a-z_]*)/|dart:ui)" \
    lib/catalog/core || true)"
  if [[ -n "$impure" ]]; then
    fail "lib/catalog/core/ must not import Flutter, path_provider or Firebase:"$'\n'"$impure"
  fi
else
  fail "lib/catalog/core/ is missing"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_off_config: FAILED ($failures check(s))" >&2
  exit 1
fi
echo "check_off_config: OK (${#files[@]} files checked for the contact)"
