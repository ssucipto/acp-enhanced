#!/usr/bin/env bash
# acp.gitleaks.sh — optional gitleaks detection helpers (M83, ADR-23)
#
# Variant B (detection-as-consent): explicit false disables; auto/true allow
# activation when the local binary is present. This is a sourced helper library
# and intentionally does NOT enable strict shell options in callers.

_ACP_GITLEAKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.preferences.sh
source "${_ACP_GITLEAKS_DIR}/acp.preferences.sh"

_gitleaks_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || echo "."
}

_gitleaks_pref() {
  local root
  root="$(_gitleaks_repo_root)"
  ( cd "$root" 2>/dev/null && get_preference_or "acp" "integrations.gitleaks.enabled" "auto" ) || echo "auto"
}

gitleaks_available() {
  command -v gitleaks >/dev/null 2>&1
}

gitleaks_active() {
  local pref
  pref="$(_gitleaks_pref)"
  [[ "$pref" == "false" ]] && return 1
  gitleaks_available
}

gitleaks_hint_if_missing() {
  local pref
  pref="$(_gitleaks_pref)"
  if [[ "$pref" == "true" ]] && ! gitleaks_available; then
    echo "[ACP] gitleaks is enabled but not installed — install gitleaks or set integrations.gitleaks.enabled to auto/false." >&2
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    available) if gitleaks_available; then echo "available"; else echo "unavailable"; exit 1; fi ;;
    active)    if gitleaks_active;    then echo "active";    else echo "inactive";    exit 1; fi ;;
    hint)      gitleaks_hint_if_missing ;;
    *)
      echo "Usage: $0 {available|active|hint}" >&2
      exit 2
      ;;
  esac
fi
