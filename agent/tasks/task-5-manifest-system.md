# Task 5: Manifest System Implementation

**Milestone**: [M3 - ACP Package Management System](../milestones/milestone-3-acp-package-management.md)  
**Estimated Time**: 6-8 hours  
**Dependencies**: None  
**Status**: Not Started  
**Priority**: High

---

## Objective

Create the `agent/manifest.yaml` structure and enhance `package-install.sh` to write manifest entries when packages are installed, including package metadata, file versions, and checksums for modification tracking.

---

## Context

The manifest system is the foundation of the package management system. It tracks which packages are installed, their versions, which specific files were installed, and checksums to detect local modifications. This enables smart updates, conflict detection, and team collaboration through version-controlled manifests.

---

## Steps

### 1. Design Manifest Schema

Create the YAML structure for `agent/manifest.yaml`:

```yaml
# agent/manifest.yaml
# Tracks installed ACP packages and their versions

packages:
  <package-name>:
    source: string           # Git URL
    package_version: string  # Semantic version
    commit: string           # Git commit hash
    installed_at: datetime   # ISO 8601
    updated_at: datetime     # ISO 8601
    
    installed:
      patterns:
        - name: string
          version: string
          installed_at: datetime
          modified: boolean
          checksum: string  # sha256:...
      
      commands:
        - name: string
          version: string
          installed_at: datetime
          modified: boolean
          checksum: string
      
      designs:
        - name: string
          version: string
          installed_at: datetime
          modified: boolean
          checksum: string

manifest_version: string  # Format version
last_updated: datetime
```

### 2. Create Manifest Template

Create `agent/manifest.template.yaml`:

```yaml
# agent/manifest.template.yaml
# Template for package manifest

packages: {}

manifest_version: 1.0.0
last_updated: null
```

### 3. Implement Manifest Writing Functions

Add functions to `scripts/package-install.sh`:

```bash
#!/bin/bash

# Initialize manifest if doesn't exist
init_manifest() {
  if [ ! -f "agent/manifest.yaml" ]; then
    cat > agent/manifest.yaml << 'EOF'
packages: {}
manifest_version: 1.0.0
last_updated: null
EOF
    echo "✓ Created agent/manifest.yaml"
  fi
}

# Calculate file checksum
calculate_checksum() {
  local file=$1
  sha256sum "$file" | cut -d' ' -f1
}

# Add package to manifest
add_package_to_manifest() {
  local package_name=$1
  local source_url=$2
  local package_version=$3
  local commit_hash=$4
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Create package entry
  yq eval -i ".packages.${package_name}.source = \"${source_url}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.package_version = \"${package_version}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.commit = \"${commit_hash}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.installed_at = \"${timestamp}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.updated_at = \"${timestamp}\"" agent/manifest.yaml
  yq eval -i ".last_updated = \"${timestamp}\"" agent/manifest.yaml
}

# Add installed file to manifest
add_file_to_manifest() {
  local package_name=$1
  local file_type=$2  # patterns, commands, designs
  local file_name=$3
  local file_version=$4
  local file_path=$5
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Calculate checksum
  local checksum=$(calculate_checksum "$file_path")
  
  # Add file entry
  local index=$(yq eval ".packages.${package_name}.installed.${file_type} | length" agent/manifest.yaml)
  yq eval -i ".packages.${package_name}.installed.${file_type}[${index}].name = \"${file_name}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.installed.${file_type}[${index}].version = \"${file_version}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.installed.${file_type}[${index}].installed_at = \"${timestamp}\"" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.installed.${file_type}[${index}].modified = false" agent/manifest.yaml
  yq eval -i ".packages.${package_name}.installed.${file_type}[${index}].checksum = \"sha256:${checksum}\"" agent/manifest.yaml
}
```

### 4. Parse package.yaml from Repository

Add function to read package metadata:

```bash
# Parse package.yaml from cloned repository
parse_package_metadata() {
  local repo_dir=$1
  local package_yaml="${repo_dir}/package.yaml"
  
  if [ ! -f "$package_yaml" ]; then
    echo "Error: package.yaml not found in repository"
    return 1
  fi
  
  # Extract metadata
  PACKAGE_NAME=$(yq eval '.name' "$package_yaml")
  PACKAGE_VERSION=$(yq eval '.version' "$package_yaml")
  PACKAGE_DESCRIPTION=$(yq eval '.description' "$package_yaml")
  
  echo "Package: $PACKAGE_NAME"
  echo "Version: $PACKAGE_VERSION"
  echo "Description: $PACKAGE_DESCRIPTION"
}

# Get file version from package.yaml
get_file_version() {
  local package_yaml=$1
  local file_type=$2  # patterns, commands, designs
  local file_name=$3
  
  yq eval ".contents.${file_type}[] | select(.name == \"${file_name}\") | .version" "$package_yaml"
}
```

### 5. Integrate Manifest Writing into Installation Flow

Update `package-install.sh` main flow:

