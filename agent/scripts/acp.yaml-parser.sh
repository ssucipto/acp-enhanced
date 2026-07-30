#!/bin/bash
# Generic YAML Parser with AST
# Pure POSIX shell implementation
# Version: 1.0.0
# Created: 2026-02-21

# ============================================================================
# PORTABILITY HELPERS
# ============================================================================

# Portable in-place sed (works on both GNU and BSD/macOS sed)
# Usage: _yaml_sed_i "expression" "file"
# Delegates to _sed_i when acp.common.sh is also loaded (avoids duplication).
_yaml_sed_i() {
    if declare -f _sed_i > /dev/null 2>&1; then
        _sed_i "$@"
    elif [ "$(uname)" = "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# ============================================================================
# GLOBAL STATE
# ============================================================================

# Prevent variable reset on re-sourcing
if [ -z "${YAML_PARSER_LOADED:-}" ]; then
    YAML_PARSER_LOADED=1
    AST_FILE=""
    AST_ROOT_ID=0
    YAML_CURRENT_FILE=""
fi

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

init_ast() {
    cleanup_ast  # remove any prior temp file before creating a new one
    AST_FILE=$(mktemp)
    echo "0|map||root|-1|" > "$AST_FILE"
    AST_ROOT_ID=0
    # Script-level trap cleanup_ast on EXIT is set at the bottom of this file.
    # Do NOT set trap here — subshells ($(...)) inherit the trap and would
    # delete AST_FILE on subshell exit, breaking the parent shell's AST state.
}

cleanup_ast() {
    if [ -n "$AST_FILE" ] && [ -f "$AST_FILE" ]; then
        rm -f "$AST_FILE"
    fi
}

get_next_node_id() {
    wc -l < "$AST_FILE"
}

# NOTE (M85 task-299 / F2-06): a SECOND definition of create_node() lived here.
# It escaped `|` as `\|`, but a later definition (further down this file, commented
# "Original create_node for backward compatibility") overrode it — bash keeps the
# last definition loaded — so the escaping never ran. `declare -f create_node`
# confirmed zero escaping lines in the live function. That shadowing duplicate was
# the actual mechanism behind F-112-01. Deleted here; the surviving definition now
# percent-encodes instead. Do not reintroduce a second definition.

get_node() {
    local node_id="$1"
    sed -n "$((node_id + 1))p" "$AST_FILE"
}

# Percent-encode / decode the record delimiter so a value containing `|` survives
# the pipe-delimited AST format (F-112-01).
#
# Chosen over backslash escaping deliberately: with `\|` every splitter must
# distinguish an escaped delimiter from a real one, and 7 sites in this file rebuild
# a record from split fields — 7 chances to lose it silently. With percent-encoding
# no literal `|` ever reaches the record, so splitting stays trivial and those 7
# sites need no change.
#
# `%` is encoded FIRST and decoded LAST; otherwise a literal "%7C" in user data
# would decode into a delimiter.
_yaml_pct_encode() {   # sets _YE
    _YE="${1//%/%25}"
    _YE="${_YE//|/%7C}"
}

_yaml_pct_decode() {   # sets _YD
    _YD="${1//%7C/|}"
    _YD="${_YD//%25/%}"
}

# Split an AST record into globals without forking.
#
# Records are "id|type|key|value|parent|children". Every field read used to cost a
# `cut` subprocess, and `cut` was 703 of the 1498 forks in a single 89-node parse
# (47%) — see M85 task-299 / F2-07. Parameter expansion does the same work in-process.
#
# Semantics are deliberately IDENTICAL to `cut -d'|' -fN`, including the behaviour on
# a value that itself contains `|`: the field is truncated at the first pipe and later
# fields shift. That is bug F-112-01 and it is preserved here on purpose so this change
# is byte-identical; the fix is a separate commit with its own assertions.
#
# Sets: _YN_ID _YN_TYPE _YN_KEY _YN_VALUE _YN_PARENT _YN_CHILDREN
_yaml_split_node() {
    local _rec="$1" _rest
    _YN_ID="${_rec%%|*}";       _rest="${_rec#*|}"
    _YN_TYPE="${_rest%%|*}";    _rest="${_rest#*|}"
    _YN_KEY="${_rest%%|*}";     _rest="${_rest#*|}"
    _YN_VALUE="${_rest%%|*}";   _rest="${_rest#*|}"
    _YN_PARENT="${_rest%%|*}";  _rest="${_rest#*|}"
    _YN_CHILDREN="${_rest%%|*}"
}

# Trim whitespace without forking. bash 3.2 has no extglob-free greedy suffix
# strip, so these loop — still far cheaper than `sed`, which cost one fork per call
# and was paired with `cut` on every key:value line (M85 task-299).
_YAML_TAB="$(printf '\t')"

_yaml_rtrim() {   # sets _YT
    _YT="$1"
    while :; do
        case "$_YT" in
            *' ') _YT="${_YT% }" ;;
            *"$_YAML_TAB") _YT="${_YT%?}" ;;
            *) break ;;
        esac
    done
}

