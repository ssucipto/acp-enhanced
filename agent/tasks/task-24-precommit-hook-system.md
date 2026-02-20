# Task 24: Pre-Commit Hook System

**Milestone**: [M4 - ACP Package Development System](../milestones/milestone-4-package-development.md)
**Estimated Time**: 3-4 hours
**Dependencies**: Task 14 (YAML Schema)
**Status**: Not Started

---

## Objective

Create pre-commit hook system that validates package.yaml before allowing commits. Hook is automatically installed by @acp.package-create.

---

## Context

From clarifications:
- Automatically installed by @acp.package-create
- Start simple (package.yaml validation only)
- Document future enhancements
- No bypass mechanism
- Offer to fix validation errors

---

## Steps

### 1. Create Hook Template

Create pre-commit hook template:

**Template**:
```bash
#!/bin/sh
# ACP Package Pre-Commit Hook
# Validates package.yaml before allowing commit

# Source validation script
. ./agent/scripts/acp.yaml-validate.sh

# Validate package.yaml
if [ -f "package.yaml" ]; then
    if ! validate_yaml_file "package.yaml" "agent/schemas/package.schema.yaml"; then
        echo "Error: package.yaml validation failed"
        echo "Fix errors and try again"
        exit 1
    fi
fi

# Future enhancements:
# - Namespace consistency checking
# - CHANGELOG.md validation for version changes
# - File existence verification

exit 0
```

### 2. Implement Hook Installation

Add install_precommit_hook() to common.sh:

**Implementation**:
```bash
# Install pre-commit hook
# Usage: install_precommit_hook
install_precommit_hook() {
    local hook_file=".git/hooks/pre-commit"
    
    # Create hook from template
    cat > "$hook_file" << 'EOF'
[hook template here]
EOF
    
    # Make executable
    chmod +x "$hook_file"
    
    echo "${GREEN}✓${NC} Installed pre-commit hook"
}
```

### 3. Test Hook

Test pre-commit hook:
- Test with valid package.yaml (commit succeeds)
- Test with invalid package.yaml (commit blocked)
- Test error messages

### 4. Document Hook System

Update documentation:
- Document in package README.md
- Add to design doc
- Explain how to disable if needed

---

## Verification

- [ ] Pre-commit hook template created
- [ ] install_precommit_hook() implemented
- [ ] Hook validates package.yaml
- [ ] Hook blocks invalid commits
- [ ] Error messages are helpful
- [ ] Documentation updated

---

**Next Task**: None (Milestone 4 complete after this task)
