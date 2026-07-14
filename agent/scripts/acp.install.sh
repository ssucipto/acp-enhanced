#!/bin/bash

# Agent Context Protocol (ACP) Installation Script
# This script sets up the ACP directory structure and template files in a project

set -euo pipefail
trap 'echo "[acp.install] Error on line $LINENO" >&2; exit 1' ERR
trap 'echo "ERROR: $(basename "$0") failed at line $LINENO -- check output above for details." >&2; exit 1' ERR

# Colors for output using tput (more reliable than ANSI codes)
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

# Repository details
REPO_URL="https://github.com/ssucipto/acp-enhanced.git"
BRANCH="mainline"

echo "${GREEN}Agent Context Protocol (ACP) Installer${NC}"
echo "========================================"
echo ""

# Use current directory
TARGET_DIR="$(pwd)"

echo "Installing ACP to: $TARGET_DIR"
echo ""

# Backup + overwrite warning
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${BLUE}  Tier C — framework files refreshed:${NC}"
echo "    • AGENTS.md, CLAUDE.md, copilot-instructions.md"
echo "    • agent/commands/acp.*.md, agent/commands/git.*.md, agent/scripts/*.sh"
echo ""
echo "${BLUE}  Tier B — preserved if customized:${NC}"
echo "    • agent/core/*.yml, agent/wiki/*, agent/routing/taxonomy.yml"
echo "    • agent/skills/local.*.md"
echo ""
echo "${BLUE}  Tier A — never overwritten:${NC}"
echo "    • agent/memory/*, agent/design/*, agent/milestones/*, agent/progress.yaml"
echo "    • agent/preferences/, agent/configurables/"
echo ""
echo "  💡 Backup customized files before continuing:"
echo "    cp AGENTS.md AGENTS.md.bak"
echo "    cp -r agent/commands agent/commands.bak"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if agent directory already exists
if [ -d "$TARGET_DIR/agent" ]; then
    echo "${YELLOW}Note: agent/ directory already exists${NC}"
    echo "All ACP files will be updated to latest versions."
    echo ""
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Cloning ACP repository..."
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR" &>/dev/null; then
    echo "${RED}Error: Failed to clone repository${NC}"
    echo "Please check your internet connection and try again."
    exit 1
fi

echo "${GREEN}✓${NC} Repository cloned"
echo ""

export TEMP_DIR
. "$TEMP_DIR/agent/scripts/acp.common.sh"
init_colors
export ACP_DIFF_ONLY=false ACP_FORCE=false ACP_PRESERVE_PROJECT_CORE=false ACP_YES=true

