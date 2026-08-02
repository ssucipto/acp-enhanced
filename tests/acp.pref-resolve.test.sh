#!/usr/bin/env bash
# task-301 (M85): acp.pref-resolve.py — single-pass preference resolver.
# Proves it returns identical values to the bash get_preference() path
# (agent/scripts/acp.preferences.sh) it's meant to replace, across real
# preference keys and a synthetic 4-layer precedence fixture.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "${ROOT_DIR}/tests/common.sh"
. "${ROOT_DIR}/agent/scripts/acp.preferences.sh"

PY_RESOLVER="${ROOT_DIR}/agent/scripts/acp.pref-resolve.py"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# ── Part 1: real repo files, real keys — bash vs python must agree ────────
REAL_PROJECT="${ROOT_DIR}/agent/preferences/acp.default.yaml"
REAL_WORKSPACE="${ROOT_DIR}/.vscode/preferences/acp.yaml"
REAL_USER="${HOME}/.acp/agent/preferences/acp.default.yaml"
REAL_CONFIG="${ROOT_DIR}/agent/configurables/acp.configurables.yaml"

REAL_KEYS=(
    plan.draft.create_mode
    plan.batch.auto_confirm
    task.create.granularity
    task.create.auto_number
    validation.auto_fix.enabled
    validation.strict_mode.enabled
    output.verbosity.level
    git.auto_commit.enabled
    integrations.coderabbit.enabled
    integrations.coderabbit.config_path
    integrations.gitleaks.enabled
    integrations.dupehound.enabled
    integrations.dupehound.min_tokens
    integrations.dupehound.install_prompt_version
    plan.draft
    nonexistent.key.path
)

for key in "${REAL_KEYS[@]}"; do
    bash_val="$(get_preference acp "$key" 2>/dev/null)"; bash_exit=$?
    py_val="$(python3 "$PY_RESOLVER" acp "$key" "$REAL_PROJECT" "$REAL_WORKSPACE" "$REAL_USER" "$REAL_CONFIG" 2>/dev/null)"; py_exit=$?
    assert_equals "${bash_exit}:${bash_val}" "${py_exit}:${py_val}" "real key '$key' — bash and python agree"
done

# ── Part 2: synthetic 4-layer precedence fixture ───────────────────────────
cat > "${WORKDIR}/project.yaml" << 'EOF'
acp:
  test:
    key: project_value
EOF
cat > "${WORKDIR}/workspace.yaml" << 'EOF'
acp:
  test:
    key: workspace_value
EOF
cat > "${WORKDIR}/user.yaml" << 'EOF'
acp:
  test:
    key: user_value
EOF
cat > "${WORKDIR}/configurables.yaml" << 'EOF'
acp:
  test:
    key:
      default: configurables_value
EOF

_pref_project_file() { echo "${WORKDIR}/project.yaml"; }
_pref_workspace_file() { echo "${WORKDIR}/workspace.yaml"; }
_pref_user_file() { echo "${WORKDIR}/user.yaml"; }
_pref_configurables_file() { echo "${WORKDIR}/configurables.yaml"; }

run_layer_case() {
    local label="$1"
    local bash_val py_val bash_exit py_exit
    bash_val="$(get_preference acp test.key 2>/dev/null)"; bash_exit=$?
    py_val="$(python3 "$PY_RESOLVER" acp test.key "${WORKDIR}/project.yaml" "${WORKDIR}/workspace.yaml" "${WORKDIR}/user.yaml" "${WORKDIR}/configurables.yaml" 2>/dev/null)"; py_exit=$?
    assert_equals "${bash_exit}:${bash_val}" "${py_exit}:${py_val}" "$label"
}

run_layer_case "precedence: all 4 layers present (project wins)"
assert_equals "project_value" "$(python3 "$PY_RESOLVER" acp test.key "${WORKDIR}/project.yaml" "${WORKDIR}/workspace.yaml" "${WORKDIR}/user.yaml" "${WORKDIR}/configurables.yaml")" "precedence: project value is 'project_value'"

rm "${WORKDIR}/project.yaml"
run_layer_case "precedence: project removed (workspace wins)"

rm "${WORKDIR}/workspace.yaml"
run_layer_case "precedence: workspace removed (user wins)"

rm "${WORKDIR}/user.yaml"
run_layer_case "precedence: only configurables left (.default wins)"

rm "${WORKDIR}/configurables.yaml"
run_layer_case "precedence: nothing left (not found, exit 1)"

# ── Part 3: configurables layer uses .default suffix, not the bare path ───
cat > "${WORKDIR}/config-shape.yaml" << 'EOF'
acp:
  shape:
    key:
      id: 'shape.key'
      description: not the value
      default: the_real_default
      type: string
