#!/bin/bash

# Agent Context Protocol (ACP) Update Script
# Tier-aware update — preserves project-owned files (M68 / route-079)

# Self-relocation guard: re-exec from temp copy so on-disk script can change safely
if [ -z "$_ACP_UPDATE_RELOCATED" ]; then
    _tmp_copy=$(mktemp)
    cp "$0" "$_tmp_copy"
    export _ACP_UPDATE_RELOCATED=1
    bash "$_tmp_copy" "$@"
    _rc=$?
    rm -f "$_tmp_copy"
    exit $_rc
fi

set -euo pipefail
trap 'echo "ERROR: $(basename "$0") failed at line $LINENO -- check output above for details." >&2; exit 1' ERR

# ── Argument parsing (route-079) ─────────────────────────────────────────────
ACP_DIFF_ONLY=false
ACP_FORCE=false
ACP_PRESERVE_PROJECT_CORE=false
ACP_YES=false

while [ $# -gt 0 ]; do
    case "$1" in
        --diff) ACP_DIFF_ONLY=true ;;
        --preserve-project-core) ACP_PRESERVE_PROJECT_CORE=true ;;
        --force) ACP_FORCE=true ;;
        --yes|-y) ACP_YES=true ;;
        -h|--help)
            echo "Usage: acp.version-update.sh [--diff] [--preserve-project-core] [--force] [--yes]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

export ACP_DIFF_ONLY ACP_FORCE ACP_PRESERVE_PROJECT_CORE ACP_YES

# Colors
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4); BOLD=$(tput bold); NC=$(tput sgr0)
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

REPO_URL="https://github.com/ssucipto/acp-enhanced.git"
BRANCH="mainline"

echo "${BLUE}Agent Context Protocol (ACP) Updater${NC}"
echo "======================================"
echo ""

# Entry check: AGENTS.md OR AGENT.md (F-080-09)
if [ ! -f "AGENTS.md" ] && [ ! -f "AGENT.md" ]; then
    echo "${RED}Error: AGENTS.md or AGENT.md not found in current directory${NC}"
    echo "Run this script from your project root."
    exit 1
fi

if [ ! -f "agent/core/identity.yml" ] || [ ! -f "agent/core/routing.yml" ]; then
    echo "${YELLOW}Warning: Incomplete ACP installation detected.${NC}"
    echo "  Run scripts/acp-bootstrap.sh first for a full install."
fi

# Upstream source: offline fixture (E2E) or git clone
_CLEANUP_TEMP=false
if [ -n "${ACP_UPSTREAM_ROOT:-}" ]; then
    TEMP_DIR="$ACP_UPSTREAM_ROOT"
    echo "Using offline upstream: ${TEMP_DIR}"
else
    TEMP_DIR=$(mktemp -d)
    _CLEANUP_TEMP=true
    trap 'rm -rf "$TEMP_DIR"' EXIT
    echo "Fetching latest ACP files..."
    if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR" &>/dev/null; then
        echo "${RED}Error: Failed to fetch repository${NC}"
        exit 1
    fi
    echo "${GREEN}✓${NC} Latest files fetched"
fi
export TEMP_DIR

. "agent/scripts/acp.common.sh"
init_colors

if [ "$ACP_DIFF_ONLY" = true ]; then
    echo "${YELLOW}Dry-run mode (--diff) — no files will be modified${NC}"
    echo ""
fi

# ── Legacy .agent/ migration ──────────────────────────────────────────────────
if [ "$ACP_DIFF_ONLY" = false ] && [ -d ".agent" ]; then
    echo "${YELLOW}Found legacy .agent/ directory — auto-migrating to agent/ layout...${NC}"
    if [ -d ".agent/memory" ]; then
        mkdir -p agent/memory
        for _f in sessions.md lessons.md decisions.md patterns.md; do
            if [ -f ".agent/memory/$_f" ] && [ ! -f "agent/memory/$_f" ]; then
                mv ".agent/memory/$_f" "agent/memory/$_f"
                echo "  ✓ Migrated memory/$_f"
            fi
        done
    fi
    if [ -d ".agent/tasks" ]; then
        mkdir -p agent/routing/tasks
        for _f in ".agent/tasks/task-"*.md; do
            [ -f "$_f" ] || continue
            _dest="agent/routing/tasks/$(basename "$_f")"
            if [ ! -f "$_dest" ]; then
                mv "$_f" "$_dest"
                echo "  ✓ Migrated routing/tasks/$(basename "$_f")"
            fi
        done
    fi
    if [ -f ".agent/routing/ledger.md" ] && [ ! -f "agent/routing/ledger.md" ]; then
        mkdir -p agent/routing
        mv ".agent/routing/ledger.md" "agent/routing/ledger.md"
        echo "  ✓ Migrated routing/ledger.md"
    fi
    rm -rf ".agent"
    echo "${GREEN}✓${NC} Legacy .agent/ merged and removed"
    echo ""
