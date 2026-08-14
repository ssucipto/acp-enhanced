#!/usr/bin/env bash
# acp.findings-import.sh — Import CodeRabbit findings → audit-carryovers (M81 / ADR-22)
#
# Usage:
#   bash agent/scripts/acp.findings-import.sh --input tests/fixtures/coderabbit-findings-sample.json
#   bash agent/scripts/acp.findings-import.sh --dry-run --input <file>
#
# v1: --input file only (no --pr / network). Silent no-op when ! coderabbit_active.
# Severity map: critical→critical, major→high, minor→medium, trivial→low;
#               high|medium|low pass through.

set -euo pipefail
trap 'echo "[acp.findings-import] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=acp.coderabbit.sh
source "${SCRIPT_DIR}/acp.coderabbit.sh"

DRY_RUN=false
INPUT=""

usage() {
  cat <<'EOF'
Usage: acp.findings-import.sh --input <file> [--dry-run]

Import CodeRabbit findings from a local JSON/NDJSON export into
agent/memory/audit-carryovers.md when coderabbit_active.

Options:
  --input <file>   Findings sample (required for active import)
  --dry-run        Print entries that would be appended; do not write
  -h, --help       Show help

Deferred (not in M81): --pr / live API fetch.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      if [[ $# -lt 2 ]]; then
        echo "[acp.findings-import] --input requires a path" >&2
        exit 2
      fi
      INPUT="$2"
      shift 2
      ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --pr)
      echo "[acp.findings-import] --pr is deferred (M81 v1 is --input only; F-101-05)" >&2
      exit 2
      ;;
    -*)
      echo "[acp.findings-import] Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      echo "[acp.findings-import] Unexpected argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

# Gate: inactive → hint (if enabled+absent) then silent success
if ! coderabbit_active; then
  coderabbit_hint_if_missing
  exit 0
fi

if [[ -z "${INPUT}" ]]; then
  echo "[acp.findings-import] ERROR: --input <file> is required when CodeRabbit is active" >&2
  exit 2
fi
if [[ ! -f "${INPUT}" ]]; then
  echo "[acp.findings-import] ERROR: input not found: ${INPUT}" >&2
  exit 1
fi

REPO_ROOT="$(_coderabbit_repo_root)"
CARRYOVERS="${REPO_ROOT}/agent/memory/audit-carryovers.md"
if [[ ! -f "${CARRYOVERS}" ]]; then
  mkdir -p "$(dirname "${CARRYOVERS}")"
  cat > "${CARRYOVERS}" <<'HDR'
# Audit Carryover Tracking
carryovers:
HDR
fi

# Parse + emit YAML blocks via Python (JSON + escaping). Exit codes: 0 ok, 1 fail.
IMPORT_OUT="$(
  INPUT_PATH="${INPUT}" CARRYOVERS_PATH="${CARRYOVERS}" DRY_RUN="${DRY_RUN}" python3 - <<'PY'
import hashlib, json, os, re, sys
from pathlib import Path

inp = Path(os.environ["INPUT_PATH"])
carry = Path(os.environ["CARRYOVERS_PATH"])
dry = os.environ.get("DRY_RUN", "false") == "true"

def map_sev(s: str) -> str:
    s = (s or "medium").strip().lower()
    return {
        "critical": "critical",
        "major": "high",
        "high": "high",
        "minor": "medium",
        "medium": "medium",
        "trivial": "low",
        "low": "low",
        "info": "low",
    }.get(s, "medium")

def one_line(s: str, n: int = 200) -> str:
    s = " ".join((s or "").split())
    return s if len(s) <= n else s[: n - 1] + "…"

def yq(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

def load_findings(path: Path):
    text = path.read_text(encoding="utf-8")
    # NDJSON: lines with type=finding
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    if lines and all(ln.startswith("{") for ln in lines) and any('"type"' in ln for ln in lines):
        # Prefer NDJSON only when every non-empty line is an object AND no top-level array wrapper
        try:
            first = json.loads(lines[0])
            if first.get("type") in ("finding", "status", "review_context", "complete", "heartbeat"):
                out = []
                for ln in lines:
                    try:
                        o = json.loads(ln)
                    except json.JSONDecodeError:
                        continue
                    if o.get("type") == "finding":
                        out.append(o)
                if out:
                    return out
        except json.JSONDecodeError:
            pass
    data = json.loads(text)
    if isinstance(data, dict) and "findings" in data:
        return list(data["findings"] or [])
    if isinstance(data, list):
        return data
    raise SystemExit(f"Unrecognized findings shape in {path}")

existing = carry.read_text(encoding="utf-8") if carry.exists() else ""
existing_ids = set(re.findall(r"finding_id:\s*(\S+)", existing))

findings = load_findings(inp)
added = 0
skipped = 0
blocks = []

for f in findings:
    if not isinstance(f, dict):
        continue
    # Skip non-finding rows if present
    if f.get("type") not in (None, "finding"):
        continue
    sev_raw = f.get("severity") or "medium"
    sev = map_sev(str(sev_raw))
    path = f.get("fileName") or f.get("file") or "e2e/"
    path = str(path)
    summary = f.get("codegenInstructions") or f.get("summary") or f.get("instruction") or "CodeRabbit finding"
    summary = one_line(str(summary), 180)
    sug = f.get("suggestions") or []
    fix = "TBD"
    if isinstance(sug, list) and sug:
        fix = one_line(str(sug[0]), 160)
    elif f.get("fix_target"):
        fix = one_line(str(f["fix_target"]), 160)

    material = f"{path}|{sev_raw}|{summary}"
    digest = hashlib.sha256(material.encode("utf-8")).hexdigest()[:12]
    fid = f"CR-{digest}"

    if fid in existing_ids:
        skipped += 1
        continue

    finding_line = one_line(f"{summary} (imported from CodeRabbit)", 200)
    block = (
        f"  - audit_id: coderabbit-import\n"
        f"    finding_id: {fid}\n"
        f"    severity: {sev}\n"
        f"    file: {yq(path)}\n"
        f"    finding: {yq(finding_line)}\n"
        f"    description: {yq(one_line(str(summary), 240))}\n"
        f"    fix_target: {yq(fix)}\n"
        f"    status: pending\n"
        f"    planned_in: M81\n"
        f"    fix_applied_date: null\n"
        f"    verified_in_audit: null\n"
        f"    escalated_to: null\n"
    )
    blocks.append(block)
    existing_ids.add(fid)
    added += 1

if dry:
    print(f"[acp.findings-import] dry-run: would add {added}, skip {skipped}")
    for b in blocks:
        print(b.rstrip())
    sys.exit(0)

if added == 0:
    print(f"[acp.findings-import] nothing to add (skipped_dup={skipped})")
    sys.exit(0)

text = carry.read_text(encoding="utf-8") if carry.exists() else "carryovers:\n"
if not re.search(r"(?m)^carryovers:\s*$", text) and "carryovers:" not in text:
    text = text.rstrip() + "\n\ncarryovers:\n"

appendix = "\n  # ── CODERABBIT IMPORT (acp.findings-import.sh) ──\n" + "".join(blocks)
# Append before EOF
carry.write_text(text.rstrip() + "\n" + appendix, encoding="utf-8")
print(f"[acp.findings-import] added={added} skipped_dup={skipped} → {carry}")
PY
)"

echo "${IMPORT_OUT}"