EOF
NOPE="${WORKDIR}/does-not-exist.yaml"
_pref_project_file() { echo "$NOPE"; }
_pref_workspace_file() { echo "$NOPE"; }
_pref_user_file() { echo "$NOPE"; }
_pref_configurables_file() { echo "${WORKDIR}/config-shape.yaml"; }
bash_val="$(get_preference acp shape.key 2>/dev/null)"
py_val="$(python3 "$PY_RESOLVER" acp shape.key "$NOPE" "$NOPE" "$NOPE" "${WORKDIR}/config-shape.yaml" 2>/dev/null)"
assert_equals "$bash_val" "$py_val" "configurables layer resolves via .default suffix (F2-02)"
assert_equals "the_real_default" "$py_val" "configurables .default value is correct, not 'description' or other sibling field"

# ── Part 4: flat-dot fallback (layers 1-3 only, not configurables) ────────
cat > "${WORKDIR}/flat.yaml" << 'EOF'
acp:
  other: value
  test.flat.key: 'flat_value_here'
EOF
cat > "${WORKDIR}/empty.yaml" << 'EOF'
EOF
_pref_project_file() { echo "${WORKDIR}/flat.yaml"; }
_pref_workspace_file() { echo "${WORKDIR}/empty.yaml"; }
_pref_user_file() { echo "${WORKDIR}/empty.yaml"; }
_pref_configurables_file() { echo "${WORKDIR}/empty.yaml"; }
bash_val="$(get_preference acp test.flat.key 2>/dev/null)"
py_val="$(python3 "$PY_RESOLVER" acp test.flat.key "${WORKDIR}/flat.yaml" "${WORKDIR}/empty.yaml" "${WORKDIR}/empty.yaml" "${WORKDIR}/empty.yaml" 2>/dev/null)"
assert_equals "$bash_val" "$py_val" "flat-dot fallback (project layer)"
assert_equals "flat_value_here" "$py_val" "flat-dot fallback value is correct"

# ── Part 5: runs without PyYAML, stdlib only ───────────────────────────────
# $PY_RESOLVER passed as sys.argv[1], NOT interpolated into the -c code
# string: Git Bash on Windows CI runners auto-translates POSIX-style paths
# (/d/a/...) to native ones (D:\a\...) for whole command-line ARGUMENTS
# passed to a non-MSYS binary, but has no way to find and translate a path
# buried as a substring inside a larger -c code blob — that surfaced as a
# FileNotFoundError only on windows-latest CI, never locally or on
# ubuntu/macos-latest.
py_import_check="$(python3 -c '
import ast, sys
tree = ast.parse(open(sys.argv[1]).read())
names = [n.names[0].name for n in ast.walk(tree) if isinstance(n, (ast.Import, ast.ImportFrom)) and getattr(n, "module", n.names[0].name)]
bad = [n for n in names if "yaml" in n.lower()]
print("BAD" if bad else "OK")
' "$PY_RESOLVER" 2>&1)"
assert_equals "OK" "$py_import_check" "acp.pref-resolve.py imports no yaml package"

# ── Part 6: median runtime with CI headroom (target from 854ms bash baseline) ──
# 250ms, not 100ms: Windows CI runners measured 135ms median for this exact
# call (still a 6x win over 854ms) — process-spawn overhead is well known to
# run higher there than on Unix. A tight local-only threshold is exactly the
# kind of hard-coded perf assertion audit-110 warned against: it would flake
# on the platform it was never measured against, and the instinctive fix
# (raise it just above the flaky figure) gives no margin at all. 250ms keeps
# real headroom while still proving the fast path, not the 854ms bash walk.
samples=()
for i in 1 2 3 4 5; do
    start="$(python3 -c 'import time; print(int(time.time()*1000))')"
    python3 "$PY_RESOLVER" acp integrations.gitleaks.enabled "$REAL_PROJECT" "$REAL_WORKSPACE" "$REAL_USER" "$REAL_CONFIG" > /dev/null 2>&1
    end="$(python3 -c 'import time; print(int(time.time()*1000))')"
    samples[${#samples[@]}]="$((end - start))"
done
median_ms="$(printf '%s\n' "${samples[@]}" | sort -n | awk '{a[NR]=$1} END {if (NR%2) print a[(NR+1)/2]; else print int((a[NR/2]+a[NR/2+1])/2)}')"
TESTS_RUN=$((TESTS_RUN + 1))
if [ "$median_ms" -lt 250 ]; then
    echo -e "${GREEN}✓${NC} median runtime ${median_ms}ms < 250ms target"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} median runtime ${median_ms}ms >= 250ms target"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

print_test_summary
exit $?