_yaml_ltrim() {   # sets _YT
    _YT="$1"
    while :; do
        case "$_YT" in
            ' '*) _YT="${_YT# }" ;;
            "$_YAML_TAB"*) _YT="${_YT#?}" ;;
            *) break ;;
        esac
    done
}

get_node_field() {
    local node_id="$1"
    local field_num="$2"
    _yaml_split_node "$(get_node "$node_id")"
    case "$field_num" in
        1) printf '%s\n' "$_YN_ID" ;;
        2) printf '%s\n' "$_YN_TYPE" ;;
        3) _yaml_pct_decode "$_YN_KEY";   printf '%s\n' "$_YD" ;;
        4) _yaml_pct_decode "$_YN_VALUE"; printf '%s\n' "$_YD" ;;
        5) printf '%s\n' "$_YN_PARENT" ;;
        6) printf '%s\n' "$_YN_CHILDREN" ;;
        *) printf '\n' ;;
    esac
}

add_child() {
    local parent_id="$1"
    local child_id="$2"
    
    local node
    node=$(get_node "$parent_id")
    
    local id type key value parent children
    _yaml_split_node "$node"
    id="$_YN_ID"; type="$_YN_TYPE"; key="$_YN_KEY"
    value="$_YN_VALUE"; parent="$_YN_PARENT"; children="$_YN_CHILDREN"
    
    if [ -z "$children" ]; then
        children="$child_id"
    else
        children="$children,$child_id"
    fi
    
    local updated="$id|$type|$key|$value|$parent|$children"
    _yaml_sed_i "$((parent_id + 1))s@.*@$updated@" "$AST_FILE"
}

update_node_type() {
    local node_id="$1"
    local new_type="$2"
    
    local node
    node=$(get_node "$node_id")
    
    local id type key value parent children
    _yaml_split_node "$node"
    id="$_YN_ID"; key="$_YN_KEY"; value="$_YN_VALUE"
    parent="$_YN_PARENT"; children="$_YN_CHILDREN"
    
    local updated="$id|$new_type|$key|$value|$parent|$children"
    _yaml_sed_i "$((node_id + 1))s@.*@$updated@" "$AST_FILE"
}

# Count leading spaces in a string.
# Usage: get_indent_level "  key: value"  → 2
get_indent_level() {
    local line="$1"
    local count=0
    while [ "$line" != "${line# }" ]; do
        count=$((count + 1))
        line="${line# }"
    done
    echo "$count"
}

# Remove inline comments from a YAML line (everything from # onwards).
# Usage: strip_comments "key: value # comment"  → "key: value "
strip_comments() {
    echo "$1" | sed 's/#.*$//'
}

# Trim leading and trailing whitespace from a string.
# Usage: trim "  value  "  → "value"
trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# Return 0 (true) if line is a YAML array item (starts with optional whitespace then "- ").
# Usage: is_array_item "  - item"  → 0 (true)
is_array_item() {
    local trimmed="${1#"${1%%[![:space:]]*}"}"
    case "$trimmed" in
        -\ *|-) return 0 ;;
        *) return 1 ;;
    esac
}

# ============================================================================
# PARSER
# ============================================================================

