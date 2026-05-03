#!/usr/bin/env bash
# ACP Preferences System — Unified Utilities
# All preference operations: get, set, validate, generate, presets
# Can be invoked directly or sourced for functions
#
# Usage (direct):
#   ./acp.preferences.sh get <namespace> <preference.path>
#   ./acp.preferences.sh generate <namespace> [yaml|json]
#   ./acp.preferences.sh source <namespace> <preference.path>
#
# Usage (sourced):
#   source ./acp.preferences.sh
#   get_preference "acp" "plan.draft.create_mode"

# Only apply strict mode when run directly (not when sourced by tests or other scripts).
# set -euo pipefail + ERR trap must not bleed into the parent shell on source.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  trap 'echo "ERROR: $(basename "$0") failed at line $LINENO -- check output above for details." >&2; exit 1' ERR
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies — only when not already loaded
if ! declare -f yaml_query > /dev/null 2>&1; then
  # shellcheck source=acp.yaml-parser.sh
  source "${SCRIPT_DIR}/acp.yaml-parser.sh"
fi

if ! declare -f log_info > /dev/null 2>&1; then
  # shellcheck source=acp.common.sh
  source "${SCRIPT_DIR}/acp.common.sh"
fi

# ── Preference file resolution ────────────────────────────────────────────────

# Resolve project-level preference file path
# Usage: _pref_project_file <namespace>
_pref_project_file() {
  echo "./agent/preferences/${1}.default.yaml"
}

# Resolve workspace-level preference file path
# Usage: _pref_workspace_file <namespace>
_pref_workspace_file() {
  echo ".vscode/preferences/${1}.yaml"
}

# Resolve user-level preference file path
# Usage: _pref_user_file <namespace>
_pref_user_file() {
  echo "${HOME}/.acp/agent/preferences/${1}.default.yaml"
}

# Resolve configurables file path (source of defaults)
# Usage: _pref_configurables_file <namespace>
_pref_configurables_file() {
  echo "./agent/configurables/${1}.configurables.yaml"
}

# Flat-dot format fallback: reads "  pref.path.key: value" style entries
# used by preference files written before nested YAML was adopted (and by
# set_preference, which writes flat-dot format for simplicity).
# Allows both flat-dot and nested YAML preference files to work interchangeably.
# Usage: _flat_dot_get <file> <pref_path>
_flat_dot_get() {
  local file="$1" pref_path="$2"
  local escaped_path="${pref_path//./\\.}"
  grep -E "^[[:space:]]+${escaped_path}:" "$file" 2>/dev/null \
    | head -1 \
    | sed 's/^[^:]*:[[:space:]]*//' \
    | tr -d "'\"" \
    | tr -d '[:space:]'
}

# ── Core functions ────────────────────────────────────────────────────────────

# Get preference value with precedence resolution:
#   Project > Workspace > User > Configurables default
# Usage: get_preference <namespace> <preference.path>
# Returns: preference value or empty string if not set anywhere
# Exit codes: 0 = found, 1 = not found at any level
get_preference() {
  local namespace="$1"
  local pref_path="$2"
  local value=""

  # Project (highest precedence)
  local project_file
  project_file="$(_pref_project_file "$namespace")"
  if [[ -f "$project_file" ]]; then
    value="$(yaml_get "$project_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
    [[ -z "$value" ]] && value="$(_flat_dot_get "$project_file" "$pref_path")"
    if [[ -n "$value" ]]; then
      echo "$value"
      return 0
    fi
  fi

  # Workspace
  local workspace_file
  workspace_file="$(_pref_workspace_file "$namespace")"
  if [[ -f "$workspace_file" ]]; then
    value="$(yaml_get "$workspace_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
    [[ -z "$value" ]] && value="$(_flat_dot_get "$workspace_file" "$pref_path")"
    if [[ -n "$value" ]]; then
      echo "$value"
      return 0
    fi
  fi

  # User (lowest explicit level)
  local user_file
  user_file="$(_pref_user_file "$namespace")"
  if [[ -f "$user_file" ]]; then
    value="$(yaml_get "$user_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
    [[ -z "$value" ]] && value="$(_flat_dot_get "$user_file" "$pref_path")"
    if [[ -n "$value" ]]; then
      echo "$value"
      return 0
    fi
  fi

  # Configurables default (fallback)
  local configurables_file
  configurables_file="$(_pref_configurables_file "$namespace")"
  if [[ -f "$configurables_file" ]]; then
    value="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.default" 2>/dev/null || true)"
    if [[ -n "$value" ]]; then
      echo "$value"
      return 0
    fi
  fi

  # Not found at any level
  return 1
}

