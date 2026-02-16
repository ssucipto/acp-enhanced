# Command: package-install

> **🤖 Agent Directive**: If you are reading this file, the command `@acp.package-install` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp
**Version**: 1.0.0
**Created**: 2026-02-16
**Last Updated**: 2026-02-16
**Status**: Active

---

**Purpose**: Install third-party command packages from git repositories using the package-install script
**Category**: Maintenance
**Frequency**: As Needed

---

## What This Command Does

This command installs third-party ACP packages from git repositories by running the `agent/scripts/package-install.sh` script. The script clones the repository and installs files from the `agent/` directory, including commands, patterns, and design documents.

Use this command when you want to add community-created commands and patterns, install organization-specific ACP content, or share reusable components across multiple projects. It enables extending ACP with custom functionality, patterns, and documentation.

⚠️ **SECURITY WARNING**: Third-party packages can instruct agents to modify files and execute scripts. Always review package contents before installation. You assume all risk when installing third-party packages.

---

## Prerequisites

- [ ] ACP installed in project
- [ ] Git installed and available
- [ ] Internet connection available
- [ ] `agent/scripts/package-install.sh` exists
- [ ] You trust the source of the commands
- [ ] You have reviewed the command repository

---

## Steps

### 1. Run Package Install Script

Execute the package installation script with the repository URL.

**Actions**:
- Verify `./agent/scripts/package-install.sh` exists
- Run the script with repository URL as argument:
  ```bash
  ./agent/scripts/package-install.sh <repository-url>
  ```
- The script will:
  - Validate the repository URL
  - Clone the repository to a temporary location
  - Locate and validate command files
  - Check for naming conflicts
  - Copy commands to `agent/commands/`
  - Document the installation
  - Clean up temporary files
  - Report what was installed

**Expected Outcome**: Script completes successfully and commands are installed

### 2. Review Installed Commands

Verify the commands were installed correctly.

**Actions**:
- List files in `agent/commands/` to see new commands
- Read the installed command files
- Verify they follow ACP structure
- Check namespace is not `acp` (reserved)
- Ensure no malicious content

**Expected Outcome**: Commands verified safe and functional

### 3. Test Installed Commands

Try invoking one of the installed commands.

**Actions**:
- Choose a simple command to test
- Invoke it using `@{namespace}.{action}` syntax
- Verify it works as expected
- Check for any errors

**Expected Outcome**: Commands work correctly

### 4. Document Installation

Update progress tracking with installation notes.

**Actions**:
- Add note to `agent/progress.yaml` about installed commands
- Document which package was installed
- Note installation date
- List installed command names

**Expected Outcome**: Installation tracked in progress

---

## Verification

- [ ] package-install.sh script exists
- [ ] Script executed successfully
- [ ] Commands installed to agent/commands/
- [ ] Installed commands reviewed for safety
- [ ] Commands tested and working
- [ ] Installation documented in progress.yaml
- [ ] No errors during installation

---

## Expected Output

### Files Modified
- `agent/commands/*.md` - Installed command files
- `agent/commands/installed.yaml` - Installation record

### Console Output
```
📦 Installing ACP Commands

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: https://github.com/example/acp-deploy-commands.git

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cloning repository...
✓ Repository cloned to /tmp/acp-install-a1b2c3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Locating commands...
✓ Found 3 command files:
  - deploy.production.md
  - deploy.staging.md
  - deploy.rollback.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Validating commands...
✓ All commands have agent directives
✓ All commands have required sections
✓ Namespace 'deploy' is valid (not reserved)
✓ No malicious content detected

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking for conflicts...
✓ No naming conflicts found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Installing commands...
✓ Copied deploy.production.md
✓ Copied deploy.staging.md
✓ Copied deploy.rollback.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Documenting installation...
✓ Updated agent/commands/installed.yaml

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cleaning up...
✓ Removed temporary files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Installation Complete!

Installed 3 commands from example/acp-deploy-commands:
- @deploy.production - Deploy to production environment
- @deploy.staging - Deploy to staging environment
- @deploy.rollback - Rollback to previous version

Repository: https://github.com/example/acp-deploy-commands.git
Installed: 2026-02-16
```

