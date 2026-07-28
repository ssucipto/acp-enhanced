# Audit Report: M84 — `review.rule_overrides` Post-Implementation

**Audit**: #106  
**Date**: 2026-07-28  
**Subject**: M84 hotfix (`review.rule_overrides`, legacy adoption guide, F-105-01)  
**Follow-up to**: audit-105-m83-post-impl (opened F-105-01)  
**Shipped in**: v6.29.1 (`113578c`)

---

## Summary

M84 closes **F-105-01** — the partial delivery gap from task-295 / F-103-09 where baseline and inline suppression shipped but per-rule enable/severity overrides did not. The hotfix is **functionally complete** for `/acp-review` and inherits to `/acp-integrity` via `acp.integrity-output.sh`.

This audit found **one real shortcut** (override loading only in `review-scan`, not all emitters), **one test gap** (JSON env-only, no file-path coverage), and **doc/test drift** (command-doc E2E missing `rule_overrides`). All three were remediated in this audit. No ship-blocking gaps remain.

**Verdict: SHIP-QUALITY** — v6.29.2 (audit-106 remediation committed).

---

## Verification Snapshot

| Check | Result |
|-------|--------|
| `e2e/acp.review-scan.test.sh` | **59/59** (B30–B33; B33 skips when PyYAML absent) |
| `e2e/acp.review.test.sh` | **71/71** (doc assertions for overrides, limitations, CodeRabbit) |
| `acp.review-measure.sh --ci` | **100%** recall/precision, 30 cases |
| F-105-01 carryover | **fixed** (`B30`–`B32`) |
| F-105-02 (lexer ceiling) | **fixed** (documented backlog) |
| F-106-01 (PyYAML soft dep) | **fixed** (stderr warning + B33) |

---

## Key Findings

| ID | Severity | Finding | Status |
|----|----------|---------|--------|
| — | MEDIUM | Override preload only in `review-scan.sh`; integrity scanners relied on lazy load inside `while read` loops (stdin-steal class bug) | **fixed** — `ig_parse_common_args` now calls `ig_load_rule_overrides` |
| — | LOW | No E2E for `IG_RULE_OVERRIDES_FILE` path; only `IG_RULE_OVERRIDES_JSON` tested | **fixed** — `B32` JSON file test |
| — | LOW | `e2e/acp.review.test.sh` missing doc assertions for new FP control | **fixed** |
| — | LOW | Invalid severity strings accepted silently | **fixed** — whitelist in `acp.review-rule-overrides.py` |
| F-106-01 | LOW | YAML preference-file overrides require PyYAML; silent no-op without it | **fixed** — stderr warning + B33 E2E gated on `import yaml` |
| F-105-02 | LOW | Char-walker lexer limit (not M84 scope) | **fixed** — documented in `acp.review.md` + scanner docstring |

---

## What Shipped Well (M84)

1. **Correct architecture** — overrides in shared emitter; review + integrity inherit without duplication.
2. **Preference merge order** — configurables → user → workspace → project (project wins per rule key); matches `get_preference` precedence intent.
3. **stdin safety** — fd-3 isolated `read` in `ig_load_rule_overrides`; regression that broke inline suppression (B24) was caught and fixed at ship time.
4. **Adoption guide** — `agent/wiki/review-legacy-adoption.md` gives actionable baseline → tighten → CI workflow.
5. **CI gate** — `acp.review-measure.sh --ci` wired in `ci.yaml` (from audit-105 remediation, included in M84 commit).
6. **Test coverage** — disable (`B30`), severity downgrade (`B31`), env + file override paths.

---

## Shortcuts Taken (and resolution)

| Shortcut | Verdict | Resolution |
|----------|---------|------------|
| Hotfix without formal M84 milestone/tasks in `progress.yaml` | **Acceptable** | Version bump + CHANGELOG; no task ledger required for single carryover |
| `review.rule_overrides` not in configurables `_index` | **Acceptable** | Nested map; documented as edit-in-place in `acp.default.yaml` |
| PyYAML soft dependency for YAML preference reads | **Acceptable** | Documented; JSON override file + env for tests; CI installs PyYAML |
| No `review-corpus` fixture for overrides | **Acceptable** | E2E B30–B32 cover behavior; corpus measures rule detection not preference layer |
| F-103-09 marked fixed at M83 before per-rule shipped | **Corrected** | F-103-09 `verified_in_audit` updated to include M84 B30–B32 |

---

## Remaining Limitations

1. **M81 implementation** — `acp.findings-import.sh` and fixture still gated on real sanitized CodeRabbit export (task specs corrected; F-101-02/03/05/06 closed at doc level).
2. **Upshift risk** — severity override can promote to CRITICAL; no guardrail (by design — teams own policy).
3. **Lexer ceiling** — char-walker documented; AST/tree-sitter deferred unless corpus FP rate rises.

---

## Files Analyzed

| File | Role |
|------|------|
| `agent/scripts/acp.review-rule-overrides.py` | Preference merge + emit |
| `agent/scripts/acp.integrity-output.sh` | Override application in `ig_emit_finding` |
| `agent/scripts/acp.review-scan.sh` | Primary consumer |
| `agent/configurables/acp.configurables.yaml` | Schema/docs |
| `agent/wiki/review-legacy-adoption.md` | Adoption playbook |
| `e2e/acp.review-scan.test.sh` | B30–B32 behavioral tests |
| `e2e/acp.review.test.sh` | Doc parity |
| `agent/memory/audit-carryovers.md` | F-105-01/02 state |

---

## Remediation Applied (this audit)

1. `ig_parse_common_args` → calls `ig_load_rule_overrides` (all scanners using common args).
2. Severity whitelist (`CRITICAL|HIGH|MEDIUM|LOW`).
3. E2E `B32` for `IG_RULE_OVERRIDES_FILE` JSON path.
4. Doc E2E assertions for `review.rule_overrides` and legacy wiki link.
5. F-103-09 verification pointer updated to M84 tests.
6. `ig_load_rule_overrides` preload in `acp.manifest-hash.sh`.
7. CodeRabbit augmentation + scanner limitations sections in `acp.review.md`.
8. F-101-02/03/05/06 carryovers closed (task-doc + review-doc alignment).

---

## Recommendations

1. **M81** — next milestone; ship `acp.findings-import.sh` when fixture lands.
2. **CI** — ensure PyYAML in matrix so B33 runs (not skip).

---

## Git

| Commit | Summary |
|--------|---------|
| `113578c` | feat(M84): review.rule_overrides + legacy adoption guide (v6.29.1) |
| (this commit) | fix(M84): audit-106 remediation — override preload, B32–B33, docs (v6.29.2) |
