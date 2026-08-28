#!/bin/bash
# Generate Claude Code slash commands (.claude/commands/) from ACP command sources.
# Maps agent/commands/acp.init.md -> .claude/commands/acp-init.md (slash form).
# Mirrors agent/scripts/acp.cursor-commands-sync.sh (see ADR-6, extended per its
# explicit "third tool ecosystem" trigger for Claude Code's own command directory).
#
# local.*.md: emit local-* wrappers. If the destination already exists, skip
# (do not clobber custom overlays). version-update re-runs this sync (F-127-16);
# skip-if-exists is mandatory.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CMD_DIR="${ACP_SYNC_CMD_DIR:-$ROOT/agent/commands}"
OUT_DIR="${ACP_SYNC_OUT_DIR:-$ROOT/.claude/commands}"

mkdir -p "$OUT_DIR"

to_slash_name() {
  local name="${1%.md}"
  echo "$name" | sed 's/\./-/g'
}

extract_purpose() {
  local file="$1"
  local purpose
  purpose=$(grep -m1 '^\*\*Purpose\*\*:' "$file" | sed 's/^\*\*Purpose\*\*: //' | sed 's/[[:space:]]*$//' || true)
  if [ -z "$purpose" ]; then
    purpose="ACP Enhanced command"
  fi
  # YAML frontmatter safety: escape double quotes
  printf '%s' "$purpose" | sed 's/"/\\"/g'
}

emit_wrapper() {
  local cmd_file="$1"
  local skip_if_exists="${2:-false}"
  local base slash_name purpose out_file
  [ -f "$cmd_file" ] || return 0
  base=$(basename "$cmd_file")
  slash_name=$(to_slash_name "$base")
  purpose=$(extract_purpose "$cmd_file")
  out_file="$OUT_DIR/${slash_name}.md"

  if [ "$skip_if_exists" = true ] && [ -f "$out_file" ]; then
    echo "  ⊘ skip existing: ${out_file}"
    return 0
  fi

  cat > "$out_file" <<EOF
---
description: "${purpose}"
---

# ACP Command: /${slash_name}

Execute ACP Enhanced command \`/${slash_name}\`.

1. Read and follow **every step** in \`agent/commands/${base}\`.
2. Treat text after the command in the user's message as command arguments (\$ARGUMENTS).
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: \`agent/commands/${base}\`
**Equivalent invocations**: \`/${slash_name}\`, \`@${slash_name}\`, \`@agent/commands/${base}\`
EOF
  count=$((count + 1))
}

count=0
for cmd_file in "$CMD_DIR"/acp.*.md "$CMD_DIR"/git.*.md; do
  emit_wrapper "$cmd_file" false
done

for cmd_file in "$CMD_DIR"/local.*.md; do
  [ -f "$cmd_file" ] || continue
  emit_wrapper "$cmd_file" true
done

echo "Generated ${count} Claude Code slash commands in ${OUT_DIR}/"