# ── Legacy .agent/ migration ──────────────────────────────────────────────────
# Detect ACP < 6.x layout and auto-merge user-state files into agent/ before
# the install proceeds. Static files (.agent/core, skills, wiki) are dropped —
# they will be refreshed by the install anyway.
if [ -d "$TARGET_DIR/.agent" ]; then
    echo "${YELLOW}Found legacy .agent/ directory — auto-migrating to agent/ layout...${NC}"

    # User-state memory files (create-if-absent: never overwrite)
    if [ -d "$TARGET_DIR/.agent/memory" ]; then
        mkdir -p "$TARGET_DIR/agent/memory"
        for _f in sessions.md lessons.md decisions.md patterns.md; do
            if [ -f "$TARGET_DIR/.agent/memory/$_f" ] && [ ! -f "$TARGET_DIR/agent/memory/$_f" ]; then
                mv "$TARGET_DIR/.agent/memory/$_f" "$TARGET_DIR/agent/memory/$_f"
                echo "  ✓ Migrated memory/$_f"
            fi
        done
    fi

    # Routing task files (route-NNN.md — user-created, never overwrite)
    if [ -d "$TARGET_DIR/.agent/tasks" ]; then
        mkdir -p "$TARGET_DIR/agent/routing/tasks"
        for _f in "$TARGET_DIR/.agent/tasks/task-"*.md; do
            [ -f "$_f" ] || continue
            _dest="$TARGET_DIR/agent/routing/tasks/$(basename "$_f")"
            if [ ! -f "$_dest" ]; then
                mv "$_f" "$_dest"
                echo "  ✓ Migrated routing/tasks/$(basename "$_f")"
            fi
        done
    fi

    # Routing ledger (user-state — never overwrite)
    if [ -f "$TARGET_DIR/.agent/routing/ledger.md" ] && [ ! -f "$TARGET_DIR/agent/routing/ledger.md" ]; then
        mkdir -p "$TARGET_DIR/agent/routing"
        mv "$TARGET_DIR/.agent/routing/ledger.md" "$TARGET_DIR/agent/routing/ledger.md"
        echo "  ✓ Migrated routing/ledger.md"
    fi

    rm -rf "$TARGET_DIR/.agent"
    echo "${GREEN}✓${NC} Legacy .agent/ merged and removed"
    echo ""
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$TARGET_DIR/agent/design"
mkdir -p "$TARGET_DIR/agent/milestones"
mkdir -p "$TARGET_DIR/agent/patterns"
mkdir -p "$TARGET_DIR/agent/tasks"
mkdir -p "$TARGET_DIR/agent/commands"
mkdir -p "$TARGET_DIR/agent/scripts"
mkdir -p "$TARGET_DIR/agent/schemas"
mkdir -p "$TARGET_DIR/agent/reports"
mkdir -p "$TARGET_DIR/agent/drafts"
mkdir -p "$TARGET_DIR/agent/clarifications"
mkdir -p "$TARGET_DIR/agent/feedback"
mkdir -p "$TARGET_DIR/agent/preferences"
mkdir -p "$TARGET_DIR/agent/index"
mkdir -p "$TARGET_DIR/agent/specs"
mkdir -p "$TARGET_DIR/agent/artifacts"
mkdir -p "$TARGET_DIR/agent/configurables"
mkdir -p "$TARGET_DIR/agent/benchmarks/runner"
mkdir -p "$TARGET_DIR/agent/benchmarks/suite"

# Create .gitkeep files
touch "$TARGET_DIR/agent/design/.gitkeep"
touch "$TARGET_DIR/agent/milestones/.gitkeep"
touch "$TARGET_DIR/agent/patterns/.gitkeep"
touch "$TARGET_DIR/agent/tasks/.gitkeep"
touch "$TARGET_DIR/agent/clarifications/.gitkeep"
touch "$TARGET_DIR/agent/drafts/.gitkeep"
touch "$TARGET_DIR/agent/index/.gitkeep"
touch "$TARGET_DIR/agent/specs/.gitkeep"
touch "$TARGET_DIR/agent/artifacts/.gitkeep"

# Create agent/.gitignore to exclude local-only directories from version control
cat > "$TARGET_DIR/agent/.gitignore" << 'EOF'
# Agent Context Protocol - Local Files
# These files are generated locally and should not be committed

