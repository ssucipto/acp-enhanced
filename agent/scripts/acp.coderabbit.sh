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
#   - agent/patterns/local.optional-external-tool.md (the 3-gate contract)
#   - agent/wiki/coderabbit-integration.md (user guide)
#   - agent/scripts/acp.branch-protection-setup.sh:27 (the command -v exemplar)

_ACP_CODERABBIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.preferences.sh
source "${_ACP_CODERABBIT_DIR}/acp.preferences.sh"

# coderabbit_available — Gate 2 (feature detection).
# Returns 0 if the repo is CodeRabbit-configured (config file present at CWD),
# 1 otherwise. Config-file detection only (F-098-04): the CodeRabbit CLI name
# is not assumed until verified during real adoption. No output; no findings
# parsing. Absence is normal — this is not an error.
coderabbit_available() {
  local config_path
  config_path="$(get_preference_or "acp" "integrations.coderabbit.config_path" ".coderabbit.yaml")"
  [[ -f "$config_path" ]]
}

# coderabbit_active — Gate 1 (opt-in) AND Gate 2 (available).
# Returns 0 (usable) only when the preference is enabled AND a config is
# detected. Callers guard CodeRabbit-specific branches with this.
# Exact-string compare (F-098-03): a `false` default resolves as the non-empty
# string "false", so a presence/has_preference check would misread it as "set".
coderabbit_active() {
  local enabled
  enabled="$(get_preference "acp" "integrations.coderabbit.enabled" 2>/dev/null || echo false)"
  [[ "$enabled" == "true" ]] && coderabbit_available
}

# coderabbit_hint_if_missing — Gate 3 (graceful degradation).
# When the user has opted in but no config is detected, emit ONE non-fatal
# stderr hint. Silent in every other state (disabled, or enabled+available).
coderabbit_hint_if_missing() {
  local enabled
  enabled="$(get_preference "acp" "integrations.coderabbit.enabled" 2>/dev/null || echo false)"
  if [[ "$enabled" == "true" ]] && ! coderabbit_available; then
    echo "[ACP] CodeRabbit is enabled but no config was detected — add a .coderabbit.yaml or set integrations.coderabbit.enabled false." >&2
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
