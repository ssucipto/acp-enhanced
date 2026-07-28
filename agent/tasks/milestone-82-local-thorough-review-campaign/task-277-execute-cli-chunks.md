---
id: task-277
milestone: M82
title: "Execute chunked CodeRabbit CLI reviews"
status: completed
priority: 5
complexity: high
estimated_hours: 4
created: 2026-07-24
started: null
completed: 2026-07-24
depends_on: [task-276]
files_affected:
  - agent/reports/coderabbit-local-*/
---

## Objective

Execute the playbook’s chunked CodeRabbit CLI reviews against this local repo and capture sanitized `--agent` JSON artifacts.

## Steps

1. Create `agent/reports/coderabbit-local-YYYY-MM-DD/` (campaign date).
2. For each chunk in the playbook:
   - Prefer a real diff window (`--base` / `--base-commit`) that touches that tree
   - If “No changes detected”, pick a historical SHA window (tags between v6.27.0–HEAD or directory-touching commits)
   - If “too many files”, subdivide `--dir`
   - Run with `--agent`; save stdout/artifact as `chunk-<name>.json`
3. Run `coderabbit review findings` per chunk if useful; store summaries.
4. Sanitize: strip emails, tokens, absolute home paths, private org URLs where needed.
5. Write `MANIFEST.md` listing commands run, exit status, finding counts.

## Verification

- [ ] ≥3 chunk artifacts committed (or stored then committed after sanitize)
- [ ] MANIFEST lists exact commands (reproducible)
- [ ] No secrets in committed JSON

## User-Observable Acceptance

Campaign directory contains reproducible CLI review outputs for the major code surfaces.
