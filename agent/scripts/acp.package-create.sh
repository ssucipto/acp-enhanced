#!/bin/bash

# ACP Package Creator
# Interactive wizard to create a new ACP package

set -e

# Source common utilities
SCRIPT_DIR="$(dirname "$0")"
. "${SCRIPT_DIR}/acp.common.sh"

# Initialize colors
init_colors

echo "${BLUE}📦 ACP Package Creator${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Let's create a new ACP package!"
echo ""

# Step 1: Gather package information
echo "${BOLD}Package Information${NC}"
echo ""

# Package name
read -p "Package name (lowercase, no spaces): " PACKAGE_NAME
if [ -z "$PACKAGE_NAME" ]; then
    echo "${RED}Error: Package name is required${NC}"
    exit 1
fi

# Validate package name (lowercase, alphanumeric, hyphens only)
if ! echo "$PACKAGE_NAME" | grep -qE '^[a-z0-9-]+$'; then
    echo "${RED}Error: Package name must be lowercase letters, numbers, and hyphens only${NC}"
    exit 1
fi

# Description
read -p "Description: " DESCRIPTION
if [ -z "$DESCRIPTION" ]; then
    echo "${RED}Error: Description is required${NC}"
    exit 1
fi

# Author
read -p "Author name: " AUTHOR
if [ -z "$AUTHOR" ]; then
    echo "${RED}Error: Author name is required${NC}"
    exit 1
fi

# License
read -p "License [MIT]: " LICENSE
LICENSE=${LICENSE:-MIT}

# Homepage
read -p "Homepage URL (optional): " HOMEPAGE

# Repository URL (will be filled in later)
read -p "Repository URL (e.g., https://github.com/username/acp-${PACKAGE_NAME}.git): " REPO_URL

# Tags
read -p "Tags (comma-separated): " TAGS_INPUT

# Convert tags to array
IFS=',' read -ra TAGS_ARRAY <<< "$TAGS_INPUT"

# Target directory (optional)
read -p "Target directory (default: current directory): " TARGET_DIR

# Expand path (handle ~, $HOME, and relative paths)
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="."
else
    # Expand ~ to home directory
    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
    # Expand $HOME
    TARGET_DIR=$(eval echo "$TARGET_DIR")
fi

# Convert to absolute path
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

echo ""
echo "${GREEN}✓${NC} Package information collected"
echo ""

# Step 2: Create directory structure
PACKAGE_DIR="${TARGET_DIR}/acp-${PACKAGE_NAME}"

if [ -d "$PACKAGE_DIR" ]; then
    echo "${RED}Error: Directory $PACKAGE_DIR already exists${NC}"
    exit 1
fi

echo "${BOLD}Creating Directory Structure${NC}"
echo ""

mkdir -p "$PACKAGE_DIR/agent/patterns"
mkdir -p "$PACKAGE_DIR/agent/commands"
mkdir -p "$PACKAGE_DIR/agent/design"

touch "$PACKAGE_DIR/agent/patterns/.gitkeep"
touch "$PACKAGE_DIR/agent/commands/.gitkeep"
touch "$PACKAGE_DIR/agent/design/.gitkeep"

echo "${GREEN}✓${NC} Created directory: $PACKAGE_DIR/"
echo "${GREEN}✓${NC} Created agent/ structure"

# Step 3: Create package.yaml
echo ""
echo "${BOLD}Creating package.yaml${NC}"
echo ""

# Convert tags array to YAML list
TAGS_YAML=""
for tag in "${TAGS_ARRAY[@]}"; do
    # Trim whitespace
    tag=$(echo "$tag" | xargs)
    TAGS_YAML="${TAGS_YAML}  - ${tag}\n"
done

cat > "$PACKAGE_DIR/package.yaml" << EOF
# package.yaml
name: ${PACKAGE_NAME}
version: 1.0.0
description: ${DESCRIPTION}
author: ${AUTHOR}
license: ${LICENSE}
homepage: ${HOMEPAGE}
repository: ${REPO_URL}