fi

if [ "$ACP_DIFF_ONLY" = false ]; then
    mkdir -p "agent/reports"
    if [ ! -f "agent/.gitignore" ]; then
        cat > "agent/.gitignore" << 'EOF'
# Agent Context Protocol - Local Files
reports/
clarifications/
feedback/
drafts/
preferences/
EOF
        echo "${GREEN}✓${NC} Created agent/.gitignore"
    fi
fi

echo "Updating ACP files..."

# Tier C: templates
if [ "$ACP_DIFF_ONLY" = false ]; then
    find "$TEMP_DIR/agent/design" -maxdepth 1 -name "*.template.md" -exec cp {} "agent/design/" \; 2>/dev/null || true
    find "$TEMP_DIR/agent/milestones" -maxdepth 1 -name "*.template.md" -exec cp {} "agent/milestones/" \; 2>/dev/null || true
    find "$TEMP_DIR/agent/patterns" -maxdepth 1 -name "*.template.md" -exec cp {} "agent/patterns/" \; 2>/dev/null || true
    find "$TEMP_DIR/agent/tasks" -maxdepth 1 -name "*.template.md" -exec cp {} "agent/tasks/" \; 2>/dev/null || true
    mkdir -p "agent/commands"
    acp_copy_framework_file "agent/commands/command.template.md" C
else
    echo "  ↻ would update (tier C): agent/design/*.template.md"
    echo "  ↻ would update (tier C): agent/commands/command.template.md"
fi

# Tier C: framework commands only (P-081-01) — third-party namespaces preserved
for _cmd in "$TEMP_DIR/agent/commands"/acp.*.md "$TEMP_DIR/agent/commands"/git.*.md; do
    [ -e "$_cmd" ] || continue
    _rel="agent/commands/$(basename "$_cmd")"
    acp_copy_framework_file "$_rel" C
done

# Tier C: templates and schemas
for _tpl in progress.template.yaml manifest.template.yaml package.template.yaml; do
    acp_copy_framework_file "agent/${_tpl}" C
