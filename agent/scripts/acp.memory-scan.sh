#!/usr/bin/env bash
# acp.memory-scan.sh — Memory vs constraints prep for Phase 2 LLM analysis (M58)
# Part of /acp-integrity v2.0
#
# Covered rules: IG-58–IG-62 (preparatory — LLM performs semantic comparison)

set -euo pipefail
trap 'echo "Error: memory-scan.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONSTRAINTS="${PROJECT_ROOT}/agent/core/constraints.yml"
MEMORY_DIR="${PROJECT_ROOT}/agent/memory"

if [[ ! -f "$CONSTRAINTS" ]]; then
  echo "Error: constraints.yml not found at $CONSTRAINTS" >&2
  exit 2
fi

if [[ ! -d "$MEMORY_DIR" ]]; then
  echo "Error: agent/memory/ not found" >&2
  exit 2
fi

python3 -c "
import yaml
from pathlib import Path

root = Path('${PROJECT_ROOT}')
constraints_path = root / 'agent/core/constraints.yml'
memory_dir = root / 'agent/memory'

constraints = yaml.safe_load(constraints_path.read_text(encoding='utf-8'))
hard_rules = []
for item in constraints.get('rules', []) or []:
    if isinstance(item, dict):
        for k, v in item.items():
            hard_rules.append({'id': k, 'text': str(v).strip()})
    elif isinstance(item, str):
        hard_rules.append({'id': item, 'text': item})

entries = []
for path in sorted(memory_dir.glob('*.md')):
    text = path.read_text(encoding='utf-8', errors='replace')
    entries.append({
        'file': str(path.relative_to(root)).replace('\\\\', '/'),
        'bytes': len(text.encode('utf-8')),
        'preview': text[:500].replace('\\n', ' ')[:200],
    })

out = {
    'phase2': 'memory-scan',
    'verdict_hint': 'REQUIRES_HUMAN_REVIEW',
    'max_confidence': 'LOW',
    'constraints_hard_rules': hard_rules,
    'memory_files': entries,
}
print(yaml.dump(out, default_flow_style=False, allow_unicode=True))
" 2>&1

exit 0
