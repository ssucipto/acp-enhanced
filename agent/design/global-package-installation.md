# Global Package Installation

**Concept**: Install ACP packages globally to be shared across multiple projects
**Created**: 2026-02-21
**Status**: Proposal
**Priority**: Medium
**Estimated Effort**: 8-12 hours

---

## Overview

Enable users to install ACP packages globally (to `~/.acp/packages/` or `$HOME/.acp/packages/`) instead of locally to each project's `agent/` directory. Global packages would be available to all projects on the system, reducing duplication and simplifying package management.

---

## Problem Statement

### Current Limitations

Currently, ACP packages are installed locally to each project:
- Packages installed to `./agent/patterns/`, `./agent/commands/`, `./agent/designs/`
- Each project has its own copy of installed packages
- Updates must be applied to each project individually
- Disk space wasted with duplicate package files

### User Pain Points

**Scenario 1**: Using firebase package across 5 projects
- Currently: Install firebase package 5 times (once per project)
- Desired: Install once globally, use in all projects

**Scenario 2**: Updating a package
- Currently: Run `@acp.package-update` in each project
- Desired: Update once globally, all projects get update

**Scenario 3**: Managing disk space
- Currently: 10 projects × 5 packages × 100KB = 5MB duplicated
- Desired: 5 packages × 100KB = 500KB (10x reduction)

---

## Solution

### High-Level Design

```
Global Installation:
  @acp.package-install --global {repo-url}
      ↓
  Install to ~/.acp/packages/{package-name}/
      ↓
  Create symlinks in project's agent/ directories
      ↓
  Track in global manifest: ~/.acp/manifest.yaml
      ↓
  Track in project manifest: ./agent/manifest.yaml (references global)

Local Installation (existing):
  @acp.package-install {repo-url}
      ↓
  Install to ./agent/patterns/, ./agent/commands/, ./agent/designs/
      ↓
  Track in project manifest: ./agent/manifest.yaml
```

### Directory Structure

```
~/.acp/
├── packages/                    # Global packages
│   ├── firebase/
│   │   ├── package.yaml
│   │   ├── agent/
│   │   │   ├── patterns/
│   │   │   │   └── firebase.firestore-pattern.md
│   │   │   └── commands/
│   │   │       └── firebase.deploy.md
│   ├── mcp-integration/
│   └── oauth/
└── manifest.yaml                # Global package manifest

project-1/
└── agent/
    ├── patterns/
    │   └── firebase.firestore-pattern.md -> ~/.acp/packages/firebase/agent/patterns/firebase.firestore-pattern.md
    ├── commands/
    │   └── firebase.deploy.md -> ~/.acp/packages/firebase/agent/commands/firebase.deploy.md
    └── manifest.yaml            # References global packages

project-2/
└── agent/
    ├── patterns/
    │   └── firebase.firestore-pattern.md -> ~/.acp/packages/firebase/agent/patterns/firebase.firestore-pattern.md
    └── manifest.yaml
```

---

## Implementation

### 1. Global Manifest

**Location**: `~/.acp/manifest.yaml`

**Structure**:
```yaml
# Global ACP Package Manifest
version: 1.0.0
updated: 2026-02-21T03:28:00Z

packages:
  firebase:
    name: firebase
    version: 1.2.0
    source: https://github.com/user/acp-firebase.git
    commit: abc123
    installed: 2026-02-21T03:28:00Z
    updated: 2026-02-21T03:28:00Z
    location: /home/user/.acp/packages/firebase
    files:
      patterns:
        - name: firebase.firestore-pattern.md
          version: 1.0.0
          checksum: sha256:...
      commands:
        - name: firebase.deploy.md
          version: 1.0.0
          checksum: sha256:...
```

### 2. Project Manifest Enhancement

**Add global package references**:
```yaml
packages:
  firebase:
    name: firebase
    version: 1.2.0
    source: https://github.com/user/acp-firebase.git
    global: true                 # NEW: Indicates global installation
    location: /home/user/.acp/packages/firebase  # NEW: Global location
    files:
      patterns:
        - name: firebase.firestore-pattern.md
          version: 1.0.0
          symlink: true          # NEW: Indicates symlink
          target: ~/.acp/packages/firebase/agent/patterns/firebase.firestore-pattern.md
```

### 3. Installation Flags

**@acp.package-install enhancements**:
```bash
# Global installation
@acp.package-install --global {repo-url}
@acp.package-install -g {repo-url}

# Local installation (existing, default)
@acp.package-install {repo-url}
```

**Script changes**:
```bash
# Parse --global flag
GLOBAL_INSTALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --global|-g)
            GLOBAL_INSTALL=true
            shift
            ;;
        *)
            REPO_URL=$1
            shift
            ;;
    esac
done

# Determine installation directory
if [ "$GLOBAL_INSTALL" = true ]; then
    INSTALL_DIR="$HOME/.acp/packages/${PACKAGE_NAME}"
    MANIFEST_FILE="$HOME/.acp/manifest.yaml"
else
    INSTALL_DIR="./agent"
    MANIFEST_FILE="./agent/manifest.yaml"
fi
```

### 4. Symlink Creation

**Create symlinks in project**:
```bash
# After global installation, create symlinks in current project
create_global_symlinks() {
    local package_name=$1
    local global_dir="$HOME/.acp/packages/${package_name}"
    
    # Create symlinks for patterns
    for pattern in "$global_dir/agent/patterns"/*.md; do
        [ -f "$pattern" ] || continue
        local filename=$(basename "$pattern")
        ln -sf "$pattern" "./agent/patterns/$filename"
    done
    
    # Create symlinks for commands
    for command in "$global_dir/agent/commands"/*.md; do
        [ -f "$command" ] || continue
        local filename=$(basename "$command")
        ln -sf "$command" "./agent/commands/$filename"
    done
    
    # Create symlinks for designs
    for design in "$global_dir/agent/design"/*.md; do
        [ -f "$design" ] || continue
        local filename=$(basename "$design")
        ln -sf "$design" "./agent/design/$filename"
    done
}
```