### Status Update
- Commands installed
- Installation documented
- Commands ready to use

---

## Examples

### Example 1: Installing Deployment Commands

**Context**: Want to add deployment commands from community

**Invocation**: `@acp.package-install https://github.com/example/acp-deploy-package.git`

**Result**: Script clones repo, installs 3 commands to agent/commands/, now can use @deploy.production

### Example 2: Installing Patterns Package

**Context**: Want to add TypeScript patterns from organization

**Invocation**: `@acp.package-install https://github.com/myorg/typescript-patterns.git`

**Result**: Script installs 5 pattern files to agent/patterns/, now have reusable TypeScript patterns

### Example 3: Installing Complete Package

**Context**: Installing package with commands, patterns, and designs

**Invocation**: `@acp.package-install https://github.com/example/fullstack-package.git`

**Result**: Script installs 3 commands, 4 patterns, 2 design docs across agent/ directories

### Example 4: Installing with Conflicts

**Context**: Installing package that conflicts with existing files

**Invocation**: `@acp.package-install https://github.com/example/package.git`

**Result**: Script detects conflicts, asks for confirmation, overwrites if approved

---

## Related Commands

- [`@acp.validate`](acp.validate.md) - Validate installed commands
- [`@acp.version-update`](acp.version-update.md) - Update core ACP commands
- [`@acp.status`](acp.status.md) - View project status

---

## Troubleshooting

### Issue 1: Git clone fails

**Symptom**: Cannot clone repository

**Cause**: Invalid URL, no internet, or private repository

**Solution**: Verify URL is correct, check internet connection, ensure repository is public or you have access

### Issue 2: No commands found

**Symptom**: Repository cloned but no commands found

**Cause**: Commands not in expected location or wrong structure

**Solution**: Check repository structure, look for commands/ directory, verify files are .md format

### Issue 3: Validation fails

**Symptom**: Commands fail validation

**Cause**: Commands don't follow ACP structure

**Solution**: Review command files, ensure they have agent directive and required sections, contact command author

### Issue 4: Namespace conflict

**Symptom**: Command uses reserved namespace

**Cause**: Command tries to use 'acp' namespace

**Solution**: Cannot install - 'acp' namespace is reserved for core commands, contact command author to change namespace

---

## Security Considerations

### ⚠️ CRITICAL SECURITY WARNING

**Third-party commands can:**
- Modify any files in your project
- Execute shell commands
- Make network requests
- Access environment variables
- Read sensitive data

**YOU ASSUME ALL RISK when installing third-party commands.**

### Security Best Practices

**Before Installing**:
1. Review the repository and command files
2. Check the author's reputation
3. Read what each command does
4. Verify no malicious content
5. Test in a non-production environment first

**After Installing**:
1. Review installed command files
2. Test commands in safe environment
3. Monitor command behavior
4. Remove if suspicious activity
5. Keep installation records

### File Access
- **Reads**: Repository files, existing commands
- **Writes**: `agent/commands/*.md`, `agent/commands/installed.yaml`
- **Executes**: `git clone` command

### Network Access
- **APIs**: None directly
- **Repositories**: Clones from specified git repository

### Sensitive Data
- **Secrets**: Does not access secrets
- **Credentials**: May use git credentials for private repos

---

## Notes

- Only install commands from trusted sources
- Review command files before installation
- Test in safe environment first
- Keep record of installed commands
- Update installed commands periodically
- Remove unused commands
- Report security issues to command authors
- Consider forking repositories for stability
- Pin to specific versions/commits for reproducibility

---

**Namespace**: acp
**Command**: package-install
**Version**: 1.0.0
**Created**: 2026-02-16
**Last Updated**: 2026-02-16
**Status**: Active
**Compatibility**: ACP 1.1.0+
**Author**: ACP Project