# Check if a preference is set at any level (returns true if any non-empty value found)
# Usage: has_preference <namespace> <preference.path>
# Exit codes: 0 = exists, 1 = not found
has_preference() {
  local namespace="$1"
  local pref_path="$2"
  local value
  value="$(get_preference "$namespace" "$pref_path" 2>/dev/null || true)"
  [[ -n "$value" ]]
}

# Get preference value with an explicit fallback if not found anywhere
# Usage: get_preference_or <namespace> <preference.path> <fallback>
# Returns: resolved value, or fallback if not found
get_preference_or() {
  local namespace="$1"
  local pref_path="$2"
  local fallback="$3"
  local value
  value="$(get_preference "$namespace" "$pref_path" 2>/dev/null || true)"
  echo "${value:-$fallback}"
}

# Report which level provided the preference value
# Usage: get_preference_source <namespace> <preference.path>
# Returns: "project" | "workspace" | "user" | "default" | "none"
get_preference_source() {
  local namespace="$1"
  local pref_path="$2"
  local value=""

  local project_file
  project_file="$(_pref_project_file "$namespace")"
  if [[ -f "$project_file" ]]; then
    value="$(yaml_get "$project_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
    [[ -z "$value" ]] && value="$(_flat_dot_get "$project_file" "$pref_path")"
    [[ -n "$value" ]] && echo "project" && return 0
  fi

  local workspace_file
  workspace_file="$(_pref_workspace_file "$namespace")"
  if [[ -f "$workspace_file" ]]; then
    value="$(yaml_get "$workspace_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
    [[ -z "$value" ]] && value="$(_flat_dot_get "$workspace_file" "$pref_path")"
    [[ -n "$value" ]] && echo "workspace" && return 0
  fi

  local user_file
  user_file="$(_pref_user_file "$namespace")"
  if [[ -f "$user_file" ]]; then
    value="$(yaml_get "$user_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
    [[ -z "$value" ]] && value="$(_flat_dot_get "$user_file" "$pref_path")"
    [[ -n "$value" ]] && echo "user" && return 0
  fi

  local configurables_file
  configurables_file="$(_pref_configurables_file "$namespace")"
  if [[ -f "$configurables_file" ]]; then
    value="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.default" 2>/dev/null || true)"
    [[ -n "$value" ]] && echo "default" && return 0
  fi

  echo "none"
  return 0
}

# ── Generate output ───────────────────────────────────────────────────────────

# Generate complete, precedence-resolved preference set for a namespace
# Reads configurables as the authoritative list of known preference paths,
# resolves each one, and emits all in the requested format.
# Usage: generate_preferences <namespace> [yaml|json]
generate_preferences() {
  local namespace="$1"
  local format="${2:-yaml}"

  local configurables_file
  configurables_file="$(_pref_configurables_file "$namespace")"

  if [[ ! -f "$configurables_file" ]]; then
    echo "Error: Configurables not found: $configurables_file" >&2
    return 1
  fi

  # Collect all preference paths from configurables using _index array
  local count
  count="$(yaml_get_array "$configurables_file" "${namespace}._index" 2>/dev/null || echo 0)"

  if [[ "$count" -eq 0 ]]; then
    # No _index array — emit empty namespace block
    if [[ "$format" == "yaml" ]]; then
      echo "${namespace}: {}"
    else
      echo "{\"${namespace}\": {}}"
    fi
    return 0
  fi

  # Build output
  if [[ "$format" == "yaml" ]]; then
    echo "${namespace}:"
    local i=0
    while [[ "$i" -lt "$count" ]]; do
      local pref_id
      pref_id="$(yaml_get "$configurables_file" "${namespace}._index[${i}]" 2>/dev/null || true)"
      [[ -z "$pref_id" ]] && { i=$((i + 1)); continue; }
      local val
      val="$(get_preference "$namespace" "$pref_id" 2>/dev/null || echo "")"
      echo "  ${pref_id}: '${val}'"
      i=$((i + 1))
    done
  elif [[ "$format" == "json" ]]; then
    echo "{"
    echo "  \"${namespace}\": {"
    local first=true i=0
    while [[ "$i" -lt "$count" ]]; do
      local pref_id
      pref_id="$(yaml_get "$configurables_file" "${namespace}._index[${i}]" 2>/dev/null || true)"
      [[ -z "$pref_id" ]] && { i=$((i + 1)); continue; }
      local val
      val="$(get_preference "$namespace" "$pref_id" 2>/dev/null || echo "")"
      [[ "$first" == "true" ]] && first=false || echo ","
      printf '    "%s": "%s"' "$pref_id" "$val"
      i=$((i + 1))
    done
    echo ""
    echo "  }"
    echo "}"
  else
    echo "Error: Unknown format '${format}'. Use 'yaml' or 'json'." >&2
    return 1
  fi
}

