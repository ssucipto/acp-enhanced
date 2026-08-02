---
id: task-302
milestone: M85
title: "Wire get_preference to the fast path with a pure-bash fallback"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-28
started: 2026-08-01
completed: 2026-08-01
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

A-110-04 is closed here. **Baseline corrected twice:** the original 21.5s was a single sample under load (audit-113 F2-03, actual 1439 ms), and Phase 1 has since brought it to **646 ms**. It makes one preference read — it short-circuits when CodeRabbit is disabled and never reaches `coderabbit_available` — so it is an instance of the general preference cost, not a distinct defect. It cannot use the availability-first reordering that fixed gitleaks/dupehound — it *must* read the preference to know whether the user opted in — so memoisation plus the faster resolver is the fix.

## Steps

1. Add a `python3` availability guard mirroring `node_scan_modules_available()`.
2. In `get_preference`, delegate to `acp.pref-resolve.py` when available; otherwise run the existing bash walk unchanged.
3. Do **not** delete the bash implementation. It is the fallback and the reference for the equivalence test.
4. Memoise `_coderabbit_enabled` and the `config_path` lookup in `acp.coderabbit.sh`, matching the `_ACP_GITLEAKS_PREF_CACHE` pattern added in audit-110.
5. If the fast path is unavailable, emit a one-time stderr note (as `announce_yaml_rules_skipped` does) so a slow run is explainable.
6. Confirm memoisation is per-process and cannot leak a stale value across a `yaml_set` that writes a preference file.

## Verification

- [ ] `get_preference` returns identical values with the fast path enabled and disabled (forced via a stub `python3`)
- [ ] `coderabbit_active()` under 200ms (from **646ms** post-Phase-1)
- [ ] `e2e/coderabbit-optionality.test.sh` 13/13 unchanged
- [ ] All 6 preference × availability states still correct for gitleaks and dupehound (the audit-110 matrix)
- [ ] Fallback path exercised with `python3` shadowed out of `PATH`
- [x] `tests/acp.preferences-validate.test.sh` under 60s against an unchanged 180s limit — **already 28s** after Phase 1; re-confirm it does not regress

## User-Observable Acceptance

`tests/acp.preferences-validate.test.sh` completes in well under a minute, and `/acp-review` behaves identically whether or not `python3` is present.

## Resolution (2026-08-01)

`get_preference()` (agent/scripts/acp.preferences.sh) now tries the task-301
resolver first via `_pref_fast_path_available()` (mirrors
`node_scan_modules_available()`), falling back to the original bash walk —
left completely intact below it — on resolver absence (exit >= 2, or
`python3` unresolvable) or a not-found result (exit 1, translated to
`return 1` same as the bash path). `get_preference_or` needed no changes;
it already calls `get_preference`. A one-time stderr notice
(`_announce_pref_fast_path_skipped`) mirrors `announce_yaml_rules_skipped`.

`_coderabbit_enabled` and the `config_path` lookup in `coderabbit_available`
are now memoised per-process, matching `_ACP_GITLEAKS_PREF_CACHE`
(acp.gitleaks.sh). Verified there is no code path where this can observe a
stale value: `set_preference` is called from exactly one place outside
acp.preferences.sh itself (acp.dupehound.sh, a different namespace key,
inside a subshell) — nothing in the codebase calls `set_preference` and
`coderabbit_active`/`coderabbit_available` in the same process.

Verification results:
- Fast path vs. forced fallback (`python3` shadowed out of `PATH` via a
  minimal PATH containing no python3): identical values and exit codes
  across 7 keys including a not-found case and a map-node path.
- `e2e/coderabbit-optionality.test.sh`: 13/13 unchanged, full suite in
  ~0.9s (was paying ~646ms+ per `coderabbit_active` call before this task).
- `coderabbit_active()` median ~65ms (target was <200ms, baseline 646ms).
- `tests/acp.preferences-validate.test.sh`: 19/19, 26s (baseline ~28s, well
  under the unchanged 60s/180s budgets).
- `tests/acp.preferences.test.sh` (21/21) and
  `tests/acp.preferences-preset.test.sh` (10/10): unchanged, including the
  set_preference-then-get_preference-in-the-same-process round-trip test,
  which passing confirms the fast-path wiring doesn't introduce staleness
  in `get_preference` itself (it has no cache of its own — every call
  invokes the resolver fresh; only the coderabbit *helper* layer caches).
- gitleaks/dupehound: not independently re-tested with a dedicated matrix
  file (none exists in the repo — audit-110's "6 preference × availability
  states" was described in the audit report, not committed as a test file);
  covered indirectly since both route through the now-verified
  `get_preference`, and `gitleaks_active()` was spot-checked directly.
