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

# Resolving a preference costs ~1.5s (pure-bash YAML walk over the preference
# layers), so the result is memoised for the life of the process. Every scanner
# invocation previously paid it at least once (audit-110).
_ACP_GITLEAKS_PREF_CACHE=""
_gitleaks_pref() {
  if [[ -n "$_ACP_GITLEAKS_PREF_CACHE" ]]; then
    echo "$_ACP_GITLEAKS_PREF_CACHE"
    return 0
  fi
  local root
  root="$(_gitleaks_repo_root)"
  _ACP_GITLEAKS_PREF_CACHE="$( ( cd "$root" 2>/dev/null && get_preference_or "acp" "integrations.gitleaks.enabled" "auto" ) || echo "auto" )"
  echo "$_ACP_GITLEAKS_PREF_CACHE"
}

gitleaks_available() {
  command -v gitleaks >/dev/null 2>&1
}

gitleaks_active() {
  # Availability is a `command -v`; the preference is a ~1.5s YAML walk. When the
  # tool is absent the answer is "inactive" for every possible preference value,
  # so checking availability first is semantically identical and skips the cost
  # entirely on machines without gitleaks — which is the common case, and was
  # costing ~1.5s on every scanner invocation (audit-110).
  gitleaks_available || return 1
  local pref
  pref="$(_gitleaks_pref)"
  [[ "$pref" == "false" ]] && return 1
  return 0
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