# ── Management functions ──────────────────────────────────────────────────────

# Set a preference value at the specified level
# Usage: set_preference <namespace> <preference.path> <value> <level>
# Level: project | workspace | user (default: project)
# Returns: 0 on success, 1 on failure
set_preference() {
  local namespace="$1"
  local pref_path="$2"
  local value="$3"
  local level="${4:-project}"

  # Resolve target file
  local target_file
  case "$level" in
    project)
      target_file="$(_pref_project_file "$namespace")"
      ;;
    workspace)
      target_file="$(_pref_workspace_file "$namespace")"
      ;;
    user|global)
      target_file="$(_pref_user_file "$namespace")"
      ;;
    *)
      echo "Error: Invalid level '${level}'. Use: project, workspace, or user" >&2
      return 1
      ;;
  esac

  # Create file and parent directory if they don't exist
  if [[ ! -f "$target_file" ]]; then
    local target_dir
    target_dir="$(dirname "$target_file")"
    mkdir -p "$target_dir"
    printf '%s:\n' "$namespace" > "$target_file"
  fi

  # Load the file into the AST, update the nested path, and write back.
  # yaml_set creates any missing intermediate map nodes automatically.
  # This writes proper nested YAML (readable by yaml_get without flat-dot fallback).
  yaml_parse "$target_file" || {
    echo "Error: Failed to parse preference file: ${target_file}" >&2
    return 1
  }
  yaml_set ".${namespace}.${pref_path}" "$value" || {
    echo "Error: Failed to set preference path: ${namespace}.${pref_path}" >&2
    return 1
  }
  yaml_write "$target_file"
}

# Validate a preference value against the configurables schema
# Usage: validate_preference <namespace> <preference.path> <value>
# Returns: 0 if valid, 1 if invalid (error written to stderr)
validate_preference() {
  local namespace="$1"
  local pref_path="$2"
  local value="$3"

  local configurables_file
  configurables_file="$(_pref_configurables_file "$namespace")"

  if [[ ! -f "$configurables_file" ]]; then
    echo "Error: Configurables not found: ${configurables_file}" >&2
    return 1
  fi

  # Check that the preference exists in configurables
  local pref_type
  pref_type="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.type" 2>/dev/null || true)"
  if [[ -z "$pref_type" ]]; then
    echo "Error: Preference '${pref_path}' not found in namespace '${namespace}'" >&2
    return 1
  fi

  # Type-specific validation
  case "$pref_type" in
    string)
      # Check options if defined (iterate by index using yaml_get)
      local opt_count
      opt_count="$(yaml_get_array "$configurables_file" "${namespace}.${pref_path}.options" 2>/dev/null || echo 0)"
      if [[ "$opt_count" -gt 0 ]]; then
        local found=false
        local i=0
        while [[ "$i" -lt "$opt_count" ]]; do
          local opt_val
          opt_val="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.options[${i}].value" 2>/dev/null || true)"
          [[ "$opt_val" == "$value" ]] && found=true && break
          i=$((i + 1))
        done
        if [[ "$found" == "false" ]]; then
          echo "Error: Invalid value '${value}' for '${pref_path}' (type: string with options)" >&2
          return 1
        fi
      fi
      ;;
    number)
      # Must be numeric
      if ! [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Value '${value}' is not a number for '${pref_path}'" >&2
        return 1
      fi
      # Check min/max
      local min max
      min="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.min" 2>/dev/null || true)"
      max="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.max" 2>/dev/null || true)"
      # Use bash integer arithmetic — no bc dependency required
      if [[ -n "$min" ]] && (( value < min )); then
        echo "Error: Value ${value} is below minimum ${min} for '${pref_path}'" >&2
        return 1
      fi
      if [[ -n "$max" ]] && (( value > max )); then
        echo "Error: Value ${value} exceeds maximum ${max} for '${pref_path}'" >&2
        return 1
      fi
      ;;
    boolean)
      if [[ "$value" != "true" && "$value" != "false" ]]; then
        echo "Error: Value '${value}' is not a boolean for '${pref_path}' (use: true or false)" >&2
        return 1
      fi
      ;;
    *)
      # Unknown type — pass through without validation
      ;;
  esac

  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Preset helpers
