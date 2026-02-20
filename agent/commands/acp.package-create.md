# Command: package-create

> **🤖 Agent Directive**: If you are reading this file, the command `@acp.package-create` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp
**Version**: 1.0.0
**Created**: 2026-02-20
**Last Updated**: 2026-02-20
**Status**: Active

---

**Purpose**: Interactive wizard to create a new ACP package from scratch
**Category**: Creation
**Frequency**: Once per package

---

## What This Command Does

This command provides a step-by-step wizard to help users create a new ACP package. It guides through:

1. **Project Setup** - Initialize directory structure and git repository
2. **Package Metadata** - Create `package.yaml` with package information
3. **Content Creation** - Set up patterns, commands, and designs directories
4. **Documentation** - Generate README.md and CHANGELOG.md
5. **GitHub Setup** - Instructions for publishing to GitHub

Unlike manually creating files, this wizard ensures:
- Correct directory structure
- Valid `package.yaml` format
- Proper GitHub topics for discoverability
- Complete documentation templates
- Best practices followed

Use this command when starting a new ACP package that you plan to share with others.

---

## Prerequisites

- [ ] ACP installed in current directory
- [ ] Git installed on system
- [ ] Basic understanding of what content you want to package
- [ ] (Optional) GitHub account for publishing

---

## Steps

### 1. Gather Package Information

Prompt the user for package metadata:

**Actions**:
- Ask for package name (e.g., "firebase", "mcp-integration", "oauth")
- Ask for package description (one-line summary)
- Ask for author name
- Ask for license (default: MIT)
- Ask for homepage URL (optional)
- Ask for tags (comma-separated, for discovery)

**Expected Outcome**: All metadata collected for `package.yaml`

**Example Interaction**:
```
📦 Creating New ACP Package

Let's gather some information about your package:

Package name (lowercase, no spaces): firebase
Description: Firebase patterns and utilities for ACP projects
Author name: Patrick Michaelsen
License [MIT]: 
Homepage URL (optional): https://github.com/prmichaelsen/acp-firebase
Tags (comma-separated): firebase, firestore, database, backend

✓ Package information collected
```

### 2. Initialize Directory Structure

Create the standard ACP package structure:

**Actions**:
- Create project directory: `acp-{package-name}/`
- Create `agent/` directory
- Create `agent/patterns/` directory
- Create `agent/commands/` directory
- Create `agent/design/` directory
- Add `.gitkeep` files to empty directories
- Initialize git repository: `git init`

**Expected Outcome**: Complete directory structure ready for content

**Directory Structure Created**:
```
acp-{package-name}/
├── README.md                    # (to be created in step 4)
├── LICENSE                      # (to be created in step 4)
├── CHANGELOG.md                 # (to be created in step 4)
├── package.yaml                 # (to be created in step 3)
└── agent/
    ├── patterns/
    │   └── .gitkeep
    ├── commands/
    │   └── .gitkeep
    └── design/
        └── .gitkeep
```

### 3. Create package.yaml

Generate the package metadata file:

**Actions**:
- Create `package.yaml` with collected information
- Set initial version to 1.0.0
- Add empty `contents` sections for patterns, commands, designs
- Add empty `dependencies` section
- Add `requires` section with ACP version

**Expected Outcome**: Valid `package.yaml` file created

**Template**:
```yaml
# package.yaml
name: {package-name}
version: 1.0.0
description: {description}
author: {author}
license: {license}
homepage: {homepage}
repository: {repository-url}

# Package contents
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
  {tags-as-yaml-list}
```

### 4. Create Documentation Files

Generate standard documentation:

**Actions**:
- Create `README.md` with package overview
- Create `LICENSE` file (MIT by default)
- Create `CHANGELOG.md` with initial version
- Create `.gitignore` for common files

**Expected Outcome**: Complete documentation ready for customization

**README.md Template**:
```markdown
# ACP Package: {package-name}

{description}

## Installation

\`\`\`bash
@acp.package-install https://github.com/{username}/acp-{package-name}.git
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

## License

{license}

## Author

{author}
```

**CHANGELOG.md Template**:
```markdown
# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - {current-date}

### Added
- Initial release
- Package structure created
```

### 5. Add Example Content (Optional)

Offer to create example files:

**Actions**:
- Ask if user wants example pattern file
- Ask if user wants example command file
- Ask if user wants example design file
- Create requested examples from templates

**Expected Outcome**: Example files created if requested

**Example Pattern** (`agent/patterns/example-pattern.md`):
```markdown
# Example Pattern

**Version**: 1.0.0
**Last Updated**: {date}

---

## Overview

[Describe what this pattern is and when to use it]

## Problem

[What problem does this pattern solve?]

## Solution

[How does this pattern solve the problem?]

## Implementation

[Code examples and implementation details]

## Benefits

[Why use this pattern?]

## Trade-offs

[What are the downsides?]

---

**Status**: Example
**Recommendation**: Replace with your actual pattern
```

