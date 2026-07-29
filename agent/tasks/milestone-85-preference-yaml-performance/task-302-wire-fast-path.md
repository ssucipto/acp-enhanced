---
id: task-302
milestone: M85
title: "Wire get_preference to the fast path with a pure-bash fallback"
status: not_started
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-28
started: null
completed: null
phase: 2
depends_on: [task-301]
audit_findings: [A-110-04, A-110-05]
files_affected:
  - agent/scripts/acp.preferences.sh
  - agent/scripts/acp.coderabbit.sh
---

## Objective

Route `get_preference` / `get_preference_or` through the resolver when `python3` is available, keep the bash path when it is not, and memoise the CodeRabbit helpers.

## Context

`identity.yml` sets `no_external_deps: pure bash preferred`, so the fast path must degrade rather than hard-depend. The pattern already exists in this repo: `node_scan_modules_available()` guards the YM rules and, since audit-108, warns once when it skips so a degraded run is never mistaken for a clean one.

A-110-04 is closed here: `coderabbit_active()` costs 21.5s (`_coderabbit_enabled` 13.8s + `coderabbit_available` 5.5s), neither memoised. It cannot use the availability-first reordering that fixed gitleaks/dupehound — it *must* read the preference to know whether the user opted in — so memoisation plus the faster resolver is the fix.

## Steps

1. Add a `python3` availability guard mirroring `node_scan_modules_available()`.
2. In `get_preference`, delegate to `acp.pref-resolve.py` when available; otherwise run the existing bash walk unchanged.
3. Do **not** delete the bash implementation. It is the fallback and the reference for the equivalence test.
4. Memoise `_coderabbit_enabled` and the `config_path` lookup in `acp.coderabbit.sh`, matching the `_ACP_GITLEAKS_PREF_CACHE` pattern added in audit-110.
5. If the fast path is unavailable, emit a one-time stderr note (as `announce_yaml_rules_skipped` does) so a slow run is explainable.
6. Confirm memoisation is per-process and cannot leak a stale value across a `yaml_set` that writes a preference file.

## Verification

- [ ] `get_preference` returns identical values with the fast path enabled and disabled (forced via a stub `python3`)
- [ ] `coderabbit_active()` under 200ms (from 21.5s)
- [ ] `e2e/coderabbit-optionality.test.sh` 13/13 unchanged
- [ ] All 6 preference × availability states still correct for gitleaks and dupehound (the audit-110 matrix)
- [ ] Fallback path exercised with `python3` shadowed out of `PATH`
- [ ] `tests/acp.preferences-validate.test.sh` under 60s against an unchanged 180s limit

## User-Observable Acceptance

`tests/acp.preferences-validate.test.sh` completes in well under a minute, and `/acp-review` behaves identically whether or not `python3` is present.
