#!/usr/bin/env bash
# Checks the GitHub Actions inputs of the Play workflows before any file is
# written or any build starts (actions-release-fix FR1.1-FR1.4, FR4.1).
#
# A secret that is not configured reaches a workflow as an empty string, and
# `base64 -d` of an empty string succeeds: without this check release.yml
# wrote empty files and failed later in `tool/play_api.sh` with no message.
#
# The values are read from the environment, decoded only into pipes and never
# printed or written to disk: every message names the input, the GitHub
# environment that must hold it and the rule it breaks (NFR1). All the
# problems are reported together, so one run lists everything to configure.
#
# Usage:
#   tool/check_release_inputs.sh --profile internal     # release.yml, environment play-internal
#   tool/check_release_inputs.sh --profile production   # promote.yml, environment play-production
#
# Exit codes: 0 every input is valid, 1 at least one input is missing or
# invalid, 2 wrong usage.
set -euo pipefail

package_name="${PLAY_PACKAGE_NAME:-com.vinoozy.app}"

usage() {
  echo "usage: $0 --profile internal|production" >&2
  exit 2
}

[[ $# -eq 2 && "$1" == "--profile" ]] || usage
profile="$2"

case "$profile" in
  internal) environment="play-internal" ;;
  production) environment="play-production" ;;
  *) usage ;;
esac

problems=()

problem() {
  # $1 kind (secret or variable), $2 name, $3 rule broken.
  problems+=("$1 $2 (environment $environment): $3")
}

# True when the variable named $1 is set and not only whitespace.
present() {
  local value="${!1:-}"
  [[ -n "${value//[[:space:]]/}" ]]
}

require() {
  # $1 kind, $2 name. Returns 1 when missing, so the caller skips deeper checks.
  if ! present "$2"; then
    problem "$1" "$2" "missing or empty"
    return 1
  fi
}

# Strict Base64: the same answer on GNU (runners) and BSD (macOS) base64,
# whose leniency differs. Line breaks are allowed (base64 wraps at 76).
valid_base64() {
  local compact
  compact="$(printf '%s' "${!1}" | tr -d ' \r\n\t')"
  [[ -n "$compact" ]] || return 1
  [[ $((${#compact} % 4)) -eq 0 ]] || return 1
  [[ "$compact" =~ ^[A-Za-z0-9+/]+={0,2}$ ]] || return 1
}

decode() {
  printf '%s' "${!1}" | tr -d ' \r\n\t' | base64 -d 2>/dev/null
}

check_base64() {
  # $1 secret name. Returns 1 when the value cannot be used as Base64.
  if ! valid_base64 "$1"; then
    problem secret "$1" "not valid Base64"
    return 1
  fi
  if [[ "$(decode "$1" | wc -c | tr -d ' ')" -eq 0 ]]; then
    problem secret "$1" "empty after Base64 decoding"
    return 1
  fi
}

# $1 secret name, $2 "plain" or "base64", $3 jq filter that prints the name
# of the first missing field, or nothing when the document is complete.
check_json() {
  local name="$1" encoding="$2" filter="$3" missing
  local reader=(printf '%s' "${!name}")
  if [[ "$encoding" == "base64" ]]; then reader=(decode "$name"); fi
  if ! "${reader[@]}" | jq -e 'type == "object"' >/dev/null 2>&1; then
    problem secret "$name" "not a valid JSON object"
    return 0
  fi
  missing="$("${reader[@]}" | jq -r --arg pkg "$package_name" "$filter")"
  if [[ -n "$missing" ]]; then
    problem secret "$name" "$missing"
  fi
}

service_account_filter='
  if .type != "service_account" then "field type is not service_account"
  elif ((.client_email // "") | length) == 0 then "missing field client_email"
  elif ((.private_key // "") | length) == 0 then "missing field private_key"
  else empty end'

check_service_account() {
  if require secret "$1"; then
    check_json "$1" plain "$service_account_filter"
  fi
}

case "$profile" in
  internal)
    check_service_account PLAY_INTERNAL_SA_JSON

    if require secret ANDROID_UPLOAD_KEYSTORE_B64; then
      check_base64 ANDROID_UPLOAD_KEYSTORE_B64 || true
    fi
    require secret ANDROID_UPLOAD_KEYSTORE_PASSWORD || true
    require secret ANDROID_UPLOAD_KEY_ALIAS || true
    require secret ANDROID_UPLOAD_KEY_PASSWORD || true

    if require secret FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64 &&
      check_base64 FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64; then
      check_json FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64 base64 '
        if (.project_info | type) != "object" then "missing field project_info"
        elif ([.client[]?.client_info.android_client_info.package_name] | index($pkg)) == null
        then "no client for the package \($pkg)"
        else empty end'
    fi

    if require secret FIREBASE_PROD_DEFINES_JSON_B64 &&
      check_base64 FIREBASE_PROD_DEFINES_JSON_B64; then
      check_json FIREBASE_PROD_DEFINES_JSON_B64 base64 '
        . as $defines
        | [("FIREBASE_API_KEY", "FIREBASE_APP_ID", "FIREBASE_PROJECT_ID")
            | select((($defines[.] // "") | tostring | length) == 0)] as $absent
        | if ($absent | length) > 0 then "missing define \($absent | join(", "))" else empty end'
    fi

    require variable GOOGLE_SERVER_CLIENT_ID || true
    ;;
  production)
    check_service_account PLAY_PRODUCTION_SA_JSON
    ;;
esac

if [[ ${#problems[@]} -gt 0 ]]; then
  {
    echo "The $environment configuration is incomplete (${#problems[@]} problem(s)):"
    for line in "${problems[@]}"; do echo "  - $line"; done
    echo "Configure them in GitHub: Settings > Environments > $environment (see docs/github-actions-setup.md)."
  } >&2
  exit 1
fi

echo "The $environment configuration is complete."
