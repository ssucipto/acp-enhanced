# Audit Report: M78 CodeRabbit Optionality Foundation — Pre-Implementation Readiness

**Audit**: #98
**Date**: 2026-07-23
**Subject**: Pre-implementation readiness of all plans created today — M78 milestone, tasks 255–260, ADR-20, ADR-21 — before `/acp-proceed task-255`
**Mode**: --pre-impl

## Summary

Cross-referenced every task in M78 against the actual codebase (preferences engine, common.sh sourcing graph, e2e harness, doc conventions, version stamping). The plan is **structurally sound and ADR-compliant** (validate green, all file pointers resolve, no M74–M77 entries leaked). Phase 2 surfaced **one blocking implementation error** (F-098-01, circular source) and six correctness/consistency improvements. None require re-opening ADR-19 or ADR-21's decisions — they are implementation-location and scoping corrections. **Verdict: READY AFTER AMENDMENTS** (applied this session via `/acp-plan`).

## Pre-Implementation Readiness (M78)

**Mode**: --pre-impl

### Phase 1 — Plan Correctness
| Check | Result | Notes |
|-------|--------|-------|
| Milestone + 6 task files exist, criteria unambiguous | ✅ | validate: file pointers all resolve |
| ADR-20 (backfill) + ADR-21 present & valid | ✅ | decisions.schema: 21 entries valid |
| files_affected accurate | ⚠️ | task-256 targets `acp.common.sh` (wrong — F-098-01); task-259 targets nonexistent `agent/docs/` (F-098-02) |
| Open blockers | ❌ F-098-01 | task-256 unimplementable as written (circular source) |

### Phase 2 — Code Cross-Reference (key phase)
| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| acp.preferences.sh:83 | `get` subcommand + `get_preference` sourced API | ✅ | task-255/256 interface correct |
| acp.preferences.sh:92 | `integrations.coderabbit.enabled` nesting depth | ✅ | identical shape to `plan.draft.create_mode` — resolves |
| acp.preferences.sh:32 | **preferences.sh sources common.sh** | ❌ | **F-098-01**: common.sh cannot call `get_preference` (circular) |
| acp.preferences.sh:394 | boolean validate = exactly true/false | ✅ | default `false` validates; but non-empty ⇒ F-098-03 |
| acp.common.sh | sources preferences.sh? | ❌ | it does NOT — confirms helper cannot live here |
| agent/docs/ | directory exists? | ❌ | **F-098-02**: absent; how-to docs live in `agent/wiki/` |
| agent/wiki/*-integration.md | doc-location precedent | ✅ | claude-integration.md, cursor-integration.md → coderabbit-integration.md |
| run-e2e-tests.sh:90 | test discovery | ✅ | globs `e2e/*.test.sh` — **F-098-05**: no manual CI registration needed |
| e2e/acp.audit.test.sh | harness (`tests/common.sh`, asserts) | ✅ | task-258 sourcing correct |
| CI e2e-tests.yaml | `run-e2e-tests.sh --skip-network` | ✅ | test must stay offline (it is) |
| coderabbit CLI name (`command -v coderabbit`) | verified? | ⚠️ | **F-098-04**: unverified vendor assumption |

### Phase 3 — Carryover Check
| Carryover | Severity | Status | Blocks? |
|-----------|----------|--------|---------|
| F-097-01: optionality contract | low | pending (planned_in M78) | No — M78 addresses it |
| F-086-02: FIFOZ /acp-version-update downstream | medium | pending | No — needs consumer repo access, unrelated |

### Phase 4 — Operational Completeness
| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ⚠️ | **F-098-06**: route-244..249 referenced, none on disk (validate doesn't require; M73 had them) |
| Version bump planned | ⚠️ | **F-098-07**: task-260 under-specifies — 10 files carry version; use `/acp-version-update` |
| Wiki/docs update planned | ⚠️ | doc belongs in wiki (F-098-02); follow `/acp-wiki-update` |
| CHANGELOG entry planned | ✅ | task-260 |
| No gated work in scope | ✅ | leak-check gate present; but `generate_on_commit` key is dormant (F-098-04) |

### Phase Summary
| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 2 | high |
| Phase 2 — Code Cross-Reference | 4 | high |
| Phase 3 — Carryover Check | 0 new | — |
| Phase 4 — Operational Completeness | 3 | low |
| **Total** | **7 unique** | **high** |

## Key Findings (actionable)

| ID | Sev | Finding | Fix |
|----|-----|---------|-----|
| F-098-01 | **high** | task-256/ADR-21 put `coderabbit_available/active` in `acp.common.sh`, but preferences.sh **sources** common.sh (line 32) → calling `get_preference` from common.sh is a circular source | Create dedicated `agent/scripts/acp.coderabbit.sh` that sources `acp.preferences.sh`; helpers live there. Amend task-256, milestone map, ADR-21 location phrase |
| F-098-02 | medium | task-259 targets `agent/docs/working-with-coderabbit.md`; `agent/docs/` does not exist | Relocate to `agent/wiki/coderabbit-integration.md` (matches claude/cursor-integration precedent); follow `/acp-wiki-update` |
| F-098-03 | medium | boolean `enabled=false` resolves as non-empty "false"; presence checks misread it as "set" | task-256 must compare `[[ "$(get_preference …)" == "true" ]]`; never use `has_preference` for `enabled` |
| F-098-04 | medium | Speculative vendor assumptions: `command -v coderabbit` CLI name unverified; `generate_on_commit` reserves a gated-generator key with no consumer (ADR-19 "no speculative interface") | M78 detection = config-file presence only (defer CLI detect to adoption); drop `generate_on_commit` from M78 — reserve only `enabled` + `config_path` (both have live detection consumers) |
| F-098-05 | low | task-258 "register test in CI" step is wrong — runner auto-discovers `e2e/*.test.sh` | Remove step; note auto-discovery + offline (`--skip-network`) requirement |
| F-098-06 | low | route-244..249 referenced but no route files on disk | Note "routes created at `/acp-dispatch` time" in milestone, or create stubs; not validate-blocking |
| F-098-07 | low | task-260 version bump under-specified (10 stamped files; header-sync gate) | Reference `/acp-version-update`; enumerate CLAUDE/AGENT/AGENTS/README/CHANGELOG/package.yaml/progress/identity |

## Code Pointers

| Location | Description |
|----------|-------------|
| agent/scripts/acp.preferences.sh:32 | `source acp.common.sh` — the circular-source constraint (F-098-01) |
| agent/scripts/acp.preferences.sh:83-137 | `get_preference` precedence resolution — the API helpers must use |
| agent/scripts/acp.preferences.sh:394 | boolean validate (exactly true/false) — informs F-098-03 |
| run-e2e-tests.sh:90 | `for test_file in e2e/*.test.sh tests/*.test.sh` — auto-discovery (F-098-05) |
| agent/wiki/claude-integration.md | doc-location precedent for F-098-02 |

## Recommendations

1. Apply F-098-01..07 to M78 via `/acp-plan` amendment **before** `/acp-proceed task-255` — F-098-01 alone would block task-256.
2. Keep ADR-19/ADR-21 decisions intact; only correct ADR-21's factual helper-location phrase (common.sh → acp.coderabbit.sh), citing this audit.
3. Re-run `/acp-validate` after amendment to confirm green.
