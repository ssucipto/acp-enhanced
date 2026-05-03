# Reusable Code Patterns
# Populated automatically by /acp-commit when patterns are identified
# Format: date-stamped YAML entries, max 60 days active

- date: 2026-05-03
  name: legacy-dir-migration-create-if-absent
  task_type: shell-scripting
  code_ref: agent/scripts/acp.install.sh (legacy .agent/ migration block)
  description: |
    Pattern for auto-migrating a legacy hidden directory to a new layout in bash.
    Core idea: detect old dir, mv user-state files with create-if-absent guard
    ([ ! -f dest ] before mv), drop static files (regenerated anyway), rm -rf old dir.
    Never glob-mv whole directories — enumerate by file to avoid overwriting newer state.
  template: |
    if [ -d "$OLD_DIR" ]; then
      for _f in file1.md file2.md; do
        [ -f "$OLD_DIR/$_f" ] && [ ! -f "$NEW_DIR/$_f" ] && mv "$OLD_DIR/$_f" "$NEW_DIR/$_f"
      done
      for _f in "$OLD_DIR/prefix-"*.md; do
        [ -f "$_f" ] || continue
        _dest="$NEW_DIR/$(basename "$_f")"
        [ ! -f "$_dest" ] && mv "$_f" "$_dest"
      done
      rm -rf "$OLD_DIR"
    fi

- date: 2026-05-03
  name: posix-awk-key-extraction
  task_type: bash-script-fix
  code_ref: agent/scripts/acp.project-remove.sh (awk project removal block)
  description: |
    macOS ships BSD awk (POSIX only). The 3-argument match($0, /regex/, arr) form is
    a gawk extension and fails on macOS with "awk: syntax error". To extract a capture
    group in POSIX awk, use two sub() calls on a copy of the line instead.
  template: |
    # WRONG (gawk only):
    #   match($0, /^  ([a-zA-Z0-9_-]+):/, arr); use arr[1]
    # CORRECT (POSIX):
    key = $0
    sub(/^  /, "", key)
    sub(/:.*/, "", key)
    # key now holds the value between the indent and the colon
