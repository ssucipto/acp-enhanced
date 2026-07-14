#!/usr/bin/env bash
# E2E: version-update preserves project-owned files (M68)
# Uses ACP_UPSTREAM_ROOT — no network clone in CI (P-081-03)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

VERSION_UPDATE_SH="${PROJECT_ROOT}/agent/scripts/acp.version-update.sh"
TMPDIR_ROOT=""

cleanup() {
    [ -n "${TMPDIR_ROOT}" ] && [ -d "${TMPDIR_ROOT}" ] && rm -rf "${TMPDIR_ROOT}"
}
trap cleanup EXIT

print_suite_header "Version Update Preserve — E2E Tests"

TMPDIR_ROOT="$(mktemp -d)"

# Minimal project layout
mkdir -p "${TMPDIR_ROOT}/agent/core" "${TMPDIR_ROOT}/agent/memory" \
    "${TMPDIR_ROOT}/agent/routing/tasks" "${TMPDIR_ROOT}/agent/skills" \
    "${TMPDIR_ROOT}/agent/wiki" "${TMPDIR_ROOT}/agent/commands" \
    "${TMPDIR_ROOT}/agent/scripts"

cp "${PROJECT_ROOT}/agent/scripts/acp.common.sh" "${TMPDIR_ROOT}/agent/scripts/"
cp "${PROJECT_ROOT}/agent/scripts/acp.version-update.sh" "${TMPDIR_ROOT}/agent/scripts/"
cp "${PROJECT_ROOT}/agent/scripts/acp.cursor-commands-sync.sh" "${TMPDIR_ROOT}/agent/scripts/" 2>/dev/null || true
chmod +x "${TMPDIR_ROOT}/agent/scripts/"*.sh 2>/dev/null || true

grep "^\*\*Version\*\*:" "${PROJECT_ROOT}/AGENTS.md" > /dev/null
cp "${PROJECT_ROOT}/AGENTS.md" "${TMPDIR_ROOT}/AGENTS.md"

# Customized identity (must survive)
cat > "${TMPDIR_ROOT}/agent/core/identity.yml" << 'EOF'
project: consumer-project-custom-project
type: test
description: Custom identity for preserve E2E
stack:
  - primary: Bash
team: solo-developer
EOF

IDENTITY_BEFORE=$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")

# progress.yaml tier A — never touched
cat > "${TMPDIR_ROOT}/agent/progress.yaml" << 'EOF'
project:
  name: preserve-e2e
  version: 1.0.0
milestones: {}
EOF
PROGRESS_BEFORE=$(cat "${TMPDIR_ROOT}/agent/progress.yaml")

# Third-party command (P-081-01)
cat > "${TMPDIR_ROOT}/agent/commands/deploy.production.md" << 'EOF'
# Custom deploy command — must survive update
EOF
DEPLOY_BEFORE=$(cat "${TMPDIR_ROOT}/agent/commands/deploy.production.md")

# local.* skill (P-081-02)
cat > "${TMPDIR_ROOT}/agent/skills/local.custom.md" << 'EOF'
# Local skill extension
EOF
LOCAL_SKILL_BEFORE=$(cat "${TMPDIR_ROOT}/agent/skills/local.custom.md")

# Stale domain.yml (tier B — should preserve if differs)
echo "custom_domain_marker: true" > "${TMPDIR_ROOT}/agent/wiki/domain.yml"
DOMAIN_BEFORE=$(cat "${TMPDIR_ROOT}/agent/wiki/domain.yml")

# Manifest with extra package
cat > "${TMPDIR_ROOT}/agent/manifest.yaml" << 'EOF'
packages:
  acp-core:
    package_version: 0.0.0
    updated_at: "2020-01-01T00:00:00Z"
  my-package:
    package_version: 1.0.0
    source: https://example.com/pkg.git
manifest_version: 1.0.0
last_updated: "2020-01-01T00:00:00Z"
EOF

print_test_header "V1 — bash -n version-update.sh"
bash -n "${VERSION_UPDATE_SH}"
assert_true "version-update.sh syntax valid" $?

print_test_header "V2 — default update preserves identity.yml"
(
    cd "${TMPDIR_ROOT}"
    ACP_UPSTREAM_ROOT="${PROJECT_ROOT}" bash agent/scripts/acp.version-update.sh --yes
)
IDENTITY_AFTER=$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")
assert_equals "${IDENTITY_BEFORE}" "${IDENTITY_AFTER}" "identity.yml unchanged after update"

print_test_header "V3 — progress.yaml untouched (F-080-13)"
PROGRESS_AFTER=$(cat "${TMPDIR_ROOT}/agent/progress.yaml")
assert_equals "${PROGRESS_BEFORE}" "${PROGRESS_AFTER}" "progress.yaml unchanged"

print_test_header "V4 — third-party command preserved (P-081-01)"
DEPLOY_AFTER=$(cat "${TMPDIR_ROOT}/agent/commands/deploy.production.md")
assert_equals "${DEPLOY_BEFORE}" "${DEPLOY_AFTER}" "deploy.production.md preserved"

print_test_header "V5 — local.* skill preserved (P-081-02)"
LOCAL_SKILL_AFTER=$(cat "${TMPDIR_ROOT}/agent/skills/local.custom.md")
assert_equals "${LOCAL_SKILL_BEFORE}" "${LOCAL_SKILL_AFTER}" "local.custom.md preserved"

print_test_header "V6 — customized domain.yml preserved"
DOMAIN_AFTER=$(cat "${TMPDIR_ROOT}/agent/wiki/domain.yml")
assert_equals "${DOMAIN_BEFORE}" "${DOMAIN_AFTER}" "domain.yml preserved"

print_test_header "V7 — manifest retains my-package (tier D)"
assert_contains "$(cat "${TMPDIR_ROOT}/agent/manifest.yaml")" "my-package:" "my-package entry retained"

print_test_header "V8 — manifest acp-core version updated"
assert_contains "$(cat "${TMPDIR_ROOT}/agent/manifest.yaml")" "package_version:" "manifest has package_version"

print_test_header "V9 — framework command refreshed"
assert_file_exists "${TMPDIR_ROOT}/agent/commands/acp.init.md" "acp.init.md installed from upstream"

print_test_header "V10 — --diff makes no changes"
DIFF_MARKER="diff_mode_marker"
echo "${DIFF_MARKER}" > "${TMPDIR_ROOT}/agent/core/identity.yml"
(
    cd "${TMPDIR_ROOT}"
    ACP_UPSTREAM_ROOT="${PROJECT_ROOT}" bash agent/scripts/acp.version-update.sh --diff
)
assert_contains "$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")" "${DIFF_MARKER}" "--diff did not modify identity"

print_test_header "V11 — --preserve-project-core skips tier B overwrite"
echo "preserve_core_marker: true" > "${TMPDIR_ROOT}/agent/core/constraints.yml"
CONSTRAINTS_BEFORE=$(cat "${TMPDIR_ROOT}/agent/core/constraints.yml")
(
    cd "${TMPDIR_ROOT}"
    ACP_UPSTREAM_ROOT="${PROJECT_ROOT}" bash agent/scripts/acp.version-update.sh --preserve-project-core --yes
)
assert_equals "${CONSTRAINTS_BEFORE}" "$(cat "${TMPDIR_ROOT}/agent/core/constraints.yml")" "constraints preserved with --preserve-project-core"

print_test_header "V12 — AGENTS.md entry accepted (F-080-09)"
assert_file_exists "${TMPDIR_ROOT}/AGENTS.md" "AGENTS.md present after update"

print_test_summary "acp.version-update-preserve.test.sh"
exit $?
