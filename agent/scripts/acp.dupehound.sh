#!/usr/bin/env bash
# acp.dupehound.sh — optional dupehound helpers + assisted install (M83, ADR-23)
#
# Variant B (detection-as-consent): explicit false disables; auto/true allow
# activation when the local binary is present. This is a sourced helper library
# and intentionally does NOT enable strict shell options in callers.

_ACP_DUPEHOUND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.preferences.sh
source "${_ACP_DUPEHOUND_DIR}/acp.preferences.sh"

_dupehound_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || echo "."
}

_dupehound_pref() {
  local root
  root="$(_dupehound_repo_root)"
  ( cd "$root" 2>/dev/null && get_preference_or "acp" "integrations.dupehound.enabled" "auto" ) || echo "auto"
}

_dupehound_prompt_version() {
  local root
  root="$(_dupehound_repo_root)"
  ( cd "$root" 2>/dev/null && get_preference_or "acp" "integrations.dupehound.install_prompt_version" "" ) || echo ""
}

_dupehound_acp_version() {
  local root package_file version
  root="$(_dupehound_repo_root)"
  package_file="${root}/package.yaml"
  if [[ ! -f "$package_file" ]]; then
    echo ""
    return 0
  fi
  version="$(awk '/^version:/ { print $2; exit }' "$package_file" 2>/dev/null || true)"
  echo "${version}"
}

dupehound_available() {
  command -v dupehound >/dev/null 2>&1
}

dupehound_active() {
  local pref
  pref="$(_dupehound_pref)"
  [[ "$pref" == "false" ]] && return 1
  dupehound_available
}

dupehound_hint_if_missing() {
  local pref
  pref="$(_dupehound_pref)"
  if [[ "$pref" == "true" ]] && ! dupehound_available; then
    echo "[ACP] dupehound is enabled but not installed — run acp.dupehound.sh install or set integrations.dupehound.enabled to auto/false." >&2
  fi
}

_dupehound_default_branch() {
  local root branch
  root="$(_dupehound_repo_root)"
  branch="$(yaml_get "${root}/agent/core/identity.yml" "git_workflow.default_working_branch" 2>/dev/null || true)"
  echo "${branch:-develop}"
}

dupehound_diff_base() {
  local root default_branch upstream
  if [[ -n "${ACP_DUPEHOUND_DIFF_BASE:-}" ]]; then
    echo "${ACP_DUPEHOUND_DIFF_BASE}"
    return 0
  fi
  root="$(_dupehound_repo_root)"
  default_branch="$(_dupehound_default_branch)"
  upstream="$(git -C "$root" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
  if [[ -n "$upstream" ]]; then
    echo "$upstream"
    return 0
  fi
  if git -C "$root" show-ref --verify --quiet "refs/remotes/origin/${default_branch}"; then
    echo "origin/${default_branch}"
    return 0
  fi
  if git -C "$root" show-ref --verify --quiet "refs/heads/${default_branch}"; then
    echo "${default_branch}"
    return 0
  fi
  if git -C "$root" rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    echo "HEAD~1"
    return 0
  fi
  return 1
}

dupehound_write_json() {
  local report_path="$1"
  local root base rc=0
  root="$(_dupehound_repo_root)"
  if [[ -z "$report_path" ]]; then
    echo "[ACP] dupehound_write_json requires a report path." >&2
    return 2
  fi
  if ! dupehound_available; then
    return 1
  fi
  if base="$(dupehound_diff_base 2>/dev/null)"; then
    ( cd "$root" && dupehound check --diff "$base" . --json > "$report_path" ) || rc=$?
  else
    ( cd "$root" && dupehound check . --json > "$report_path" ) || rc=$?
  fi
  case "$rc" in
    0|1) return 0 ;;
    *) return "$rc" ;;
  esac
}

dupehound_should_prompt_install() {
  local pref current stamped
  pref="$(_dupehound_pref)"
  [[ "$pref" == "false" ]] && return 1
  dupehound_available && return 1
  current="$(_dupehound_acp_version)"
  [[ -z "$current" ]] && return 1
  stamped="$(_dupehound_prompt_version)"
  [[ "$stamped" != "$current" ]]
}

dupehound_mark_prompt_version() {
  local version root
  version="${1:-$(_dupehound_acp_version)}"
  [[ -z "$version" ]] && return 0
  root="$(_dupehound_repo_root)"
  ( cd "$root" && set_preference "acp" "integrations.dupehound.install_prompt_version" "$version" project )
}

dupehound_install() {
  local yes="${1:-false}"
  local root prompt_version install_kind release_url response=""
  root="$(_dupehound_repo_root)"
  prompt_version="$(_dupehound_acp_version)"
  release_url="https://github.com/Rafaelpta/dupehound/releases"
  install_kind=""

  if dupehound_available; then
    echo "[ACP] dupehound is already installed." >&2
    [[ -n "$prompt_version" ]] && dupehound_mark_prompt_version "$prompt_version"
    return 0
  fi

  if command -v brew >/dev/null 2>&1; then
    install_kind="brew"
  elif command -v cargo >/dev/null 2>&1; then
    install_kind="cargo"
  fi

  if [[ -z "$install_kind" ]]; then
    echo "[ACP] No supported installer detected for dupehound." >&2
    echo "[ACP] See releases: ${release_url}" >&2
    return 0
  fi

  echo "[ACP] dupehound is optional and still early-stage (v0.1.2, ~153 downloads)." >&2
  case "$install_kind" in
    brew)  echo "[ACP] Proposed install command: brew install rafaelpta/dupehound/dupehound" >&2 ;;
    cargo) echo "[ACP] Proposed install command: cargo install dupehound" >&2 ;;
  esac

  if [[ "$yes" != "true" ]]; then
    if [[ ! -t 0 || ! -t 1 || "${CI:-}" == "true" ]]; then
      echo "[ACP] Non-interactive context detected; re-run with --yes to install dupehound." >&2
      return 0
    fi
    read -r -p "Proceed? (y/N) " response
    echo "" >&2
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      [[ -n "$prompt_version" ]] && dupehound_mark_prompt_version "$prompt_version"
      echo "[ACP] dupehound install declined." >&2
      return 0
    fi
  fi

  if ! (
    cd "$root" && case "$install_kind" in
      brew) brew install rafaelpta/dupehound/dupehound ;;
      cargo) cargo install dupehound ;;
    esac
  ); then
    echo "[ACP] dupehound install command failed." >&2
    return 1
  fi
  if ! dupehound_available; then
    echo "[ACP] dupehound still not found on PATH after install." >&2
    return 1
  fi

  [[ -n "$prompt_version" ]] && dupehound_mark_prompt_version "$prompt_version"
  echo "[ACP] dupehound installed and detected on PATH." >&2
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    available) if dupehound_available; then echo "available"; else echo "unavailable"; exit 1; fi ;;
    active)    if dupehound_active;    then echo "active";    else echo "inactive";    exit 1; fi ;;
    hint)      dupehound_hint_if_missing ;;
    should-prompt) if dupehound_should_prompt_install; then echo "prompt"; else echo "skip"; exit 1; fi ;;
    mark-prompt) dupehound_mark_prompt_version "${2:-}" ;;
    install)
      shift
      if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
        dupehound_install "true"
      else
        dupehound_install "false"
      fi
      ;;
    *)
      echo "Usage: $0 {available|active|hint|should-prompt|mark-prompt [version]|install [--yes]}" >&2
      exit 2
      ;;
  esac
fi
