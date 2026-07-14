#!/usr/bin/env bash
# E2E: install manifest merge preserves third-party packages (M68)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COMMON_SH="${PROJECT_ROOT}/agent/scripts/acp.common.sh"
TMPDIR_ROOT=""

cleanup() {
    [ -n "${TMPDIR_ROOT}" ] && [ -d "${TMPDIR_ROOT}" ] && rm -rf "${TMPDIR_ROOT}"
}
trap cleanup EXIT

print_suite_header "Install Preserve — E2E Tests"

TMPDIR_ROOT="$(mktemp -d)"
mkdir -p "${TMPDIR_ROOT}/agent/commands" "${TMPDIR_ROOT}/agent/patterns" \
    "${TMPDIR_ROOT}/agent/design"

touch "${TMPDIR_ROOT}/agent/commands/acp.init.md"
touch "${TMPDIR_ROOT}/agent/commands/git.commit.md"
touch "${TMPDIR_ROOT}/agent/patterns/foo.template.md"
touch "${TMPDIR_ROOT}/agent/design/bar.template.md"

cat > "${TMPDIR_ROOT}/agent/manifest.yaml" << 'EOF'
packages:
  acp-core:
    package_version: 6.0.0
    updated_at: "2020-01-01T00:00:00Z"
  my-package:
    package_version: 2.5.0
    source: https://example.com/my-package.git
scaffold:
  team_size: small
manifest_version: 1.0.0
last_updated: "2020-01-01T00:00:00Z"
EOF

MANIFEST_BEFORE_LINES=$(grep -c 'my-package' "${TMPDIR_ROOT}/agent/manifest.yaml" || true)

print_test_header "I1 — acp_install_manifest_acp_core preserves my-package"
(
    . "${COMMON_SH}"
    acp_install_manifest_acp_core "${TMPDIR_ROOT}" "6.24.0"
)
assert_contains "$(cat "${TMPDIR_ROOT}/agent/manifest.yaml")" "my-package:" "my-package retained after manifest refresh"
assert_contains "$(cat "${TMPDIR_ROOT}/agent/manifest.yaml")" "package_version: 6.24.0" "acp-core version updated"
assert_contains "$(cat "${TMPDIR_ROOT}/agent/manifest.yaml")" "scaffold:" "scaffold block preserved"

print_test_header "I2 — acp_list_basenames works without xargs (F-080-11)"
. "${COMMON_SH}"
_count=$(acp_list_basenames "${TMPDIR_ROOT}/agent/commands" "acp.*.md" | wc -l | tr -d ' ')
assert_equals "1" "${_count}" "basename list finds acp.init.md"

print_test_header "I3 — tier B preserve on reinstall (identity)"
mkdir -p "${TMPDIR_ROOT}/agent/core"
echo "project: custom-install-project" > "${TMPDIR_ROOT}/agent/core/identity.yml"
IDENTITY_BEFORE=$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")
(
    cd "${TMPDIR_ROOT}"
    export TEMP_DIR="${PROJECT_ROOT}"
    export ACP_DIFF_ONLY=false ACP_FORCE=false ACP_PRESERVE_PROJECT_CORE=false ACP_YES=true
    . "${COMMON_SH}"
    acp_copy_framework_file "agent/core/identity.yml" B
)
assert_equals "${IDENTITY_BEFORE}" "$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")" "identity preserved on tier B copy"

print_test_summary "acp.install-preserve.test.sh"
exit $?
