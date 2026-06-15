---
id: route-157
title: "M58-003: Scripts — memory-scan.sh + taint-scan.sh"
task_type: bash-script-create
milestone: M58
complexity: medium
executor: copilot
context_required: [milestones/milestone-58-acp-integrity-v2-semantic-analysis.md, routes 155-156]
files_affected: [agent/scripts/acp.memory-scan.sh, agent/scripts/acp.taint-scan.sh]
tokens_est: 8000
created: 2026-06-08
completed: 2026-06-15
---

# Route 157: Phase 2 Scripts — Memory Scanner + Taint Extractor

## Objective

Create two supporting scripts for Phase 2 semantic analysis. These are *preparatory* scripts — they extract structured data for the LLM to reason about, following the LLM/Script Boundary Rule.

## Expected Output

### Files Created
- `agent/scripts/acp.memory-scan.sh` — Semantic contradiction preparation script
- `agent/scripts/acp.taint-scan.sh` — Taint source/sink pattern extractor

## Script Specifications

### acp.memory-scan.sh
- **Purpose**: Extract `agent/memory/` entries and `constraints.yml` hard rules for LLM comparison
- **Input**: None (reads from fixed paths)
- **Output**: Structured YAML with memory entries side-by-side with constraints
- **Exit codes**: 0 = extracted successfully, 2 = files missing, 3 = internal error
- **Rules covered**: IG-58–IG-62 (preparatory only — LLM does the semantic analysis)

### acp.taint-scan.sh
- **Purpose**: Extract taint sources and sinks from source files for LLM cross-file tracing
- **Input**: File or directory
- **Output**: `<file>:<line> <type> <identifier>` — one per source/sink found
- **Taint sources detected**: `req.query`, `req.body`, `req.params`, `process.env`, `argv`, `window.location`
- **Taint sinks detected**: `db.query`, `exec(`, `spawn(`, `fs.readFile`, `res.redirect`, `eval(`
- **Exit codes**: 0 = clean, 1 = sources/sinks found (informational)
- **Rules covered**: IG-45–IG-50 (preparatory only)

## Implementation Requirements

- `set -euo pipefail` + `trap ERR`
- bash 3.2+ compatible (no associative arrays)
- Pass parameters via environment variables (not string interpolation)
- Python3 optional — use grep patterns as primary, Python for complex parsing

## Verification

- [ ] Both scripts pass `bash -n`
- [ ] Both scripts have `trap ERR`
- [ ] `acp.memory-scan.sh` extracts entries from `agent/memory/` correctly
- [ ] `acp.memory-scan.sh` handles missing `constraints.yml` gracefully (exit 2, message)
- [ ] `acp.taint-scan.sh` extracts sources and sinks from fixture files
- [ ] `acp.taint-scan.sh` handles empty directories gracefully

## User-Observable Acceptance

- `acp.memory-scan.sh` outputs structured data for LLM comparison
- `acp.taint-scan.sh src/` lists all taint sources and sinks
