#!/usr/bin/env bash
# E2E Tests for acp.private-pack.sh (M87 task-329)
# Packs fixture dirs under /tmp only — never real vendor dumps.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

PACK="${PROJECT_ROOT}/agent/scripts/acp.private-pack.sh"

print_suite_header "/acp-private-pack — E2E Tests (M87)"

if [[ "${OS:-}" == "Windows_NT" ]] || [[ "$(uname -s 2>/dev/null || true)" == MINGW* ]]; then
  print_test_header "S0 — skip on Windows (gpg/age fixture)"
  assert_true "Windows skip documented" 0
  print_test_summary
  exit 0
fi

print_test_header "S1 — script exists and bash -n"
assert_file_exists "${PACK}" "private-pack script"
bash -n "${PACK}"
assert_true "bash -n private-pack" $?

if ! command -v gpg >/dev/null 2>&1; then
  print_test_header "S2 — skip (gpg missing)"
  assert_true "gpg missing skip" 0
  print_test_summary
  exit 0
fi

print_test_header "S2 — pack/unpack fixture counts"
FIXTURE="$(mktemp -d /tmp/acp-pack-fix.XXXXXX)"
DEST="$(mktemp -d /tmp/acp-pack-dest.XXXXXX)"
OUT="/tmp/acp-pack-out-$$.tar.gz.gpg"
mkdir -p "${FIXTURE}/agent/reports" "${FIXTURE}/agent/feedback"
printf 'r1\n' > "${FIXTURE}/agent/reports/a.md"
printf 'f1\n' > "${FIXTURE}/agent/feedback/b.md"
export ACP_PRIVATE_PACK_ROOT="${FIXTURE}"
export ACP_PACK_PASSPHRASE="e2e-m87-pack-pass-not-a-secret"
bash "${PACK}" pack --output "${OUT}"
assert_file_exists "${OUT}" "ciphertext exists"
bash "${PACK}" unpack --input "${OUT}" --dest "${DEST}" --dry-run >/tmp/acp-pack-dry.out
assert_contains "$(cat /tmp/acp-pack-dry.out)" "dry-run: no files written" "dry-run banner"
BEFORE_DEST="$(find "${DEST}" | wc -l | tr -d ' ')"
assert_equals "1" "${BEFORE_DEST}" "dry-run wrote nothing besides dest dir"
bash "${PACK}" unpack --input "${OUT}" --dest "${DEST}"
test -d "${DEST}/agent/reports"
assert_true "unpacked reports dir" $?
test -d "${DEST}/agent/feedback"
assert_true "unpacked feedback dir" $?
R_LIVE="$(find "${FIXTURE}/agent/reports" | wc -l | tr -d ' ')"
R_OUT="$(find "${DEST}/agent/reports" | wc -l | tr -d ' ')"
assert_equals "${R_LIVE}" "${R_OUT}" "reports find counts match"
rm -rf "${FIXTURE}" "${DEST}" "${OUT}" /tmp/acp-pack-dry.out
unset ACP_PACK_PASSPHRASE
unset ACP_PRIVATE_PACK_ROOT

print_test_header "S3 — refuse tracked output under clone"
if bash "${PACK}" pack --output "${PROJECT_ROOT}/agent/scripts/leaked-pack.tar.gz.gpg" 2>/tmp/acp-pack-refuse.out; then
  RC=0
else
  RC=$?
fi
assert_equals "2" "${RC}" "refuse tracked output exit 2"
assert_contains "$(cat /tmp/acp-pack-refuse.out)" "not gitignored" "refuse message"
rm -f /tmp/acp-pack-refuse.out "${PROJECT_ROOT}/agent/scripts/leaked-pack.tar.gz.gpg"

print_test_summary
