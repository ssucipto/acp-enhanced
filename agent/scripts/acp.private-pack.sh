#!/usr/bin/env bash
# acp.private-pack.sh — encrypt gitignored ACP dirs for machine transport (M87 / ADR-27)
#
# Usage:
#   bash agent/scripts/acp.private-pack.sh pack --output PATH
#   bash agent/scripts/acp.private-pack.sh unpack --input PATH --dest DIR [--dry-run]
#
# Encryption: age -p when `age` exists and no passphrase env; otherwise gpg AES256.
# Passphrase: AGE_PASSPHRASE or ACP_PACK_PASSPHRASE (never argv). Interactive if unset.

set -euo pipefail
trap 'echo "[acp.private-pack] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PACK_ROOT="${ACP_PRIVATE_PACK_ROOT:-${REPO_ROOT}}"
cd "${REPO_ROOT}"

STAMP="$(date +%Y%m%dT%H%M%S)"
DEFAULT_OUT="${HOME}/acp-enhanced-private/acp-private-pack-${STAMP}.tar.gz.gpg"
_ACP_PACK_TMP=""
cleanup_tmp() { rm -f "${_ACP_PACK_TMP:-}"; }
trap cleanup_tmp EXIT

PACK_REL_DIRS=(
  agent/reports
  agent/feedback
  agent/clarifications
  agent/drafts
  agent/preferences
  agent/private
  agent/milestones
  agent/tasks
  agent/sessions
  agent/design
  agent/patterns
  agent/routing/tasks
)

usage() {
  cat <<'EOF'
Usage: acp.private-pack.sh <pack|unpack> [options]

  pack --output PATH     Encrypt local ACP dirs to PATH (default: $HOME/acp-enhanced-private/...)
  unpack --input PATH --dest DIR [--dry-run]

Never pass the passphrase on argv. Use AGE_PASSPHRASE or ACP_PACK_PASSPHRASE, or an interactive prompt.
Output must not be inside .git/ or a tracked (non-ignored) path under the clone.
EOF
}

abs_path() {
  local p="$1"
  local dir base
  dir="$(cd "$(dirname "${p}")" && pwd)"
  base="$(basename "${p}")"
  printf '%s/%s\n' "${dir}" "${base}"
}

