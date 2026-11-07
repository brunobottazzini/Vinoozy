#!/usr/bin/env bash
# Cloud boundary of the label photo (u6-label-recognition security-design.md
# §1, NFR4.1, NFR5.2; job `analyze`): no file of lib/label/ imports
# package:cloud_firestore or package:firebase_storage. The label module never
# reads or writes Firestore and never uploads an image; saving goes through
# CellarActions of U4.
#
# Usage: tool/check_label_imports.sh [folder]   (default: lib/label)
# Uses only grep and find (present on ubuntu-latest and macOS).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
dir="${1:-lib/label}"
dir="${dir%/}"

if [[ ! -d "$dir" ]]; then
  echo "check_label_imports: folder '$dir' not found" >&2
  exit 2
fi

import_line="^[[:space:]]*(import|export)[[:space:]]+['\"]"
forbidden="$(grep -RInE --include='*.dart' \
  "${import_line}package:(cloud_firestore|firebase_storage)/" \
  "$dir" || true)"

if [[ -n "$forbidden" ]]; then
  echo "check_label_imports: FAILED, Firestore or Storage imported in $dir:"$'\n'"$forbidden" >&2
  exit 1
fi
count="$(find "$dir" -name '*.dart' -type f | wc -l | tr -d ' ')"
echo "check_label_imports: OK ($count files in $dir, no Firestore or Storage)"
