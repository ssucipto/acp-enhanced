#!/usr/bin/env bash
# acp.exec-host-ssh.sh — portable exec-host orchestrator (M91 / D10)
#
# Env (ACP_* only — no product prefixes):
#   ACP_EXEC_HOST=github|windows|local
#   ACP_WINDOWS_SSH     user@host (windows OpenSSH)
#   ACP_WINDOWS_REPO    remote repo path for scp of the bundle
#   ACP_SECRET_FILES    comma-separated relative paths; never printed
#   ACP_AVD_NAME        optional AVD name default (not a product constant)
#
# --prepare uses git bundle create + scp. Do not require SSH_AUTH_SOCK.
# ssh -A is unused for clone. Not a /acp-ci --fast step. Zero git/gh mutations
# except git bundle create when --prepare runs for real.
#
# False-green: FG-1 (no set +e under trap), FG-6 (dry-run is not verification),
# FG-7 (unknown host fail-closed).

set -euo pipefail
trap 'echo "[acp.exec-host] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

HOST="${ACP_EXEC_HOST:-}"
DRY_RUN=false
PREPARE=false
DOCTOR=false

usage() {
  cat <<'EOF'
Usage: acp.exec-host-ssh.sh [options]

Portable exec-host: move heavy device work off the editor via git bundle
+ scp. Not a CI step. Never print secret file bytes.

Env:
  ACP_EXEC_HOST=github|windows|local   default host (overridden by --host)
  ACP_WINDOWS_SSH                      user@host for Windows OpenSSH
  ACP_WINDOWS_REPO                     remote path to receive the bundle
  ACP_SECRET_FILES                     relative paths, comma-separated
  ACP_AVD_NAME                         AVD name (optional; not a product id)

Options:
  --host github|windows|local   Override ACP_EXEC_HOST
  --prepare                     git bundle create; scp when SSH target is set
  --dry-run                     Print the plan; do not bundle, scp, or ssh
  --doctor                      Print env presence (yes/no), not secret bytes
  -h, --help                    Help

LAN adb is --host local only. Win32-OpenSSH has no SSH_AUTH_SOCK.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      if [[ -z "${2-}" ]]; then
        echo "[acp.exec-host] ERROR: --host requires github|windows|local" >&2
        exit 2
      fi
      HOST="$2"
      shift 2
      ;;
    --prepare) PREPARE=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --doctor) DOCTOR=true; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "[acp.exec-host] ERROR: unknown option: $1" >&2
      echo "[acp.exec-host] see --help" >&2
      exit 2
      ;;
    *)
      echo "[acp.exec-host] ERROR: unexpected argument: $1" >&2
      exit 2
      ;;
  esac
done

valid_host() {
  case "$1" in
    github|windows|local) return 0 ;;
    *) return 1 ;;
  esac
}

