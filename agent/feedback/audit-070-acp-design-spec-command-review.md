# Audit Report: `/acp-design-spec` Command (acp.design-spec.md)

**Audit**: #070  
**Date**: 2026-06-06  
**Subject**: `agent/commands/acp.design-spec.md` — gaps, inconsistencies, industry alignment, ACP framework fit  
**Baseline**: v1.0.0 (400 lines); exemplar `design-spec-app-interfaces-m15-spine-v2.1.md`; peer commands `acp.report.md`, `acp.audit.md`, `acp.design-create.md`  
**Deliverable**: v1.1.0 command update + `feedback-005` for upstream team  

---

## Summary

The v1.0.0 `/acp-design-spec` command was a **strong first draft** — correct positioning vs `/acp-report` and `/acp-audit`, solid industry standards table, and a workable 12-step workflow. Production use on FIFOZ (M15 spine spec v2 → v2.1, audit-068/069) exposed **template–exemplar drift**, **missing ACP framework integration**, and **FIFOZ-specific assumptions** that would block upstream adoption.

**Verdict**: v1.1.0 addresses all HIGH/MEDIUM findings. Ship feedback-005 to ACP Enhanced for framework distribution (E2E test, routing.yml, template file, taxonomy).

---

## Files Analyzed

| File | Role |
|------|------|
| `agent/commands/acp.design-spec.md` | Subject — v1.0.0 → v1.1.0 |
| `agent/reports/design-spec-app-interfaces-m15-spine-v2.1.md` | Exemplar output (731 lines, 19 sections) |
| `agent/reports/audit-068-design-spec-m15-spine-v2-audit.md` | First spec audit |
| `agent/reports/audit-069-design-spec-m15-spine-v2-round2.md` | Second spec audit |
| `agent/commands/acp.report.md` | Peer command structure |
| `agent/commands/acp.audit.md` | Audit numbering, investigation depth |
| `agent/commands/acp.design-create.md` | Naming collision risk |
| `agent/core/constraints.yml` | command_doc_rules |
| `agent/core/routing.yml` | command_suggestions gap |

---

## Findings (v1.0.0)

| ID | Sev | Finding | v1.1.0 fix |
|----|-----|---------|------------|
| G-070-01 | **HIGH** | Report template §2–§3 did not match exemplar — template had "System context" at §2; exemplar has **§2 Terminology**, **§3 System context** | Template aligned to 19-section exemplar |
| G-070-02 | **HIGH** | Missing §9 before-state / §10 after-state steps — exemplar's highest-value diagrams (siloed vs spine) had no generation guidance | New Step 9 + template §9–§10 |
| G-070-03 | **HIGH** | No distinction from `/acp-design-create` — agents may create wrong artifact type | New "Distinction From Other Commands" table |
| G-070-04 | **MEDIUM** | FIFOZ-hardcoded paths (`frontend/store/`, `backend/server.py`) in Steps without detection | Stack detection table + investigation patterns |
| G-070-05 | **MEDIUM** | `--audit` did not specify audit-NNN numbering (unlike acp.audit Step 2) | Step 17 references acp.audit algorithm |
| G-070-06 | **MEDIUM** | Traceability step did not warn against copying `progress.yaml` status | Explicit "code truth" rule in Step 10 + troubleshooting |
| G-070-07 | **MEDIUM** | arc42 mapping incomplete (§1, §7 deployment, §12 glossary, §11 risks) | Expanded standards table + ISO 42010 viewpoints |
| G-070-08 | **MEDIUM** | No `--supersedes`, `--narrow`, `--draft` flags | Added to Arguments + Steps |
| G-070-09 | **LOW** | No stakeholder / document status metadata in template | Header fields: Status, Stakeholders |
| G-070-10 | **LOW** | No upstream integration checklist (E2E, routing.yml, taxonomy) | "Upstream Integration Notes" section |
| G-070-11 | **LOW** | `command_suggestions` missing for `acp-design-spec` in routing.yml | Noted in feedback-005 for upstream |
| G-070-12 | **LOW** | No E2E test (constraints.yml: every command needs E2E) | Noted in feedback-005 |
| G-070-13 | **LOW** | §8 calculation engines in template but no dedicated step in v1.0 | Step 8 added |
| G-070-14 | **LOW** | §14 aggregation (configuredDomains pattern) not guided | Step 12 added |
| G-070-15 | **LOW** | Visualizer version notes project-specific | Retained in Step 18 with version pins |

---

## Industry Standards Gap Analysis

| Standard element | v1.0.0 | v1.1.0 | Industry best practice |
|------------------|--------|--------|------------------------|
| Glossary | Missing step | §2 required | arc42 §12, IEEE entity definitions |
| Stakeholders / viewpoints | Header only partial | ISO 42010 table | Required for multi-audience specs |
| Deployment view | Absent | §3.1 optional | arc42 §7 — env vars, staging/prod |
| Before/after architecture | Absent | §9–§10 | Common in migration/refactor specs (DFD delta) |
| Threat boundaries | Encryption only | Trust boundaries on §3 | STRIDE-lite / arc42 §8 |
| Verification viewpoint | §17 matrix | Unchanged + regression rows | ISO 42010 QA viewpoint |
| Document control | Version only | Status draft/review/approved | IEEE 1016 revision history |

**Not included (intentionally)** — out of scope for interface spec command:
- Full arc42 §10 quality scenarios (performance SLOs) — defer to `/acp-design-create`
- C4 L4 code diagrams — too granular; use `/acp-audit` on specific modules
- Formal UML component diagrams — Mermaid flowchart/sequence sufficient

---

## v1.1.0 Verification

| Check | Result |
|-------|--------|
| 🤖 Agent Directive header | ✅ |
| Scripts field | ✅ None |
| Verification checklist | ✅ Expanded (15 items) |
| Security Considerations | ✅ |
| Related Commands | ✅ Includes design-create |
| Template matches v2.1 exemplar section numbers | ✅ |
| Version bumped (1.0.0 → 1.1.0) | ✅ |
| Breaking change documented | ✅ Template renumbering |

---

## Recommendations

### FIFOZ (local)
1. Use v1.1.0 command for M16 health interface spec
2. Add `command_suggestions.acp-design-spec` to local `routing.yml` when convenient

### ACP Enhanced (upstream) — see feedback-005
1. Distribute `acp.design-spec.md` v1.1.0 in next framework release (6.9.3+)
2. Ship `agent/templates/design-spec.template.md`
3. Add E2E test + taxonomy entry
4. Cross-link in `acp.report.md` Related Commands

---

**Audit type**: Command documentation / framework contribution review  
**Generated by**: ACP `/acp-audit` #070
