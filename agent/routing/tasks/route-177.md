---
id: route-177
title: Low-severity cleanups (L1-L4)
task_type: bash-script-fix
milestone: M62
complexity: low
executor: copilot
context_required:
  - skills/scripts.md
files_affected:
  - agent/core/network_whitelist.yml
  - agent/core/routing.yml
  - scripts/acp-dispatch.ts
  - agent/scripts/acp.git-provenance.sh
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Clear the four low-severity findings from the consolidated register.

## Context

L1-L4 from audit-065/066/067: cosmetic/hygiene items that don't block but improve correctness and convention adherence.

## Steps

1. **L1** — Set `reviewed_by` in `agent/core/network_whitelist.yml` (currently empty); update `last_reviewed`.
2. **L2** — Address `routing.yml` holding dynamic session state in a static/cached file: document the intended separation, or move dynamic `session:` state so the prompt-cached portion is stable (coordinate with route-159's surgical update).
3. **L3** — Replace dispatch's `split("\n- date:")` parsing of sessions/lessons with the YAML parser or a more robust parse (reduce format-drift fragility); covered partly by route-175 schemas.
4. **L4** — Migrate `acp.git-provenance.sh` team_members parsing from `grep`/`while read` to `yaml_get_array` from `acp.yaml-parser.sh` (scripts.md rule).
5. Run E2E + TS tests to confirm no regressions.

## Expected Output

### Files Modified
- `network_whitelist.yml`, `routing.yml` (or docs), `acp-dispatch.ts`, `acp.git-provenance.sh`

## Verification (double-verify)

- [ ] **Automated**: E2E + TS unit tests green after changes
- [ ] **Manual**: whitelist reviewed_by populated; git-provenance reads team_members via parser (verify with a multi-entry list)
- [ ] No grep-based YAML parsing remains in git-provenance.sh

## User-Observable Acceptance

- `/acp-validate` whitelist review warning cleared
- git-provenance correctly reads a multi-member team_members list

## Addresses

audit-065 L1/L2, audit-066 L3, audit-067 L4 (consolidated register L1-L4)
