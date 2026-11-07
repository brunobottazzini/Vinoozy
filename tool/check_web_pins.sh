#!/usr/bin/env bash
# Checks the account deletion page (u8-account NFR4.7; exact criterion in
# infrastructure-specification.md, "Seconda correzione"; job `analyze` and
# pages.yml):
#   1. app.bundle.js rebuilt with the pinned esbuild and firebase is
#      byte-identical to the one in the repository (run `npm ci` first);
#   2. in every HTML page each <script> has a relative src and no inline
#      code, and there is no inline script at all;
#   3. the bundle has no import of an http(s) URL;
#   4. the CSP of every page lists exactly the origins of
#      tool/fixtures/web_csp_allowed.txt, without 'unsafe-inline' or
#      'unsafe-eval';
#   and the page exists in it, en and pt-BR with the right lang attribute.
# Every failure is listed; the exit status is 1 if there is any.
#
# Usage: tool/check_web_pins.sh [site-dir] [allowed-origins-file]
#   defaults: docs/account-deletion tool/fixtures/web_csp_allowed.txt
# Needs node, perl and the npm devDependencies (`npm ci`).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
site="${1:-docs/account-deletion}"
allowed_file="${2:-tool/fixtures/web_csp_allowed.txt}"

if [[ ! -d "$site" ]]; then
  echo "check_web_pins: '$site' is not a folder" >&2
  exit 2
fi
if [[ ! -f "$allowed_file" ]]; then
  echo "check_web_pins: '$allowed_file' does not exist" >&2
  exit 2
fi

failures=()
fail() { failures+=("$1"); }

# ---- 1. Reproducible bundle ------------------------------------------------
rebuilt="build/check_web_pins/app.bundle.js"
mkdir -p "$(dirname "$rebuilt")"
if ! tool/build_web_bundle.sh "$rebuilt" >/dev/null; then
  fail "the bundle could not be rebuilt (run 'npm ci')"
elif [[ ! -f "$site/app.bundle.js" ]]; then
  fail "$site/app.bundle.js is missing"
elif ! cmp -s "$rebuilt" "$site/app.bundle.js"; then
  fail "$site/app.bundle.js differs from the rebuilt bundle: run tool/build_web_bundle.sh"
fi

# ---- 3. No remote import in the bundle --------------------------------------
if [[ -f "$site/app.bundle.js" ]] &&
  perl -0777 -ne 'exit(/(?:\bimport\s*\(\s*|\bimport\s+|\bfrom\s*)["\x27`](?:https?:)?\/\//s ? 0 : 1)' \
    "$site/app.bundle.js"; then
  fail "$site/app.bundle.js imports a remote URL"
fi

# ---- Pages in the three languages -------------------------------------------
pages=()
for entry in "index.html:it" "en/index.html:en" "pt-BR/index.html:pt-BR"; do
  page="$site/${entry%%:*}"
  lang="${entry##*:}"
  if [[ ! -f "$page" ]]; then
    fail "$page is missing"
    continue
  fi
  pages+=("$page")
  if ! grep -Eq "<html[^>]*lang=\"$lang\"" "$page"; then
    fail "$page has no lang=\"$lang\""
  fi
done

expected="$(grep -Ev '^\s*(#|$)' "$allowed_file" | sort -u)"

for page in "${pages[@]}"; do
  # ---- 2. Only relative script sources, no inline code ----------------------
  while IFS= read -r problem; do
    [[ -n "$problem" ]] && fail "$page: $problem"
  done < <(perl -0777 -ne '
    while (/<script\b([^>]*)>(.*?)<\/script\s*>/gis) {
      my ($attrs, $body) = ($1, $2);
      if ($attrs !~ /\bsrc\s*=\s*["\x27]([^"\x27]+)["\x27]/i) {
        print "inline <script> without src\n";
        next;
      }
      my $src = $1;
      print "script src \"$src\" is not relative\n" if $src =~ m{^(?:[a-z][a-z0-9+.-]*:|//)}i;
      print "script \"$src\" has inline code\n" if $body =~ /\S/;
    }
    print "on* event handler attribute\n" if /<[^>]+\son[a-z]+\s*=/i;
  ' "$page")

  # ---- 4. CSP with exactly the allowed origins -----------------------------
  csp="$(perl -0777 -ne 'print $2 if /<meta\s+http-equiv=["\x27]Content-Security-Policy["\x27]\s+content=(["\x27])(.*?)\1/is' "$page")"
  if [[ -z "$csp" ]]; then
    fail "$page has no Content-Security-Policy meta tag"
    continue
  fi
  if [[ "$csp" == *"'unsafe-inline'"* || "$csp" == *"'unsafe-eval'"* ]]; then
    fail "$page: the CSP allows unsafe-inline or unsafe-eval"
  fi
  for directive in "default-src 'self'" "object-src 'none'" "base-uri 'none'"; do
    [[ "$csp" == *"$directive"* ]] || fail "$page: the CSP lacks \"$directive\""
  done
  found="$(tr ' ;' '\n\n' <<<"$csp" | grep -E '^(https?:|wss?:|\*)' | sort -u || true)"
  if [[ "$found" != "$expected" ]]; then
    extra="$(comm -13 <(printf '%s\n' "$expected") <(printf '%s\n' "$found") | tr '\n' ' ')"
    missing="$(comm -23 <(printf '%s\n' "$expected") <(printf '%s\n' "$found") | tr '\n' ' ')"
    fail "$page: CSP origins differ from $allowed_file (extra: ${extra:-none}; missing: ${missing:-none})"
  fi
done

if [[ ${#failures[@]} -gt 0 ]]; then
  echo "check_web_pins: FAILED" >&2
  printf '  - %s\n' "${failures[@]}" >&2
  exit 1
fi
echo "check_web_pins: OK (bundle reproducible, scripts local, CSP as $allowed_file, 3 languages)"
