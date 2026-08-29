#!/usr/bin/env bash
# acp.coderabbit.sh — optional CodeRabbit detection helpers (M78, ADR-21)
#
# Detection ONLY. This script never parses CodeRabbit output — that is the
# GATED integration surface (ADR-19). It answers one question: "does this repo
# look CodeRabbit-configured, and has the user opted in?"
#
# Layering (audit-098 F-098-01): this script sources acp.preferences.sh, which
# in turn sources acp.common.sh. NEVER the reverse — acp.common.sh must not
# depend on preferences (preferences.sh already sources it → circular source).
#
# This is a sourced function library: it deliberately does NOT set `set -euo
# pipefail`, which would leak into the caller's shell. Callers own their shell
# options. See:
#   - agent/wiki/coderabbit-integration.md (user guide)
#   - agent/scripts/acp.branch-protection-setup.sh:27 (the command -v exemplar)

_ACP_CODERABBIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.preferences.sh
source "${_ACP_CODERABBIT_DIR}/acp.preferences.sh"

# _coderabbit_repo_root — the git repo root, or "." outside a git repo.
# Both preference resolution (get_preference reads ./agent/preferences relative
# to CWD) and config-file detection are anchored here so the helpers work from
# any subdirectory (audit-099 F-099-05).
_coderabbit_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || echo "."
}

# _coderabbit_enabled / config_path resolution are memoised for the life of
# the process — matches the _ACP_GITLEAKS_PREF_CACHE pattern (acp.gitleaks.sh,
# audit-110). coderabbit_active() can't use gitleaks' availability-first
# reordering (it must read the preference to know whether the user opted in
# before it can check availability), so this plus the M85 fast resolver is
# the fix for A-110-04 (was 21.5s single-sample / actually 1439ms per
# audit-113 F2-03; Phase 1 alone already brought it to 646ms).
#
# Per-process only, by design (M85 task-302 step 6): a `yaml_set` that writes
# a preference file happens in a DIFFERENT process (acp.preferences.sh set is
# always invoked as its own script run, never sourced mid-process alongside a
# long-lived reader), so there is no path where this cache observes a stale
# value after a write within the same process lifetime.
_ACP_CODERABBIT_ENABLED_CACHE=""
_ACP_CODERABBIT_CONFIG_PATH_CACHE=""

# _coderabbit_enabled — resolve the opt-in preference from the repo root.
# Exact-string compare (F-098-03): a `false` default resolves as the non-empty
# string "false", so a presence/has_preference check would misread it as "set".
_coderabbit_enabled() {
  if [[ -n "$_ACP_CODERABBIT_ENABLED_CACHE" ]]; then
    echo "$_ACP_CODERABBIT_ENABLED_CACHE"
    return 0
  fi
  local root
  root="$(_coderabbit_repo_root)"
  _ACP_CODERABBIT_ENABLED_CACHE="$( ( cd "$root" 2>/dev/null && get_preference "acp" "integrations.coderabbit.enabled" 2>/dev/null ) || echo false )"
  echo "$_ACP_CODERABBIT_ENABLED_CACHE"
}

# coderabbit_available — Gate 2 (feature detection).
# Returns 0 if the repo is CodeRabbit-configured (config file present), 1 otherwise.
# Preference resolution and the file check are anchored to the repo root, so
# detection works from any subdirectory (F-099-05). Absolute config_path is used
# as-is. Config-file detection only (F-098-04): the CodeRabbit CLI name is not
# assumed until verified during real adoption. No output; no findings parsing.
# Absence is normal — not an error.
coderabbit_available() {
  local config_path root target
  root="$(_coderabbit_repo_root)"
  if [[ -n "$_ACP_CODERABBIT_CONFIG_PATH_CACHE" ]]; then
    config_path="$_ACP_CODERABBIT_CONFIG_PATH_CACHE"
  else
    config_path="$( ( cd "$root" 2>/dev/null && get_preference_or "acp" "integrations.coderabbit.config_path" ".coderabbit.yaml" ) )"
    [[ -n "$config_path" ]] || config_path=".coderabbit.yaml"
    _ACP_CODERABBIT_CONFIG_PATH_CACHE="$config_path"
  fi
  if [[ "$config_path" == /* ]]; then
    target="$config_path"
  else
    target="${root}/${config_path}"
  fi
  [[ -f "$target" ]]
}

# coderabbit_active — Gate 1 (opt-in) AND Gate 2 (available).
# Returns 0 (usable) only when the preference is enabled AND a config is detected.
coderabbit_active() {
  [[ "$(_coderabbit_enabled)" == "true" ]] && coderabbit_available
}

# coderabbit_hint_if_missing — Gate 3 (graceful degradation).
# When the user has opted in but no config is detected, emit ONE non-fatal
# stderr hint. Silent in every other state (disabled, or enabled+available).
coderabbit_hint_if_missing() {
  if [[ "$(_coderabbit_enabled)" == "true" ]] && ! coderabbit_available; then
    echo "[ACP] CodeRabbit is enabled but no config was detected — copy agent/templates/coderabbit.yaml.template to .coderabbit.yaml (or set integrations.coderabbit.config_path), or set integrations.coderabbit.enabled false." >&2
  fi
}

# Direct-execution CLI (not run when sourced) — for quick checks and E2E.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    available) if coderabbit_available; then echo "available"; else echo "unavailable"; exit 1; fi ;;
    active)    if coderabbit_active;    then echo "active";    else echo "inactive";    exit 1; fi ;;
    hint)      coderabbit_hint_if_missing ;;
    *) echo "Usage: $0 {available|active|hint}" >&2; exit 2 ;;
  esac
fi
