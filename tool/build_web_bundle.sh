#!/usr/bin/env bash
# Builds docs/account-deletion/app.bundle.js (u8-account
# infrastructure-specification.md, "Correzioni dopo la revisione"): the page
# entry point page.js, account-deletion.js and the Firebase JS SDK modules
# they use, in one self-contained ES module with no external import.
#
# The only import kept outside is ./firebase-config.js, the public web
# configuration the owner fills without rebuilding the bundle.
#
# The build is reproducible: the pinned esbuild and firebase of package.json
# (installed with `npm ci`), no source map, no legal comments, no date. The
# same inputs give the same bytes, which tool/check_web_pins.sh compares.
#
# Usage: tool/build_web_bundle.sh [outfile]
#   default outfile: docs/account-deletion/app.bundle.js
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
out="${1:-docs/account-deletion/app.bundle.js}"

esbuild="node_modules/.bin/esbuild"
if [[ ! -x "$esbuild" ]]; then
  echo "build_web_bundle: $esbuild missing, run 'npm ci' first" >&2
  exit 2
fi

wanted="$(node -p "require('./package.json').devDependencies.firebase")"
installed="$(node -p "require('./node_modules/firebase/package.json').version")"
if [[ "$wanted" != "$installed" ]]; then
  echo "build_web_bundle: firebase $installed installed, package.json pins $wanted: run 'npm ci'" >&2
  exit 2
fi

"$esbuild" docs/account-deletion/page.js \
  --bundle \
  --format=esm \
  --platform=browser \
  --target=es2020 \
  --minify \
  --legal-comments=none \
  --charset=utf8 \
  --external:./firebase-config.js \
  --log-level=warning \
  --outfile="$out"

echo "build_web_bundle: wrote $out (firebase $installed)"
