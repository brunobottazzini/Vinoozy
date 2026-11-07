#!/usr/bin/env bash
# Fails when line coverage in an lcov file is below a threshold (NFR7.1).
#
# Usage: tool/check_coverage.sh <min-percent> [lcov-file] [path-prefix]
#   tool/check_coverage.sh 80                       # reads coverage/lcov.info
#   tool/check_coverage.sh 80 coverage/u1.lcov.info
#   tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/
#
# With a path prefix only the files whose `SF:` path starts with it count
# (u3-wine-catalog NFR7.1); without it every file counts, as before.
#
# The threshold is an input from team.md (80% of lines, no exclusions): never
# lower it to make a build pass.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <min-percent> [lcov-file] [path-prefix]" >&2
  exit 2
fi

min="$1"
lcov="${2:-coverage/lcov.info}"
prefix="${3:-}"

if ! [[ "$min" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "check_coverage: threshold must be a number, got '$min'" >&2
  exit 2
fi
if [[ ! -s "$lcov" ]]; then
  echo "check_coverage: lcov file '$lcov' is missing or empty" >&2
  exit 2
fi

awk -F: -v min="$min" -v prefix="$prefix" '
  BEGIN { include = 1 }
  /^SF:/ {
    path = substr($0, 4)
    include = (prefix == "" || index(path, prefix) == 1)
  }
  include && /^LF:/ { found += $2 }
  include && /^LH:/ { hit += $2 }
  END {
    if (found == 0) {
      print "check_coverage: no instrumented lines found" > "/dev/stderr"
      exit 2
    }
    pct = 100 * hit / found
    scope = (prefix == "") ? "" : " of " prefix
    printf "Line coverage%s: %.2f%% (%d/%d lines), minimum %s%%\n", scope, pct, hit, found, min
    if (pct + 1e-9 < min) {
      print "check_coverage: FAILED, coverage below the minimum" > "/dev/stderr"
      exit 1
    }
  }
' "$lcov"
