#!/usr/bin/env bash
# Test of tool/check_lens_manifest.sh (label-recognition NFR3.3): the check
# must pass on the manifest of the app and on a clean fixture, and fail on a
# fixture with an exported provider, a wider path and other queries, so a
# broken check never passes in silence.
#
#   tool/fixtures/lens_manifest/ok/   provider and queries as required
#   tool/fixtures/lens_manifest/bad/  exported, files-path ".", other queries
#   tool/fixtures/lens_manifest/comment_ok/   forbidden text only inside a
#                                             comment with ">" (passes)
#   tool/fixtures/lens_manifest/comment_bad/  the only provider inside such
#                                             a comment (fails)
#
# Usage: tool/check_lens_manifest_test.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
check="tool/check_lens_manifest.sh"
fixtures="tool/fixtures/lens_manifest"

failures=0

if output="$("$check" 2>&1)"; then
  echo "app manifest: passes (expected)"
else
  echo "check_lens_manifest_test: the app manifest should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

if output="$("$check" "$fixtures/ok/AndroidManifest.xml" "$fixtures/ok/label_file_paths.xml" 2>&1)"; then
  echo "ok/: passes (expected)"
else
  echo "check_lens_manifest_test: ok/ should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$fixtures/bad/AndroidManifest.xml" "$fixtures/bad/label_file_paths.xml" 2>&1)"
status=$?
set -e
expected=(
  'exported="false"'
  'only <cache-path path="label/">'
  'another package: com.example.other'
  'another intent: android.intent.action.VIEW image/*'
)
if [[ $status -ne 1 ]]; then
  echo "check_lens_manifest_test: bad/ should fail with exit 1, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi
for message in "${expected[@]}"; do
  if [[ "$output" != *"$message"* ]]; then
    echo "check_lens_manifest_test: bad/ should report '$message':"$'\n'"$output" >&2
    failures=$((failures + 1))
  fi
done
[[ $status -eq 1 ]] && echo "bad/: fails on each of the 4 problems (expected)"

# Review R-05: comments with ">" inside are removed whole. comment_ok/ has
# an exported provider and another package only in a comment: it passes.
# comment_bad/ has its only FileProvider in a comment: it fails.
if output="$("$check" "$fixtures/comment_ok/AndroidManifest.xml" "$fixtures/ok/label_file_paths.xml" 2>&1)"; then
  echo "comment_ok/: passes, the commented text is not active (expected)"
else
  echo "check_lens_manifest_test: comment_ok/ should pass but failed:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

set +e
output="$("$check" "$fixtures/comment_bad/AndroidManifest.xml" "$fixtures/ok/label_file_paths.xml" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 && "$output" == *"no androidx.core.content.FileProvider"* ]]; then
  echo "comment_bad/: fails, a commented provider does not count (expected)"
else
  echo "check_lens_manifest_test: comment_bad/ should fail with exit 1 on the missing provider, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

# label-autofill-windows NFR3.3: a text share filter wider than ACTION_SEND
# of text/plain fails; the Google Lens package of ok/ is allowed.
set +e
output="$("$check" "$fixtures/bad_text/AndroidManifest.xml" "$fixtures/ok/label_file_paths.xml" 2>&1)"
status=$?
set -e
if [[ $status -eq 1 && "$output" == *"text share filter accepts more than SEND text/plain"* ]]; then
  echo "bad_text/: fails on the text share filter (expected)"
else
  echo "check_lens_manifest_test: bad_text/ should fail with exit 1 on the text filter, got $status:"$'\n'"$output" >&2
  failures=$((failures + 1))
fi

if "$check" "$fixtures/missing.xml" "$fixtures/ok/label_file_paths.xml" >/dev/null 2>&1; then
  echo "check_lens_manifest_test: a missing manifest should not pass" >&2
  failures=$((failures + 1))
else
  echo "missing manifest: refused (expected)"
fi

if [[ $failures -gt 0 ]]; then
  echo "check_lens_manifest_test: FAILED ($failures case(s))" >&2
  exit 1
fi
echo "check_lens_manifest_test: OK"
