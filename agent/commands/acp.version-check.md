# Command: version-check

> **🤖 Agent Directive**: If you are reading this file, the command `@acp-version-check` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp
**Version**: 1.0.0
**Created**: 2026-02-16
**Last Updated**: 2026-02-16
**Status**: Active

---

**Purpose**: Display current ACP version and compatibility information
**Category**: Maintenance
**Frequency**: As Needed

---

## What This Command Does

This command displays the current version of ACP installed in the project by reading the version information from AGENT.md and CHANGELOG.md. It provides a quick way to check which version you're using without needing to manually open files.

Use this command when you need to verify your ACP version, check compatibility with other tools, or before reporting issues. It's a simple, read-only operation that provides version information at a glance.

Unlike `@acp-version-check-for-updates` which checks for newer versions, this command only shows your current version without making any network requests.

---

## Prerequisites

- [ ] ACP installed in project (AGENT.md exists)

---

## Steps

### 1. Read AGENT.md Header

Extract version information from AGENT.md.

**Actions**:
- Open `AGENT.md`
- Read the header section (first ~10 lines)
- Extract version number from `**Version**: X.X.X` line
- Extract created date
- Extract status

**Expected Outcome**: Version information extracted

### 2. Read CHANGELOG.md

Get details about the current version.

**Actions**:
- Open `CHANGELOG.md`
- Find the section for current version
- Extract release date
- Extract list of changes (Added, Changed, Removed, Fixed)

**Expected Outcome**: Version details loaded

### 3. Display Version Information

Present version information in formatted output.

**Actions**:
- Display version number prominently
- Show release date
- Show created date
- Show current status
- List key features/changes in this version
- Show compatibility information

**Expected Outcome**: User sees complete version information

---

## Verification

- [ ] AGENT.md read successfully
- [ ] Version number extracted
- [ ] CHANGELOG.md read successfully
- [ ] Version details extracted
- [ ] Output is clear and well-formatted
- [ ] No errors encountered

---

## Expected Output

### Files Modified
None - this is a read-only command

### Console Output
```
📦 ACP Version Information

Version: 1.0.3
Created: 2026-02-11
Released: 2026-02-13
Status: Production Pattern

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Version 1.0.3 Features:

Added:
  • Template files for all ACP document types
  • Generic patterns (TypeScript service layer)
  • Installation & update scripts
  • Automatic update checking
  • Command system (in development)

Changed:
  • Converted to generic templates (from project-specific)
  • Reorganized scripts into dedicated directory
  • Simplified installation process

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 Compatibility:
  • Node.js: 18+
  • Git: Required for updates
  • Works with: All programming languages

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 Documentation:
  • AGENT.md: Complete methodology
  • README.md: Quick start guide
  • CHANGELOG.md: Version history

ℹ️  To check for updates: @acp-version-check-for-updates
ℹ️  To update ACP: @acp-version-update
```

### Status Update
No status changes - read-only operation

---

## Examples

### Example 1: Quick Version Check

**Context**: Want to know which ACP version you're using

**Invocation**: `@acp-version-check`

**Result**: Shows version 1.0.3, released 2026-02-13, with list of features

### Example 2: Before Reporting Issue

**Context**: Need to report a bug and want to include version info

**Invocation**: `@acp-version-check`

**Result**: Displays version 1.0.3, compatibility info, helps you provide accurate bug report

### Example 3: Checking Compatibility

**Context**: Want to verify ACP version supports a specific feature

**Invocation**: `@acp-version-check`

**Result**: Shows version and feature list, confirms if feature is available

---

## Related Commands

- [`@acp-version-check-for-updates`](acp.version-check-for-updates.md) - Check if newer version available
- [`@acp-version-update`](acp.version-update.md) - Update to latest version
- [`@acp-init`](acp.init.md) - Includes version check as part of initialization

---

## Troubleshooting

### Issue 1: AGENT.md not found

**Symptom**: Error message "Cannot read AGENT.md"

**Cause**: ACP not installed or AGENT.md deleted

**Solution**: Reinstall ACP using the installation script

### Issue 2: Version number not found

**Symptom**: Warning "Version not found in AGENT.md"

**Cause**: AGENT.md format changed or corrupted

**Solution**: Update ACP to latest version using `@acp-version-update`

### Issue 3: CHANGELOG.md not found

**Symptom**: Warning "Cannot read CHANGELOG.md"

**Cause**: Older ACP installation or file deleted

**Solution**: Non-critical, version number still displayed. Consider updating ACP.

---

## Security Considerations

### File Access
- **Reads**: `AGENT.md`, `CHANGELOG.md`
- **Writes**: None (read-only command)
- **Executes**: None

### Network Access
- **APIs**: None
- **Repositories**: None

### Sensitive Data
- **Secrets**: Does not access any secrets or credentials
- **Credentials**: Does not access any credentials

---

## Notes

- This is a read-only command with no side effects
- No network access required
- Fast operation (reads 2 small files)
- Safe to run anytime
- Useful for troubleshooting and bug reports
- Can be run offline

---

**Namespace**: acp
**Command**: version-check
**Version**: 1.0.0
**Created**: 2026-02-16
**Last Updated**: 2026-02-16
**Status**: Active
**Compatibility**: ACP 1.0.3+
**Author**: ACP Project
