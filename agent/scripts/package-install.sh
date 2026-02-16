#!/bin/bash

# Agent Context Protocol (ACP) Package Install Script
# Installs third-party ACP packages (commands, patterns, designs, etc.) from git repositories

set -e

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

# Parse arguments
SKIP_CONFIRM=false
REPO_URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            REPO_URL="$1"
            shift
            ;;
    esac
done

# Check if repository URL provided
if [ -z "$REPO_URL" ]; then
    echo "${RED}Error: Repository URL required${NC}"
    echo "Usage: $0 [-y|--yes] <repository-url>"
    echo ""
    echo "Options:"
    echo "  -y, --yes    Skip confirmation prompts"
    echo ""
    echo "Example: $0 https://github.com/example/acp-package.git"
    echo "Example: $0 -y https://github.com/example/acp-package.git"
    exit 1
fi

echo "${BLUE}📦 ACP Package Installer${NC}"
echo "========================================"
echo ""
echo "Repository: $REPO_URL"
echo ""

# Validate URL format
if [[ ! "$REPO_URL" =~ ^https?:// ]]; then
    echo "${RED}Error: Invalid repository URL${NC}"
    echo "URL must start with http:// or https://"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Cloning repository..."
if ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &>/dev/null; then
    echo "${RED}Error: Failed to clone repository${NC}"
    echo "Please check the URL and your internet connection."
    exit 1
fi

echo "${GREEN}✓${NC} Repository cloned"
echo ""

# Check if repository has agent/ directory
if [ ! -d "$TEMP_DIR/agent" ]; then
    echo "${RED}Error: No agent/ directory found${NC}"
    echo "Repository must contain an 'agent/' directory with ACP files"
    exit 1
fi

# Directories to install from
INSTALL_DIRS=("commands" "patterns" "design")
INSTALLED_COUNT=0
SKIPPED_COUNT=0

echo "Scanning for installable files..."
echo ""

# Process each directory
for dir in "${INSTALL_DIRS[@]}"; do
    SOURCE_DIR="$TEMP_DIR/agent/$dir"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        continue
    fi
    
    # Find files (exclude templates and .gitkeep)
    FILES=$(find "$SOURCE_DIR" -maxdepth 1 -name "*.md" ! -name "*.template.md" -type f)
    
    if [ -z "$FILES" ]; then
        continue
    fi
    
    FILE_COUNT=$(echo "$FILES" | wc -l)
    echo "${BLUE}📁 $dir/${NC} ($FILE_COUNT file(s))"
    
    # Validate and list files
    while IFS= read -r file; do
        filename=$(basename "$file")
        
        # Special validation for commands
        if [ "$dir" = "commands" ]; then
            # Check for reserved 'acp' namespace
            if [[ "$filename" =~ ^acp\. ]]; then
                echo "  ${RED}✗${NC} $filename (reserved namespace 'acp')"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
            
            # Check for agent directive
            if ! grep -q "🤖 Agent Directive" "$file"; then
                echo "  ${YELLOW}⚠${NC}  $filename (missing agent directive - skipping)"
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                continue
            fi
        fi
        
        # Check for conflicts
        if [ -f "agent/$dir/$filename" ]; then
            echo "  ${YELLOW}⚠${NC}  $filename (will overwrite existing)"
        else
            echo "  ${GREEN}✓${NC} $filename"
        fi
        
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    done <<< "$FILES"
    
    echo ""
done

# Exit if nothing to install
if [ $INSTALLED_COUNT -eq 0 ]; then
    echo "${RED}Error: No valid files to install${NC}"
    if [ $SKIPPED_COUNT -gt 0 ]; then
        echo "Skipped $SKIPPED_COUNT file(s) due to validation failures"
    fi
    exit 1
fi

# Confirm installation
echo "Ready to install $INSTALLED_COUNT file(s)"
if [ $SKIPPED_COUNT -gt 0 ]; then
    echo "($SKIPPED_COUNT file(s) will be skipped)"
fi
echo ""

if [ "$SKIP_CONFIRM" = false ]; then
    read -p "Proceed with installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
else
    echo "Auto-confirming installation (-y flag)"
fi

echo ""
echo "Installing files..."

# Install files from each directory
for dir in "${INSTALL_DIRS[@]}"; do
    SOURCE_DIR="$TEMP_DIR/agent/$dir"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        continue
    fi
    
    # Create target directory
    mkdir -p "agent/$dir"
    
    # Find and copy files
    FILES=$(find "$SOURCE_DIR" -maxdepth 1 -name "*.md" ! -name "*.template.md" -type f)
    
    if [ -z "$FILES" ]; then
        continue
    fi
    
    while IFS= read -r file; do
        filename=$(basename "$file")
        
        # Skip invalid files
        if [ "$dir" = "commands" ]; then
            if [[ "$filename" =~ ^acp\. ]] || ! grep -q "🤖 Agent Directive" "$file"; then
                continue
            fi
        fi
        
        # Copy file
        cp "$file" "agent/$dir/$filename"
        echo "  ${GREEN}✓${NC} Installed $dir/$filename"
    done <<< "$FILES"
done

echo ""
echo "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Installed $INSTALLED_COUNT file(s) from:"
echo "  $REPO_URL"
echo ""

# List installed commands
if [ -d "$TEMP_DIR/agent/commands" ]; then
    COMMANDS=$(find "$TEMP_DIR/agent/commands" -maxdepth 1 -name "*.*.md" ! -name "*.template.md" -type f)
    if [ -n "$COMMANDS" ]; then
        echo "Installed commands:"
        while IFS= read -r cmd_file; do
            cmd_name=$(basename "$cmd_file" .md)
            if [[ ! "$cmd_name" =~ ^acp\. ]]; then
                invocation="@${cmd_name}"
                echo "  - $invocation"
            fi
        done <<< "$COMMANDS"
        echo ""
    fi
fi

echo "${YELLOW}⚠️  Security Reminder:${NC}"
echo "Review installed files before using them."
echo "Third-party files can instruct agents to modify files and execute scripts."
echo ""
echo "Next steps:"
echo "  1. Review installed files in agent/ directories"
echo "  2. Test installed commands"
echo "  3. Update progress.yaml with installation notes"
echo ""
