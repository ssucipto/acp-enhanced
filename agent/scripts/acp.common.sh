#!/bin/sh
# Common utilities for ACP scripts
# POSIX-compliant for maximum portability

# Initialize colors using tput (more reliable than ANSI codes)
init_colors() {
    if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
        BOLD=$(tput bold)
        NC=$(tput sgr0)
    else
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        BOLD=''
        NC=''
    fi
}

# Calculate file checksum (SHA-256)
# Usage: calculate_checksum "path/to/file"
# Returns: checksum string (without "sha256:" prefix)
calculate_checksum() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    sha256sum "$file" 2>/dev/null | cut -d' ' -f1
}

# Get current timestamp in ISO 8601 format (UTC)
# Usage: timestamp=$(get_timestamp)
# Returns: YYYY-MM-DDTHH:MM:SSZ
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Validate URL format
# Usage: if validate_url "$url"; then ...
# Returns: 0 if valid, 1 if invalid
validate_url() {
    local url="$1"
    case "$url" in
        http://*|https://*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get script directory (portable way)
# Usage: script_dir=$(get_script_dir)
get_script_dir() {
    # Get the directory of the calling script
    dirname "$0"
}

# Source YAML parser
# Usage: source_yaml_parser
source_yaml_parser() {
    local script_dir
    script_dir=$(get_script_dir)
    if [ -f "${script_dir}/acp.yaml.sh" ]; then
        . "${script_dir}/acp.yaml.sh"
    else
        echo "${RED}Error: acp.yaml.sh not found${NC}" >&2
        return 1
    fi
}

# Initialize manifest file if it doesn't exist
# Usage: init_manifest
init_manifest() {
    if [ ! -f "agent/manifest.yaml" ]; then
        cat > agent/manifest.yaml << 'EOF'
# ACP Package Manifest
# Tracks installed packages and their versions

packages: {}

manifest_version: 1.0.0
last_updated: null
EOF
        echo "${GREEN}✓${NC} Created agent/manifest.yaml"
    fi
}

# Validate manifest structure
# Usage: if validate_manifest; then ...
# Returns: 0 if valid, 1 if invalid
validate_manifest() {
    local manifest="agent/manifest.yaml"
    
    if [ ! -f "$manifest" ]; then
        echo "${RED}Error: Manifest not found${NC}" >&2
        return 1
    fi
    
    # Source YAML parser if not already loaded
    if ! command -v yaml_get >/dev/null 2>&1; then
        source_yaml_parser || return 1
    fi
    
    # Check required fields
    local manifest_version
    manifest_version=$(yaml_get "$manifest" "manifest_version" 2>/dev/null)
    
    if [ -z "$manifest_version" ] || [ "$manifest_version" = "null" ]; then
        echo "${RED}Error: manifest_version missing${NC}" >&2
        return 1
    fi
    
    echo "${GREEN}✓${NC} Manifest valid"
    return 0
}

# Update manifest last_updated timestamp
# Usage: update_manifest_timestamp
update_manifest_timestamp() {
    local manifest="agent/manifest.yaml"
    local timestamp
    timestamp=$(get_timestamp)
    
    # Source YAML parser if not already loaded
    if ! command -v yaml_set >/dev/null 2>&1; then
        source_yaml_parser || return 1
    fi
    
    yaml_set "$manifest" "last_updated" "$timestamp"
}

# Check if package exists in manifest
# Usage: if package_exists "package-name"; then ...
# Returns: 0 if exists, 1 if not
package_exists() {
    local package_name="$1"
    local manifest="agent/manifest.yaml"
    
    # Source YAML parser if not already loaded
    if ! command -v yaml_has_key >/dev/null 2>&1; then
        source_yaml_parser || return 1
    fi
    
    yaml_has_key "$manifest" "packages.${package_name}.source"
}

# Print error message and exit
# Usage: die "Error message"
die() {
    echo "${RED}Error: $1${NC}" >&2
    exit 1
}

# Print warning message
# Usage: warn "Warning message"
warn() {
    echo "${YELLOW}Warning: $1${NC}" >&2
}

# Print success message
# Usage: success "Success message"
success() {
    echo "${GREEN}✓${NC} $1"
}

# Print info message
# Usage: info "Info message"
info() {
    echo "${BLUE}ℹ${NC} $1"
}

# Remove deprecated script files (from versions < 2.0.0)
# Usage: cleanup_deprecated_scripts
cleanup_deprecated_scripts() {
    local deprecated_scripts=(
        "check-for-updates.sh"
        "common.sh"
        "install.sh"
        "package-install.sh"
        "uninstall.sh"
        "update.sh"
        "version.sh"
        "yaml.sh"
    )
    
    local removed_count=0
    for script in "${deprecated_scripts[@]}"; do
        if [ -f "agent/scripts/$script" ]; then
            rm "agent/scripts/$script"
            warn "Removed deprecated script: $script"
            removed_count=$((removed_count + 1))
        fi
    done
    
    if [ $removed_count -gt 0 ]; then
        success "Cleaned up $removed_count deprecated script(s)"
    fi
}
