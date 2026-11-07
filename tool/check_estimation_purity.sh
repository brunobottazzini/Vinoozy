#!/usr/bin/env bash
# Purity gate of packages/estimation (security-design.md §1 and §3; NFR4.1,
# NFR4.4, NFR2.2). Fails when:
#   1. the `dependencies:` section of the package pubspec.yaml has an entry;
#   2. a file of lib/ imports or exports anything other than dart:collection,
#      dart:math, a relative path or package:estimation/;
#   3. a non-comment line of lib/ uses a forbidden word: DateTime.now, Random,
#      Stopwatch, Platform, Isolate, Zone or print(;
#   4. lib/ has mutable global state: a column-0 `var ` or `late `
#      declaration, or a `static` field that is neither const nor final;
#   5. `buildAliasIndex(` appears in lib/ other than exactly twice (its
#      definition and the `final aliasIndex = buildAliasIndex();` initialiser).
#
# Usage: tool/check_estimation_purity.sh   (from any directory)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pkg="$script_dir/../packages/estimation"
lib="$pkg/lib"
pubspec="$pkg/pubspec.yaml"

if [[ ! -d "$lib" || ! -f "$pubspec" ]]; then
  echo "check_estimation_purity: $pkg is not the estimation package" >&2
  exit 2
fi

failures=0
fail() {
  echo "check_estimation_purity: $*" >&2
  failures=$((failures + 1))
}

# Every Dart file of lib/, sorted, as relative paths for readable messages.
dart_files=()
while IFS= read -r file; do
  dart_files+=("$file")
done < <(cd "$pkg" && find lib -type f -name '*.dart' | LC_ALL=C sort)

if [[ ${#dart_files[@]} -eq 0 ]]; then
  echo "check_estimation_purity: no Dart files under $lib" >&2
  exit 2
fi

# Prints "path:line:text" for the non-comment lines of every lib/ file.
code_lines() {
  (cd "$pkg" && awk '
    FNR == 1 { in_block = 0 }
    {
      text = $0
      if (in_block) {
        if (text ~ /\*\//) { in_block = 0 }
        next
      }
      if (text ~ /^[ \t]*\/\*/) {
        if (text !~ /\*\//) { in_block = 1 }
        next
      }
      if (text ~ /^[ \t]*\/\//) { next }
      print FILENAME ":" FNR ":" text
    }
  ' "${dart_files[@]}")
}

# 1. No production dependencies.
dependency_entries="$(awk '
  /^dependencies:/ {
    in_section = 1
    rest = $0
    sub(/^dependencies:[ \t]*/, "", rest)
    sub(/[ \t]*#.*$/, "", rest)
    if (rest != "" && rest != "{}") { print NR ": " $0 }
    next
  }
  in_section && /^[^ \t#]/ { in_section = 0 }
  in_section && /^[ \t]+[^ \t#]/ { print NR ": " $0 }
' "$pubspec")"
if [[ -n "$dependency_entries" ]]; then
  fail "pubspec.yaml dependencies must be empty:"$'\n'"$dependency_entries"
fi

# 2. Allowed imports and exports only.
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  uri="$(sed -E "s/^[^:]*:[0-9]+:[[:space:]]*(import|export|part)[[:space:]]+['\"]([^'\"]*)['\"].*/\2/" <<<"$line")"
  case "$uri" in
    dart:collection | dart:math | package:estimation/*) ;;
    *:*) fail "forbidden directive: $line" ;;
    *) ;; # relative path inside the package
  esac
done < <(code_lines | grep -E "^[^:]*:[0-9]+:[[:space:]]*(import|export|part)[[:space:]]+['\"]" || true)

# 3. Forbidden words (whole words) on non-comment lines.
forbidden="$(code_lines | grep -E 'DateTime\.now|(^|[^A-Za-z0-9_])(Random|Stopwatch|Platform|Isolate|Zone)([^A-Za-z0-9_]|$)|(^|[^A-Za-z0-9_])print\(' || true)"
if [[ -n "$forbidden" ]]; then
  fail "forbidden words in lib/:"$'\n'"$forbidden"
fi

# 4. No mutable global state.
globals="$(code_lines | awk -F: '
  {
    text = $0
    sub(/^[^:]*:[0-9]+:/, "", text)
    if (text ~ /^(var|late)[ \t]/) { print; next }
    if (text ~ /(^|[^A-Za-z0-9_])static[ \t]/ && text !~ /static[ \t]+(const|final)[ \t]/) {
      head = text
      sub(/=.*/, "", head)
      # Static methods and getters are not state.
      if (head !~ /\(/ && head !~ /[ \t]get[ \t]/) { print }
    }
  }
')"
if [[ -n "$globals" ]]; then
  fail "mutable global or static state in lib/:"$'\n'"$globals"
fi

# 5. The alias index is built exactly once.
builds="$(code_lines | grep -o 'buildAliasIndex(' | wc -l | tr -d ' ')"
if [[ "$builds" != "2" ]]; then
  fail "expected exactly 2 occurrences of buildAliasIndex( in lib/, found $builds:"$'\n'"$(code_lines | grep 'buildAliasIndex(' || true)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_estimation_purity: FAILED ($failures check(s))" >&2
  exit 1
fi
echo "check_estimation_purity: OK (${#dart_files[@]} files in lib/)"