# ─────────────────────────────────────────────────────────────────────────────

# Resolve preset file path: project → user
# Returns the path if found, empty string otherwise
_pref_preset_file() {
  local namespace="$1" preset_name="$2"
  local project_file="./agent/preferences/${namespace}.${preset_name}.yaml"
  local user_file="${HOME}/.acp/agent/preferences/${namespace}.${preset_name}.yaml"
  if [ -f "$project_file" ]; then
    echo "$project_file"
  elif [ -f "$user_file" ]; then
    echo "$user_file"
  fi
}

# Load a preference value from a preset (bypasses normal precedence).
# Usage: get_preference_with_preset <namespace> <preference.path> <preset_name>
# Returns: resolved value (preset → then falls back to get_preference)
get_preference_with_preset() {
  local namespace="$1" pref_path="$2" preset_name="${3:-}"
  if [ -n "$preset_name" ]; then
    local preset_file
    preset_file="$(_pref_preset_file "$namespace" "$preset_name")"
    if [ -f "$preset_file" ]; then
      local preset_val
      preset_val="$(yaml_get "$preset_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
      [ -z "$preset_val" ] && preset_val="$(_flat_dot_get "$preset_file" "$pref_path")"
      if [ -n "$preset_val" ]; then
        echo "$preset_val"
        return 0
      fi
    fi
  fi
  get_preference "$namespace" "$pref_path"
}

# Load a preset and export each value as PREF_<NAMESPACE>_<DOTPATH> env vars.
# Usage: load_preset <namespace> <preset_name>
# Returns: 0 if found and loaded, 1 if not found
load_preset() {
  local namespace="$1" preset_name="$2"
  local preset_file
  preset_file="$(_pref_preset_file "$namespace" "$preset_name")"
  if [ -z "$preset_file" ]; then
    echo "Error: Preset not found: ${namespace}.${preset_name}" >&2
    return 1
  fi
  echo "${preset_file}"
  return 0
}

# List available presets for a namespace.
# Prints preset names (without namespace prefix or .yaml suffix).
# Usage: list_presets <namespace>
list_presets() {
  local namespace="$1"
  local found=0

  local project_dir="./agent/preferences"
  if [ -d "$project_dir" ]; then
    while IFS= read -r -d '' f; do
      local base
      base="$(basename "$f" .yaml)"
      local preset="${base#${namespace}.}"
      # skip .default files (those are not named presets)
      [[ "$preset" == "default" ]] && continue
      [[ "$preset" == "$base" ]] && continue  # no namespace prefix
      echo "  📁 project: ${preset}"
      found=1
    done < <(find "$project_dir" -maxdepth 1 -name "${namespace}.*.yaml" -print0 2>/dev/null)
  fi

  local user_dir="${HOME}/.acp/agent/preferences"
  if [ -d "$user_dir" ]; then
    while IFS= read -r -d '' f; do
      local base
      base="$(basename "$f" .yaml)"
      local preset="${base#${namespace}.}"
      [[ "$preset" == "default" ]] && continue
      [[ "$preset" == "$base" ]] && continue
      echo "  👤 user:    ${preset}"
      found=1
    done < <(find "$user_dir" -maxdepth 1 -name "${namespace}.*.yaml" -print0 2>/dev/null)
  fi

  if [ "$found" -eq 0 ]; then
    echo "  (no presets found for namespace '${namespace}')"
  fi
}

