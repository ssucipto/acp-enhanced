#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# CI Validation Script — run by GitHub Actions in ci.yaml
# Validates YAML syntax, Markdown frontmatter, shell scripts.
# Exits 1 on any failure.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

ERRORS=0
WARNINGS=0

# ── Prerequisites ─────────────────────────────────────────────
if ! python3 -c "import yaml" 2>/dev/null; then
  echo "[ci-validate] ❌ Python module 'yaml' (PyYAML) is not installed."
  echo "  Install with: python3 -m pip install pyyaml"
  exit 1
fi

# ── 1. YAML Syntax ────────────────────────────────────────────
echo "[ci-validate] Checking YAML syntax..."

find_yaml() {
  find agent/ -name '*.yaml' -o -name '*.yml' 2>/dev/null
}

while IFS= read -r f; do
  python3 -c "
import yaml, sys
try:
    with open('$f') as fh:
        yaml.safe_load(fh)
    print(f'  OK: $f')
except yaml.YAMLError as e:
    print(f'  FAIL: $f — {e}')
    sys.exit(1)
" || { ERRORS=$((ERRORS + 1)); }
done < <(find_yaml)

# ── 2. package.yaml ↔ command file count ───────────────────────
echo "[ci-validate] Checking package.yaml command parity..."

CMD_FILE_COUNT=$(find agent/commands -maxdepth 1 -name 'acp.*.md' ! -name '*.template.md' 2>/dev/null | wc -l | tr -d ' ')
PKG_CMD_COUNT=$(python3 -c "
import yaml
pkg = yaml.safe_load(open('package.yaml'))
cmds = [c['name'] for c in pkg['contents']['commands'] if c['name'].startswith('acp.')]
print(len(cmds))
")

if [ "$CMD_FILE_COUNT" != "$PKG_CMD_COUNT" ]; then
  echo "[ci-validate] ❌ package.yaml lists $PKG_CMD_COUNT acp.* commands but $CMD_FILE_COUNT files exist in agent/commands/"
  ERRORS=$((ERRORS + 1))
else
  echo "[ci-validate]   OK: $CMD_FILE_COUNT command files match package.yaml entries"
fi

# ── 3. Command doc structure (ACP command files) ──────────────
echo "[ci-validate] Checking ACP command doc structure..."

check_command_doc() {
  local f="$1"
  local base
  base=$(basename "$f")
  local failed=0

  if ! grep -q '^# Command:' "$f"; then
    echo "  FAIL: $f — missing '# Command:' heading"
    failed=1
  fi
  if ! grep -q '^\*\*Namespace\*\*:' "$f"; then
    echo "  FAIL: $f — missing **Namespace**:"
    failed=1
  fi
  if ! grep -q '^\*\*Version\*\*:' "$f"; then
    echo "  FAIL: $f — missing **Version**:"
    failed=1
  fi
  if ! grep -q '^\*\*Scripts\*\*:' "$f"; then
    echo "  FAIL: $f — missing **Scripts**:"
    failed=1
  fi
  if ! grep -q '^## Steps' "$f"; then
    echo "  WARN: $f — missing ## Steps (allowlisted until M62 route-174)"
    WARNINGS=$((WARNINGS + 1))
  fi
  if ! grep -q '^## Verification' "$f"; then
    echo "  WARN: $f — missing ## Verification (allowlisted until M62 route-174)"
    WARNINGS=$((WARNINGS + 1))
  fi

  if [ "$failed" -eq 0 ]; then
    echo "  OK: $f"
  else
    ERRORS=$((ERRORS + 1))
  fi
}

while IFS= read -r f; do
  check_command_doc "$f"
done < <(find agent/commands -maxdepth 1 -name 'acp.*.md' ! -name '*.template.md' 2>/dev/null | sort)

# ── 4. Markdown YAML frontmatter (skills, etc.) ───────────────
echo "[ci-validate] Checking Markdown YAML frontmatter..."

find_md_with_frontmatter() {
  find agent/skills/ -name '*.md' 2>/dev/null
}

while IFS= read -r f; do
  if head -1 "$f" | grep -q '^---$'; then
    python3 -c "
import yaml, sys
with open('$f') as fh:
    content = fh.read()
try:
    parts = content.split('---', 2)
    if len(parts) >= 3:
        yaml.safe_load(parts[1])
        print(f'  OK: $f')
    else:
        print(f'  SKIP (no closing ---): $f')
except yaml.YAMLError as e:
    print(f'  FAIL frontmatter: $f — {e}')
    sys.exit(1)
" || { ERRORS=$((ERRORS + 1)); }
  fi
done < <(find_md_with_frontmatter)

# ── 5. Summary ────────────────────────────────────────────────
if [ "$WARNINGS" -gt 0 ]; then
  echo "[ci-validate] ⚠️  $WARNINGS warning(s) (non-blocking until M62)."
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "[ci-validate] ❌ $ERRORS error(s) found."
  exit 1
else
  echo "[ci-validate] ✅ All checks passed."
fi
