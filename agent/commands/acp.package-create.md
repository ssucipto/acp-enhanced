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

### 1. Gather Package Information via Chat

**IMPORTANT**: Collect all information from the user via chat BEFORE executing the script. This provides maximum context and allows validation.

**Actions**:
1. Explain what information is needed and why
2. Ask user for each piece of information one at a time
3. Validate each input before proceeding
4. Summarize all collected information
5. Ask for confirmation before proceeding

**Information to Collect**:

**Package Name** (required)
- Ask: "What would you like to name your package? (lowercase, no spaces, hyphens allowed)"
- Validation: Must be lowercase, alphanumeric, and hyphens only
- Examples: "firebase", "mcp-integration", "oauth-2"
- Note: This becomes the directory name `acp-{name}/`

**Description** (required)
- Ask: "Provide a one-line description of your package:"
- Validation: Should be clear and concise (< 100 characters recommended)
- Examples: "Firebase patterns and utilities for ACP projects"

**Author Name** (required)
- Ask: "What is your name (package author)?"
- Examples: "Patrick Michaelsen", "Your Name"

**License** (optional, default: MIT)
- Ask: "What license would you like to use? (default: MIT)"
- Common options: MIT, Apache-2.0, GPL-3.0, BSD-3-Clause
- Default: MIT if not specified

**Homepage URL** (optional)
- Ask: "What is the homepage URL for this package? (optional, press Enter to skip)"
- Examples: "https://github.com/username/acp-firebase"
- Note: Can be GitHub repo URL or documentation site

**Repository URL** (required)
- Ask: "What is the git repository URL? (e.g., https://github.com/username/acp-{name}.git)"
- Validation: Should be a valid git URL
- Examples: "https://github.com/prmichaelsen/acp-firebase.git"

**Tags** (required)
- Ask: "What tags describe your package? (comma-separated, for discovery)"
- Validation: At least one tag recommended
- Examples: "firebase, firestore, database, backend"
- Note: These help users find your package via `@acp.package-search`

**Create Example Files** (optional)
- Ask: "Would you like to create example files? (yes/no)"
- If yes: Creates example pattern, command, and design files
- If no: Creates empty structure only

**Target Directory** (optional)
- Ask: "Where would you like to create the package? (default: current directory)"
- Supports: Absolute paths, relative paths, `~` expansion, `$HOME` expansion
- Examples: ".", "~/projects", "$HOME/packages", "/tmp"
- Default: Current directory if not specified
- Note: Package will be created as `{target-dir}/acp-{name}/`

**Expected Outcome**: All metadata collected and validated

**Example Chat Interaction**:
```
Agent: Let's create a new ACP package! I'll need to collect some information from you.

Agent: What would you like to name your package? (lowercase, no spaces, hyphens allowed)
      Examples: "firebase", "mcp-integration", "oauth-2"

User: firebase

Agent: Great! "firebase" is a valid package name. ✓

Agent: Provide a one-line description of your package:

User: Firebase patterns and utilities for ACP projects

Agent: Perfect! ✓

Agent: What is your name (package author)?

User: Patrick Michaelsen

Agent: ✓

Agent: What license would you like to use? (default: MIT)

User: [Enter]

Agent: Using MIT license. ✓

Agent: What is the homepage URL for this package? (optional, press Enter to skip)

User: https://github.com/prmichaelsen/acp-firebase

Agent: ✓

Agent: What is the git repository URL?
      Example: https://github.com/username/acp-firebase.git

User: https://github.com/prmichaelsen/acp-firebase.git

Agent: ✓

Agent: What tags describe your package? (comma-separated, for discovery)
      These help users find your package via @acp.package-search

User: firebase, firestore, database, backend

Agent: ✓

Agent: Would you like to create example files? (yes/no)
      This creates example pattern, command, and design files as templates.

User: yes

Agent: ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary of collected information:

Package name: firebase
Description: Firebase patterns and utilities for ACP projects
Author: Patrick Michaelsen
License: MIT
Homepage: https://github.com/prmichaelsen/acp-firebase
Repository: https://github.com/prmichaelsen/acp-firebase.git
Tags: firebase, firestore, database, backend
Create examples: yes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Agent: Does this look correct? (yes/no)

User: yes

Agent: Excellent! I'll now create your package...
```

### 2. Execute Package Creation Script

Once all information is collected and confirmed, execute the script with the collected arguments.

**Actions**:
1. Prepare script execution with collected values
2. Execute `./agent/scripts/acp.package-create.sh` with heredoc input
3. Monitor script output and report progress
4. Verify successful completion

**Script Execution**:

```bash
cd /home/prmichaelsen/agent-context-protocol

./agent/scripts/acp.package-create.sh << 'EOF'
{package-name}
{description}
{author}
{license}
{homepage}
{repository-url}
{tags}
{create-examples: y or n}
{target-directory}
EOF
```

**Example with collected values**:
```bash
./agent/scripts/acp.package-create.sh << 'EOF'
firebase
Firebase patterns and utilities for ACP projects
Patrick Michaelsen
MIT
https://github.com/prmichaelsen/acp-firebase
https://github.com/prmichaelsen/acp-firebase.git
firebase, firestore, database, backend
y
~/projects
EOF
```

**Path Expansion**:
- `~` expands to user's home directory
- `$HOME` expands to home directory
- Relative paths resolved from current directory
- Absolute paths used as-is

**Expected Outcome**: Script executes successfully and creates complete package structure

**Script Output to Display**:
```
📦 ACP Package Creator
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Let's create a new ACP package!

Package name: firebase
Description: Firebase patterns and utilities for ACP projects
Author: Patrick Michaelsen
License [MIT]: MIT
Homepage: https://github.com/prmichaelsen/acp-firebase
Repository URL: https://github.com/prmichaelsen/acp-firebase.git
Tags: firebase, firestore, database, backend

✓ Package information collected

Creating Directory Structure

✓ Created directory: acp-firebase/
✓ Created agent/ structure

Creating package.yaml

✓ Created package.yaml

Creating Documentation

✓ Created README.md
✓ Created LICENSE (MIT)
✓ Created CHANGELOG.md
✓ Created .gitignore

Initializing Git Repository

✓ Initialized git repository
✓ Created initial commit

Would you like to create example files? (y/N): y

Creating Example Files

✓ Created agent/patterns/example-pattern.md
✓ Created agent/commands/example-command.md
✓ Created agent/design/example-design.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Package Created Successfully!

Your ACP package is ready at: ./acp-firebase/

[Next steps displayed...]
```

**Directory Structure Created**:
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

### 3. Display Script Output and Next Steps

After script execution completes, display the next steps for the user.

**Actions**:
- Confirm package was created successfully
- Show package location
- Provide GitHub publishing instructions
- Explain how to add content
- Remind about package.yaml maintenance

**Expected Outcome**: User knows exactly what to do next

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

### 4. Verify Package Creation

Check that all files were created correctly.

**Actions**:
- List created files
- Verify directory structure
- Check git repository status
- Confirm package.yaml is valid

**Expected Outcome**: Package is ready for content addition

**Verification Commands**:
```bash
# List package contents
ls -la acp-{package-name}/

# Check git status
cd acp-{package-name} && git status

# Verify package.yaml
cat acp-{package-name}/package.yaml
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
