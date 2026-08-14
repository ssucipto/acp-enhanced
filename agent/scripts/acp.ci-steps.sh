#!/usr/bin/env bash
# acp.ci-steps.sh — AE CI step bodies for /acp-ci (M86 / P-PATH-1)
#
# SOURCED by agent/scripts/acp.ci.sh — do NOT execute this file directly.
# Do NOT place bodies at top-level scripts/acp-ci-steps.sh.
#
# Bodies invoke real local AE commands from .github/workflows/ci.yaml /
# e2e-tests.yaml. No Expo / Firebase / payslip / m50.
#
# Each runner must be named after ci.yml steps.*.command and exit non-zero
# on failure. Orchestrator captures status in if-context (FG-1).

# Guard: sourced library — no set -euo here (would alter caller). Callers
# already run under set -euo pipefail + trap ERR.

: "${REPO_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

ci_run_step() {
  local id="$1"
  case "${id}" in
    validate-ts)        _ci_step_validate_ts ;;
    review-measure)     _ci_step_review_measure ;;
    npm-test)           _ci_step_npm_test ;;
    ci-validate)        _ci_step_ci_validate ;;
    shellcheck)         _ci_step_shellcheck ;;
    integrity-e2e)      _ci_step_integrity_e2e ;;
    integrity-v2-e2e)   _ci_step_integrity_v2_e2e ;;
    e2e-smoke)          _ci_step_e2e_smoke ;;
    npm-audit)          _ci_step_npm_audit ;;
    e2e-matrix)         _ci_step_e2e_matrix ;;
    *)
      echo "[acp.ci-steps] Unknown step command id: ${id}" >&2
      return 2
      ;;
  esac
}

_ci_ensure_scripts_node_modules() {
  if [[ ! -d "${REPO_ROOT}/scripts/node_modules" ]]; then
    echo "[acp.ci-steps] installing scripts/ deps (npm install --ignore-scripts)"
    ( cd "${REPO_ROOT}/scripts" && npm install --silent --ignore-scripts )
  fi
}

_ci_step_validate_ts() {
  _ci_ensure_scripts_node_modules
  ( cd "${REPO_ROOT}/scripts" && npx tsx acp-validate.ts )
}

_ci_step_review_measure() {
  bash "${REPO_ROOT}/agent/scripts/acp.review-measure.sh" --ci
}

_ci_step_npm_test() {
  _ci_ensure_scripts_node_modules
  ( cd "${REPO_ROOT}/scripts" && npm test --silent )
}

_ci_step_ci_validate() {
  bash "${REPO_ROOT}/scripts/ci-validate.sh"
}

_ci_step_shellcheck() {
  local scripts count
  # Match .github/workflows/ci.yaml shellcheck job (error severity only)
  scripts="$(find "${REPO_ROOT}/agent/scripts" "${REPO_ROOT}/scripts" "${REPO_ROOT}/e2e" "${REPO_ROOT}/tests" \
    -name '*.sh' 2>/dev/null | sort)"
  count="$(printf '%s\n' "${scripts}" | sed '/^$/d' | wc -l | tr -d ' ')"
  echo "Found ${count} shell scripts"
  # shellcheck disable=SC2086 — xargs needs word-split paths from newline list
  echo "${scripts}" | xargs shellcheck --shell=bash --severity=error
  echo "shellcheck passed (no errors)"
}

_ci_step_integrity_e2e() {
  bash "${REPO_ROOT}/e2e/acp.integrity.test.sh"
}

_ci_step_integrity_v2_e2e() {
  bash "${REPO_ROOT}/e2e/acp.integrity-v2.test.sh"
}

_ci_step_e2e_smoke() {
  bash "${REPO_ROOT}/run-e2e-tests.sh" --skip-network
}

_ci_step_npm_audit() {
  # Mirrors supply-chain job's npm audit (CI uses continue-on-error).
  # allow_skip in ci.yml handles missing npm; here we run the audit itself.
  _ci_ensure_scripts_node_modules
  ( cd "${REPO_ROOT}/scripts" && npm audit --audit-level=high )
}

_ci_step_e2e_matrix() {
  # Local stand-in for e2e-tests.yaml matrix (single OS). Full OS matrix is CI-only.
  if [[ -f "${REPO_ROOT}/run-e2e-tests.sh" ]]; then
    bash "${REPO_ROOT}/run-e2e-tests.sh"
  else
    echo "[acp.ci-steps] run-e2e-tests.sh not found" >&2
    return 1
  fi
}