yaml_parse() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    cleanup_ast
    init_ast
    YAML_CURRENT_FILE="$file"
    
    # State tracking
    local parent_stack="0"
    local indent_stack="-1"
    local current_parent=0
    local prev_indent=-1
    local last_key_node=-1
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines
        [ -z "$line" ] && continue
        
        # Skip comment lines
        case "$line" in \#*) continue ;; esac
        
        # Strip inline comments
        line=$(echo "$line" | sed 's/#.*$//')
        
        # Calculate indentation
        local indent=0
        local trimmed="$line"
        while [ "$trimmed" != "${trimmed# }" ]; do
            indent=$((indent + 1))
            trimmed="${trimmed# }"
        done
        
        # Skip empty after trim
        [ -z "$trimmed" ] && continue
        
        # Handle dedent - pop stack
        while [ "$prev_indent" -ge 0 ] && [ "$indent" -le "$prev_indent" ]; do
            # Pop one level
            parent_stack=$(echo "$parent_stack" | sed 's/,[^,]*$//')
            indent_stack=$(echo "$indent_stack" | sed 's/,[^,]*$//')
            
            # Get new current parent
            current_parent=$(echo "$parent_stack" | awk -F',' '{print $NF}')
            prev_indent=$(echo "$indent_stack" | awk -F',' '{print $NF}')
            
            # Handle empty stack
            [ -z "$current_parent" ] && current_parent=0
            [ -z "$prev_indent" ] && prev_indent=-1
            
            last_key_node=-1
        done
        
        # Parse line content
        if echo "$trimmed" | grep -q '^-[[:space:]]'; then
            # Array item
            local item_content
            item_content=$(echo "$trimmed" | sed 's/^-[[:space:]]*//')
            
            # Convert last key node to array if needed
            if [ "$last_key_node" -ge 0 ]; then
                update_node_type "$last_key_node" "array"
                current_parent="$last_key_node"
                last_key_node=-1
            fi
            
            # Check if inline object (has colon on same line)
            if echo "$item_content" | grep -q ':'; then
                # Inline object: - name: value
                local obj_node
                obj_node=$(create_node "map" "" "" "$current_parent")
                add_child "$current_parent" "$obj_node"
                
                # Parse first field
                local key value
                _yaml_rtrim "${item_content%%:*}"; key="$_YT"
                _yaml_ltrim "${item_content#*:}"; value="$_YT"
                
                local field_node
                field_node=$(create_node "scalar" "$key" "$value" "$obj_node")
                add_child "$obj_node" "$field_node"
                
                # Push object onto stack for potential additional fields
                parent_stack="$parent_stack,$obj_node"
                indent_stack="$indent_stack,$indent"
                current_parent="$obj_node"
                prev_indent="$indent"
            else
                # Simple array item: - value
                local item_node
                item_node=$(create_node "scalar" "" "$item_content" "$current_parent")
                add_child "$current_parent" "$item_node"
            fi
        elif echo "$trimmed" | grep -q ':'; then
            # Key-value pair
            local key value
            _yaml_rtrim "${trimmed%%:*}"; key="$_YT"
            _yaml_ltrim "${trimmed#*:}"; value="$_YT"
            
            if [ -z "$value" ]; then
                # Key with no value - map or array follows
                local node_id
                node_id=$(create_node "map" "$key" "" "$current_parent")
                add_child "$current_parent" "$node_id"
                
                # Push onto stack
                parent_stack="$parent_stack,$node_id"
                indent_stack="$indent_stack,$indent"
                current_parent="$node_id"
                prev_indent="$indent"
                last_key_node="$node_id"
            else
                # Check for empty array [] or empty map {}
                if [ "$value" = "[]" ]; then
                    # Empty array
                    local node_id
                    node_id=$(create_node "array" "$key" "" "$current_parent")
                    add_child "$current_parent" "$node_id"
                elif [ "$value" = "{}" ]; then
                    # Empty map
                    local node_id
                    node_id=$(create_node "map" "$key" "" "$current_parent")
                    add_child "$current_parent" "$node_id"
                else
                    # Scalar value
                    local node_id
                    node_id=$(create_node "scalar" "$key" "$value" "$current_parent")
                    add_child "$current_parent" "$node_id"
                fi
            fi
        fi
    done < "$file"
    
    return 0
}

# ============================================================================
# QUERY ENGINE
# ============================================================================

find_child_by_key() {
    local parent_id="$1"
    local key="$2"
    
    local children
    children=$(get_node_field "$parent_id" 6)
    
    [ -z "$children" ] && return 1
    
    local IFS=','
    for child_id in $children; do
        local child_key
        child_key=$(get_node_field "$child_id" 3)
        
        if [ "$child_key" = "$key" ]; then
            echo "$child_id"
            return 0
        fi
    done
    
    return 1
}

find_child_by_index() {
    local parent_id="$1"
    local index="$2"
    
    local children
    children=$(get_node_field "$parent_id" 6)
    
    [ -z "$children" ] && return 1
    
    local child_id
    child_id=$(echo "$children" | tr ',' '\n' | sed -n "$((index + 1))p")
    
    if [ -n "$child_id" ]; then
        echo "$child_id"
        return 0
    fi
    
    return 1
}