# Presence only — never print secret file contents (D10).
secret_paths_ok() {
  local spec="${ACP_SECRET_FILES:-}"
  local rel p
  if [[ -z "$spec" ]]; then
    return 0
  fi
  IFS=',' read -r -a parts <<< "$spec"
  for rel in "${parts[@]}"; do
    rel="${rel#"${rel%%[![:space:]]*}"}"
    rel="${rel%"${rel##*[![:space:]]}"}"
    [[ -z "$rel" ]] && continue
    p="${REPO_ROOT}/${rel}"
    if [[ ! -f "$p" ]]; then
      echo "[acp.exec-host] ERROR: secret file missing: ${rel}" >&2
      return 1
    fi
  done
  return 0
}

ssh_set="no"
repo_set="no"
[[ -n "${ACP_WINDOWS_SSH:-}" ]] && ssh_set="yes"
[[ -n "${ACP_WINDOWS_REPO:-}" ]] && repo_set="yes"

if [[ "$DOCTOR" == true ]]; then
  echo "[acp.exec-host] ACP_EXEC_HOST: ${HOST:-"(unset)"}"
  echo "[acp.exec-host] ACP_WINDOWS_SSH set: ${ssh_set}"
  echo "[acp.exec-host] ACP_WINDOWS_REPO set: ${repo_set}"
  echo "[acp.exec-host] ACP_SECRET_FILES set: $([[ -n "${ACP_SECRET_FILES:-}" ]] && echo yes || echo no)"
  echo "[acp.exec-host] ACP_AVD_NAME: ${ACP_AVD_NAME:-"(unset)"}"
  echo "[acp.exec-host] SSH_AUTH_SOCK required: no (Win32-OpenSSH has none)"
  if command -v git >/dev/null 2>&1; then
    echo "[acp.exec-host] git: yes"
  else
    echo "[acp.exec-host] git: no" >&2
    exit 1
  fi
  if [[ -n "${HOST}" ]] && ! valid_host "${HOST}"; then
    echo "[acp.exec-host] ERROR: unknown host: ${HOST}" >&2
    exit 2
  fi
  if ! secret_paths_ok; then
    exit 1
  fi
  exit 0
fi

if [[ -n "${HOST}" ]] && ! valid_host "${HOST}"; then
  echo "[acp.exec-host] ERROR: unknown host: ${HOST} (want github|windows|local)" >&2
  exit 2
fi

if ! secret_paths_ok; then
  exit 1
fi

BUNDLE_NAME="acp-exec-host.bundle"
BUNDLE_PATH="${TMPDIR:-/tmp}/${BUNDLE_NAME}"

plan_windows() {
  echo "[acp.exec-host] plan host=windows"
  echo "[acp.exec-host] would: git bundle create ${BUNDLE_NAME} HEAD"
  echo "[acp.exec-host] would: scp ${BUNDLE_NAME} to ACP_WINDOWS_SSH:ACP_WINDOWS_REPO (not ssh -A clone)"
  echo "[acp.exec-host] Win32-OpenSSH: no SSH_AUTH_SOCK; Git Bash uses a temp script file (not bash -lc)"
  echo "[acp.exec-host] LAN adb is --host local only"
}

plan_github() {
  echo "[acp.exec-host] plan host=github"
  echo "[acp.exec-host] would: git bundle create ${BUNDLE_NAME} HEAD"
  echo "[acp.exec-host] GitHub clone 404 without a bundle — use --prepare + -BundleFile on Windows"
}

plan_local() {
  echo "[acp.exec-host] plan host=local"
  echo "[acp.exec-host] LAN adb / local device only; do not plan remote Gradle"
}

if [[ "$DRY_RUN" == true ]]; then
  case "${HOST:-windows}" in
    windows) plan_windows ;;
    github) plan_github ;;
    local) plan_local ;;
  esac
  echo "[acp.exec-host] dry-run is not verification (FG-6)"
  exit 0
fi

if [[ "$PREPARE" == true ]]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "[acp.exec-host] ERROR: git not found" >&2
    exit 1
  fi
  echo "[acp.exec-host] git bundle create ${BUNDLE_PATH} HEAD"
  git bundle create "${BUNDLE_PATH}" HEAD
  if [[ "${HOST:-}" == "windows" && -n "${ACP_WINDOWS_SSH:-}" && -n "${ACP_WINDOWS_REPO:-}" ]]; then
    echo "[acp.exec-host] scp bundle to ${ssh_set} target (host redacted)"
    scp "${BUNDLE_PATH}" "${ACP_WINDOWS_SSH}:${ACP_WINDOWS_REPO%/}/${BUNDLE_NAME}"
  else
    echo "[acp.exec-host] bundle written: ${BUNDLE_PATH} (scp skipped — ACP_WINDOWS_SSH/REPO unset)"
  fi
  exit 0
fi

echo "[acp.exec-host] ERROR: nothing to do — pass --dry-run, --prepare, or --doctor" >&2
exit 2
