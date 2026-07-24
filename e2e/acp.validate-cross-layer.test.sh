#!/usr/bin/env bash
# E2E Tests for /acp-validate cross-layer consistency checks
# Tests validateStatusConsistency and validateFilePointers from scripts/acp-validate.ts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

VALIDATE_SCRIPT="${PROJECT_ROOT}/scripts/acp-validate.ts"
TS_NODE_ESM="${PROJECT_ROOT}/scripts/node_modules/ts-node/dist/bin-esm.js"
VALIDATE_CMD=(node "${TS_NODE_ESM}" "${VALIDATE_SCRIPT}")

_copy_fixture_workspace() {
  local dest="$1"
  cp -r "${PROJECT_ROOT}/agent" "${dest}/agent"
  cp -r "${PROJECT_ROOT}/scripts" "${dest}/scripts"
  if [[ -f "${PROJECT_ROOT}/package.json" ]]; then
    cp "${PROJECT_ROOT}/package.json" "${dest}/"
  fi
  if [[ -f "${PROJECT_ROOT}/package.yaml" ]]; then
    cp "${PROJECT_ROOT}/package.yaml" "${dest}/"
  fi
  if [[ -f "${PROJECT_ROOT}/AGENTS.md" ]]; then
    cp "${PROJECT_ROOT}/AGENTS.md" "${dest}/"
    cp "${PROJECT_ROOT}/AGENTS.md" "${dest}/CLAUDE.md"
    mkdir -p "${dest}/.github"
    cp "${PROJECT_ROOT}/AGENTS.md" "${dest}/.github/copilot-instructions.md"
  fi
}

_run_validator() {
  local repo_root="$1"
  ACP_REPO_ROOT="${repo_root}" "${VALIDATE_CMD[@]}"
}

print_suite_header "/acp-validate cross-layer checks"

print_test_header "V1 — status desync detected: temp milestone doc disagrees with progress.yaml"

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

_copy_fixture_workspace "${TMPDIR}"

# First completed milestone block (M44+), not nested task status lines
COMPLETED_MILESTONE=$(awk '
  /^  M[0-9]+:/ { ms=$0; sub(/^  /,"",ms); sub(/:.*/,"",ms); in_ms=1; next }
  in_ms && /^    status: completed/ { print ms; exit }
  in_ms && /^  M[0-9]+:/ { in_ms=0 }
' "${TMPDIR}/agent/progress.yaml")

if [[ -z "${COMPLETED_MILESTONE}" ]]; then
  echo "  ⚠ SKIP: No completed milestone found in progress.yaml — skipping V1"
else
  MILESTONE_FILE=$(grep -A12 "^  ${COMPLETED_MILESTONE}:" "${TMPDIR}/agent/progress.yaml" | grep "file:" | head -1 | sed 's/.*file: *//' | sed 's/ *$//' | sed 's/"//g')

  if [[ -n "${MILESTONE_FILE}" ]]; then
    TARGET_DOC="${TMPDIR}/${MILESTONE_FILE}"

    if [[ -f "${TARGET_DOC}" ]]; then
      sed 's/\*\*Status\*\*: *completed/\*\*Status\*\*: planned/' "${TARGET_DOC}" > "${TARGET_DOC}.tmp" && mv "${TARGET_DOC}.tmp" "${TARGET_DOC}"

      pushd "${TMPDIR}" > /dev/null
      VALIDATE_OUT=$(_run_validator "${TMPDIR}" 2>&1) || VALIDATE_RC=$?
      popd > /dev/null

      assert_not_empty "${VALIDATE_OUT}" "Validator produced output"
      DESYNC_FOUND=$(echo "${VALIDATE_OUT}" | grep -ci "Status desync\|status.*disagree\|desync" || true)
      if [[ "${DESYNC_FOUND}" -ge 1 ]]; then
        assert_true "Validator flagged status desync for ${COMPLETED_MILESTONE}" 0
      else
        assert_true "Validator flagged status desync for ${COMPLETED_MILESTONE}" 1
      fi
    else
      echo "  ⚠ SKIP: ${MILESTONE_FILE} not found in fixture workspace — skipping V1"
    fi
  else
    echo "  ⚠ SKIP: No file: pointer for ${COMPLETED_MILESTONE} — skipping V1"
  fi
fi

print_test_header "V2 — aligned workspace produces clean exit (no desync)"
TMPDIR2=$(mktemp -d)
trap 'rm -rf "${TMPDIR2}" ${TMPDIR}' EXIT

_copy_fixture_workspace "${TMPDIR2}"

pushd "${TMPDIR2}" > /dev/null
VALIDATE_OUT2=$(_run_validator "${TMPDIR2}" 2>&1) || VALIDATE_RC2=$?
popd > /dev/null

DESYNC_FOUND2=$(echo "${VALIDATE_OUT2}" | grep -ci "Status desync\|status.*disagree" || true)
assert_equals "${DESYNC_FOUND2}" 0 "Clean workspace has no desync warnings"

print_test_header "V3 — dangling file pointer detected"
TMPDIR3=$(mktemp -d)
trap 'rm -rf "${TMPDIR2}" "${TMPDIR3}" ${TMPDIR}' EXIT

_copy_fixture_workspace "${TMPDIR3}"

# Insert under milestones: (appending at EOF breaks YAML and is ignored by parsers).
# Use M99 — unused id; must stay a real milestones: child so validateFilePointers sees it.
PROGRESS3="${TMPDIR3}/agent/progress.yaml"
awk '
  /^milestones:[[:space:]]*$/ {
    print
    print "  M99:"
    print "    name: Nonexistent Test Milestone"
    print "    status: active"
    print "    file: agent/milestones/milestone-99-does-not-exist.md"
    next
  }
  { print }
' "${PROGRESS3}" > "${PROGRESS3}.tmp" && mv "${PROGRESS3}.tmp" "${PROGRESS3}"

pushd "${TMPDIR3}" > /dev/null
VALIDATE_OUT3=$(_run_validator "${TMPDIR3}" 2>&1) || VALIDATE_RC3=$?
popd > /dev/null

DANGLING_FOUND=$(echo "${VALIDATE_OUT3}" | grep -ci "dangling\|not found\|does not exist\|missing.*file" || true)
if [[ "${DANGLING_FOUND}" -ge 1 ]]; then
  assert_true "Validator flagged dangling file pointer for M99" 0
else
  assert_true "Validator flagged dangling file pointer for M99" 1
fi

print_test_summary