# yaml_query: query the loaded AST for a value at the given dot-path.
# The path must NOT start with a dot (e.g. "acp.plan.draft.create_mode").
#
# For SCALAR nodes: returns the value with no trailing colon.
# For MAP or ARRAY nodes: returns each direct child key followed by ':'
#   (e.g. "plan:" for a map child named "plan"). This is intentional
#   for YAML-list-style output. Callers that need bare key names should
#   strip the trailing colon via: key="${key%:}"
# Returns: empty output and exit 1 if path not found.
# Note: Call yaml_get(file, path) instead if the AST is not yet loaded.
yaml_query() {
    local path="$1"
    
    if [ -z "$AST_FILE" ] || [ ! -f "$AST_FILE" ]; then
        echo "Error: No AST loaded. Call yaml_parse first." >&2
        return 1
    fi
    
    path=$(echo "$path" | sed 's/^\.//')
    
    local current_node="$AST_ROOT_ID"
    
    local IFS='.'
    for segment in $path; do
        if echo "$segment" | grep -q '\['; then
            local key index
            key=$(echo "$segment" | sed 's/\[.*//')
            index=$(echo "$segment" | sed 's/.*\[\([0-9]*\)\].*/\1/')
            
            current_node=$(find_child_by_key "$current_node" "$key")
            [ -z "$current_node" ] && return 1
            
            current_node=$(find_child_by_index "$current_node" "$index")
            [ -z "$current_node" ] && return 1
        else
            current_node=$(find_child_by_key "$current_node" "$segment")
            [ -z "$current_node" ] && return 1
        fi
    done
    
    # Check node type
    local node_type
    node_type=$(get_node_field "$current_node" 2)
    
    # For map or array nodes, return children keys in YAML format
    if [ "$node_type" = "map" ] || [ "$node_type" = "array" ]; then
        local children
        children=$(get_node_field "$current_node" 6)
        
        if [ -n "$children" ]; then
            # Split by comma and iterate
            local IFS=','
            for child_id in $children; do
                local child_type child_key child_value
                child_type=$(get_node_field "$child_id" 2)
                child_key=$(get_node_field "$child_id" 3)
                child_value=$(get_node_field "$child_id" 4)
                if [ "$child_type" = "scalar" ] && [ -z "$child_key" ]; then
                    # Bare array scalar item (e.g. "- production") — return value
                    echo "$child_value"
                else
                    echo "${child_key}:"
                fi
            done
        fi
    else
        # For scalar nodes, return the value
        get_node_field "$current_node" 4
    fi
}

# Create a new node in the AST (used by yaml_set for auto-creation)
# Usage: node_id=$(create_node_and_link "type" "key" "value" "parent_id")
# Returns: new node ID
# NOTE: This version adds the node as a child of parent (for yaml_set)
create_node_and_link() {
    local type="$1"
    local key="$2"
    local value="$3"
    local parent_id="$4"
    
    # Get next node ID
    local next_id
    next_id=$(wc -l < "$AST_FILE")
    
    # Create node: id|type|key|value|parent|children
    # F-112-01: encode the delimiter out of user data before it reaches the record.
    local _ekey _evalue
    _yaml_pct_encode "$key";   _ekey="$_YE"
    _yaml_pct_encode "$value"; _evalue="$_YE"
    echo "${next_id}|${type}|${_ekey}|${_evalue}|${parent_id}|" >> "$AST_FILE"
    
    # Add this node to parent's children list
    if [ "$parent_id" != "-1" ]; then
        # Read current parent node
        local parent_line
        parent_line=$(sed -n "$((parent_id + 1))p" "$AST_FILE")
        
        # Extract parent fields
        local parent_children
        _yaml_split_node "$parent_line"
        parent_children="$_YN_CHILDREN"
        
        # Append new child ID
        if [ -z "$parent_children" ]; then
            parent_children="$next_id"
        else
            parent_children="${parent_children},${next_id}"
        fi
        
        # Update parent node with new children list
        local parent_prefix
        # cut -f1-5 joins fields 1..5 with the delimiter; stripping the last
        # field is the same thing for a 6-field record, and `children` is a
        # comma-joined id list that never contains a pipe.
        parent_prefix="${parent_line%|*}"
        _yaml_sed_i "$((parent_id + 1))s@.*@${parent_prefix}|${parent_children}@" "$AST_FILE"
    fi
    
    echo "$next_id"
}

