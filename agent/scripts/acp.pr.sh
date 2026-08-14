#!/usr/bin/env bash
# acp.pr.sh — PR prep with gates delegated ONLY to acp.ci.sh (M86 / D2 / ADR-24)
#
# FORBIDDEN: any duplicated tsc/lint/test/shellcheck/e2e gate implementation.
# CodeRabbit: optional; if unconfigured → SKIP with hint (never invent fixtures).
#
# Usage:
#   bash agent/scripts/acp.pr.sh --dry-run
#   bash agent/scripts/acp.pr.sh --strict-local --skip-push
#   bash agent/scripts/acp.pr.sh --branch feature/m86-ci --title "feat(M86): …" --create-pr --yes

set -euo pipefail
trap 'echo "[acp.pr] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck source=acp.yaml-parser.sh
source "${SCRIPT_DIR}/acp.yaml-parser.sh"

BASE_BRANCH=""
BRANCH=""
TITLE=""
BODY=""
BODY_FILE=""
DRY_RUN=false
SKIP_LOCAL=false
YES=false
SKIP_PUSH=false
CREATE_PR=false
STRICT_LOCAL=false
AUTO=false

IDENTITY="${REPO_ROOT}/agent/core/identity.yml"
PRODUCTION_BRANCH="mainline"
DEFAULT_WORKING="develop"

if [[ -f "${IDENTITY}" ]]; then
  PRODUCTION_BRANCH="$(yaml_get "${IDENTITY}" "git_workflow.production_branch" 2>/dev/null || echo mainline)"
  DEFAULT_WORKING="$(yaml_get "${IDENTITY}" "git_workflow.default_working_branch" 2>/dev/null || echo develop)"
fi
BASE_BRANCH="${DEFAULT_WORKING}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Prepare and/or push a feature PR targeting the default working branch.

Options:
  --base BRANCH         PR base (default: identity.yml default_working_branch)
  --branch NAME         Feature branch name
  --title TEXT          PR title (for gh pr create)
  --body TEXT           PR body
  --body-file PATH      PR body file
  --dry-run             Print plan only; no git/gh mutations
  --skip-local          Skip local gates (delegated to acp.ci.sh)
  --strict-local        Run the full CI tier locally instead of fast
  --skip-push           Run local gates only; do not push
  --auto                Derive title/body from commits since base
  --create-pr           After push, run gh pr create (needs --title)
  --yes                 Non-interactive where possible
  -h, --help            Help

Agent command: /acp-pr — see agent/commands/acp.pr.md

Gate delegation:
  default            → acp.ci.sh --fast
  --strict-local     → acp.ci.sh --full
  base=production    → acp.ci.sh --full
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE_BRANCH="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --body) BODY="$2"; shift 2 ;;
    --body-file) BODY_FILE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --skip-local) SKIP_LOCAL=true; shift ;;
    --strict-local) STRICT_LOCAL=true; shift ;;
    --auto) AUTO=true; shift ;;
    --skip-push) SKIP_PUSH=true; shift ;;
    --create-pr) CREATE_PR=true; shift ;;
    --yes|-y) YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

CURRENT_BRANCH="$(git branch --show-current)"

if [[ "${CURRENT_BRANCH}" == "${PRODUCTION_BRANCH}" ]]; then
  echo "[acp.pr] ERROR: Refusing to open PR from production branch '${PRODUCTION_BRANCH}'." >&2
  echo "  git checkout ${DEFAULT_WORKING}" >&2
  exit 1
fi

AHEAD_COUNT=0
if git rev-parse --verify "origin/${BASE_BRANCH}" >/dev/null 2>&1; then
  AHEAD_COUNT="$(git rev-list --count "origin/${BASE_BRANCH}..HEAD" 2>/dev/null || echo 0)"
elif git rev-parse --verify "${BASE_BRANCH}" >/dev/null 2>&1; then
  AHEAD_COUNT="$(git rev-list --count "${BASE_BRANCH}..HEAD" 2>/dev/null || echo 0)"
fi

if [[ -z "${BRANCH}" ]]; then
  if [[ "${CURRENT_BRANCH}" == "${BASE_BRANCH}" && "${AHEAD_COUNT}" -gt 0 ]]; then
    echo "[acp.pr] WARN: On ${BASE_BRANCH} with ${AHEAD_COUNT} unpushed commit(s). Set --branch feature/…" >&2
  fi
  BRANCH="${CURRENT_BRANCH}"
fi

echo "=== ACP PR prep ==="
echo "current_branch: ${CURRENT_BRANCH}"
echo "target_branch:  ${BRANCH}"
echo "base_branch:    ${BASE_BRANCH}"
echo "ahead_of_base:  ${AHEAD_COUNT}"
echo "dry_run:        ${DRY_RUN}"
echo ""

# --- Optional CodeRabbit path-filter check (SKIP if unconfigured) ---
CODERABBIT_SCRIPT="${SCRIPT_DIR}/acp.coderabbit.sh"
if [[ -f "${CODERABBIT_SCRIPT}" ]]; then
  # Prefer SKIP over silent pass when preferences/config absent.
  if [[ -f "${REPO_ROOT}/.coderabbit.yaml" ]] || [[ -f "${REPO_ROOT}/agent/configurables/coderabbit.yml" ]]; then
    echo ">>> CodeRabbit path-filter check"
    if [[ "${DRY_RUN}" == "true" ]]; then
      echo "  (dry-run) would invoke ${CODERABBIT_SCRIPT} path-filter check"
    else
      # Best-effort: if script exposes a check function when sourced, call it;
      # otherwise run as help-only probe. Never invent fixtures (ADR-22).
      if bash "${CODERABBIT_SCRIPT}" --help >/dev/null 2>&1; then
        echo "  CodeRabbit configured — ensure reviews.path_filters excludes agent/**"
      fi
    fi
  else
    echo ">>> CodeRabbit path-filter check — SKIP"
    echo "  hint: install/configure CodeRabbit (.coderabbit.yaml) or ignore; M81 fixture track is separate (ADR-22)"
  fi
  echo ""
