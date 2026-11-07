#!/usr/bin/env bash
# Every business rule has at least one test with its ID in the test name
# (u4-cellar NFR7.2, tech-stack-decisions.md; job `analyze`).
#
# For each ID from <prefix>1 to <prefix><max> (e.g. BR1.1 ... BR1.20) the
# check looks for the ID as a whole word, so BR1.1 is not found by BR1.10,
# only in the first string argument of a test:
#   - Dart files (*_test.dart): test(, testWidgets(, group(;
#   - JavaScript files (*.test.mjs, *.test.js): test(, it(.
# Adjacent string literals ('a ' 'b') count as one name, as in Dart. IDs in
# comments or in the test bodies do not count. It fails listing every ID
# with no test.
#
# Usage: tool/check_rule_ids.sh <prefix> <max> <path...>
#   tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs
# A path is a test file or a folder searched recursively. Needs perl
# (present on ubuntu-latest and macOS).
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "usage: $0 <prefix> <max> <path...>" >&2
  exit 2
fi

prefix="$1"
max="$2"
shift 2

if ! [[ "$max" =~ ^[1-9][0-9]*$ ]]; then
  echo "check_rule_ids: <max> must be a positive integer, got '$max'" >&2
  exit 2
fi

files=()
for path in "$@"; do
  if [[ -d "$path" ]]; then
    while IFS= read -r file; do
      files+=("$file")
    done < <(find "$path" -type f \( -name '*_test.dart' -o -name '*.test.mjs' -o -name '*.test.js' \) | sort)
  elif [[ -f "$path" ]]; then
    files+=("$path")
  else
    echo "check_rule_ids: '$path' does not exist" >&2
    exit 2
  fi
done

if [[ ${#files[@]} -eq 0 ]]; then
  echo "check_rule_ids: no test files in $*" >&2
  exit 2
fi

# The names of every test in the files, one per line.
names="$(perl -0777 -ne '
  my $is_js = $ARGV =~ /\.(?:mjs|js)$/;
  my $calls = $is_js ? qr/\b(?:test|it)\(/ : qr/\b(?:testWidgets|test|group)\(/;
  my $literal = qr/(?:\x27(?:[^\x27\\]|\\.)*\x27|"(?:[^"\\]|\\.)*"|`[^`]*`)/s;
  while (/$calls\s*((?:$literal\s*)+)/g) {
    my $name = $1;
    $name =~ s/\s+/ /g;
    print "$name\n";
  }
' "${files[@]}")"

missing=()
escaped_prefix="$(printf '%s' "$prefix" | sed 's/[.[\*^$()+?{}|]/\\&/g')"
for ((n = 1; n <= max; n++)); do
  if ! grep -Eq "(^|[^A-Za-z0-9_.])${escaped_prefix}${n}([^0-9]|$)" <<<"$names"; then
    missing+=("${prefix}${n}")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "check_rule_ids: FAILED, no test names ${missing[*]} in ${*}" >&2
  exit 1
fi
echo "check_rule_ids: OK (${prefix}1-${prefix}${max} in ${#files[@]} files)"