# Original create_node for backward compatibility (does NOT link to parent)
create_node() {
    local type="$1"
    local key="$2"
    local value="$3"
    local parent_id="$4"
    
    # Get next node ID
    local next_id
    next_id=$(wc -l < "$AST_FILE")
    
    # Create node: id|type|key|value|parent|children
    # F-112-01: encode the delimiter out of user data before it reaches the record.
    local _ekey _evalue
    _yaml_pct_encode "$key";   _ekey="$_YE"
    _yaml_pct_encode "$value"; _evalue="$_YE"
    echo "${next_id}|${type}|${_ekey}|${_evalue}|${parent_id}|" >> "$AST_FILE"
    
    echo "$next_id"
}

yaml_set() {
    local path="$1"
    local new_value="$2"
    
    if [ -z "$AST_FILE" ] || [ ! -f "$AST_FILE" ]; then
        echo "Error: No AST loaded. Call yaml_parse first." >&2
        return 1
    fi
    
    path=$(echo "$path" | sed 's/^\.//')
    
    local current_node="$AST_ROOT_ID"
    local IFS='.'
    local segments=($path)
    local last_index=$((${#segments[@]} - 1))
    
    # Traverse path, creating missing nodes
    local i=0
    for segment in "${segments[@]}"; do
        local is_last=$((i == last_index))
        
        if echo "$segment" | grep -q '\['; then
            local key index
            key=$(echo "$segment" | sed 's/\[.*//')
            index=$(echo "$segment" | sed 's/.*\[\([0-9]*\)\].*/\1/')
            
            local child_node
            child_node=$(find_child_by_key "$current_node" "$key") || true
            if [ -z "$child_node" ]; then
                # Create missing array node
                child_node=$(create_node_and_link "array" "$key" "" "$current_node")
            fi
            current_node="$child_node"
            
            child_node=$(find_child_by_index "$current_node" "$index")
            if [ -z "$child_node" ]; then
                echo "Error: Cannot create array index $index (not supported yet)" >&2
                return 1
            fi
            current_node="$child_node"
        else
            local child_node
            child_node=$(find_child_by_key "$current_node" "$segment") || true
            
            if [ -z "$child_node" ]; then
                # Create missing node
                if [ "$is_last" -eq 1 ]; then
                    # Last segment - check for empty array/map
                    if [ "$new_value" = "[]" ]; then
                        # Create empty array
                        child_node=$(create_node_and_link "array" "$segment" "" "$current_node")
                    elif [ "$new_value" = "{}" ]; then
                        # Create empty map
                        child_node=$(create_node_and_link "map" "$segment" "" "$current_node")
                    else
                        # Create scalar with value
                        child_node=$(create_node_and_link "scalar" "$segment" "$new_value" "$current_node")
                    fi
                    return 0
                else
                    # Intermediate segment - create map
                    child_node=$(create_node_and_link "map" "$segment" "" "$current_node")
                fi
            fi
            current_node="$child_node"
        fi
        
        i=$((i + 1))
    done
    
    # Update existing node value
    local node
    node=$(get_node "$current_node")
    
    local id type key value parent children
    _yaml_split_node "$node"
    id="$_YN_ID"; type="$_YN_TYPE"; key="$_YN_KEY"
    parent="$_YN_PARENT"; children="$_YN_CHILDREN"
    
    # Check if converting to empty array
    if [ "$new_value" = "[]" ]; then
        # Convert node to array type and clear children
        local updated="$id|array|$key||$parent|"
        _yaml_sed_i "$((current_node + 1))s@.*@$updated@" "$AST_FILE"
    else
        new_value=$(echo "$new_value" | sed 's/|/\\|/g')
        local updated="$id|$type|$key|$new_value|$parent|$children"
        _yaml_sed_i "$((current_node + 1))s@.*@$updated@" "$AST_FILE"
    fi
}

yaml_write() {
    local output_file="$1"
    
    if [ -z "$AST_FILE" ] || [ ! -f "$AST_FILE" ]; then
        echo "Error: No AST loaded. Call yaml_parse first." >&2
        return 1
    fi
    
    serialize_node "$AST_ROOT_ID" 0 > "$output_file"
}

serialize_node() {
    local node_id="$1"
    local indent_level="$2"
    local parent_type="${3:-}"
    
    local node
    node=$(get_node "$node_id")
    
    local type key value children parent_id
    _yaml_split_node "$node"
    type="$_YN_TYPE"; key="$_YN_KEY"; value="$_YN_VALUE"
    parent_id="$_YN_PARENT"; children="$_YN_CHILDREN"
    
    # Determine parent type if not provided
    if [ -z "$parent_type" ] && [ "$parent_id" -ge 0 ]; then
        parent_type=$(get_node_field "$parent_id" 2)
    fi
    
    local indent=""
    local i=0
    while [ "$i" -lt "$indent_level" ]; do
        indent="$indent  "
        i=$((i + 1))
    done
    
    case "$type" in
        scalar)
            if [ -n "$key" ]; then
                echo "$indent$key: $value"
            else
                echo "$indent-  $value"
            fi
            ;;
        
        map)
            # If this map is in an array, first child gets dash prefix
            local is_first_child=true
            
            if [ "$node_id" -ne 0 ] && [ -n "$key" ]; then
                echo "$indent$key:"
            fi
            
            if [ -n "$children" ]; then
                local IFS=','
                local next_indent
                # Root node (id=0) doesn't add indentation
                if [ "$node_id" -eq 0 ]; then
                    next_indent="$indent_level"
                else
                    next_indent="$((indent_level + 1))"
                fi
                
                for child_id in $children; do
                    # If parent is array and this is first child, use dash
                    if [ "$parent_type" = "array" ] && [ "$is_first_child" = true ]; then
                        # Serialize first field with dash
                        local child_node
                        child_node=$(get_node "$child_id")
                        local child_type child_key child_value
                        _yaml_split_node "$child_node"
                        child_type="$_YN_TYPE"; child_key="$_YN_KEY"; child_value="$_YN_VALUE"
                        
                        if [ "$child_type" = "scalar" ] && [ -n "$child_key" ]; then
                            echo "$indent- $child_key: $child_value"
                        fi
                        is_first_child=false
                    else
                        serialize_node "$child_id" "$next_indent" "$type"
                    fi
                done
            fi
            ;;
        
        array)
            if [ -n "$key" ]; then
                if [ -z "$children" ]; then
                    # Empty array — emit inline [] so yaml_parse reloads it as array, not map
                    echo "$indent$key: []"
                else
                    echo "$indent$key:"
                fi
            fi
            
            if [ -n "$children" ]; then
                local IFS=','
                # Array children need to be indented
                for child_id in $children; do
                    serialize_node "$child_id" "$((indent_level + 1))" "array"
                done
            fi
            ;;
    esac
}

