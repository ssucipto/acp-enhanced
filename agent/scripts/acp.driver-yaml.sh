#!/bin/bash
# acp.driver-yaml.sh — Pluggable Driver System helpers
# Reads and queries agent/driver.yaml to determine how ACP routes tool invocations.
#
# Usage: source agent/scripts/acp.driver-yaml.sh
#
# All functions are POSIX-portable and macOS bash 3.2+ compatible.
# No external deps. No declare -A, mapfile, or bash 4+ features.
#
# Driver config is read from ${DRIVER_YAML:-agent/driver.yaml}.
# Override DRIVER_YAML in tests to point to a fixture file.
#
# See: agent/schemas/driver.schema.yaml (validation schema)
# See: agent/driver.template.yaml (starter config)
# See: agent/patterns/local.driver-dispatch-directive.md

# Prevent duplicate sourcing
if [ -n "${ACP_DRIVER_YAML_LOADED:-}" ]; then
    return 0
fi
ACP_DRIVER_YAML_LOADED=1

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# _driver_file — resolves the path to driver.yaml (or override via env)
_driver_file() {
    echo "${DRIVER_YAML:-agent/driver.yaml}"
}

# _driver_exists — returns 0 if driver.yaml is present, 1 otherwise
_driver_exists() {
    [ -f "$(_driver_file)" ]
}

# _driver_tool_block <tool>
# Extracts the indented YAML block for a specific tool from driver.yaml.
# Returns the lines under "  <tool>:" (2-space indent), stops at the next tool.
_driver_tool_block() {
    local tool="$1"
    local file
    file="$(_driver_file)"
    _driver_exists || return 1

    # Match "  <tool>:" then collect indented sub-lines (4+ spaces or deeper)
    awk -v tool="$tool" '
        /^  [a-zA-Z0-9_-]+:/ {
            if (in_block) { exit }
            if ($0 ~ "^  " tool ":") { in_block=1; next }
        }
        in_block && /^    / { print; next }
        in_block && /^  [a-zA-Z0-9_-]+:/ { exit }
    ' "$file"
}

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

# driver_get <tool> [field]
# Returns driver config for a tool. If field specified, returns only that field value.
# Returns empty string if driver.yaml doesn't exist or tool not configured.
driver_get() {
    local tool="$1"
    local field="${2:-}"
    _driver_exists || return 0

    if [ -n "$field" ]; then
        driver_query "$tool" "$field"
    else
        _driver_tool_block "$tool"
    fi
}

# driver_list
# Lists all configured tool names, one per line.
driver_list() {
    _driver_exists || return 0
    grep -E '^  [a-zA-Z0-9_-]+:' "$(_driver_file)" | sed 's/^  //' | sed 's/:.*//'
}

# driver_query <tool> <field>
# Returns the value of a specific field for a tool driver.
# Returns empty string if not found.
driver_query() {
    local tool="$1"
    local field="$2"
    _driver_tool_block "$tool" | grep "^    ${field}:" | head -1 | sed "s/^    ${field}:[[:space:]]*//" | sed 's/[[:space:]]*#.*//' | sed "s/^['\"]//;s/['\"]$//"
}

# driver_type <tool>
# Returns driver type (native|mcp|http|custom) for a tool.
# Returns 'native' if driver.yaml absent or tool not configured.
driver_type() {
    local tool="$1"
    local dtype
    _driver_exists || { echo "native"; return 0; }
    dtype="$(driver_query "$tool" "type")"
    if [ -z "$dtype" ]; then
        echo "native"
    else
        echo "$dtype"
    fi
}

# driver_is_native <tool>
# Returns 0 (success/true) if tool uses native driver or driver.yaml doesn't exist.
# Returns 1 if tool uses a non-native driver.
driver_is_native() {
    local tool="$1"
    local dtype
    dtype="$(driver_type "$tool")"
    [ "$dtype" = "native" ]
}

