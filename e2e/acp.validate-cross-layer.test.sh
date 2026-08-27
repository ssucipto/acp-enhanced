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
  cp -r "${PROJECT_ROOT}/e2e" "${dest}/e2e"
  if [[ -d "${PROJECT_ROOT}/.cursor" ]]; then
    cp -r "${PROJECT_ROOT}/.cursor" "${dest}/.cursor"
  fi
  if [[ -d "${PROJECT_ROOT}/.claude" ]]; then
    cp -r "${PROJECT_ROOT}/.claude" "${dest}/.claude"
  fi
  if [[ -d "${PROJECT_ROOT}/.opencode" ]]; then
    cp -r "${PROJECT_ROOT}/.opencode" "${dest}/.opencode"
  fi
  if [[ -d "${PROJECT_ROOT}/.github/prompts" ]]; then
    mkdir -p "${dest}/.github"
    cp -r "${PROJECT_ROOT}/.github/prompts" "${dest}/.github/prompts"
  fi
  if [[ -f "${PROJECT_ROOT}/package.json" ]]; then
    cp "${PROJECT_ROOT}/package.json" "${dest}/"
  fi
  if [[ -f "${PROJECT_ROOT}/package.yaml" ]]; then
    cp "${PROJECT_ROOT}/package.yaml" "${dest}/"
  fi
  if [[ -f "${PROJECT_ROOT}/.gitattributes" ]]; then
    cp "${PROJECT_ROOT}/.gitattributes" "${dest}/"
  fi
  if [[ -f "${PROJECT_ROOT}/.gitignore" ]]; then
    cp "${PROJECT_ROOT}/.gitignore" "${dest}/"
  fi
  if [[ -f "${PROJECT_ROOT}/docs/USAGE.md" ]]; then
    mkdir -p "${dest}/docs"
    cp "${PROJECT_ROOT}/docs/USAGE.md" "${dest}/docs/USAGE.md"
  fi
  if [[ -f "${PROJECT_ROOT}/AGENTS.md" ]]; then
    cp "${PROJECT_ROOT}/AGENTS.md" "${dest}/"
    cp "${PROJECT_ROOT}/AGENTS.md" "${dest}/CLAUDE.md"
    mkdir -p "${dest}/.github"
    cp "${PROJECT_ROOT}/AGENTS.md" "${dest}/.github/copilot-instructions.md"
  fi
  # ADR-27: local report/feedback bodies stay gitignored. Copying them into
  # the fixture makes Windows git-add + validate exceed the 180s E2E timeout.
  if [[ -d "${dest}/agent/reports" ]]; then
    find "${dest}/agent/reports" -type f ! -name '.gitkeep' ! -name 'README.md' -delete
  fi
  if [[ -d "${dest}/agent/feedback" ]]; then
    find "${dest}/agent/feedback" -type f ! -name '.gitkeep' ! -name 'README.md' -delete
  fi
  # ADR-28: instance milestone/task/session bodies stay local. Copying them
  # into the fixture makes Windows git-add + validate exceed the E2E timeout.
  if [[ -d "${dest}/agent/milestones" ]]; then
    find "${dest}/agent/milestones" -type f ! -name '.gitkeep' ! -name 'README.md' ! -name '*.template.md' -delete
  fi
  if [[ -d "${dest}/agent/tasks" ]]; then
    find "${dest}/agent/tasks" -type f ! -name '.gitkeep' ! -name 'README.md' ! -name '*.template.md' -delete
  fi
  if [[ -d "${dest}/agent/sessions" ]]; then
    find "${dest}/agent/sessions" -type f ! -name '.gitkeep' ! -name 'README.md' -delete
  fi
}