# ============================================================================
# BACKWARD COMPATIBILITY
# ============================================================================

# _ast_valid: returns 0 if AST is loaded and the temp file still exists
_ast_valid() {
    [ -n "$AST_FILE" ] && [ -f "$AST_FILE" ]
}

yaml_get() {
    local file="$1"
    local key="$2"
    
    if [ "$YAML_CURRENT_FILE" != "$file" ] || ! _ast_valid; then
        yaml_parse "$file" || return 1
    fi
    
    yaml_query ".$key"
}

yaml_get_nested() {
    local file="$1"
    local path="$2"
    
    if [ "$YAML_CURRENT_FILE" != "$file" ] || ! _ast_valid; then
        yaml_parse "$file" || return 1
    fi
    
    yaml_query ".$path"
}

# Check if key exists (checks if node exists, not if it has a value)
yaml_has_key() {
    local file="$1"
    local key="$2"
    
    if [ "$YAML_CURRENT_FILE" != "$file" ] || ! _ast_valid; then
        yaml_parse "$file" || return 1
    fi
    
    # Try to find the node (returns empty string on failure, but exit code tells us)
    path=$(echo "$key" | sed 's/^\.//')
    local current_node="$AST_ROOT_ID"
    
    local IFS='.'
    for segment in $path; do
        if echo "$segment" | grep -q '\['; then
            local k index
            k=$(echo "$segment" | sed 's/\[.*//')
            index=$(echo "$segment" | sed 's/.*\[\([0-9]*\)\].*/\1/')
            
            current_node=$(find_child_by_key "$current_node" "$k" 2>/dev/null)
            [ -z "$current_node" ] && return 1
            
            current_node=$(find_child_by_index "$current_node" "$index" 2>/dev/null)
            [ -z "$current_node" ] && return 1
        else
            current_node=$(find_child_by_key "$current_node" "$segment" 2>/dev/null)
            [ -z "$current_node" ] && return 1
        fi
    done
    
    # Node exists
    return 0
}

