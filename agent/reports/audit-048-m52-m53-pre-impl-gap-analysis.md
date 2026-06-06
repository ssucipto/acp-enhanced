# Audit Report: M52+M53 Pre-Implementation — Gap Analysis

**Audit**: #048  
**Date**: 2026-06-07  
**Subject**: M52 (stakeholder-report) + M53 (cursor commands) plans — verify against feedback-001/006, ACP conventions, industry standards, real-world workflows  

---

## Summary

Both milestone plans are structurally sound — they follow the proven M50/M51 pattern (command integration + infrastructure fix). All P0 items are covered. However, **7 gaps** were identified: 1 missing content update in M52 (acp.report.md Example 3), 2 missing integration points in M53 (.cursor/rules/ file, preferences disable flag), 1 cross-milestone concern (route-129 @acp. fix placement), and 3 documentation/clarity items.

**Verdict**: Plans are **READY with minor amendments**. All gaps are single-route additions or clarifications — no structural changes needed.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-52-stakeholder-report-carryovers.md` | milestone | M52 plan |
| `agent/milestones/milestone-53-cursor-slash-commands.md` | milestone | M53 plan |
| `agent/routing/tasks/route-117.md` through `route-130.md` | routes | All 14 route files |
| `agent/feedback/feedback-006-acp-stakeholder-report-command-upstream.md` | feedback | M52 requirements source |
| `agent/feedback/feedback-001-cursor-slash-commands-bootstrap.md` | feedback | M53 requirements source |
| `agent/feedback/acp.stakeholder-report.md` | command | Source command v1.1.0 |
| `agent/feedback/acp.cursor-commands-sync.sh` | script | Reference implementation |
| `agent/commands/acp.report.md` | command | Example 3 needs update (GAP found) |
| `agent/scripts/acp.install.sh` | script | Hook insertion point at line 201 |
| `agent/scripts/acp.version-update.sh` | script | Hook insertion point at line 217 |
| `agent/commands/acp.cost-report.md` | command | Related Commands section check |
| `agent/memory/audit-carryovers.md` | tracking | 4 pending carryovers for M52 |

---

## Key Findings

### M52 — Stakeholder Report Gaps

| ID | Severity | Finding | Location | Recommendation |
|----|----------|---------|----------|----------------|
| G-048-01 | **MEDIUM** | `acp.report.md` Example 3 ("Stakeholder Update", line 338) currently says "Invocation: `/acp-report`" — must be updated to reference `/acp-stakeholder-report`. Feedback-006 explicitly requires this (Phase B, §5 item 4). Route-119 says "cross-links" but doesn't enumerate this specific content change. | `acp.report.md:338-340` | Add to route-119 changes: update Example 3 to use `/acp-stakeholder-report` as the invocation, with a note that `/acp-report` is for full archives. |
| G-048-02 | **LOW** | feedback-006 §5 P1 item 11 specifies "Verify checklist: not Green when blockers exist (automated grep test)". Route-120 says 14 assertions but doesn't explicitly list a grep-based RAG rule test. The 14 assertions should include a specific check for "not Green" / "current_blockers" / "Minimum Amber" language. | `route-120.md` | Add explicit assertion #15: grep for "not Green when `current_blockers` non-empty" or equivalent RAG rule text. |
| G-048-03 | **LOW** | feedback-006 §5 P2 items 12-13 (Visualizer: compact card + email export) are not tracked anywhere in M52. These are P2/future items that should be deferred with tracking (like DEFER-044-01 pattern). | M52 plan (missing) | Add to route-122 or M52 session commit deferred: Visualizer stakeholder card + email export preset. |
| G-048-04 | **INFO** | M52 → M53 dependency: stakeholder-report command added in M52 will be auto-included in M53's cursor sync (since sync reads all `agent/commands/acp.*.md`). If M53 is implemented first, stakeholder-report wrappers won't exist until sync is re-run. Order: M52 first is correct. ✅ | Cross-milestone | No action needed — M52 first ensures correct sequencing. Note in implementation. |

### M53 — Cursor Commands Gaps

| ID | Severity | Finding | Location | Recommendation |
|----|----------|---------|----------|----------------|
| G-048-05 | **MEDIUM** | feedback-001 §3.3 recommends shipping `.cursor/rules/acp-slash-commands.mdc` (always-on Cursor rule for agent alias protocol). The plan marks this as "optional" in notes but no route creates it. Without this rule, Cursor agents using `@acp-*` fallbacks won't know to execute (not just read) the command file. | M53 plan (missing) | Add route or fold into route-128: create `.cursor/rules/acp-slash-commands.mdc` with `alwaysApply: true`, defining `/acp-*` as canonical and `@acp-*` / `@agent/commands/` as execution aliases. |
| G-048-06 | **LOW** | feedback-001 §6 specifies "Optional: allow `agent/preferences/cursor.yml` to disable generation for teams that do not use Cursor." No route addresses this. Teams using OpenCode only would get unnecessary `.cursor/commands/` files. | M53 plan (missing) | Add to route-126 or as a deferred item: check for `agent/preferences/cursor.yml` with `enabled: false` before generating in bootstrap/install. |
| G-048-07 | **LOW** | Route-129 (@acp. fix in visualize.md) is in M53 (v6.10.0) but this is a pre-existing bug affecting ALL versions. Should be a hotfix applied immediately, not bundled with a feature milestone. Consider pulling into its own commit before M52/M53 implementation. | `route-129.md` | Option A: Move route-129 to a standalone hotfix before M52. Option B: Keep in M53 but flag as "apply first" in implementation order. |
| G-048-08 | **INFO** | `acp.cost-report.md` has no "Related Commands" section (verified by grep). The feedback-006 routing.yml requires cross-referencing `acp-stakeholder-report` from cost-report. Need to either create a Related Commands section or add to existing examples. | `acp.cost-report.md` | Route-119 should note: if Related Commands section missing, create one; otherwise append. |

### Cross-Cutting

| ID | Severity | Finding | Recommendation |
|----|----------|---------|---------------|
| G-048-09 | **INFO** | Both milestones follow the proven M50/M51 pattern: command integration (M50→M52) + infrastructure fix (M51→M53). Route numbering is sequential (117-130). Industry standards properly referenced (ISO 42010, PMI, Cursor plugin format). ACP conventions maintained (triple-file, `/acp-` naming, E2E tests). ✅ | No action needed. |

---

## Industry Standards Verification

| Standard | M52 Coverage | M53 Coverage |
|----------|-------------|-------------|
| **ISO/IEC/IEEE 42010** | ✅ Stakeholder viewpoint separated from developer viewpoint | N/A |
| **PMI Weekly Status** | ✅ RAG, accomplishments, forward look, risks with severity, decisions required | N/A |
| **Executive Communication** | ✅ ≤300 words, no task IDs, outcome language, email subject line | N/A |
| **Cursor Plugin Format** | N/A | ✅ YAML frontmatter with `description`, thin wrappers |
| **ACP Triple-File Architecture** | ✅ Command + prompt + opencode | ✅ Script + install hooks |
| **ACP Naming Convention** | ✅ `/acp-` prefix, dots in filenames | ✅ Dots→hyphens mapping |
| **ACP Constraints (bash)** | N/A (no scripts) | ✅ BSD sed, `set -euo pipefail` |
| **Keep a Changelog** | ✅ [6.9.5] entry planned | ✅ [6.10.0] entry planned |
| **Semantic Versioning** | ✅ Minor bump (new feature) | ✅ Minor bump (new integration) |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `acp.report.md:338` | **G-048-01**: Example 3 "Stakeholder Update" — says `/acp-report` but should say `/acp-stakeholder-report` |
| `acp.install.sh:199-201` | Cursor hook insertion point (after opencode copy at line 201) |
| `acp.version-update.sh:214-217` | Cursor hook insertion point (after opencode copy at line 217) |
| `acp.version-update.sh:260` | Install summary line — add cursor count alongside opencode count |
| `feedback-006 §5 line` | P2 items 12-13: Visualizer stakeholder card + email export |
| `feedback-001 §3.3` | `.cursor/rules/acp-slash-commands.mdc` — always-on agent protocol rule |
| `feedback-001 §6` | `agent/preferences/cursor.yml` disable flag |

---

## Recommendations

### Pre-Implementation (amend routes before coding)

1. **G-048-01 (MEDIUM)**: Add to route-119 — update `acp.report.md` Example 3 to use `/acp-stakeholder-report` as invocation, with explanation that `/acp-report` is the full archive.

2. **G-048-05 (MEDIUM)**: Add to route-128 — create `.cursor/rules/acp-slash-commands.mdc` with `alwaysApply: true`, defining slash command execution protocol for Cursor agents.

3. **G-048-02 (LOW)**: Add explicit assertion #15 to route-120: grep for RAG/blocker rule text ("not Green when `current_blockers` non-empty" or equivalent).

### Implementation Order

4. **G-048-07 (LOW)**: Apply route-129 (@acp. fix) as a standalone hotfix commit before starting M52 implementation. This is a pre-existing bug, not a new feature.

5. **G-048-04 (INFO)**: Implement M52 before M53 to ensure stakeholder-report wrappers are included in cursor sync generation.

### Post-Implementation / Deferred

6. **G-048-03 (LOW)**: Track P2 Visualizer items (stakeholder card, email export) as deferred in M52 session commit.

7. **G-048-06 (LOW)**: Defer `agent/preferences/cursor.yml` disable flag to a future milestone. Document as known limitation.

---

## Verdict

**Both plans are READY with 3 pre-implementation amendments.** The core structure is correct — all P0 items covered, all industry standards addressed, ACP conventions maintained. The 7 gaps are minor: 1 missing content update, 1 missing integration artifact, 1 missing E2E assertion, and 4 informational/deferred items. No architectural changes needed.

---

**Audit type**: Pre-implementation gap analysis  
**Generated by**: ACP `/acp-audit` #048
