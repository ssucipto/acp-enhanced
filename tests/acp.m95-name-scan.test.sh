#!/usr/bin/env bash
# Unit tests for acp.m95-name-scan.sh (M95 task-388 / F-141-01)
# Fixture dirs only — does not require a dirty or clean HEAD.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

SCRIPT="${PROJECT_ROOT}/agent/scripts/acp.m95-name-scan.sh"
TOKENS="${PROJECT_ROOT}/agent/configurables/m95-name-deny.b64"

print_suite_header "acp.m95-name-scan.sh (M95)"

print_test_header "S1 — script exists and bash -n"
assert_file_exists "${SCRIPT}" "m95-name-scan script"
assert_file_exists "${TOKENS}" "encoded tokens file"
bash -n "${SCRIPT}"
assert_true "bash -n m95-name-scan" $?

print_test_header "S2 — dirty fixture exits 1"
DIRTY="$(mktemp -d /tmp/m95-scan-dirty-XXXXXX)"
python3 -c 'import base64,pathlib,sys; p=pathlib.Path(sys.argv[1]); t=base64.b64decode("RklGT1o=").decode(); (p/"hit.txt").write_text("prefix "+t+" suffix\n")' "${DIRTY}"
set +e
bash "${SCRIPT}" --dir "${DIRTY}" >/tmp/m95-scan-dirty-out.txt 2>&1
rc=$?
set -e
assert_equals "1" "${rc}" "dirty fixture exit 1"
rm -rf "${DIRTY}"

print_test_header "S3 — clean fixture exits 0"
CLEAN="$(mktemp -d /tmp/m95-scan-clean-XXXXXX)"
echo "consumer-project field evidence only" > "${CLEAN}/ok.txt"
set +e
bash "${SCRIPT}" --dir "${CLEAN}" >/tmp/m95-scan-clean-out.txt 2>&1
rc=$?
set -e
assert_equals "0" "${rc}" "clean fixture exit 0"
rm -rf "${CLEAN}"

print_test_header "S4 — encoded file has no decoded first token as plaintext"
# The b64 file must not contain the decoded literal of the first token.
DECODED="$(python3 -c 'import base64; print(base64.b64decode("RklGT1o=").decode())')"
if grep -F -q -- "${DECODED}" "${TOKENS}"; then
  assert_true "tokens file must not contain decoded plaintext" 1
else
  assert_true "tokens file stays encoded" 0
fi

print_test_summary