done
if [ -d "$TEMP_DIR/agent/schemas" ]; then
    mkdir -p agent/schemas
    for _sch in "$TEMP_DIR/agent/schemas"/*; do
        [ -f "$_sch" ] || continue
        acp_copy_framework_file "agent/schemas/$(basename "$_sch")" C
    done
fi

# Tier C: protocol docs (triple-sync)
if [ -f "$TEMP_DIR/AGENTS.md" ]; then
    acp_copy_framework_file "AGENTS.md" C
elif [ -f "$TEMP_DIR/AGENT.md" ]; then
    if [ "$ACP_DIFF_ONLY" = true ]; then
        echo "  ↻ would update (tier C): AGENTS.md (from AGENT.md)"
    else
        cp "$TEMP_DIR/AGENT.md" "AGENTS.md"
        echo "  ↻ updated: AGENTS.md (from AGENT.md)"
    fi
fi
if [ "$ACP_DIFF_ONLY" = false ] && [ -f "AGENTS.md" ]; then
    cp AGENTS.md CLAUDE.md 2>/dev/null || true
    mkdir -p .github
    cp AGENTS.md .github/copilot-instructions.md 2>/dev/null || true
fi

# Tier C: scripts (self-update — copy after helpers loaded)
if [ -d "$TEMP_DIR/agent/scripts" ]; then
    if [ "$ACP_DIFF_ONLY" = true ]; then
        echo "  ↻ would update (tier C): agent/scripts/*.sh"
    else
        find "$TEMP_DIR/agent/scripts" -maxdepth 1 -name "*.sh" -exec cp {} "agent/scripts/" \;
        chmod +x agent/scripts/*.sh 2>/dev/null || true
        echo "  ↻ updated: agent/scripts/*.sh"
    fi
fi

if [ "$ACP_DIFF_ONLY" = false ]; then
    cleanup_deprecated_scripts
fi

echo ""
echo "Updating ACP Enhanced context layer (tier-aware)..."
mkdir -p agent/core agent/memory agent/routing/tasks agent/skills agent/wiki agent/routing

# Tier B: core
for _f in identity.yml constraints.yml routing.yml; do
    acp_copy_framework_file "agent/core/${_f}" B
done

# Tier B/C skills: skip local.* (P-081-02)
if [ -d "$TEMP_DIR/agent/skills" ]; then
    for _skill in "$TEMP_DIR/agent/skills/"*.md; do
        [ -e "$_skill" ] || continue
        _base=$(basename "$_skill")
        case "$_base" in
            local.*) echo "  ⊘ preserved: agent/skills/${_base}"; continue ;;
        esac
        acp_copy_framework_file "agent/skills/${_base}" C
    done
fi

# Tier B: wiki
for _f in "$TEMP_DIR/agent/wiki/"*.yml "$TEMP_DIR/agent/wiki/"*.md; do
    [ -e "$_f" ] || continue
    acp_copy_framework_file "agent/wiki/$(basename "$_f")" B
done

# Tier B: routing config
for _f in taxonomy.yml rules.md config.yml; do
    acp_copy_framework_file "agent/routing/${_f}" B
done
acp_copy_framework_file "agent/routing/tasks/route-template.md" C

# Tier A: user-state create-if-absent only
if [ "$ACP_DIFF_ONLY" = false ]; then
    [ -f "agent/memory/sessions.md"  ] || echo "# Session Memory"    > agent/memory/sessions.md
    [ -f "agent/memory/lessons.md"   ] || echo "# Lessons Log"       > agent/memory/lessons.md
    [ -f "agent/memory/decisions.md" ] || echo "# ADR Log"           > agent/memory/decisions.md
    [ -f "agent/memory/patterns.md"  ] || echo "# Reusable Patterns" > agent/memory/patterns.md
    [ -f "agent/routing/ledger.md"   ] || echo "# Routing Ledger"    > agent/routing/ledger.md
else
    echo "  ⊘ preserved (tier A): agent/memory/*, agent/progress.yaml"
fi

# Tier C: opencode + cursor commands
if [ "$ACP_DIFF_ONLY" = false ]; then
    if [ -d "$TEMP_DIR/.opencode/commands" ]; then
        mkdir -p .opencode/commands
        cp "$TEMP_DIR/.opencode/commands/"*.md .opencode/commands/ 2>/dev/null || true
    fi
    if [ -f "agent/scripts/acp.cursor-commands-sync.sh" ]; then
        echo "Regenerating Cursor slash commands..."
        bash agent/scripts/acp.cursor-commands-sync.sh 2>/dev/null || echo "${YELLOW}Note: Cursor slash command sync skipped${NC}"
    fi
fi

echo "${GREEN}✓${NC} ACP Enhanced context layer updated"
echo ""

# Tier D: manifest merge only
if [ -f "agent/manifest.yaml" ]; then
    _ver_file="AGENTS.md"
    [ -f "$_ver_file" ] || _ver_file="AGENT.md"
    NEW_VERSION=$(grep -m1 "^\*\*Version\*\*:" "$_ver_file" 2>/dev/null | sed 's/.*: *//' | tr -d '\r')
    if [ -z "$NEW_VERSION" ]; then
        NEW_VERSION=$(grep -m1 '^> v' "$_ver_file" 2>/dev/null | sed 's/^> v//' | cut -d' ' -f1 | tr -d '\r')
    fi
    [ -n "$NEW_VERSION" ] || NEW_VERSION="unknown"
    if [ "$ACP_DIFF_ONLY" = true ]; then
        echo "  ↻ would merge (tier D): agent/manifest.yaml acp-core → v${NEW_VERSION}"
    else
        echo "Updating manifest (tier D merge)..."
        acp_merge_manifest_acp_core "$NEW_VERSION" "agent/manifest.yaml"
        echo "${GREEN}✓${NC} Updated acp-core to v${NEW_VERSION} in manifest.yaml"
    fi
    echo ""
fi

if [ "$_CLEANUP_TEMP" = true ]; then
    rm -rf "$TEMP_DIR"
    trap - EXIT
fi

if [ "$ACP_DIFF_ONLY" = true ]; then
    echo "${GREEN}Dry-run complete — no files modified.${NC}"
    exit 0
fi

echo "${GREEN}Update complete!${NC}"
echo ""
echo "${BLUE}What was updated:${NC}"
echo "  ✓ Framework commands (acp.*, git.* only)"
echo "  ✓ Scripts, schemas, templates"
echo "  ✓ AGENTS.md + sync copies"
echo "  ✓ Unmodified project core/wiki/routing preserved"
echo ""
echo "${BLUE}Next steps:${NC}"
echo "1. Review changes: git diff"
echo "2. Revert if needed: git checkout <file>"
echo ""
display_available_commands
echo ""
echo "${BLUE}For AI agents:${NC}"
echo "Type '${GREEN}/acp-init${NC}' to reload context with updated files."
echo ""
