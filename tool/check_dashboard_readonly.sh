#!/usr/bin/env bash
# Read-only gate of the Dashboard (u5-dashboard security-design.md §1,
# NFR4.1; cicd-pipeline.md §1, job `analyze`). It checks imports and the
# names of the write providers, not methods, so `List.add` and `Map.update`
# of the calculator stay allowed. It fails when, in the checked folder:
#   1. a file imports package:cloud_firestore, package:firebase_auth,
#      package:firebase_storage, cellar/data/wine_repository.dart,
#      cellar/data/cellar_repository.dart, cellar/data/retry.dart,
#      sync/sync_watcher.dart, sync/sync_gateway.dart or anything under
#      sync/ledger/. The shared OfflineBanner (sync/ui/) stays allowed: it
#      reads the sync status the Cellar tab already uses;
#   2. a file names wineRepositoryProvider, cellarRepositoryProvider,
#      localLedgerProvider or syncWatcherProvider;
#   3. a file of domain/ imports package:flutter*, package:firebase_* or
#      package:shared_preferences (the pure core runs with `dart run`);
#   4. package:shared_preferences appears outside dashboard_providers.dart.
#
# Usage: tool/check_dashboard_readonly.sh [folder]   (default: lib/dashboard)
# Uses only grep and find (present on ubuntu-latest and macOS).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
dir="${1:-lib/dashboard}"
dir="${dir%/}"

if [[ ! -d "$dir" ]]; then
  echo "check_dashboard_readonly: folder '$dir' not found" >&2
  exit 2
fi
if [[ ! -d "$dir/domain" ]]; then
  echo "check_dashboard_readonly: folder '$dir/domain' not found" >&2
  exit 2
fi

failures=0
fail() {
  echo "check_dashboard_readonly: $*" >&2
  failures=$((failures + 1))
}

import_line="^[[:space:]]*(import|export)[[:space:]]+['\"]"

# 1. No Firebase SDK, no write repository, no ledger.
forbidden_imports="$(grep -RInE --include='*.dart' \
  "${import_line}(package:(cloud_firestore|firebase_auth|firebase_storage)/|[^'\"]*cellar/data/(wine_repository|cellar_repository|retry)\.dart|[^'\"]*sync/ledger/|[^'\"]*sync/(sync_watcher|sync_gateway)\.dart)" \
  "$dir" || true)"
if [[ -n "$forbidden_imports" ]]; then
  fail "write access imported in $dir:"$'\n'"$forbidden_imports"
fi

# 2. No write provider named anywhere.
write_providers="$(grep -RInwE --include='*.dart' \
  'wineRepositoryProvider|cellarRepositoryProvider|localLedgerProvider|syncWatcherProvider' \
  "$dir" || true)"
if [[ -n "$write_providers" ]]; then
  fail "write provider used in $dir:"$'\n'"$write_providers"
fi

# 3. A pure Dart domain.
impure="$(grep -RInE --include='*.dart' \
  "${import_line}(package:(flutter[a-z_]*|firebase_[a-z_]*|shared_preferences)/|dart:ui)" \
  "$dir/domain" || true)"
if [[ -n "$impure" ]]; then
  fail "$dir/domain must not import Flutter, Firebase or shared_preferences:"$'\n'"$impure"
fi

# 4. The breakdown preference is the only local write, in one file.
prefs="$(grep -RIlE --include='*.dart' 'package:shared_preferences/' "$dir" |
  grep -vE "(^|/)dashboard_providers\.dart$" || true)"
if [[ -n "$prefs" ]]; then
  fail "shared_preferences outside $dir/dashboard_providers.dart:"$'\n'"$prefs"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_dashboard_readonly: FAILED ($failures check(s))" >&2
  exit 1
fi
count="$(find "$dir" -name '*.dart' -type f | wc -l | tr -d ' ')"
echo "check_dashboard_readonly: OK ($count files in $dir are read-only)"