### 6. Initialize Git Repository

Set up version control:

**Actions**:
- Run `git init` (if not already done)
- Create `.gitignore` with common exclusions
- Stage all files: `git add .`
- Create initial commit: `git commit -m "chore: initialize ACP package"`
- Display git status

**Expected Outcome**: Git repository initialized with initial commit

**.gitignore Template**:
```
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
```

### 7. Provide GitHub Publishing Instructions

Guide user on publishing to GitHub:

**Actions**:
- Display instructions for creating GitHub repository
- Show commands for pushing to GitHub
- Explain how to add `acp-package` topic
- Provide checklist for making package discoverable

**Expected Outcome**: User knows how to publish package

**Instructions Display**:
```
🎉 Package Created Successfully!

Your ACP package is ready at: ./acp-{package-name}/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Next Steps:

1. Add your content:
   - Add patterns to agent/patterns/
   - Add commands to agent/commands/
   - Add designs to agent/design/

2. Update package.yaml:
   - Add each file to the contents section
   - Specify version for each file
   - Add dependencies if needed

3. Create GitHub repository:
   - Go to https://github.com/new
   - Name: acp-{package-name}
   - Description: {description}
   - Create repository

4. Push to GitHub:
   cd acp-{package-name}
   git remote add origin https://github.com/{username}/acp-{package-name}.git
   git branch -M main
   git push -u origin main

5. Add GitHub topic for discoverability:
   - Go to repository settings
   - Add topic: "acp-package"
   - Add other relevant topics: {tags}

6. Test installation:
   @acp.package-install https://github.com/{username}/acp-{package-name}.git

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 Resources:

- Package structure guide: See AGENT.md in agent-context-protocol
- package.yaml reference: agent/design/acp-package-management-system.md
- Example packages: https://github.com/prmichaelsen?tab=repositories&q=acp-

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Package creation complete!
```

### 8. Update package.yaml as Content is Added

Remind user to maintain package.yaml:

**Actions**:
- Explain that `package.yaml` must be updated when files are added
- Show example of adding a pattern to `package.yaml`
- Explain version numbering for files
- Remind about updating package version

**Expected Outcome**: User understands how to maintain package.yaml

**Example Update**:
```yaml
# When you add agent/patterns/user-scoped-collections.md:

contents:
  patterns:
    - name: user-scoped-collections.md
      version: 1.0.0
      description: User-scoped Firestore data organization
```

---

## Verification

- [ ] Package directory created with correct name
- [ ] `agent/` directory structure created
- [ ] `package.yaml` created with valid YAML
- [ ] README.md created with package information
- [ ] LICENSE file created
- [ ] CHANGELOG.md created with initial version
- [ ] .gitignore created
- [ ] Git repository initialized
- [ ] Initial commit created
- [ ] GitHub publishing instructions displayed
- [ ] User understands next steps

---

## Expected Output

### Files Created

```
acp-{package-name}/
├── README.md                    # Package documentation
├── LICENSE                      # License file (MIT)
├── CHANGELOG.md                 # Version history
├── package.yaml                 # Package metadata
├── .gitignore                   # Git exclusions
└── agent/
    ├── patterns/
    │   ├── .gitkeep
    │   └── example-pattern.md   # (if requested)
    ├── commands/
    │   ├── .gitkeep
    │   └── example-command.md   # (if requested)
    └── design/
        ├── .gitkeep
        └── example-design.md    # (if requested)
```

### Console Output

```
📦 ACP Package Creator
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Let's create a new ACP package!

Package name: firebase
Description: Firebase patterns and utilities for ACP projects
Author: Patrick Michaelsen
License [MIT]: 
Homepage: https://github.com/prmichaelsen/acp-firebase
Tags: firebase, firestore, database, backend

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Created directory: acp-firebase/
✓ Created agent/ structure
✓ Created package.yaml
✓ Created README.md
✓ Created LICENSE (MIT)
✓ Created CHANGELOG.md
✓ Created .gitignore
✓ Initialized git repository
✓ Created initial commit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like to create example files? (y/N): y

✓ Created agent/patterns/example-pattern.md
✓ Created agent/commands/example-command.md
✓ Created agent/design/example-design.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Package Created Successfully!

[Next steps displayed as shown in Step 7]
```

---

## Examples

### Example 1: Creating Firebase Package

**Context**: Want to share Firebase patterns with community

**Invocation**: `@acp.package-create`