# ── Direct execution entry point ──────────────────────────────────────────────

# Only runs when executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _pref_usage() {
    echo "Usage:"
    echo "  $0 get <namespace> <preference.path>                    Resolve single preference"
    echo "  $0 generate <namespace> [yaml|json]                     Generate full preference set"
    echo "  $0 source <namespace> <preference.path>                 Show which level set this value"
    echo "  $0 has <namespace> <preference.path>                    Exit 0 if preference exists"
    echo "  $0 set <namespace> <preference.path> <value> [level]    Set preference value"
    echo "  $0 validate <namespace> <preference.path> <value>       Validate value against schema"
    echo "  $0 load-preset <namespace> <preset-name>                Print preset file path (or error)"
    echo "  $0 list-presets <namespace>                             List available presets"
    echo ""
    echo "Examples:"
    echo "  $0 get acp plan.draft.create_mode"
    echo "  $0 generate acp yaml"
    echo "  $0 source acp plan.draft.create_mode"
    echo "  $0 set acp plan.draft.create_mode guided project"
    echo "  $0 validate acp plan.draft.create_mode guided"
    echo "  $0 load-preset acp batch-planning"
    echo "  $0 list-presets acp"
  }

  subcommand="${1:-}"

  case "$subcommand" in
    get)
      if [[ $# -lt 3 ]]; then
        echo "Error: 'get' requires <namespace> and <preference.path>" >&2
        _pref_usage >&2
        exit 1
      fi
      result="$(get_preference "$2" "$3" 2>/dev/null || true)"
      if [[ -n "$result" ]]; then
        echo "$result"
      else
        echo "Error: Preference '${3}' not found in namespace '${2}'" >&2
        exit 1
      fi
      ;;

    generate)
      if [[ $# -lt 2 ]]; then
        echo "Error: 'generate' requires <namespace>" >&2
        _pref_usage >&2
        exit 1
      fi
      generate_preferences "$2" "${3:-yaml}"
      ;;

    source)
      if [[ $# -lt 3 ]]; then
        echo "Error: 'source' requires <namespace> and <preference.path>" >&2
        _pref_usage >&2
        exit 1
      fi
      get_preference_source "$2" "$3"
      ;;

    has)
      if [[ $# -lt 3 ]]; then
        echo "Error: 'has' requires <namespace> and <preference.path>" >&2
        _pref_usage >&2
        exit 1
      fi
      if has_preference "$2" "$3"; then
        exit 0
      else
        exit 1
      fi
      ;;

    set)
      if [[ $# -lt 4 ]]; then
        echo "Error: 'set' requires <namespace> <preference.path> <value>" >&2
        _pref_usage >&2
        exit 1
      fi
      set_preference "$2" "$3" "$4" "${5:-project}"
      ;;

    validate)
      if [[ $# -lt 4 ]]; then
        echo "Error: 'validate' requires <namespace> <preference.path> <value>" >&2
        _pref_usage >&2
        exit 1
      fi
      if validate_preference "$2" "$3" "$4"; then
        echo "✅ Valid: ${3}=${4}"
      else
        exit 1
      fi
      ;;

    ""|help|--help|-h)
      _pref_usage
      ;;

    load-preset)
      if [[ $# -lt 3 ]]; then
        echo "Error: 'load-preset' requires <namespace> and <preset-name>" >&2
        _pref_usage >&2
        exit 1
      fi
      load_preset "$2" "$3"
      ;;

    list-presets)
      if [[ $# -lt 2 ]]; then
        echo "Error: 'list-presets' requires <namespace>" >&2
        _pref_usage >&2
        exit 1
      fi
      echo "Available presets for ${2}:"
      echo ""
      list_presets "$2"
      ;;

    *)
      echo "Error: Unknown subcommand '${subcommand}'" >&2
      _pref_usage >&2
      exit 1
      ;;
  esac
fi