# driver_override <tool> <field> <value>
# Writes a field override to driver.yaml.
# Adds the field under the tool block if it doesn't exist; updates it if it does.
# Creates the drivers: map and tool block if missing.
# POSIX-safe write (BSD sed compatible via temp file approach).
driver_override() {
    local tool="$1"
    local field="$2"
    local value="$3"
    local file
    file="$(_driver_file)"

    # Create driver.yaml if absent
    if [ ! -f "$file" ]; then
        printf '---\ndrivers:\n  %s:\n    %s: %s\n' "$tool" "$field" "$value" > "$file"
        return 0
    fi

    # Check if the tool block exists
    if ! grep -q "^  ${tool}:" "$file"; then
        # Append tool block under drivers:
        printf '  %s:\n    %s: %s\n' "$tool" "$field" "$value" >> "$file"
        return 0
    fi

    # Check if field already exists under the tool
    local block_line
    block_line=$(grep -n "^    ${field}:" "$file" | head -1 | cut -d: -f1)
    if [ -n "$block_line" ]; then
        # Replace the field in-place using temp file (BSD-safe)
        local tmpfile
        tmpfile=$(mktemp)
        awk -v line="$block_line" -v field="$field" -v val="$value" '
            NR == line { printf "    %s: %s\n", field, val; next }
            { print }
        ' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
    else
        # Insert field after the tool: line using temp file
        local tmpfile2
        tmpfile2=$(mktemp)
        awk -v tool="$tool" -v field="$field" -v val="$value" '
            /^  / && $0 ~ "^  " tool ":" {
                print
                printf "    %s: %s\n", field, val
                next
            }
            { print }
        ' "$file" > "$tmpfile2" && mv "$tmpfile2" "$file"
    fi
}

# driver_validate
# Validates driver.yaml structure: checks required fields exist.
# Prints an error message to stderr and returns 1 if invalid.
# Returns 0 if valid or if driver.yaml is absent (absent = native defaults, always valid).
driver_validate() {
    _driver_exists || return 0
    local file
    file="$(_driver_file)"

    # Must have drivers: key
    if ! grep -q "^drivers:" "$file"; then
        echo "driver_validate: missing required 'drivers:' key in $(basename "$file")" >&2
        return 1
    fi

    # Each tool block must have a type: field
    local errors=0 tool dtype
    while IFS= read -r tool; do
        dtype="$(driver_query "$tool" "type")"
        if [ -z "$dtype" ]; then
            echo "driver_validate: tool '${tool}' is missing required 'type:' field" >&2
            errors=$((errors + 1))
        else
            case "$dtype" in
                native|mcp|http|custom) ;;
                *)
                    echo "driver_validate: tool '${tool}' has invalid type '${dtype}' (must be: native, mcp, http, custom)" >&2
                    errors=$((errors + 1))
                    ;;
            esac
        fi
        # mcp requires server + method
        if [ "$dtype" = "mcp" ]; then
            [ -z "$(driver_query "$tool" "server")" ] && {
                echo "driver_validate: tool '${tool}' type=mcp requires 'server:' field" >&2
                errors=$((errors + 1))
            }
            [ -z "$(driver_query "$tool" "method")" ] && {
                echo "driver_validate: tool '${tool}' type=mcp requires 'method:' field" >&2
                errors=$((errors + 1))
            }
        fi
        # http requires url
        if [ "$dtype" = "http" ]; then
            [ -z "$(driver_query "$tool" "url")" ] && {
                echo "driver_validate: tool '${tool}' type=http requires 'url:' field" >&2
                errors=$((errors + 1))
            }
        fi
        # custom requires command
        if [ "$dtype" = "custom" ]; then
            [ -z "$(driver_query "$tool" "command")" ] && {
                echo "driver_validate: tool '${tool}' type=custom requires 'command:' field" >&2
                errors=$((errors + 1))
            }
        fi
    done <<EOF
$(driver_list)
EOF

    [ "$errors" -eq 0 ] && return 0 || return 1
}

# driver_status
# Prints a human-readable summary of configured drivers.
driver_status() {
    if ! _driver_exists; then
        echo "Driver config: absent (all tools use native defaults)"
        return 0
    fi
    echo "Driver config: $(_driver_file)"
    echo ""
    local count=0 tool dtype server method url cmd
    while IFS= read -r tool; do
        dtype="$(driver_type "$tool")"
        case "$dtype" in
            native)
                printf "  %-16s  native\n" "$tool"
                ;;
            mcp)
                server="$(driver_query "$tool" "server")"
                method="$(driver_query "$tool" "method")"
                printf "  %-16s  mcp → %s::%s\n" "$tool" "$server" "$method"
                ;;
            http)
                url="$(driver_query "$tool" "url")"
                printf "  %-16s  http → %s\n" "$tool" "$url"
                ;;
            custom)
                cmd="$(driver_query "$tool" "command")"
                printf "  %-16s  custom → %s\n" "$tool" "$cmd"
                ;;
            *)
                printf "  %-16s  %s\n" "$tool" "$dtype"
                ;;
        esac
        count=$((count + 1))
    done <<EOF
$(driver_list)
EOF
    echo ""
    echo "  $count driver(s) configured"
}