**Interaction**:
```
Package name: firebase
Description: Firebase patterns and utilities for ACP projects
Author: Patrick Michaelsen
License [MIT]: 
Homepage: https://github.com/prmichaelsen/acp-firebase
Tags: firebase, firestore, database, backend

Create example files? (y/N): n
```

**Result**: Package structure created, ready to add Firebase patterns

### Example 2: Creating MCP Integration Package

**Context**: Want to package MCP server integration patterns

**Invocation**: `@acp.package-create`

**Interaction**:
```
Package name: mcp-integration
Description: Model Context Protocol server integration patterns
Author: Patrick Michaelsen
License [MIT]: 
Homepage: https://github.com/prmichaelsen/acp-mcp-integration
Tags: mcp, model-context-protocol, integration, server

Create example files? (y/N): y
```

**Result**: Package created with example files to use as templates

### Example 3: Creating OAuth Package

**Context**: Want to share OAuth 2.0 implementation patterns

**Invocation**: `@acp.package-create`

**Interaction**:
```
Package name: oauth
Description: OAuth 2.0 authentication patterns and flows
Author: Patrick Michaelsen
License [MIT]: MIT
Homepage: https://github.com/prmichaelsen/acp-oauth
Tags: oauth, authentication, security, auth

Create example files? (y/N): n
```

**Result**: Clean package structure ready for OAuth patterns

---

## Related Commands

- [`@acp.package-install`](acp.package-install.md) - Install packages (test your package)
- [`@acp.package-search`](acp.package-search.md) - Search for existing packages
- [`@git.init`](git.init.md) - Initialize git repository
- [`@git.commit`](git.commit.md) - Version-aware commits

---

## Troubleshooting

### Issue 1: Directory already exists

**Symptom**: Error "Directory acp-{name} already exists"

**Cause**: Package directory already created

**Solution**: 
- Choose a different package name
- Or remove existing directory: `rm -rf acp-{name}`
- Or work in existing directory (skip creation steps)

### Issue 2: Git not installed

**Symptom**: Error "git: command not found"

**Cause**: Git not installed on system

**Solution**: 
- Install git: https://git-scm.com/downloads
- Or skip git initialization (manual setup later)

### Issue 3: Invalid package name

**Symptom**: Warning about package name format

**Cause**: Package name contains spaces or special characters

**Solution**: 
- Use lowercase letters, numbers, and hyphens only
- No spaces or special characters
- Examples: "firebase", "mcp-integration", "oauth-2"

### Issue 4: Missing package.yaml fields

**Symptom**: Validation errors when installing package

**Cause**: Required fields missing from package.yaml

**Solution**:
- Ensure `name`, `version`, `description` are present
- Add `contents` section (even if empty)
- Validate YAML syntax: https://www.yamllint.com/

---

## Security Considerations

### File Access
- **Reads**: None (creates new files)
- **Writes**: Creates entire package directory structure
- **Executes**: `git init`, `git add`, `git commit`

### Network Access
- **APIs**: None
- **Repositories**: None (local creation only)

### Sensitive Data
- **Secrets**: Never include secrets in package files
- **Credentials**: Never commit credentials to git
- **Personal Info**: Only include what you want public

---

## Notes

- Package name becomes directory name: `acp-{name}/`
- Package name in `package.yaml` should NOT include "acp-" prefix
- GitHub repository name should include "acp-" prefix for clarity
- Always add "acp-package" topic to GitHub repository for discoverability
- Update `package.yaml` whenever you add/remove files
- Follow semantic versioning for package and file versions
- Test package installation before publishing
- Consider creating example usage in README.md

---

## Best Practices

### Package Naming
- Use descriptive, single-word names when possible
- Use hyphens for multi-word names (e.g., "mcp-integration")
- Avoid generic names (e.g., "utils", "helpers")
- Be specific about what the package provides

### Content Organization
- **Patterns**: Reusable architectural patterns
- **Commands**: Workflow automation commands
- **Designs**: Technical specifications and architecture docs

### Documentation
- Write clear, concise descriptions
- Include usage examples in README.md
- Document dependencies clearly
- Keep CHANGELOG.md updated
- Add troubleshooting section for common issues

### Version Management
- Start at 1.0.0 for initial release
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update CHANGELOG.md with each version
- Tag releases in git: `git tag v1.0.0`

### GitHub Setup
- Add "acp-package" topic (required for discovery)
- Add descriptive topics/tags
- Write clear repository description
- Include installation instructions in README
- Add LICENSE file
- Consider adding GitHub Actions for validation

---

**Namespace**: acp
**Command**: package-create
**Version**: 1.0.0
**Created**: 2026-02-20
**Last Updated**: 2026-02-20
**Status**: Active
**Compatibility**: ACP 2.0.0+
**Author**: ACP Project