# Get array count (for object arrays)
# Usage: yaml_get_array file.yaml "contents.commands"
# Returns: count of array elements
yaml_get_array() {
    local file="$1"
    local path="$2"
    
    if [ "$YAML_CURRENT_FILE" != "$file" ] || ! _ast_valid; then
        yaml_parse "$file" || return 1
    fi
    
    # Find the array node
    path=$(echo "$path" | sed 's/^\.//')
    local current_node="$AST_ROOT_ID"
    
    local IFS='.'
    for segment in $path; do
        current_node=$(find_child_by_key "$current_node" "$segment")
        [ -z "$current_node" ] && return 1
    done
    
    # Get children count
    local children
    children=$(get_node_field "$current_node" 6)
    
    if [ -z "$children" ]; then
        echo "0"
    else
        echo "$children" | tr ',' '\n' | wc -l | tr -d ' '
    fi
}

# Append scalar item to array
# Usage: yaml_array_append ".path.to.array" "value"
# Returns: node_id of new item
yaml_array_append() {
    local path="$1"
    local value="$2"
    
    if [ -z "$AST_FILE" ] || [ ! -f "$AST_FILE" ]; then
        echo "Error: No AST loaded. Call yaml_parse first." >&2
        return 1
    fi
    
    # Find the array node
    path=$(echo "$path" | sed 's/^\.//')
    local current_node="$AST_ROOT_ID"
    
    local IFS='.'
    for segment in $path; do
        if echo "$segment" | grep -q '\['; then
            local key index
            key=$(echo "$segment" | sed 's/\[.*//')
            index=$(echo "$segment" | sed 's/.*\[\([0-9]*\)\].*/\1/')
            
            current_node=$(find_child_by_key "$current_node" "$key")
            [ -z "$current_node" ] && return 1
            
            current_node=$(find_child_by_index "$current_node" "$index")
            [ -z "$current_node" ] && return 1
        else
            current_node=$(find_child_by_key "$current_node" "$segment")
            [ -z "$current_node" ] && return 1
        fi
    done
    
    # Verify it's an array
    local node_type
    node_type=$(get_node_field "$current_node" 2)
    
    if [ "$node_type" != "array" ]; then
        echo "Error: Path does not point to an array" >&2
        return 1
    fi
    
    # Create new scalar node
    local new_node
    new_node=$(create_node "scalar" "" "$value" "$current_node")
    
    # Add as child
    add_child "$current_node" "$new_node"
    
    echo "$new_node"
}

# Delete a node at the specified path
# Usage: yaml_delete ".path.to.node"
# Returns: 0 on success, 1 on failure
yaml_delete() {
    local path="$1"
    
    if [ -z "$path" ]; then
        echo "Error: Path is required" >&2
        return 1
    fi
    
    # Remove leading dot
    path="${path#.}"
    
    # Navigate to parent and get the key to delete
    local parent_path=""
    local key_to_delete=""
    
    # Split path into parent and key
    if echo "$path" | grep -q '\.'; then
        parent_path=$(echo "$path" | sed 's/\.[^.]*$//')
        key_to_delete=$(echo "$path" | sed 's/.*\.//')
    else
        parent_path=""
        key_to_delete="$path"
    fi
    
    # Find parent node
    local current_node=0
    if [ -n "$parent_path" ]; then
        local IFS='.'
        for segment in $parent_path; do
            if echo "$segment" | grep -q '\['; then
                local key index
                key=$(echo "$segment" | sed 's/\[.*//')
                index=$(echo "$segment" | sed 's/.*\[\([0-9]*\)\].*/\1/')
                
                current_node=$(find_child_by_key "$current_node" "$key")
                [ -z "$current_node" ] && return 1
                
                current_node=$(find_child_by_index "$current_node" "$index")
                [ -z "$current_node" ] && return 1
            else
                current_node=$(find_child_by_key "$current_node" "$segment")
                [ -z "$current_node" ] && return 1
            fi
        done
    fi
    
    # Find the child node to delete
    local node_to_delete
    node_to_delete=$(find_child_by_key "$current_node" "$key_to_delete")
    
    if [ -z "$node_to_delete" ]; then
        echo "Error: Node not found: $path" >&2
        return 1
    fi
    
    # Remove child from parent's children list
    local parent_node
    parent_node=$(get_node "$current_node")
    
    local id type key value parent children
    _yaml_split_node "$parent_node"
    id="$_YN_ID"; type="$_YN_TYPE"; key="$_YN_KEY"
    value="$_YN_VALUE"; parent="$_YN_PARENT"; children="$_YN_CHILDREN"
    
    # Remove node_to_delete from children list
    local new_children=""
    local IFS=','
    for child_id in $children; do
        if [ "$child_id" != "$node_to_delete" ]; then
            if [ -z "$new_children" ]; then
                new_children="$child_id"
            else
                new_children="$new_children,$child_id"
            fi
        fi
    done
    
    # Update parent node
    local updated="$id|$type|$key|$value|$parent|$new_children"
    _yaml_sed_i "$((current_node + 1))s@.*@$updated@" "$AST_FILE"
    
    return 0
}

