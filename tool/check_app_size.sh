#!/usr/bin/env bash
# App size gate (u6-label-recognition NFR2.3, cicd-pipeline.md §1, job
# `unit`): the maximum download size of the release bundle, measured with
# `bundletool get-size total`, may grow by at most 15 MB over the value in
# tool/app_size_baseline.txt. The bundled ML Kit models are the expected
# growth.
#
# bundletool is downloaded at a fixed version into build/tools/ and checked
# against its SHA-256 before it runs (the digest GitHub publishes for the
# release asset). The baseline changes only in a dedicated block, measured on
# the build of main before the change; the limit is never raised to pass.
#
# Usage:
#   tool/check_app_size.sh                 # checks build/check_release/app-release.aab
#   tool/check_app_size.sh <aab>           # checks another bundle
#   tool/check_app_size.sh --measure <aab> # prints the size, checks nothing
# The default bundle is the plain release left by tool/check_release_build.sh
# (arm64 only, FIREBASE_ENV=demo): measure the baseline the same way.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

bundletool_version="1.18.3"
bundletool_sha256="a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29"
bundletool_url="https://github.com/google/bundletool/releases/download/${bundletool_version}/bundletool-all-${bundletool_version}.jar"
jar="build/tools/bundletool-all-${bundletool_version}.jar"
baseline_file="tool/app_size_baseline.txt"
max_growth_bytes=$((15 * 1024 * 1024))

measure_only=false
if [[ "${1:-}" == "--measure" ]]; then
  measure_only=true
  shift
fi
aab="${1:-build/check_release/app-release.aab}"

# The baseline first: with none there is nothing to compare, so fail before
# downloading or running bundletool.
if ! $measure_only; then
  baseline="$(grep -vE '^[[:space:]]*(#|$)' "$baseline_file" | head -n 1 | tr -d '[:space:]')"
  if ! [[ "$baseline" =~ ^[0-9]+$ ]]; then
    echo "check_app_size: FAILED, App size baseline is ${baseline:-empty}: run tool/check_app_size.sh --measure <pre-change AAB> and commit the number in $baseline_file." >&2
    echo "For u6-label-recognition the pre-change AAB is android/captures/pre-u6-app-release.aab on the owner's machine." >&2
    exit 1
  fi
fi

if [[ ! -s "$aab" ]]; then
  echo "check_app_size: bundle '$aab' not found (run tool/check_release_build.sh first)" >&2
  exit 2
fi

sha256_of() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

if [[ ! -s "$jar" ]] || [[ "$(sha256_of "$jar")" != "$bundletool_sha256" ]]; then
  mkdir -p build/tools
  curl -sfL --retry 3 -o "$jar" "$bundletool_url"
fi
if [[ "$(sha256_of "$jar")" != "$bundletool_sha256" ]]; then
  rm -f "$jar"
  echo "check_app_size: FAILED, bundletool SHA-256 does not match" >&2
  exit 2
fi

apks="build/tools/app-size.apks"
java -jar "$jar" build-apks --bundle="$aab" --output="$apks" --overwrite >/dev/null
# get-size total prints a CSV header and "MIN,MAX".
size_line="$(java -jar "$jar" get-size total --apks="$apks" | tail -n 1)"
max_bytes="${size_line##*,}"
if ! [[ "$max_bytes" =~ ^[0-9]+$ ]]; then
  echo "check_app_size: unexpected bundletool output '$size_line'" >&2
  exit 2
fi

if $measure_only; then
  echo "$max_bytes"
  exit 0
fi

limit=$((baseline + max_growth_bytes))
printf 'App download size (max): %d bytes; baseline %d; limit %d (+15 MB)\n' \
  "$max_bytes" "$baseline" "$limit"
if ((max_bytes > limit)); then
  echo "check_app_size: FAILED, the app grew by more than 15 MB" >&2
  exit 1
fi
echo "check_app_size: OK"
