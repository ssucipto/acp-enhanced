#!/usr/bin/env bash
# acp.recurring-complete.sh — Mark a recurring task complete and advance next_due (F-068-03 / F-062-03)
#
# Usage: acp.recurring-complete.sh --id <task-id> [--findings-count N] [--date YYYY-MM-DD]
#
# Updates agent/progress.yaml recurring_tasks: last_run, next_due (from frequency), status.

set -euo pipefail
trap 'echo "Error: recurring-complete.sh failed at line $LINENO" >&2; exit 3' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PROGRESS_FILE="${PROJECT_ROOT}/agent/progress.yaml"

TASK_ID=""
FINDINGS_COUNT=""
RUN_DATE="$(date +%Y-%m-%d)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) TASK_ID="$2"; shift 2 ;;
    --findings-count) FINDINGS_COUNT="$2"; shift 2 ;;
    --date) RUN_DATE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: acp.recurring-complete.sh --id <task-id> [--findings-count N] [--date YYYY-MM-DD]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$TASK_ID" ]]; then
  echo "Error: --id required" >&2
  exit 2
fi

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 required" >&2
  exit 2
fi

python3 - "$PROGRESS_FILE" "$TASK_ID" "$RUN_DATE" "${FINDINGS_COUNT:-}" <<'PY'
import sys
from datetime import date, timedelta

try:
    import yaml
except ImportError:
    print("Error: PyYAML required (pip install pyyaml)", file=sys.stderr)
    sys.exit(2)

path, task_id, run_date_s, findings_s = sys.argv[1:5]
run_date = date.fromisoformat(run_date_s)

with open(path, encoding="utf-8") as f:
    data = yaml.safe_load(f)

tasks = data.get("recurring_tasks") or []
found = False
for t in tasks:
    if t.get("id") != task_id:
        continue
    found = True
    freq = (t.get("frequency") or "").lower()
    if freq == "weekly":
        next_due = run_date + timedelta(days=7)
    elif freq == "monthly":
        next_due = run_date + timedelta(days=30)
    else:
        next_due = None
    t["last_run"] = run_date_s
    if next_due is not None:
        t["next_due"] = next_due.isoformat()
        t["status"] = "current"
    if findings_s:
        t["last_findings_count"] = int(findings_s)
    break

if not found:
    print(f"Error: recurring task id not found: {task_id}", file=sys.stderr)
    sys.exit(1)

with open(path, "w", encoding="utf-8") as f:
    yaml.dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

print(f"✓ recurring_tasks.{task_id}: last_run={run_date_s}, next_due updated")
PY
