#!/usr/bin/env bash
# Test of tool/check_web_pins.sh (u8-account NFR4.7): it must pass on the
# real page and fail, naming each problem, on a page that breaks every rule,
# so a broken check never passes in silence.
#
#   docs/account-deletion/        the real page (passes)
#   tool/fixtures/web_pins/bad/   a different bundle that imports a remote
#                                 URL, inline and remote scripts, an event
#                                 handler, a CSP with an extra origin and
#                                 'unsafe-inline', no en/ page, pt-BR/ with
#                                 the wrong lang and no CSP
#
# Usage: tool/check_web_pins_test.sh (after `npm ci`)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_web_pins.sh"
bad="tool/fixtures/web_pins/bad"

failures=0

if output="$("$check" 2>&1)"; then
  echo "docs/account-deletion: passes (expected)"
else
  echo "check_web_pins_test: the real page should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$bad" 2>&1)"
status=$?
set -e
if [[ $status -ne 1 ]]; then
  echo "check_web_pins_test: bad/ should fail with exit 1, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi
for expected in \
  "app.bundle.js differs from the rebuilt bundle" \
  "app.bundle.js imports a remote URL" \
  "index.html: inline <script> without src" \
  "is not relative" \
  "on* event handler attribute" \
  "allows unsafe-inline or unsafe-eval" \
  "extra: https://cdn.example.com" \
  "en/index.html is missing" \
  "pt-BR/index.html has no lang=\"pt-BR\"" \
  "pt-BR/index.html has no Content-Security-Policy meta tag"; do
  if [[ "$output" == *"$expected"* ]]; then
    echo "bad/: reports \"$expected\" (expected)"
  else
    echo "check_web_pins_test: bad/ does not report \"$expected\":"$'\n'"$output" >&2
    failures=$((failures + 1))
  fi
done

if "$check" "tool/fixtures/web_pins/absent" >/dev/null 2>&1; then
  echo "check_web_pins_test: a missing folder should not pass" >&2
  failures=$((failures + 1))
else
  echo "missing folder: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_web_pins_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_web_pins_test: OK"