# Package contents
# Add files here as you create them
contents:
  patterns: []
  
  commands: []
  
  designs: []

# Dependencies (other ACP packages required)
dependencies: []

# Compatibility
requires:
  acp: ">=2.0.0"

# Tags for discovery
tags:
$(echo -e "$TAGS_YAML")
EOF

echo "${GREEN}✓${NC} Created package.yaml"

# Step 4: Create README.md
echo ""
echo "${BOLD}Creating Documentation${NC}"
echo ""

cat > "$PACKAGE_DIR/README.md" << EOF
# ACP Package: ${PACKAGE_NAME}

${DESCRIPTION}

## Installation

\`\`\`bash
@acp.package-install ${REPO_URL}
\`\`\`

Or using the installation script:

\`\`\`bash
./agent/scripts/acp.package-install.sh ${REPO_URL}
\`\`\`

## Contents

### Patterns

(List patterns here as you add them)

### Commands

(List commands here as you add them)

### Designs

(List design documents here as you add them)

## Usage

(Add usage examples here)

## Dependencies

(List any required packages or project dependencies)

## Contributing

Contributions are welcome! Please:

1. Follow the existing pattern structure
2. Update \`package.yaml\` when adding files
3. Document your changes in CHANGELOG.md
4. Test installation before submitting

## License

${LICENSE}

## Author

${AUTHOR}
EOF

echo "${GREEN}✓${NC} Created README.md"

# Step 5: Create LICENSE
cat > "$PACKAGE_DIR/LICENSE" << 'EOF'
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

echo "${GREEN}✓${NC} Created LICENSE (MIT)"

# Step 6: Create CHANGELOG.md
CURRENT_DATE=$(date +%Y-%m-%d)

cat > "$PACKAGE_DIR/CHANGELOG.md" << EOF
# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - ${CURRENT_DATE}

### Added
- Initial release
- Package structure created
EOF

echo "${GREEN}✓${NC} Created CHANGELOG.md"

# Step 7: Create .gitignore
cat > "$PACKAGE_DIR/.gitignore" << 'EOF'
# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo

# Temporary files
*.tmp
*.log

# Node modules (if applicable)
node_modules/

# Python (if applicable)
__pycache__/
*.pyc
.venv/
venv/

# Build artifacts
dist/
build/
EOF

echo "${GREEN}✓${NC} Created .gitignore"

# Step 8: Initialize git repository
echo ""
echo "${BOLD}Initializing Git Repository${NC}"
echo ""

cd "$PACKAGE_DIR"
git init -q
git add .
git commit -q -m "chore: initialize ACP package"

echo "${GREEN}✓${NC} Initialized git repository"
echo "${GREEN}✓${NC} Created initial commit"

cd ..

# Step 9: Ask about example files
echo ""
read -p "Would you like to create example files? (y/N): " CREATE_EXAMPLES

if [[ "$CREATE_EXAMPLES" =~ ^[Yy]$ ]]; then
    echo ""
    echo "${BOLD}Creating Example Files${NC}"
    echo ""
    
    # Example pattern
    cat > "$PACKAGE_DIR/agent/patterns/example-pattern.md" << 'EOF'
# Example Pattern

**Version**: 1.0.0
**Last Updated**: 2026-02-20

---

## Overview

[Describe what this pattern is and when to use it]

## Problem

[What problem does this pattern solve?]

## Solution

[How does this pattern solve the problem?]

## Implementation

[Code examples and implementation details]

```typescript
// Example code
```

## Benefits

[Why use this pattern?]

## Trade-offs

[What are the downsides?]

---

**Status**: Example
**Recommendation**: Replace with your actual pattern
EOF
    
    echo "${GREEN}✓${NC} Created agent/patterns/example-pattern.md"
    
    # Example command
    cat > "$PACKAGE_DIR/agent/commands/example-command.md" << 'EOF'
# Command: example-command

> **🤖 Agent Directive**: If you are reading this file, the command `@example-command` has been invoked.

**Namespace**: example
**Version**: 1.0.0
**Created**: 2026-02-20
**Status**: Example

---

**Purpose**: [One-line description of what this command does]
**Category**: [Workflow | Documentation | Maintenance | Creation]
**Frequency**: [Once | Per Session | As Needed]

---

## What This Command Does

[Detailed explanation of the command's purpose and when to use it]

---

## Prerequisites

- [ ] Prerequisite 1
- [ ] Prerequisite 2

---

## Steps

### 1. Step Name

[Description]

**Actions**:
- Action 1
- Action 2

**Expected Outcome**: [What should happen]

---

## Verification

- [ ] Verification item 1
- [ ] Verification item 2

---

**Status**: Example
**Recommendation**: Replace with your actual command
EOF
    
    echo "${GREEN}✓${NC} Created agent/commands/example-command.md"
    
    # Example design
    cat > "$PACKAGE_DIR/agent/design/example-design.md" << 'EOF'
# Example Design Document

**Concept**: [One-line description]
**Created**: 2026-02-20
**Status**: Example

---

## Overview

[High-level description of what this is and why it exists]

## Problem Statement

[What problem does this solve?]

## Solution

[How does this solve the problem?]

## Implementation

[Technical details, code examples, schemas]

## Benefits

[Why this approach is better than alternatives]

## Trade-offs

[What are the downsides or limitations?]

---

**Status**: Example
**Recommendation**: Replace with your actual design document
EOF
    
    echo "${GREEN}✓${NC} Created agent/design/example-design.md"
    
    # Commit example files
    cd "$PACKAGE_DIR"
    git add .
    git commit -q -m "docs: add example files"
    cd ..
fi

# Step 10: Display success message and next steps
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${GREEN}🎉 Package Created Successfully!${NC}"
echo ""
echo "Your ACP package is ready at: ${BOLD}${PACKAGE_DIR}${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${BOLD}📋 Next Steps:${NC}"
echo ""
echo "1. ${BOLD}Add your content:${NC}"
echo "   - Add patterns to agent/patterns/"
echo "   - Add commands to agent/commands/"
echo "   - Add designs to agent/design/"
echo ""
echo "2. ${BOLD}Update package.yaml:${NC}"
echo "   - Add each file to the contents section"
echo "   - Specify version for each file"
echo "   - Add dependencies if needed"
echo ""
echo "   Example:"
echo "   ${YELLOW}contents:"
echo "     patterns:"
echo "       - name: my-pattern.md"
echo "         version: 1.0.0"
echo "         description: My pattern description${NC}"
echo ""
echo "3. ${BOLD}Create GitHub repository:${NC}"
echo "   - Go to https://github.com/new"
echo "   - Name: acp-${PACKAGE_NAME}"
echo "   - Description: ${DESCRIPTION}"
echo "   - Create repository"
echo ""
echo "4. ${BOLD}Push to GitHub:${NC}"
echo "   ${YELLOW}cd acp-${PACKAGE_NAME}"
echo "   git remote add origin ${REPO_URL}"
echo "   git branch -M main"
echo "   git push -u origin main${NC}"
echo ""
echo "5. ${BOLD}Add GitHub topic for discoverability:${NC}"
echo "   - Go to repository settings"
echo "   - Add topic: ${YELLOW}acp-package${NC}"
echo "   - Add other topics: ${TAGS_INPUT}"
echo ""
echo "6. ${BOLD}Test installation:${NC}"
echo "   ${YELLOW}@acp.package-install ${REPO_URL}${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${BOLD}📚 Resources:${NC}"
echo ""
echo "- Package structure guide: See AGENT.md in agent-context-protocol"
echo "- package.yaml reference: agent/design/acp-package-management-system.md"
echo "- Example packages: https://github.com/prmichaelsen?tab=repositories&q=acp-"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${GREEN}✅ Package creation complete!${NC}"
echo ""