```bash
# Main installation flow
main() {
  local repo_url=$1
  
  # Initialize manifest
  init_manifest
  
  # Clone repository
  clone_repository "$repo_url"
  
  # Parse package metadata
  parse_package_metadata "temp-repo"
  
  # Get commit hash
  local commit_hash=$(cd temp-repo && git rev-parse HEAD)
  
  # Add package to manifest
  add_package_to_manifest "$PACKAGE_NAME" "$repo_url" "$PACKAGE_VERSION" "$commit_hash"
  
  # Install files
  for pattern_file in temp-repo/agent/patterns/*.md; do
    local file_name=$(basename "$pattern_file")
    local file_version=$(get_file_version "temp-repo/package.yaml" "patterns" "$file_name")
    
    # Copy file
    cp "$pattern_file" "agent/patterns/"
    
    # Add to manifest
    add_file_to_manifest "$PACKAGE_NAME" "patterns" "$file_name" "$file_version" "agent/patterns/$file_name"
  done
  
  # Repeat for commands and designs
  # ...
  
  # Cleanup
  rm -rf temp-repo
  
  echo "✅ Installation complete!"
  echo "Package $PACKAGE_NAME ($PACKAGE_VERSION) installed"
}
```

### 6. Test Manifest Creation

Test the manifest system:

```bash
# Test 1: Install first package
@acp.package-install https://github.com/test/acp-test.git

# Verify:
# - agent/manifest.yaml created
# - Package entry added
# - Files tracked with versions
# - Checksums calculated

# Test 2: Install second package
@acp.package-install https://github.com/test/acp-test2.git

# Verify:
# - Manifest updated (not overwritten)
# - Second package added
# - First package still present

# Test 3: Reinstall same package
@acp.package-install https://github.com/test/acp-test.git

# Verify:
# - Conflict detected
# - User prompted
# - Manifest updated if overwritten
```

### 7. Implement Manifest Validation

Add validation function:

```bash
# Validate manifest structure
validate_manifest() {
  local manifest="agent/manifest.yaml"
  
  if [ ! -f "$manifest" ]; then
    echo "No manifest found"
    return 1
  fi
  
  # Check required fields
  local manifest_version=$(yq eval '.manifest_version' "$manifest")
  if [ -z "$manifest_version" ]; then
    echo "Error: manifest_version missing"
    return 1
  fi
  
  # Validate each package entry
  local packages=$(yq eval '.packages | keys | .[]' "$manifest")
  for package in $packages; do
    # Check required fields
    local source=$(yq eval ".packages.${package}.source" "$manifest")
    local version=$(yq eval ".packages.${package}.package_version" "$manifest")
    
    if [ -z "$source" ] || [ -z "$version" ]; then
      echo "Error: Invalid package entry for $package"
      return 1
    fi
  done
  
  echo "✓ Manifest valid"
  return 0
}
```

### 8. Document Manifest Format

Update `commands/acp.package-install.md` to document manifest:

```markdown
## Manifest Tracking

When you install a package, `@acp.package-install` creates or updates `agent/manifest.yaml` to track:

- Package source (GitHub URL)
- Package version
- Git commit hash
- Installation timestamp
- Installed files with individual versions
- File checksums for modification detection

This enables:
- Smart updates (only changed files)
- Conflict detection (modified files)
- Team collaboration (commit manifest to git)
- Reproducible setups (install from manifest)
```

---

## Verification

- [ ] `agent/manifest.yaml` created on first install
- [ ] Manifest has correct structure (packages, manifest_version, last_updated)
- [ ] Package metadata tracked (source, version, commit, timestamps)
- [ ] Files tracked with name, version, checksum
- [ ] Checksums calculated correctly (SHA-256)
- [ ] Multiple packages can be tracked in same manifest
- [ ] Manifest validation works
- [ ] Reinstalling package updates manifest (not duplicates)
- [ ] Documentation updated
- [ ] No errors during installation

---

## Files to Create

1. `agent/manifest.template.yaml` - Manifest template
2. Functions in `scripts/package-install.sh`:
   - `init_manifest()`
   - `calculate_checksum()`
   - `add_package_to_manifest()`
   - `add_file_to_manifest()`
   - `parse_package_metadata()`
   - `get_file_version()`
   - `validate_manifest()`

---

## Files to Modify

1. `scripts/package-install.sh` - Add manifest writing
2. `commands/acp.package-install.md` - Document manifest

---

## Testing Checklist

- [ ] Install package creates manifest
- [ ] Manifest has correct YAML structure
- [ ] Package metadata is accurate
- [ ] File versions extracted from package.yaml
- [ ] Checksums calculated correctly
- [ ] Second package installation updates manifest
- [ ] Reinstalling package updates (not duplicates)
- [ ] Manifest validation catches errors
- [ ] Works with packages that have no package.yaml (graceful degradation)

---

## Common Issues

### Issue 1: yq not installed
**Solution**: Install yq (`brew install yq` or download from GitHub)

### Issue 2: Checksum mismatch on Windows
**Solution**: Normalize line endings (CRLF → LF) before checksum

### Issue 3: Manifest becomes invalid YAML
**Solution**: Validate before writing, create backup

---

## Related Tasks

- Task 6: Selective Installation (uses manifest)
- Task 7: Update System (reads manifest)
- Task 8: Package List (reads manifest)

---

**Status**: Ready to implement  
**Priority**: High (foundation for all other tasks)  
**Estimated Effort**: 6-8 hours