# Reports directory - generated by /acp-report command
reports/
clarifications/
feedback/
drafts/**
!drafts/.gitkeep
!drafts/draft.template.md
preferences/
EOF

echo "${GREEN}✓${NC} Directory structure created"
echo ""

# ACP Enhanced — context loading layer
echo "Installing ACP Enhanced context layer..."
mkdir -p "$TARGET_DIR/agent/core"
mkdir -p "$TARGET_DIR/agent/memory"
mkdir -p "$TARGET_DIR/agent/routing/tasks"
mkdir -p "$TARGET_DIR/agent/skills"
mkdir -p "$TARGET_DIR/agent/wiki"

# Copy static config files (tier-aware — preserve customized Tier B on reinstall)
(
    cd "$TARGET_DIR"
    for _f in identity.yml constraints.yml routing.yml; do
        acp_copy_framework_file "agent/core/${_f}" B
    done
    if [ -d "$TEMP_DIR/agent/skills" ]; then
        for _skill_file in "$TEMP_DIR/agent/skills/"*.md; do
            [ -e "$_skill_file" ] || continue
            _skill_basename=$(basename "$_skill_file")
            case "$_skill_basename" in
                local.*) continue ;;
            esac
            acp_copy_framework_file "agent/skills/${_skill_basename}" C
        done
    fi
    if [ -d "$TEMP_DIR/agent/wiki" ]; then
        for _wf in "$TEMP_DIR/agent/wiki/"*; do
            [ -e "$_wf" ] || continue
            acp_copy_framework_file "agent/wiki/$(basename "$_wf")" B
        done
    fi
    if [ -d "$TEMP_DIR/agent/routing" ]; then
        for _rf in taxonomy.yml rules.md config.yml; do
            acp_copy_framework_file "agent/routing/${_rf}" B
        done
        acp_copy_framework_file "agent/routing/tasks/route-template.md" C
    fi
)
if [ -d "$TEMP_DIR/.opencode/commands" ]; then
    mkdir -p "$TARGET_DIR/.opencode/commands"
    cp "$TEMP_DIR/.opencode/commands/"*.md "$TARGET_DIR/.opencode/commands/" 2>/dev/null || true
fi
# Generate Cursor slash commands (.cursor/commands/) from installed command docs
if [ -f "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh" ]; then
    echo "Generating Cursor slash commands..."
    chmod +x "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh"
    (cd "$TARGET_DIR" && bash agent/scripts/acp.cursor-commands-sync.sh)
fi

# Create user-state files only if absent (never overwrite existing state)
_create_if_absent() {
    local file="$1"; local content="$2"
    [ -f "$file" ] || printf '%s\n' "$content" > "$file"
}
_create_if_absent "$TARGET_DIR/agent/memory/sessions.md" \
    "# Session Memory\n# Created by acp.install.sh — do not delete"
_create_if_absent "$TARGET_DIR/agent/memory/lessons.md" \
    "# Lessons Log\n# Created by acp.install.sh — do not delete"
_create_if_absent "$TARGET_DIR/agent/memory/decisions.md" \
    "# Architecture Decision Records (ADR Log)\n# Add entries via /acp-decide command"
_create_if_absent "$TARGET_DIR/agent/memory/patterns.md" \
    "# Reusable Patterns\n# Created by acp.install.sh — do not delete"
_create_if_absent "$TARGET_DIR/agent/routing/ledger.md" \
    "# Routing Cost Ledger\n# Appended by acp-dispatch.ts on each task run"

echo "${GREEN}✓${NC} ACP Enhanced context layer installed"
echo ""

# Copy files
echo "Installing ACP files..."

# Copy template files (only .template.md files from these directories)
find "$TEMP_DIR/agent/design" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/design/" \;
find "$TEMP_DIR/agent/milestones" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/milestones/" \;
find "$TEMP_DIR/agent/patterns" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/patterns/" \;
find "$TEMP_DIR/agent/tasks" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/tasks/" \;
find "$TEMP_DIR/agent/clarifications" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/clarifications/" \;

# Copy specs template
if [ -d "$TEMP_DIR/agent/specs" ]; then
    find "$TEMP_DIR/agent/specs" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/specs/" \;
fi

# Copy artifact templates
if [ -d "$TEMP_DIR/agent/artifacts" ]; then
    find "$TEMP_DIR/agent/artifacts" -maxdepth 1 -name "*.template.md" -exec cp {} "$TARGET_DIR/agent/artifacts/" \;
fi

# Copy drafts template (idempotent — only if absent)
if [ -d "$TEMP_DIR/agent/drafts" ] && [ ! -f "$TARGET_DIR/agent/drafts/draft.template.md" ]; then
    cp "$TEMP_DIR/agent/drafts/draft.template.md" "$TARGET_DIR/agent/drafts/draft.template.md" 2>/dev/null || true
fi

# Copy configurables (preference schema definitions)
if [ -d "$TEMP_DIR/agent/configurables" ]; then
    find "$TEMP_DIR/agent/configurables" -maxdepth 1 -name "acp.*.yaml" -exec cp {} "$TARGET_DIR/agent/configurables/" \;
fi

# Copy benchmark runner scripts
if [ -d "$TEMP_DIR/agent/benchmarks/runner" ]; then
    find "$TEMP_DIR/agent/benchmarks/runner" -maxdepth 1 -type f -exec cp {} "$TARGET_DIR/agent/benchmarks/runner/" \;
    chmod +x "$TARGET_DIR/agent/benchmarks/runner/"*.sh 2>/dev/null || true
fi

# Copy benchmark suite scenarios
if [ -d "$TEMP_DIR/agent/benchmarks/suite" ]; then
    cp -r "$TEMP_DIR/agent/benchmarks/suite/"* "$TARGET_DIR/agent/benchmarks/suite/" 2>/dev/null || true
fi

# Copy index template files
if [ -d "$TEMP_DIR/agent/index" ]; then
    find "$TEMP_DIR/agent/index" -maxdepth 1 -name "*.template.yaml" -exec cp {} "$TARGET_DIR/agent/index/" \;
fi

# Copy bundled index files (e.g. acp.core.yaml)
if [ -d "$TEMP_DIR/agent/index" ]; then
    find "$TEMP_DIR/agent/index" -maxdepth 1 -name "*.yaml" ! -name "*.template.yaml" ! -name "local.*" -exec cp {} "$TARGET_DIR/agent/index/" \;
fi

# Copy command template
cp "$TEMP_DIR/agent/commands/command.template.md" "$TARGET_DIR/agent/commands/"

# Tier C: framework commands only — preserve third-party namespaces (P-081-01)
if [ -d "$TEMP_DIR/agent/commands" ]; then
    for _cmd in "$TEMP_DIR/agent/commands"/acp.*.md "$TEMP_DIR/agent/commands"/git.*.md; do
        [ -e "$_cmd" ] || continue
        cp "$_cmd" "$TARGET_DIR/agent/commands/"
    done
fi

# Copy progress template
if [ -f "$TEMP_DIR/agent/progress.template.yaml" ]; then
    cp "$TEMP_DIR/agent/progress.template.yaml" "$TARGET_DIR/agent/"
fi

# Copy manifest template
if [ -f "$TEMP_DIR/agent/manifest.template.yaml" ]; then
    cp "$TEMP_DIR/agent/manifest.template.yaml" "$TARGET_DIR/agent/"
fi

# Copy package template
if [ -f "$TEMP_DIR/agent/package.template.yaml" ]; then
    cp "$TEMP_DIR/agent/package.template.yaml" "$TARGET_DIR/agent/"
fi

# Create initial manifest.yaml if it doesn't exist
if [ ! -f "$TARGET_DIR/agent/manifest.yaml" ]; then
    cat > "$TARGET_DIR/agent/manifest.yaml" << 'EOF'
# ACP Package Manifest
# Tracks installed packages and their versions

packages: {}

manifest_version: 1.0.0
last_updated: null
EOF
fi

# Copy schemas
if [ -f "$TEMP_DIR/agent/schemas/package.schema.yaml" ]; then
    cp "$TEMP_DIR/agent/schemas/package.schema.yaml" "$TARGET_DIR/agent/schemas/"
fi

# Entry docs (tier C) — prefer AGENTS.md; keep AGENT.md for legacy consumers
if [ -f "$TEMP_DIR/AGENTS.md" ]; then
    cp "$TEMP_DIR/AGENTS.md" "$TARGET_DIR/"
    cp "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/CLAUDE.md" 2>/dev/null || true
    mkdir -p "$TARGET_DIR/.github"
    cp "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/.github/copilot-instructions.md" 2>/dev/null || true
fi
if [ -f "$TEMP_DIR/AGENT.md" ]; then
    cp "$TEMP_DIR/AGENT.md" "$TARGET_DIR/"
fi

# Copy scripts - selective installation based on command dependencies
if [ -d "$TEMP_DIR/agent/scripts" ]; then
    # Check if this is ACP core (has package.yaml) or direct install
    if [ -f "$TEMP_DIR/package.yaml" ]; then
        # ACP core with package.yaml - selective script installation
        echo "Resolving script dependencies from package.yaml..."
        
        # Copy YAML parser first (needed for parsing)
        if [ -f "$TEMP_DIR/agent/scripts/acp.yaml-parser.sh" ]; then
            cp "$TEMP_DIR/agent/scripts/acp.yaml-parser.sh" "$TARGET_DIR/agent/scripts/"
            chmod +x "$TARGET_DIR/agent/scripts/acp.yaml-parser.sh"
        fi
        
        # Copy common utilities first (needed for parsing)
        if [ -f "$TEMP_DIR/agent/scripts/acp.common.sh" ]; then
            cp "$TEMP_DIR/agent/scripts/acp.common.sh" "$TARGET_DIR/agent/scripts/"
            chmod +x "$TARGET_DIR/agent/scripts/acp.common.sh"
        fi
        
        # Source YAML parser for querying
        if [ -f "$TARGET_DIR/agent/scripts/acp.yaml-parser.sh" ]; then
            . "$TARGET_DIR/agent/scripts/acp.yaml-parser.sh"
            yaml_parse "$TEMP_DIR/package.yaml"
        fi
        
        # Find all NON-experimental commands and collect their scripts
        PACKAGE_COMMANDS=()
        REQUIRED_SCRIPTS=()
        cmd_index=0
        MAX_ITERATIONS=200  # safety cap — prevents infinite loop on Windows Git Bash
        while true; do
            if [ "$cmd_index" -gt "$MAX_ITERATIONS" ]; then
                echo "ERROR: yaml_query loop exceeded $MAX_ITERATIONS iterations — falling back to copy-all" >&2
                break 2  # break out of outer loop, fall through to copy-all path
            fi
            cmd_name=$(yaml_query ".contents.commands[$cmd_index].name" 2>/dev/null || echo "")
            if [ -z "$cmd_name" ] || [ "$cmd_name" = "null" ]; then
                break
            fi

            # Check if command is experimental
            is_exp=$(yaml_query ".contents.commands[$cmd_index].experimental" 2>/dev/null || echo "false")
            if [ "$is_exp" != "true" ]; then
                PACKAGE_COMMANDS+=("$cmd_name")

                # Collect scripts for this command
                script_index=0
                SCRIPT_MAX=50  # safety cap
                while true; do
                    if [ "$script_index" -gt "$SCRIPT_MAX" ]; then
                        echo "WARN: script loop exceeded $SCRIPT_MAX — breaking" >&2
                        break
                    fi
                    script=$(yaml_query ".contents.commands[$cmd_index].scripts[$script_index]" 2>/dev/null || echo "")
                    if [ -z "$script" ] || [ "$script" = "null" ]; then
                        break
                    fi

                    # Add to required scripts (with deduplication)
                    already_added=false
                    for existing in "${REQUIRED_SCRIPTS[@]}"; do
                        if [ "$existing" = "$script" ]; then
                            already_added=true
                            break
                        fi
                    done

                    if [ "$already_added" = false ]; then
                        REQUIRED_SCRIPTS+=("$script")
                    fi

                    script_index=$((script_index + 1))
                done
            fi

            cmd_index=$((cmd_index + 1))
        done
        
        # Install required scripts (excluding common.sh and yaml-parser.sh already copied)
        for script in "${REQUIRED_SCRIPTS[@]}"; do
            if [ "$script" = "acp.common.sh" ] || [ "$script" = "acp.yaml-parser.sh" ]; then
                continue  # Already copied
            fi

            if [ -f "$TEMP_DIR/agent/scripts/$script" ]; then
                # Check if script is experimental by finding it in contents.scripts
                is_exp="false"
                script_check_index=0
                SCRIPT_CHK_MAX=100  # safety cap
                while true; do
                    if [ "$script_check_index" -gt "$SCRIPT_CHK_MAX" ]; then
                        echo "WARN: script check loop exceeded $SCRIPT_CHK_MAX" >&2
                        break
                    fi
                    s_name=$(yaml_query ".contents.scripts[$script_check_index].name" 2>/dev/null || echo "")
                    if [ -z "$s_name" ] || [ "$s_name" = "null" ]; then
                        break
                    fi
                    if [ "$s_name" = "$script" ]; then
                        is_exp=$(yaml_query ".contents.scripts[$script_check_index].experimental" 2>/dev/null || echo "false")
                        break
                    fi
                    script_check_index=$((script_check_index + 1))
                done
                if [ "$is_exp" != "true" ]; then
                    cp "$TEMP_DIR/agent/scripts/$script" "$TARGET_DIR/agent/scripts/"
                    chmod +x "$TARGET_DIR/agent/scripts/$script"
                fi
            fi
        done

        echo "${GREEN}✓${NC} Installed ${#REQUIRED_SCRIPTS[@]} required script(s)"
    else
        # Direct install mode (no package.yaml) - copy all scripts
        find "$TEMP_DIR/agent/scripts" -maxdepth 1 -name "*.sh" -exec cp {} "$TARGET_DIR/agent/scripts/" \;
        chmod +x "$TARGET_DIR/agent/scripts"/*.sh 2>/dev/null || true
        echo "${GREEN}✓${NC} Installed all scripts"
    fi
fi

# Clean up deprecated scripts (from versions < 2.0.0)
init_colors
cleanup_deprecated_scripts

echo "${GREEN}✓${NC} All files installed"
echo ""

# Create manifest (tier D merge — preserve third-party packages)
echo "Creating manifest..."
_ver_file="AGENTS.md"
[ -f "$TARGET_DIR/AGENTS.md" ] || _ver_file="AGENT.md"
ACP_VERSION=$(grep -m1 "^\*\*Version\*\*:" "$TARGET_DIR/$_ver_file" 2>/dev/null | sed 's/.*: *//' | tr -d '\r')
if [ -z "$ACP_VERSION" ]; then
    ACP_VERSION=$(grep -m1 '^> v' "$TARGET_DIR/$_ver_file" 2>/dev/null | sed 's/^> v//' | cut -d' ' -f1 | tr -d '\r')