refuse_bad_output() {
  local out="$1"
  local parent abs rel
  parent="$(dirname "${out}")"
  mkdir -p "${parent}"
  abs="$(abs_path "${out}")"
  case "${abs}" in
    "${REPO_ROOT}/.git"|"${REPO_ROOT}/.git"/*)
      echo "[acp.private-pack] ERROR: refuse output inside .git/" >&2
      exit 2
      ;;
  esac
  case "${abs}" in
    "${REPO_ROOT}"/*)
      rel="${abs#"${REPO_ROOT}"/}"
      if git -C "${REPO_ROOT}" check-ignore -q "${rel}"; then
        return 0
      fi
      echo "[acp.private-pack] ERROR: output ${rel} is under the clone and not gitignored" >&2
      exit 2
      ;;
  esac
}

encrypt_tar() {
  local tarfile="$1"
  local outfile="$2"
  local pass="${AGE_PASSPHRASE:-${ACP_PACK_PASSPHRASE:-}}"
  if command -v age >/dev/null 2>&1 && [[ -z "${pass}" ]]; then
    age -p -o "${outfile}" "${tarfile}"
    return 0
  fi
  if command -v age >/dev/null 2>&1 && [[ -n "${AGE_PASSPHRASE:-}" ]]; then
    # age has no stable non-interactive -p env; fall through to gpg when env is set.
    :
  fi
  if ! command -v gpg >/dev/null 2>&1; then
    echo "[acp.private-pack] ERROR: need age or gpg" >&2
    exit 1
  fi
  if [[ -z "${pass}" ]]; then
    gpg --symmetric --cipher-algo AES256 -o "${outfile}" "${tarfile}"
  else
    gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 \
      --symmetric --cipher-algo AES256 -o "${outfile}" "${tarfile}" <<<"${pass}"
  fi
}

decrypt_to_tar() {
  local infile="$1"
  local tarfile="$2"
  local pass="${AGE_PASSPHRASE:-${ACP_PACK_PASSPHRASE:-}}"
  case "${infile}" in
    *.age)
      if [[ -n "${pass}" ]]; then
        AGE_PASSPHRASE="${pass}" age -d -o "${tarfile}" "${infile}"
      else
        age -d -o "${tarfile}" "${infile}"
      fi
      ;;
    *)
      if [[ -z "${pass}" ]]; then
        gpg --decrypt -o "${tarfile}" "${infile}"
      else
        gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 \
          --decrypt -o "${tarfile}" "${infile}" <<<"${pass}"
      fi
      ;;
  esac
}

cmd_pack() {
  local output=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output)
        [[ $# -ge 2 ]] || { echo "[acp.private-pack] ERROR: --output needs PATH" >&2; exit 2; }
        output="$2"
        shift 2
        ;;
      -h|--help) usage; exit 0 ;;
      *) echo "[acp.private-pack] ERROR: unknown pack arg: $1" >&2; usage; exit 2 ;;
    esac
  done
  if [[ -z "${output}" ]]; then
    mkdir -p "$(dirname "${DEFAULT_OUT}")"
    output="${DEFAULT_OUT}"
  fi
  refuse_bad_output "${output}"

  local existing=()
  local d
  for d in "${PACK_REL_DIRS[@]}"; do
    if [[ -d "${PACK_ROOT}/${d}" ]]; then
      existing+=("${d}")
    fi
  done
  if [[ ${#existing[@]} -eq 0 ]]; then
    echo "[acp.private-pack] ERROR: no pack directories present" >&2
    exit 1
  fi

  _ACP_PACK_TMP="/tmp/acp-private-pack-${STAMP}.tar.gz"
  tar -C "${PACK_ROOT}" -czf "${_ACP_PACK_TMP}" "${existing[@]}"
  encrypt_tar "${_ACP_PACK_TMP}" "${output}"
  echo "packed: ${output}"
  echo "dirs: ${existing[*]}"
}

cmd_unpack() {
  local input="" dest="" dry_run=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --input)
        [[ $# -ge 2 ]] || { echo "[acp.private-pack] ERROR: --input needs PATH" >&2; exit 2; }
        input="$2"
        shift 2
        ;;
      --dest)
        [[ $# -ge 2 ]] || { echo "[acp.private-pack] ERROR: --dest needs DIR" >&2; exit 2; }
        dest="$2"
        shift 2
        ;;
      --dry-run) dry_run=true; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "[acp.private-pack] ERROR: unknown unpack arg: $1" >&2; usage; exit 2 ;;
    esac
  done
  if [[ -z "${input}" || -z "${dest}" ]]; then
    echo "[acp.private-pack] ERROR: unpack requires --input and --dest" >&2
    exit 2
  fi
  [[ -f "${input}" ]] || { echo "[acp.private-pack] ERROR: missing input ${input}" >&2; exit 1; }

  _ACP_PACK_TMP="/tmp/acp-private-unpack-${STAMP}.tar.gz"
  decrypt_to_tar "${input}" "${_ACP_PACK_TMP}"
  if [[ "${dry_run}" == "true" ]]; then
    tar -tzf "${_ACP_PACK_TMP}"
    echo "dry-run: no files written"
    return 0
  fi
  mkdir -p "${dest}"
  tar -C "${dest}" -xzf "${_ACP_PACK_TMP}"
  echo "unpacked: ${dest}"
}

MODE="${1:-}"
if [[ $# -gt 0 ]]; then
  shift
fi
case "${MODE}" in
  pack) cmd_pack "$@" ;;
  unpack) cmd_unpack "$@" ;;
  -h|--help|"") usage; [[ -n "${MODE}" ]] && exit 0; exit 2 ;;
  *) echo "[acp.private-pack] ERROR: unknown mode ${MODE}" >&2; usage; exit 2 ;;
esac
