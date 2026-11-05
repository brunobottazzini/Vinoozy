#!/usr/bin/env bash
# Minimal Google Play Developer API client for release.yml and promote.yml.
#
# Authentication: a service-account JSON key in $PLAY_SA_JSON_FILE (written by
# the workflow from a GitHub environment secret into $RUNNER_TEMP). The token
# comes from gcloud, preinstalled on GitHub runners. Nothing is printed except
# the requested value.
#
# Usage:
#   tool/play_api.sh next-version-code             # highest versionCode on any track + 1
#   tool/play_api.sh promote  <versionCode> <fraction>   # internal -> production, staged
#   tool/play_api.sh complete <versionCode>              # staged rollout -> 100%
#   tool/play_api.sh halt     <versionCode>              # stop the staged rollout at its current fraction (rollback)
set -euo pipefail

package="${PLAY_PACKAGE_NAME:-com.vinoozy.app}"
api="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$package"

: "${PLAY_SA_JSON_FILE:?PLAY_SA_JSON_FILE must point to the service account key}"

config_dir="$(mktemp -d)"
trap 'rm -rf "$config_dir"' EXIT
export CLOUDSDK_CONFIG="$config_dir"
gcloud auth activate-service-account --key-file="$PLAY_SA_JSON_FILE" --quiet >/dev/null 2>&1
token="$(gcloud auth print-access-token --scopes=https://www.googleapis.com/auth/androidpublisher)"

call() {
  local method="$1" path="$2" body="${3:-}"
  local args=(-sS --fail-with-body -X "$method" -H "Authorization: Bearer $token")
  if [[ -n "$body" ]]; then
    args+=(-H 'Content-Type: application/json' --data "$body")
  fi
  curl "${args[@]}" "$api$path"
}

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
