#!/usr/bin/env bash
# Minimal Google Play Developer API client for release.yml and promote.yml.
#
# Authentication: a service-account JSON key in $PLAY_SA_JSON_FILE (written by
# the workflow from a GitHub environment secret into $RUNNER_TEMP). The token
# comes from gcloud, preinstalled on GitHub runners. stdout carries only the
# requested value; every diagnostic goes to stderr and never contains the key
# or the token (actions-release-fix FR2, NFR1).
#
# Usage:
#   tool/play_api.sh next-version-code             # highest versionCode on any track + 1
#   tool/play_api.sh promote  <versionCode> <fraction>   # internal -> production, staged
#   tool/play_api.sh complete <versionCode>              # staged rollout -> 100%
#   tool/play_api.sh halt     <versionCode>              # stop the staged rollout at its current fraction (rollback)
#
# Exit codes: 1 no staged rollout to halt, 2 wrong usage, 3 the service
# account key file is missing or invalid, 4 Google authentication failed,
# 5 a Play Developer API call failed.
set -euo pipefail

package="${PLAY_PACKAGE_NAME:-com.vinoozy.app}"
api="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$package"

fail() {
  local code="$1"
  shift
  echo "play_api: $*" >&2
  exit "$code"
}

# Removes from a gcloud or API message anything that could be part of a key or
# a token: lines naming them, PEM markers and long Base64-like runs.
sanitize() {
  grep -v -i -E 'private_key|-----BEGIN|-----END|access_token|refresh_token|id_token|bearer|ya29\.' |
    sed -E 's#[A-Za-z0-9+/_.=-]{40,}#[redacted]#g' |
    head -c 500 || true
}

# FR2.1: the key file is checked before gcloud sees it.
key_file="${PLAY_SA_JSON_FILE:-}"
[[ -n "$key_file" ]] ||
  fail 3 "PLAY_SA_JSON_FILE is not set: it must point to the service account key file"
[[ -f "$key_file" && -r "$key_file" ]] ||
  fail 3 "the service account key file in PLAY_SA_JSON_FILE does not exist or is not readable"
[[ -s "$key_file" ]] ||
  fail 3 "the service account key file in PLAY_SA_JSON_FILE is empty: is the secret configured in the GitHub environment?"
jq -e 'type == "object"' "$key_file" >/dev/null 2>&1 ||
  fail 3 "the service account key file in PLAY_SA_JSON_FILE is not a valid JSON object"
jq -e '.type == "service_account" and ((.client_email // "") | length) > 0 and ((.private_key // "") | length) > 0' \
  "$key_file" >/dev/null 2>&1 ||
  fail 3 "the file in PLAY_SA_JSON_FILE is not a service account key (type service_account, client_email, private_key)"

config_dir="$(mktemp -d)"
trap 'rm -rf "$config_dir"' EXIT
export CLOUDSDK_CONFIG="$config_dir"

# FR2.2: gcloud's own reason is kept, sanitized, instead of being discarded.
if ! auth_output="$(gcloud auth activate-service-account --key-file="$key_file" --quiet 2>&1)"; then
  echo "play_api: Google Play authentication failed for the service account in PLAY_SA_JSON_FILE." >&2
  printf '%s\n' "$auth_output" | sanitize >&2
  exit 4
fi
if ! token="$(gcloud auth print-access-token --scopes=https://www.googleapis.com/auth/androidpublisher 2>"$config_dir/token.err")"; then
  echo "play_api: Google did not issue an access token for the Play Developer API." >&2
  sanitize <"$config_dir/token.err" >&2
  exit 4
fi
[[ -n "$token" ]] || fail 4 "Google returned an empty access token for the Play Developer API."

# FR2.3: a failed call names the method, the API path and the HTTP status.
call() {
  local method="$1" path="$2" body="${3:-}" response status
  local args=(-sS -X "$method" -H "Authorization: Bearer $token" -w '\n%{http_code}')
  if [[ -n "$body" ]]; then
    args+=(-H 'Content-Type: application/json' --data "$body")
  fi
  if ! response="$(curl "${args[@]}" "$api$path" 2>"$config_dir/curl.err")"; then
    echo "play_api: Play API $method $path failed: no response." >&2
    sanitize <"$config_dir/curl.err" >&2
    return 5
  fi
  status="${response##*$'\n'}"
  response="${response%$'\n'*}"
  if [[ ! "$status" =~ ^2[0-9][0-9]$ ]]; then
    echo "play_api: Play API $method $path failed with HTTP $status." >&2
    printf '%s\n' "$response" | sanitize >&2
    return 5
  fi
  printf '%s' "$response"
}
# `return`, not `exit`: the best-effort DELETE of an edit (`|| true`) must not
# stop the script; everywhere else `set -e` turns the status 5 into the exit
# code.

open_edit() { call POST /edits '{}' | jq -r .id; }

commit_edit() { call POST "/edits/$1:commit" >/dev/null; }

set_production() {
  local version_code="$1" status="$2" fraction="${3:-}"
  local release
  if [[ -n "$fraction" ]]; then
    release=$(jq -nc --arg vc "$version_code" --arg st "$status" --argjson f "$fraction" \
      '{releases: [{versionCodes: [$vc], status: $st, userFraction: $f}]}')
  else
    release=$(jq -nc --arg vc "$version_code" --arg st "$status" \
      '{releases: [{versionCodes: [$vc], status: $st}]}')
  fi
  local edit
  edit="$(open_edit)"
  call PUT "/edits/$edit/tracks/production" "$release" >/dev/null
  commit_edit "$edit"
}

# Reads a track resource on stdin; prints it with the inProgress release of
# version code $1 set to halted (userFraction kept). Fails if there is none.
halt_release() {
  jq -ce --arg vc "$1" '
    def target: .status == "inProgress" and ((.versionCodes // []) | index($vc));
    if any(.releases[]?; target)
    then .releases |= map(if target then .status = "halted" else . end)
    else error("no inProgress release for \($vc)") end'
}

case "${1:-}" in
  next-version-code)
    edit="$(open_edit)"
    highest="$(call GET "/edits/$edit/tracks" \
      | jq '[.tracks[]?.releases[]?.versionCodes[]? | tonumber] | max // 0')"
    call DELETE "/edits/$edit" >/dev/null || true
    echo $((highest + 1))
    ;;
  promote)
    [[ "${3:-}" =~ ^(0\.2|1\.0|1)$ ]] || { echo "fraction must be 0.2 or 1.0" >&2; exit 2; }
    if [[ "$3" == "0.2" ]]; then
      set_production "$2" inProgress 0.2
    else
      set_production "$2" completed
    fi
    ;;
  complete)
    set_production "$2" completed
    ;;
  halt)
    # Stops the staged rollout of <versionCode> where it is: the production
    # track is read, only that inProgress release becomes halted, and every
    # other field (its current userFraction, the previous completed release)
    # is written back unchanged.
    edit="$(open_edit)"
    track="$(call GET "/edits/$edit/tracks/production")"
    if ! halted="$(halt_release "$2" <<<"$track")"; then
      call DELETE "/edits/$edit" >/dev/null || true
      echo "no staged rollout in progress for versionCode $2" >&2
      exit 1
    fi
    call PUT "/edits/$edit/tracks/production" "$halted" >/dev/null
    commit_edit "$edit"
    ;;
  *)
    echo "usage: $0 next-version-code | promote <vc> <fraction> | complete <vc> | halt <vc>" >&2
    exit 2
    ;;
esac