### 5. Update Commands

**Commands to enhance**:
- [`@acp.package-install`](../commands/acp.package-install.md) - Add `--global` flag
- [`@acp.package-list`](../commands/acp.package-list.md) - Show global vs local
- [`@acp.package-update`](../commands/acp.package-update.md) - Update global packages
- [`@acp.package-remove`](../commands/acp.package-remove.md) - Remove global packages and symlinks
- [`@acp.package-info`](../commands/acp.package-info.md) - Show global location

---

## Benefits

### 1. Reduced Disk Usage
- Install once, use everywhere
- 10x reduction in disk space for common packages
- Faster installation (no repeated downloads)

### 2. Simplified Updates
- Update once globally
- All projects get update automatically (symlinks)
- No need to update each project individually

### 3. Consistent Versions
- All projects use same version of global package
- Easier to maintain consistency
- Reduces version conflicts

### 4. Easier Package Management
- Single location for all global packages
- Easy to see what's installed globally
- Simpler cleanup (remove from one location)

---

## Trade-offs

### 1. Symlink Complexity
**Trade-off**: Symlinks can be confusing for users unfamiliar with them

**Mitigation**:
- Clear documentation
- Visual indicators in `@acp.package-list` (show [GLOBAL] tag)
- Graceful handling of broken symlinks

### 2. Version Conflicts
**Trade-off**: Global package version may not match project needs

**Mitigation**:
- Allow local installation to override global
- Show warning if project needs different version
- Support multiple global versions (future)

### 3. Permission Issues
**Trade-off**: Global directory may have permission issues

**Mitigation**:
- Use user's home directory (no sudo needed)
- Clear error messages for permission issues
- Fallback to local installation

### 4. Broken Symlinks
**Trade-off**: Deleting global package breaks all projects using it

**Mitigation**:
- Warn before removing global packages
- Show which projects use the package
- Offer to convert to local installation

---

## Implementation Plan

### Phase 1: Global Manifest (2-3 hours)
1. Create `~/.acp/manifest.yaml` structure
2. Add global manifest functions to acp.common.sh
3. Test global manifest operations

### Phase 2: Global Installation (3-4 hours)
1. Add `--global` flag parsing to acp.package-install.sh
2. Implement global installation logic
3. Create symlink creation function
4. Update project manifest with global references
5. Test global installation

### Phase 3: Update Commands (2-3 hours)
1. Update `@acp.package-list` to show global packages
2. Update `@acp.package-update` to handle global packages
3. Update `@acp.package-remove` to handle global packages and symlinks
4. Update `@acp.package-info` to show global location

### Phase 4: Documentation (1-2 hours)
1. Update all command documentation
2. Add global installation examples
3. Document symlink behavior
4. Add troubleshooting for symlink issues

---

## Usage Examples

### Install Package Globally

```bash
# Install firebase package globally
@acp.package-install --global https://github.com/user/acp-firebase.git

# Output:
# Installing firebase globally to ~/.acp/packages/firebase/
# ✓ Package installed globally
# ✓ Created symlinks in current project
# ✓ Updated ~/.acp/manifest.yaml
# ✓ Updated ./agent/manifest.yaml
```

### List Global Packages

```bash
@acp.package-list --global

# Output:
# Global Packages (installed to ~/.acp/packages/):
#
#   firebase (v1.2.0) [GLOBAL]
#     3 patterns, 2 commands
#     Used by: 5 projects
#
#   mcp-integration (v2.0.0) [GLOBAL]
#     2 patterns, 4 commands
#     Used by: 3 projects
```

### Update Global Package

```bash
@acp.package-update --global firebase

# Output:
# Updating global package: firebase
# Current: v1.2.0
# Latest: v1.3.0
#
# This will update firebase in all projects using it:
#   - project-1
#   - project-2
#   - project-3
#
# Continue? (y/N): y
#
# ✓ Updated firebase to v1.3.0
# ✓ All symlinks updated automatically
```

### Remove Global Package

```bash
@acp.package-remove --global firebase

# Output:
# Removing global package: firebase
#
# ⚠  This package is used by 5 projects:
#   - project-1
#   - project-2
#   - project-3
#   - project-4
#   - project-5
#
# Options:
#   1. Remove global package and symlinks (breaks projects)
#   2. Convert to local installations in each project
#   3. Cancel
#
# Choose (1/2/3): 2
#
# Converting to local installations...
# ✓ Converted project-1 to local installation
# ✓ Converted project-2 to local installation
# ...
# ✓ Removed global package
```

---

## Future Enhancements

### Multiple Global Versions
- Support installing multiple versions globally
- Directory: `~/.acp/packages/{package-name}/{version}/`
- Projects specify which version to use

### Global Package Discovery
- Scan all projects to find global package usage
- Show dependency graph
- Identify unused global packages

### Automatic Conversion
- Detect duplicate local installations
- Offer to convert to global
- Consolidate disk usage

---

## Related Documents

- [`agent/design/acp-package-management-system.md`](acp-package-management-system.md)
- [`agent/commands/acp.package-install.md`](../commands/acp.package-install.md)
- [`agent/tasks/task-6-selective-installation.md`](../tasks/task-6-selective-installation.md)

---

**Status**: Proposal - Awaiting approval
**Recommendation**: Implement in Milestone 5 (Package Ecosystem)
**Next Steps**: 
1. Get user feedback on design
2. Create Milestone 5 if approved
3. Break into tasks (4-5 tasks estimated)