fi
[ -n "$ACP_VERSION" ] || ACP_VERSION="unknown"
acp_install_manifest_acp_core "$TARGET_DIR" "$ACP_VERSION"

echo "${GREEN}✓${NC} Updated manifest.yaml (tracking acp-core v${ACP_VERSION})"
echo ""
echo "${GREEN}Installation complete! (ACP Enhanced v${ACP_VERSION})${NC}"
echo ""
echo "${GREEN}What was installed:${NC}"
echo "  ✓ ACP command docs, scripts, schemas"
echo "  ✓ ACP Enhanced context layer (agent/core/, agent/skills/, agent/wiki/, agent/routing/)"
echo ""
echo "${GREEN}Next steps:${NC}"
echo "1. Create your requirements document:"
echo "   cp agent/design/requirements.template.md agent/design/requirements.md"
echo ""
echo "2. Define your first milestone:"
echo "   cp agent/milestones/milestone-1-{title}.template.md agent/milestones/milestone-1-foundation.md"
echo ""
echo "3. Initialize progress tracking:"
echo "   cp agent/progress.template.yaml agent/progress.yaml"
echo ""
echo "4. Read AGENTS.md for complete documentation"
echo ""
display_available_commands
echo ""
echo "${BLUE}For AI agents:${NC}"
echo "Type '${GREEN}/acp-init${NC}' to get started."
echo ""

# Post-install verification
_CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
_SCRIPT_COUNT=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${BLUE}  Post-Install Verification${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
[ "$_CMD_COUNT" -ge 40 ] && echo "${GREEN}✅ agent/commands/: $_CMD_COUNT files${NC}" || echo "${RED}❌ agent/commands/: $_CMD_COUNT files (expected 40+)${NC}"
[ "$_SCRIPT_COUNT" -ge 20 ] && echo "${GREEN}✅ agent/scripts/: $_SCRIPT_COUNT files${NC}" || echo "${RED}❌ agent/scripts/: $_SCRIPT_COUNT files (expected 20+)${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