else
  echo ">>> CodeRabbit — SKIP (acp.coderabbit.sh not present)"
  echo "  hint: optional; gates still run via acp.ci.sh"
  echo ""
fi

# --- Auto metadata ---
if [[ "${AUTO}" == "true" ]]; then
  if [[ -z "${TITLE}" ]]; then
    if git rev-parse --verify "origin/${BASE_BRANCH}" >/dev/null 2>&1; then
      TITLE="$(git log -1 --format='%s' "origin/${BASE_BRANCH}..HEAD" 2>/dev/null || true)"
    else
      TITLE="$(git log -1 --format='%s' "${BASE_BRANCH}..HEAD" 2>/dev/null || true)"
    fi
    [[ -n "${TITLE}" ]] || TITLE="chore: update"
  fi
  if [[ -z "${BODY}" && -z "${BODY_FILE}" ]]; then
    BODY_FILE="$(mktemp "${TMPDIR:-/tmp}/acp-pr-body.XXXXXX")"
    {
      echo "## Summary"
      echo ""
      git log --oneline "${BASE_BRANCH}..HEAD" 2>/dev/null || true
      echo ""
      echo "## Test plan"
      echo "- [ ] \`bash agent/scripts/acp.ci.sh --fast\` green locally"
    } > "${BODY_FILE}"
  fi
  echo "auto title: ${TITLE}"
fi

# --- Local gates (ONLY via acp.ci.sh — single source of gate logic) ---
CI_SCRIPT="${SCRIPT_DIR}/acp.ci.sh"
EXECUTED_STEPS=0

if [[ "${SKIP_LOCAL}" == "false" ]]; then
  echo ">>> Local gates"
  if [[ ! -f "${CI_SCRIPT}" ]]; then
    echo "[acp.pr] ERROR: ${CI_SCRIPT} not found — refuse to invent inline gates" >&2
    exit 1
  fi
  CI_TIER="--fast"
  if [[ "${STRICT_LOCAL}" == "true" || "${BASE_BRANCH}" == "${PRODUCTION_BRANCH}" ]]; then
    CI_TIER="--full"
  fi
  CI_ARGS=("${CI_TIER}")
  if [[ "${DRY_RUN}" == "true" ]]; then
    CI_ARGS+=(--dry-run)
  fi
  echo "  delegating to: acp.ci.sh ${CI_ARGS[*]}"
  # FG-1: if-context capture
  ci_rc=0
  if bash "${CI_SCRIPT}" "${CI_ARGS[@]}"; then
    ci_rc=0
  else
    ci_rc=$?
  fi
  # Dry-run plans count as 0 executed; real runs leave verification to acp.ci.sh
  if [[ "${DRY_RUN}" == "false" && "${ci_rc}" -eq 0 ]]; then
    EXECUTED_STEPS=1
  fi
  if [[ "${ci_rc}" -ne 0 ]]; then
    echo "[acp.pr] Local gates failed (acp.ci.sh exit ${ci_rc})" >&2
    exit "${ci_rc}"
  fi
  echo ""
else
  echo ">>> Skipping local gates (--skip-local)"
  echo ""
fi

# --- Branch ---
if [[ "${CURRENT_BRANCH}" != "${BRANCH}" ]]; then
  echo ">>> git checkout ${BRANCH}"
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "  (dry-run)"
  elif git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    git checkout "${BRANCH}"
  else
    git checkout -b "${BRANCH}"
  fi
elif [[ "${CURRENT_BRANCH}" == "${BASE_BRANCH}" && "${AHEAD_COUNT}" -gt 0 && "${BRANCH}" == "${BASE_BRANCH}" ]]; then
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[acp.pr] WARN: (dry-run) still on ${BASE_BRANCH} with unpushed work — real run needs --branch feature/<name>." >&2
  else
    echo "[acp.pr] ERROR: Still on ${BASE_BRANCH} with unpushed work. Pass --branch feature/<name>." >&2
    exit 1
  fi
fi

# --- Push ---
if [[ "${SKIP_PUSH}" == "false" ]]; then
  echo ">>> git push -u origin ${BRANCH}"
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "  (dry-run)"
  else
    git push -u origin "${BRANCH}"
  fi
  echo ""
fi

# --- PR create ---
if [[ "${CREATE_PR}" == "true" || -n "${TITLE}" ]]; then
  echo ">>> gh pr create --base ${BASE_BRANCH}"
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "  (dry-run) title=${TITLE}"
  else
    if [[ -z "${TITLE}" ]]; then
      echo "[acp.pr] ERROR: --create-pr requires --title (or --auto)" >&2
      exit 1
    fi
    GH_ARGS=(pr create --base "${BASE_BRANCH}" --head "${BRANCH}" --title "${TITLE}")
    if [[ -n "${BODY_FILE}" ]]; then
      GH_ARGS+=(--body-file "${BODY_FILE}")
    elif [[ -n "${BODY}" ]]; then
      GH_ARGS+=(--body "${BODY}")
    fi
    if [[ "${YES}" == "true" ]]; then
      gh "${GH_ARGS[@]}"
    else
      echo "  Run: gh ${GH_ARGS[*]}"
      echo "  (pass --yes to execute)"
    fi
  fi
fi

echo ""
echo "[ACP PR] done | executed_gate_delegation=${EXECUTED_STEPS} | dry_run=${DRY_RUN}"
