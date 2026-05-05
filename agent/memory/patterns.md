# Reusable Code Patterns
# Populated automatically by /acp-commit when patterns are identified
# Format: date-stamped YAML entries, max 60 days active

- date: 2026-05-05
  name: local-star-exclusion-case-loop
  task_type: shell-scripting
  code_ref: agent/scripts/acp.install.sh (skills copy block, task-184)
  description: |
    Bash 3.2-safe pattern to copy a directory of .md files while skipping any
    file whose basename starts with "local.". Use when an install/upgrade script
    must distribute baseline files without clobbering project-local extensions.
    Includes glob safety guard to handle empty directories (no match = no loop body).
    Cleans loop variables with unset to avoid polluting surrounding script scope.
  template: |
    if [ -d "$SRC_DIR" ]; then
        for _file in "$SRC_DIR/"*.md; do
            [ -e "$_file" ] || continue          # glob safety: skip if no match
            _base=$(basename "$_file")
            case "$_base" in
                local.*) continue ;;             # never overwrite project-local files
            esac
            cp "$_file" "$DEST_DIR/"
        done
        unset _file _base
    fi

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

- date: 2026-05-04
  name: gitignore-instance-data-separation
  task_type: repo-hygiene
  code_ref: agent/.gitignore (instance-data rules block)
  description: |
    ACP repos contain two kinds of content: protocol machinery (commands, scripts, schemas,
    templates — distributable) and instance data (tasks, milestones, progress.yaml, memory
    run-logs, routing records — project-specific, local-only).
    Rule: if ACP generated it at runtime, gitignore it. Keep only the template.
    Pattern: ignore the directory glob, whitelist .gitkeep + *.template.* files.
  template: |
    # In agent/.gitignore:
    some-dir/**
    !some-dir/.gitkeep
    !some-dir/name-{placeholder}.template.md
    # This pattern ignores all real content while preserving
    # the directory structure and template scaffold for new users.

- date: 2026-05-05
  name: install-script-gitignore-heredoc-sync
  task_type: shell-scripting
  code_ref: agent/scripts/acp.install.sh (embedded .gitignore heredoc, task-160); agent/commands/acp.project-create.md (embedded sample .gitignore, task-185)
  description: |
    Install scripts AND command docs that embed .gitignore content must use the same patterns
    as the tracked agent/.gitignore — especially `dir/**` + `!exception` form.
    Bare `dir/` in an embedded .gitignore causes all `!exception` rules beneath it to be silently blocked.
    Rule: whenever you fix agent/.gitignore, grep BOTH agent/scripts/ AND agent/commands/ for
    embedded gitignore blocks and apply the same fix there too.
  template: |
    # In install script heredoc — WRONG:
    cat > "$TARGET/agent/.gitignore" << 'EOF'
    drafts/
    EOF
    # CORRECT (mirrors agent/.gitignore source):
    cat > "$TARGET/agent/.gitignore" << 'EOF'
    drafts/**
    !drafts/.gitkeep
    !drafts/draft.template.md
    EOF