# Append object to array
# Usage: yaml_array_append_object ".path.to.array"
# Returns: node_id of new object (use yaml_object_set to add fields)
yaml_array_append_object() {
    local path="$1"
    
    if [ -z "$AST_FILE" ] || [ ! -f "$AST_FILE" ]; then
        echo "Error: No AST loaded. Call yaml_parse first." >&2
        return 1
    fi
    
    # Find the node
    path=$(echo "$path" | sed 's/^\.//')
    local current_node="$AST_ROOT_ID"
    
    local IFS='.'
    for segment in $path; do
        if echo "$segment" | grep -q '\['; then
            local key index
            key=$(echo "$segment" | sed 's/\[.*//')
            index=$(echo "$segment" | sed 's/.*\[\([0-9]*\)\].*/\1/')
            
            current_node=$(find_child_by_key "$current_node" "$key")
            [ -z "$current_node" ] && return 1
            
            current_node=$(find_child_by_index "$current_node" "$index")
            [ -z "$current_node" ] && return 1
        else
            current_node=$(find_child_by_key "$current_node" "$segment")
            [ -z "$current_node" ] && return 1
        fi
    done
    
    # Check node type
    local node_type
    node_type=$(get_node_field "$current_node" 2)
    
    # If it's a map with no children, convert to array
    if [ "$node_type" = "map" ]; then
        local children
        children=$(get_node_field "$current_node" 6)
        if [ -z "$children" ]; then
            # Empty map - convert to array
            update_node_type "$current_node" "array"
        else
            echo "Error: Path points to non-empty map, not array" >&2
            return 1
        fi
    elif [ "$node_type" != "array" ]; then
        echo "Error: Path does not point to an array" >&2
        return 1
    fi
    
    # Create new map node (object)
    local new_node
    new_node=$(create_node "map" "" "" "$current_node")
    
    # Add as child
    add_child "$current_node" "$new_node"
    
    echo "$new_node"
}

# Set field on object (for building objects in arrays)
# Usage: yaml_object_set node_id "field_name" "value"
yaml_object_set() {
    local object_node="$1"
    local field_name="$2"
    local field_value="$3"
    
    if [ -z "$AST_FILE" ] || [ ! -f "$AST_FILE" ]; then
        echo "Error: No AST loaded. Call yaml_parse first." >&2
        return 1
    fi
    
    # Create scalar field
    local field_node
    field_node=$(create_node "scalar" "$field_name" "$field_value" "$object_node")
    
    # Add as child
    add_child "$object_node" "$field_node"
    
    echo "$field_node"
}

# ============================================================================
# MAIN
# ============================================================================

# No EXIT trap here — subshells inherit traps and cleanup_ast would
# delete AST_FILE on subshell exit, breaking the parent's AST state.
# Cleanup happens in init_ast() → cleanup_ast() before each yaml_parse.

# Only run main if script is executed directly (not sourced)
if [ -n "${1:-}" ] && [ "${1:-}" != "-" ] && [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "$1" in
        parse)
            yaml_parse "$2"
            echo "✓ Parsed $2 ($(get_next_node_id) nodes)"
            ;;
        query)
            yaml_parse "$2"
            yaml_query "$3"
            ;;
        set)
            yaml_parse "$2"
            yaml_set "$3" "$4"
            yaml_write "$2"
            echo "✓ Updated $2"
            ;;
        debug)
            yaml_parse "$2"
            echo "AST Contents:"
            cat "$AST_FILE"
            ;;
        *)
            echo "Usage: $0 {parse|query|set|debug} file.yaml [path] [value]"
            echo ""
            echo "Examples:"
            echo "  $0 parse file.yaml"
            echo "  $0 query file.yaml .name"
            echo "  $0 query file.yaml .tags[0]"
            echo "  $0 set file.yaml .version 2.0.0"
            echo "  $0 debug file.yaml"
            exit 1
            ;;
    esac
fi
