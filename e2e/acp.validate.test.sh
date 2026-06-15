#!/usr/bin/env bash
# E2E Tests for /acp-validate cross-layer consistency checks
# Tests validateStatusConsistency and validateFilePointers from scripts/acp-validate.ts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

VALIDATE_SCRIPT="${PROJECT_ROOT}/scripts/acp-validate.ts"

print_suite_header "/acp-validate cross-layer checks"

print_test_header "V1 — status desync detected: temp milestone doc disagrees with progress.yaml"

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

cp -r "${PROJECT_ROOT}/agent" "${TMPDIR}/agent"
cp -r "${PROJECT_ROOT}/scripts" "${TMPDIR}/scripts"
cp "${PROJECT_ROOT}/package.json" "${TMPDIR}/"

COMPLETED_MILESTONE=$(grep -B1 "status: completed" "${TMPDIR}/agent/progress.yaml" 2>/dev/null | head -1 | sed 's/^  //;s/:.*//')

if [[ -z "${COMPLETED_MILESTONE}" ]]; then
  print_warning "No completed milestone found in progress.yaml — skipping V1 dynamic fixture"
else
  MILESTONE_FILE=$(grep -A8 "^  ${COMPLETED_MILESTONE}:" "${TMPDIR}/agent/progress.yaml" 2>/dev/null | grep "file:" | sed 's/.*file: *//' | sed 's/ *$//' | sed 's/"//g')

  if [[ -n "${MILESTONE_FILE}" ]]; then
    TARGET_DOC="${TMPDIR}/agent/milestones/${MILESTONE_FILE}"

    if [[ -f "${TARGET_DOC}" ]]; then
      sed -i 's/\*\*Status\*\*: *completed/\*\*Status\*\*: planned/' "${TARGET_DOC}"

      pushd "${TMPDIR}" > /dev/null
      VALIDATE_OUT=$(npx ts-node "${VALIDATE_SCRIPT}" 2>&1) || VALIDATE_RC=$?
      popd > /dev/null

      assert_not_empty "${VALIDATE_OUT}" "Validator produced output"
      DESYNC_FOUND=$(echo "${VALIDATE_OUT}" | grep -ci "desync\|status.*disagree\|mismatch" || true)
      assert_true "[[ ${DESYNC_FOUND} -ge 1 ]]" "Validator flagged status desync for ${COMPLETED_MILESTONE}"
    else
      print_warning "${MILESTONE_FILE} not found in fixture workspace — skipping V1"
    fi
  else
    print_warning "No file: pointer for ${COMPLETED_MILESTONE} — skipping V1"
  fi
fi

print_test_header "V2 — aligned workspace produces clean exit (no desync)"
TMPDIR2=$(mktemp -d)
trap 'rm -rf "${TMPDIR2}" ${TMPDIR}' EXIT

cp -r "${PROJECT_ROOT}/agent" "${TMPDIR2}/agent"
cp -r "${PROJECT_ROOT}/scripts" "${TMPDIR2}/scripts"
cp "${PROJECT_ROOT}/package.json" "${TMPDIR2}/"

pushd "${TMPDIR2}" > /dev/null
VALIDATE_OUT2=$(npx ts-node "${VALIDATE_SCRIPT}" 2>&1) || VALIDATE_RC2=$?
popd > /dev/null

DESYNC_FOUND2=$(echo "${VALIDATE_OUT2}" | grep -ci "desync\|status.*disagree" || true)
assert_equals "${DESYNC_FOUND2}" 0 "Clean workspace has no desync warnings"

print_test_header "V3 — dangling file pointer detected"
TMPDIR3=$(mktemp -d)
trap 'rm -rf "${TMPDIR2}" "${TMPDIR3}" ${TMPDIR}' EXIT

cp -r "${PROJECT_ROOT}/agent" "${TMPDIR3}/agent"
cp -r "${PROJECT_ROOT}/scripts" "${TMPDIR3}/scripts"
cp "${PROJECT_ROOT}/package.json" "${TMPDIR3}/"

{
  echo "  M999:"
  echo "    name: Nonexistent Test Milestone"
  echo "    status: active"
  echo "    file: agent/milestones/milestone-999-does-not-exist.md"
} >> "${TMPDIR3}/agent/progress.yaml"

pushd "${TMPDIR3}" > /dev/null
VALIDATE_OUT3=$(npx ts-node "${VALIDATE_SCRIPT}" 2>&1) || VALIDATE_RC3=$?
popd > /dev/null

DANGLING_FOUND=$(echo "${VALIDATE_OUT3}" | grep -ci "dangling\|not found\|does not exist\|missing.*file" || true)
assert_true "[[ ${DANGLING_FOUND} -ge 1 ]]" "Validator flagged dangling file pointer for M999"

print_summary_line
