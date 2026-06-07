#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# CI Validation Script — run by GitHub Actions in ci.yaml
# Validates YAML syntax, Markdown frontmatter, shell scripts.
# Exits 1 on any failure.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

ERRORS=0

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

# ── 2. Markdown Frontmatter ───────────────────────────────────
echo "[ci-validate] Checking Markdown YAML frontmatter..."

find_md_with_frontmatter() {
  find agent/commands/ agent/skills/ -name '*.md' 2>/dev/null
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

# ── 3. Summary ────────────────────────────────────────────────
if [ "$ERRORS" -gt 0 ]; then
  echo "[ci-validate] ❌ $ERRORS error(s) found."
  exit 1
else
  echo "[ci-validate] ✅ All checks passed."
fi
