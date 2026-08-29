#!/usr/bin/env bash
# acp.smoke.sh — optional device preflight dispatcher (M90 / D9 / D16)
#
# Delegates to a project runner from agent/configurables/smoke.yml.
# Missing file or empty runner → exit 2, message "not configured", never PASS.
# Do not add --host. Do not vendor Maestro. Zero git/gh mutations.
#
# False-green: FG-1 (no set +e under trap), FG-2 (never PASS with zero work).

set -euo pipefail
trap 'echo "[acp.smoke] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

SMOKE_CONFIG="${ACP_SMOKE_CONFIG:-${REPO_ROOT}/agent/configurables/smoke.yml}"

DRY_RUN=false
DOCTOR=false
PASSTHROUGH=()

usage() {
  cat <<'EOF'
Usage: acp.smoke.sh [options]

Optional device preflight. Delegates to a project runner listed in
agent/configurables/smoke.yml. This is not a CI step — AE CI uses
step id e2e-smoke (/acp-ci --full). Never --only smoke.

Options:
  --doctor            Print runner status. Exit 2 if unconfigured;
                      exit 1 if configured but the runner is missing;
                      exit 0 if the runner exists.
  --dry-run           Print the plan; do not execute the runner.
  --android           Passthrough to the project runner (not AE Gradle).
  --ios               Passthrough to the project runner.
  -h, --help          Help

Unconfigured (missing smoke.yml or empty runner): exit 2, no PASS.
Agent command: /acp-smoke — see agent/commands/acp.smoke.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --doctor) DOCTOR=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --android|--ios) PASSTHROUGH+=("$1"); shift ;;
    -h|--help) usage; exit 0 ;;
    --)
      shift
      PASSTHROUGH+=("$@")
      break
      ;;
    -*)
      echo "[acp.smoke] ERROR: unknown option: $1" >&2
      echo "[acp.smoke] see --help" >&2
      exit 2
      ;;
    *)
      PASSTHROUGH+=("$1")
      shift
      ;;
  esac
done

# Strip quotes from a YAML scalar (runner: "path" or runner: path).
_smoke_unquote() {
  local v="$1"
  v="${v#\"}"
  v="${v%\"}"
  v="${v#\'}"
  v="${v%\'}"
  printf '%s' "$v"
}

# Empty runner or missing file → unconfigured (exit 2).
read_runner() {
  local cfg="$1"
  local line val
  if [[ ! -f "$cfg" ]]; then
    echo ""
    return 1
  fi
  line=$(grep -E '^[[:space:]]*runner:' "$cfg" | head -1 || true)
  if [[ -z "$line" ]]; then
    echo ""
    return 1
  fi
  val="${line#*:}"
  val="${val#"${val%%[![:space:]]*}"}"
  val="${val%"${val##*[![:space:]]}"}"
  val="$(_smoke_unquote "$val")"
  if [[ -z "$val" ]]; then
    echo ""
    return 1
  fi
  printf '%s' "$val"
  return 0
}

resolve_runner() {
  local runner="$1"
  case "$runner" in
    /*) printf '%s' "$runner" ;;
    ./*|/*/*|*/*) printf '%s' "${REPO_ROOT}/${runner#./}" ;;
    *) printf '%s' "$runner" ;;
  esac
}

runner_exists() {
  local runner="$1"
  local resolved
  resolved=$(resolve_runner "$runner")
  case "$runner" in
    /*|./*|*/*)
      [[ -f "$resolved" || -x "$resolved" ]]
      ;;
    *)
      if [[ -f "$resolved" || -x "$resolved" ]]; then
        return 0
      fi
      command -v "$runner" >/dev/null 2>&1
      ;;
  esac
}

emit_unconfigured() {
  echo "[acp.smoke] not configured" >&2
  echo "[acp.smoke] Set runner: in agent/configurables/smoke.yml (D16). Missing or empty → exit 2." >&2
}

RUNNER=""
if RUNNER=$(read_runner "$SMOKE_CONFIG"); then
  :
else
  RUNNER=""
fi

if [[ "$DOCTOR" == true ]]; then
  echo "[acp.smoke] config: ${SMOKE_CONFIG}"
  if [[ -z "$RUNNER" ]]; then
    echo "[acp.smoke] runner: (empty)"
    emit_unconfigured
    exit 2
  fi
  echo "[acp.smoke] runner: ${RUNNER}"
  if runner_exists "$RUNNER"; then
    echo "[acp.smoke] runner exists: yes"
    exit 0
  fi
  echo "[acp.smoke] runner exists: no" >&2
  echo "[acp.smoke] configured but runner missing" >&2
  exit 1
fi

if [[ -z "$RUNNER" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    echo "[acp.smoke] dry-run: would fail closed (unconfigured)"
  fi
  emit_unconfigured
  exit 2
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "[acp.smoke] dry-run: would exec: ${RUNNER} ${PASSTHROUGH[*]:-}"
  echo "[acp.smoke] dry-run is not verification (FG-6)"
  exit 0
fi

if ! runner_exists "$RUNNER"; then
  echo "[acp.smoke] configured but runner missing: ${RUNNER}" >&2
  exit 1
fi

RESOLVED=$(resolve_runner "$RUNNER")
if [[ -f "$RESOLVED" ]]; then
  bash "$RESOLVED" "${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"}"
else
  "$RUNNER" "${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"}"
fi
