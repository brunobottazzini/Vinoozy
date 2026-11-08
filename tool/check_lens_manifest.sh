#!/usr/bin/env bash
# Google Lens boundary of the label photo (label-recognition NFR3.3, BR5.2;
# job `analyze`). Fails when:
#   1. the FileProvider is missing, exported, or without per-URI grants;
#   2. its paths expose anything but cache/label/ (one <cache-path> with
#      path="label/");
#   3. <queries> names a package other than the Google app and, since
#      label-autofill-windows (FR2.6, NFR3.3), the Google Lens app, or an
#      intent other than ACTION_SEND of image/* (PROCESS_TEXT of text/plain,
#      from the Flutter template, is the only other one allowed);
#   4. an activity filter of a text type accepts anything but ACTION_SEND of
#      text/plain (label-autofill-windows FR2.1: the text shared by Lens).
#
# Usage: tool/check_lens_manifest.sh [manifest] [paths-xml]
#   defaults: android/app/src/main/AndroidManifest.xml and
#             android/app/src/main/res/xml/label_file_paths.xml
# Uses only grep, awk and tr (present on ubuntu-latest and macOS).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
manifest="${1:-android/app/src/main/AndroidManifest.xml}"
paths="${2:-android/app/src/main/res/xml/label_file_paths.xml}"

for file in "$manifest" "$paths"; do
  if [[ ! -f "$file" ]]; then
    echo "check_lens_manifest: '$file' not found" >&2
    exit 2
  fi
done

failures=0
fail() {
  echo "check_lens_manifest: $*" >&2
  failures=$((failures + 1))
}

# A file on one line with its XML comments removed, so attributes split
# over several lines are still seen together. A comment ends only at the
# first "-->", whatever it holds (">" included, review R-05): commented
# text is never read as active. An unclosed "<!--" is kept as it is, so
# what follows is still checked.
flatten() {
  tr '\n' ' ' < "$1" | awk '{
    out = ""; rest = $0
    while ((start = index(rest, "<!--")) > 0) {
      out = out substr(rest, 1, start - 1)
      after = substr(rest, start + 4)
      end = index(after, "-->")
      if (end == 0) { out = out substr(rest, start); rest = ""; break }
      rest = substr(after, end + 3)
    }
    print out rest
  }'
}

flat="$(flatten "$manifest")"

# 1. The provider.
provider="$(printf '%s' "$flat" | grep -oE '<provider[^>]*androidx\.core\.content\.FileProvider[^>]*>' || true)"
if [[ -z "$provider" ]]; then
  fail "no androidx.core.content.FileProvider in $manifest"
else
  if ! grep -qE 'android:exported="false"' <<<"$provider"; then
    fail "the FileProvider must have android:exported=\"false\""
  fi
  if ! grep -qE 'android:grantUriPermissions="true"' <<<"$provider"; then
    fail "the FileProvider must have android:grantUriPermissions=\"true\""
  fi
fi
if grep -qE 'FLAG_GRANT_WRITE|android:writePermission' <<<"$flat"; then
  fail "no write permission may be granted on the label files"
fi

# 2. The paths: exactly one cache-path, label/.
path_flat="$(flatten "$paths")"
entries="$(printf '%s' "$path_flat" | grep -oE '<(cache|files|external|external-files|external-cache|external-media|root)-path[^>]*>' || true)"
count="$(printf '%s' "$entries" | grep -c 'path' || true)"
if [[ "$count" -ne 1 ]] || ! grep -qE '^<cache-path [^>]*path="label/"' <<<"$entries"; then
  fail "$paths must expose only <cache-path path=\"label/\">, found:"$'\n'"${entries:-nothing}"
fi

# 3. The queries.
queries="$(printf '%s' "$flat" | grep -oE '<queries>.*</queries>' || true)"
for package in $(printf '%s' "$queries" | grep -oE '<package android:name="[^"]*"' | sed -E 's/.*name="([^"]*)"/\1/'); do
  case "$package" in
    com.google.android.googlequicksearchbox | com.google.ar.lens) ;;
    *) fail "<queries> names another package: $package" ;;
  esac
done
while IFS= read -r intent; do
  [[ -z "$intent" ]] && continue
  action="$(grep -oE 'action android:name="[^"]*"' <<<"$intent" | head -n 1 | sed -E 's/.*"([^"]*)"/\1/')"
  mime="$(grep -oE 'android:mimeType="[^"]*"' <<<"$intent" | head -n 1 | sed -E 's/.*"([^"]*)"/\1/')"
  case "$action|$mime" in
    "android.intent.action.SEND|image/*") ;;
    "android.intent.action.PROCESS_TEXT|text/plain") ;;
    *) fail "<queries> has another intent: $action $mime" ;;
  esac
done < <(printf '%s' "$queries" | awk '{ n = split($0, parts, "</intent>"); for (i = 1; i < n; i++) print parts[i] "</intent>" }')
if [[ -n "$queries" ]] && ! grep -q 'com.google.android.googlequicksearchbox' <<<"$queries"; then
  fail "<queries> must declare the Google app package"
fi

# 4. The text share filters of the activities (outside <queries>).
activities="$(printf '%s' "$flat" | sed -E 's#<queries>.*</queries>##')"
while IFS= read -r filter; do
  [[ -z "$filter" ]] && continue
  if ! grep -qE 'android:mimeType="text/' <<<"$filter"; then
    continue
  fi
  actions="$(grep -oE 'action android:name="[^"]*"' <<<"$filter" | sed -E 's/.*"([^"]*)"/\1/' | sort -u | tr '\n' ' ')"
  mimes="$(grep -oE 'android:mimeType="[^"]*"' <<<"$filter" | sed -E 's/.*"([^"]*)"/\1/' | sort -u | tr '\n' ' ')"
  if [[ "$actions" != "android.intent.action.SEND " || "$mimes" != "text/plain " ]]; then
    fail "a text share filter accepts more than SEND text/plain: ${actions}${mimes}"
  fi
done < <(printf '%s' "$activities" | awk '{ n = split($0, parts, "</intent-filter>"); for (i = 1; i < n; i++) print parts[i] "</intent-filter>" }' | sed -E 's/.*<intent-filter/<intent-filter/')

if [[ $failures -gt 0 ]]; then
  echo "check_lens_manifest: FAILED ($failures check(s))" >&2
  exit 1
fi
echo "check_lens_manifest: OK (provider not exported, cache/label/ only, queries limited)"
