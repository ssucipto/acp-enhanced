# Reusable Code Patterns
# Populated automatically by /acp-commit when patterns are identified
# Format: date-stamped YAML entries, max 60 days active

- date: 2026-07-23
  name: optional-external-tool
  task_type: bash-scripting
  code_ref: agent/scripts/acp.coderabbit.sh + agent/patterns/local.optional-external-tool.md (M78, ADR-21)
  description: |
    Three-gate contract for integrating a tool ACP consumers may not have:
    (1) opt-in preference default false; (2) output-free detection
    (config-file / command -v); (3) silent graceful degradation — absence is
    a no-op exit 0, never an error. Binding rule: the tool augments, never
    gates, an ACP code path. Two hard gotchas: a boolean false default
    resolves as the non-empty string "false" (compare == "true", not
    has_preference); and the helper must live in a dedicated script sourcing
    acp.preferences.sh — never in acp.common.sh, which preferences.sh already
    sources (circular). Reference instance: CodeRabbit; next: Aikido.

- date: 2026-06-15
  name: spec-audit-fix-publish-cycle
  task_type: docs-update
  code_ref: design-spec-acp-enhanced-features (audit-063, v1→v2) + design-spec-m55-m58 (audit-064, v1→v2)
  description: |
    Write specification v1 → run /acp-audit on it → fix ALL findings → publish v2.
    This two-pass cycle caught 26 errors across two specs that would have shipped
    as authoritative documentation. The key discipline: audit AGAINST the live
    codebase, not against the spec itself. Three CRITICAL numerical errors
    (M55: 54→77 actual rules, M56: broken subtotals, development months: 11→5)
    were caught by line-by-line codebase cross-reference. Without the v2 pass,
    these would be published errors in the final spec.

- date: 2026-06-07
  name: pre-implementation-audit-drill
  task_type: audit-run
  code_ref: M56 planning (audit-053 → audit-054 → audit-055)
  description: |
    Three rounds of audit before any implementation code is written:
    Round 1 (suitability): Does this proposal fit our architecture? Scope?
    Round 2 (second opinion): Independent review confirms/challenges Round 1.
    Round 3 (pre-impl gap): Scan the final plan for inconsistencies.
    Result: 12 gaps caught across 3 rounds. Zero blockers at implementation start.
    Use when: receiving a large external feedback/proposal (>20 pages, new command).
    Anti-pattern: single audit → implement → discover gaps during coding.

- date: 2026-06-07
  name: command-doc-as-spec
  task_type: command-doc-write
  code_ref: agent/commands/acp.review.md (route-133 merge decision)
  description: |
    When a command document contains its own complete specification (rules,
    quality gates, output format, verification checklist), a separate spec file
    creates version drift risk. The command doc serves as both documentation and
    specification — self-documenting, verifiable, executable. Route 133
    (code-quality.standards.md) was merged into acp.review.md per this pattern.
    Use when: the command doc embeds a complete, verifiable ruleset.
    Anti-pattern: separate spec file that duplicates command doc content.

- date: 2026-06-04
  name: dual-store-registry-to-document-sync
  task_type: architecture-design
  code_ref: agent/commands/acp.commit.md (steps 2b, 3b, 6b)
  description: |
    Dual-store architecture where a compact YAML registry (source of truth) is
    synced to human-readable markdown documents on every commit. Registry is
    optimized for diffing and version control; documents are optimized for agent
    and visualizer consumption. Sync is idempotent (skip unchanged, update changed)
    with an escape hatch (--no-sync). Repair tools provide bulk reconciliation.
    Pattern mirrors Git checkout (object store → working tree) and database
    checkpointing (WAL → data files).

- date: 2026-05-06
  name: tanstack-start-v1-server-fn
  task_type: typescript
  code_ref: server/routes/api/progress.ts (task-139, agent-context-protocol-visualizer)
  description: |
    TanStack Start v1.x (tested on v1.167.64) does NOT export `createAPIFileRoute`
    from `@tanstack/react-start/api` — that subpath does not exist. The correct
    pattern for server-side data fetching is `createServerFn` with `.inputValidator()`.
    Note: the method is `.inputValidator()`, NOT `.input()`. Import from the root
    `@tanstack/react-start` package. Works for both GET and POST handlers.
  template: |
    import { createServerFn } from '@tanstack/react-start';
    import { readFileSync } from 'node:fs';

    export const fetchMyData = createServerFn({ method: 'GET' })
      .inputValidator((input: { param?: string }) => input)  // NOT .input()
      .handler(async ({ data }) => {
        const val = data.param ?? 'default';
        try {
          return { data: doSomething(val), error: null };
        } catch (err: unknown) {
          const message = err instanceof Error ? err.message : 'Unknown error';
          return { data: null, error: message };
        }
      });

    // Client-side usage:
    // const result = await fetchMyData({ data: { param: 'value' } });

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
  extension_2026_07_15: |
    Found the same bug class in the SOURCE agent/.gitignore itself (audit-091, F-091-14),
    not just embedded copies: a bare `reports/` line (fixed in root .gitignore's
    `!agent/reports/` form for drafts/ already, but reports/ was left bare) silently
    blocked all new files under agent/reports/ — 61 of 88 audit reports were untracked.
    Extended rule: whenever auditing for this bug class, grep the WHOLE gitignore file
    for every bare `dir/` line and check whether ANY whitelist (`!...`) rule sits below
    it anywhere in the file (root or nested) — not just the directory being actively fixed.