_init_fixture_git_repo() {
  local dest="$1"
  local version
  version="$(awk '/^version:/{print $2; exit}' "${PROJECT_ROOT}/agent/core/identity.yml")"
  (
    cd "$dest"
    git init -q
    git config user.email test@example.com
    git config user.name "ACP E2E"
    git add -A
    git commit -q -m "fixture"
    if [[ -n "$version" ]]; then
      git tag -a "v${version}" -m "fixture tag" HEAD
    fi
  )
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
_init_fixture_git_repo "${TMPDIR}"

# KEEP path (*.template.md is not gitignored). Instance milestone bodies are stripped (ADR-28).
V1_DOC="agent/milestones/e2e-v1-desync.template.md"
printf '%s\n' "**Status**: planned" > "${TMPDIR}/${V1_DOC}"
PROGRESS1="${TMPDIR}/agent/progress.yaml"
awk -v doc="${V1_DOC}" '
  /^milestones:[[:space:]]*$/ {
    print
    print "  M98:"
    print "    name: E2E Status Desync Fixture"
    print "    status: completed"
    print "    file: " doc
    next
  }
  { print }
' "${PROGRESS1}" > "${PROGRESS1}.tmp" && mv "${PROGRESS1}.tmp" "${PROGRESS1}"

pushd "${TMPDIR}" > /dev/null
VALIDATE_OUT=$(_run_validator "${TMPDIR}" 2>&1) || true
popd > /dev/null

assert_not_empty "${VALIDATE_OUT}" "Validator produced output"
DESYNC_FOUND=$(echo "${VALIDATE_OUT}" | grep -ci "Status desync\|status.*disagree\|desync" || true)
if [[ "${DESYNC_FOUND}" -ge 1 ]]; then
  assert_true "Validator flagged status desync for M98" 0
else
  assert_true "Validator flagged status desync for M98" 1
fi

print_test_header "V2 — aligned workspace produces clean exit (no desync)"
TMPDIR2=$(mktemp -d)
trap 'rm -rf "${TMPDIR2}" ${TMPDIR}' EXIT

_copy_fixture_workspace "${TMPDIR2}"
_init_fixture_git_repo "${TMPDIR2}"

pushd "${TMPDIR2}" > /dev/null
VALIDATE_RC2=0
VALIDATE_OUT2=$(_run_validator "${TMPDIR2}" 2>&1) || VALIDATE_RC2=$?
popd > /dev/null

assert_equals 0 "${VALIDATE_RC2}" "Clean workspace validator exits 0"
DESYNC_FOUND2=$(echo "${VALIDATE_OUT2}" | grep -ci "Status desync\|status.*disagree" || true)
assert_equals "${DESYNC_FOUND2}" 0 "Clean workspace has no desync warnings"

print_test_header "V3 — dangling file pointer detected"
TMPDIR3=$(mktemp -d)
trap 'rm -rf "${TMPDIR2}" "${TMPDIR3}" ${TMPDIR}' EXIT

_copy_fixture_workspace "${TMPDIR3}"
_init_fixture_git_repo "${TMPDIR3}"

# Insert under milestones: (appending at EOF breaks YAML and is ignored by parsers).
# Use M99 — unused id; must stay a real milestones: child so validateFilePointers sees it.
PROGRESS3="${TMPDIR3}/agent/progress.yaml"
awk '
  /^milestones:[[:space:]]*$/ {
    print
    print "  M99:"
    print "    name: Nonexistent Test Milestone"
    print "    status: active"
    print "    file: agent/design/e2e-m99-does-not-exist.md"
    next
  }
  { print }
' "${PROGRESS3}" > "${PROGRESS3}.tmp" && mv "${PROGRESS3}.tmp" "${PROGRESS3}"

pushd "${TMPDIR3}" > /dev/null
VALIDATE_OUT3=$(_run_validator "${TMPDIR3}" 2>&1) || VALIDATE_RC3=$?
popd > /dev/null

DANGLING_FOUND=$(echo "${VALIDATE_OUT3}" | grep -ci "Dangling pointer.*M99\|M99.*does not exist" || true)
if [[ "${DANGLING_FOUND}" -ge 1 ]]; then
  assert_true "Validator flagged dangling file pointer for M99" 0
else
  assert_true "Validator flagged dangling file pointer for M99" 1
fi

print_test_summary
