# ACP Enhanced — Field Feedback Report
## Submission: `/acp-stakeholder-report` command v1.1.0 — weekly executive progress reporting

**Report ID**: feedback-006  
**Date**: 2026-06-06 (revised after audit-071)  
**Project**: FIFOZ (Rygan-Institute/FIFOZ) — field origin; intended for **ACP Enhanced** upstream  
**ACP Version in use**: 6.9.2  
**Executor**: cursor  
**Category**: improvement — new command, stakeholder communications, report taxonomy  
**Severity**: medium  
**Companion**: audit-071, plan-2026-06-06-stakeholder-weekly-report-command, feedback-005 (design-spec), feedback-006 v1.0.0 draft  

**Submit to**: `https://github.com/ssucipto/acp-enhanced/issues`  
**Suggested release**: ACP Enhanced **6.9.3+** (bundle with `acp.design-spec` v1.1.0 from feedback-005)

---

## Executive Summary

FIFOZ production use exposed a **report taxonomy gap**: `/acp-report` produces excellent **project archives** (~178 lines) but fails industry standards for **weekly stakeholder communication** (RAG health, <300-word executive summary, decisions required, outcome bullets, email subject line).

We implemented **`/acp-stakeholder-report`** locally, ran **audit-071**, and hardened to **v1.1.0** before upstream submission. This report asks ACP Enhanced to adopt the command, document the **five-tier reporting model**, and ship template + E2E test alongside feedback-005's `acp-design-spec`.

**Key asks**:
1. Do **not** extend `/acp-report` with `--stakeholder` — separate ISO 42010 viewpoints.
2. Ship **v1.1.0** (not v1.0.0) — includes auto-amber RAG rule, artefact naming, anti-patterns.
3. Bundle **feedback-005 + feedback-006** as single "FIFOZ reporting pack" PR for 6.9.3.

---

## 1. Problem Statement

### What went wrong with `/acp-report` for stakeholders

| Issue | Evidence |
|-------|----------|
| Too long for weekly cadence | `report-2026-06-04.md` — 178 lines, 19-row milestone table |
| No RAG health indicator | Industry standard: Green/Amber/Red at top |
| Task-level detail | task-177, CO-273, audit counts — wrong audience |
| No "decisions required" section | Blockers buried; stakeholders don't know what to approve |
| Purpose line said "stakeholders" | Agents sent wrong artefact (fixed locally in Phase B) |

### Three artefact types FIFOZ was conflating

| Artefact | Lines | Type | Correct command |
|----------|-------|------|-----------------|
| `report-2026-06-04.md` | 178 | Full status archive | `/acp-report` |
| `report-2026-05-30-stakeholder-m15-m16.md` | 935 | **Roadmap brief** (one-off) | Manual / plan doc — **not** weekly |
| `stakeholder-report-2026-06-06.md` | ~1 page | **Weekly exec summary** | `/acp-stakeholder-report` |

**Naming convention (ship in framework docs)**:

| Pattern | Purpose |
|---------|---------|
| `stakeholder-report-YYYY-MM-DD.md` | This command — recurring exec summary |
| `report-YYYY-MM-DD.md` | `/acp-report` full archive |
| `roadmap-brief-{subject}-{date}.md` | One-off planning (avoid `report-*-stakeholder-*`) |

---

## 2. Proposed Solution: Five-Tier Reporting Model

Recommend ACP Enhanced document this officially in wiki/README:

```
progress.yaml + sessions.md
         │
         ├─► /acp-status              Console (~20 lines)     Developer session
         ├─► /acp-stakeholder-report  1–2 pages, RAG          Weekly board/investor
         ├─► /acp-report              5–15 pages              Milestone archive / team
         ├─► /acp-design-spec         10–30 pages + diagrams Per-milestone engineering
         └─► /acp-cost-report         1 page                  Weekly AI spend (ops, Fridays)
```

---

## 3. Command Specification v1.1.0 (Ship This — Not v1.0.0)

**Reference**: `agent/commands/acp.stakeholder-report.md` v1.1.0  
**Audit**: `agent/reports/audit-071-acp-stakeholder-report-command-review.md`

### v1.0.0 → v1.1.0 changes (audit-071)

| ID | Change |
|----|--------|
| G-071-01 | Hard limit **≤4 metrics rows** (pilot had 5) |
| G-071-02 | **`current_blockers` non-empty → minimum Amber** (never false Green) |
| G-071-03 | **Anti-pattern filter** — no task IDs, ACP commands, emoji task logs in accomplishments |
| G-071-04 | **Artefact naming** table — distinguish roadmap brief vs weekly report |
| G-071-05 | **Suggested email subject** line in header |
| G-071-06 | **Severity** column on blockers (High/Medium/Low) |
| G-071-07 | `sessions.md` fallback when `recent_work` sparse |
| G-071-08 | `acp.report.md` Example 3 → points to stakeholder-report |
| G-071-09 | `acp.cost-report.md` Related Commands — Friday pairing |
| G-071-10 | progress.yaml staleness warning in Step 1 |
| G-071-11 | Executive summary **300-word hard limit** in Step 4 |

### Arguments

| Flag | Default | Purpose |
|------|---------|---------|
| `--period weekly\|monthly` | `weekly` | 7 or 30 day window |
| `--since <date>` | auto | Override window start |
| `--audience executive\|board\|investor` | `executive` | Tone |
| `--rag green\|amber\|red` | infer | Override auto RAG |
| `--no-delta` | off | Skip week-over-week section |
| `-o / --output` | `agent/reports/` | Custom path |

### RAG inference rules (v1.1.0 — ship as-is)

| Rule | RAG |
|------|-----|
| `current_blockers` non-empty OR human gate on critical path | **Minimum 🟡 Amber** |
| No blockers; milestone on track | 🟢 Green |
| External dep with documented mitigation | 🟡 Amber |
| No mitigation OR missed committed date | 🔴 Red |

### Required output sections

1. Header: period, RAG, **rationale**, **suggested email subject**, version, audience
2. Executive summary (≤300 words, no task IDs)
3. This period — accomplishments (≤5 **product** outcomes)
4. Next period — focus (≤5 bullets)
5. Blockers & risks (Severity | Impact | Mitigation | Owner)
6. Decisions & actions required (non-empty when stakeholders must act)
7. Metrics at a glance (**2–4 rows hard limit**)
8. Changes since last report (optional `--no-delta`)
9. Detail available on request (links to `/acp-report`, design spec)

### Anti-patterns (agent must filter)

- Task IDs, CO-* codes in exec summary
- `/acp-*` command names in accomplishments (unless board audience + eng velocity topic)
- Copying milestone tables from progress.yaml
- 5+ metric rows

### Pilot exemplar (v1.1.0 conformant)

`agent/reports/stakeholder-report-2026-06-06.md` — Amber, 4 metrics, 4 decisions, email subject, severity column — **~1 page**.

Contrast: `report-2026-06-04.md` (178 lines) — why both commands exist.

---

## 4. Implementation Phases (FIFOZ)

| Phase | Scope | Status |
|-------|-------|--------|
| **A — FIFOZ local** | Command, template, wrappers, pilot | ✅ Done |
| **B — Cross-command docs** | acp.report.md, acp.design-spec distinction, acp.cost-report | ✅ Done |
| **A.1 — Audit hardening** | audit-071 → v1.1.0, pilot patch | ✅ Done 2026-06-06 |
| **C — Upstream ACP Enhanced** | Ship framework package | ⏳ This feedback |
| **D — Automation (optional)** | Friday `/loop`, Visualizer email export | 📋 Future |

---

## 5. Framework Integration Checklist

### P0 — Ship with 6.9.3 (bundle with design-spec)

| # | Item |
|---|------|
| 1 | `acp.stakeholder-report.md` **v1.1.0** |
| 2 | `agent/templates/stakeholder-report.template.md` v1.1.0 |
| 3 | `.cursor/commands` + `.opencode/commands` wrappers |
| 4 | `acp.report.md` Phase B (Purpose + Example 3 + Related) |
| 5 | `acp.cost-report.md` Related Commands |
| 6 | `routing.yml` command_suggestions |
| 7 | Wiki/README: **five-tier reporting model** + artefact naming |
| 8 | CHANGELOG: "New command: stakeholder-report v1.1.0" |

### P1 — Same or next release

| # | Item |
|---|------|
| 9 | E2E `e2e/acp-stakeholder-report.e2e.sh` |
| 10 | `taxonomy.yml` task_type `stakeholder-report` |
| 11 | Verify checklist: not Green when blockers exist (automated grep test) |

### P2 — Visualizer (optional)

| # | Item |
|---|------|
| 12 | Detect `stakeholder-report-*.md` — compact card |
| 13 | Export: email body (subject + exec + decisions only) |

### routing.yml (copy from FIFOZ)

```yaml
acp-stakeholder-report:
  - acp-report: "Full archive when stakeholders need detail"
  - acp-update: "Refresh progress.yaml before reporting"
  - acp-cost-report: "Pair on Fridays — AI spend"
  - acp-commit: "Save session after reporting phase"

acp-report:
  - acp-stakeholder-report: "Weekly executive summary (not this full report)"

acp-status:
  - acp-stakeholder-report: "Friday stakeholder update"
```

### E2E smoke test (extend v1.1.0 checks)

- [ ] Command file v1.1.0 with audit reference
- [ ] Artefact naming section present
- [ ] Auto-amber RAG rule documented
- [ ] Anti-patterns list present
- [ ] Template includes email subject + Severity column
- [ ] Metrics hard limit ≤4 documented
- [ ] `acp.report.md` Example 3 uses stakeholder-report

---

## 6. Bundle with feedback-005 (Recommended)

Single upstream PR **"FIFOZ reporting pack for 6.9.3"**:

| Command | Version | Feedback |
|---------|---------|----------|
| `/acp-design-spec` | 1.1.0 | feedback-005 |
| `/acp-stakeholder-report` | 1.1.0 | feedback-006 |

Shared convention: `agent/templates/*.template.md` for both.

---

## 7. Acceptance Criteria (Upstream Done)

- [ ] v1.1.0 (not v1.0.0) in fresh install
- [ ] Output ≤2 pages from progress.yaml
- [ ] RAG cannot be Green when `current_blockers` non-empty (documented + testable)
- [ ] Artefact naming documented in wiki
- [ ] Five-tier report model in README or wiki
- [ ] E2E passes macOS + Linux CI
- [ ] Bundled or cross-linked with design-spec command

---

## 8. Files to Attach to GitHub Issue

1. `agent/commands/acp.stakeholder-report.md` (**v1.1.0**)
2. `agent/templates/stakeholder-report.template.md` (v1.1.0)
3. `agent/reports/stakeholder-report-2026-06-06.md` (pilot)
4. `agent/reports/audit-071-acp-stakeholder-report-command-review.md`
5. `agent/reports/report-2026-06-04.md` (contrast)
6. `agent/plans/plan-2026-06-06-stakeholder-weekly-report-command.md`
7. `agent/commands/acp.report.md` (Phase B diff)
8. `agent/commands/acp.cost-report.md` (Related Commands diff)
9. This file (`feedback-006` revised)
10. Optional bundle: feedback-005 + design-spec v1.1.0 files

---

## 9. Suggested Issue Title

```
[Feature] Adopt /acp-stakeholder-report v1.1.0 + report taxonomy (bundle with design-spec for 6.9.3)
```

---

## 10. Prioritized Backlog

| Priority | Item | Effort |
|----------|------|--------|
| **P0** | Merge v1.1.0 command + template + wrappers | Low |
| **P0** | Wiki five-tier model + artefact naming | Low |
| **P0** | Phase B/C cross-command doc updates | Low |
| **P1** | E2E with RAG/blocker rule check | Medium |
| **P1** | Bundle PR with feedback-005 | Low |
| **P2** | Visualizer stakeholder card + email export | Medium |
| **P3** | Friday automation docs (Phase D) | Low |

---

**Report type**: Framework contribution — new command v1.1.0 (audit-071 hardened)  
**Revision**: v1.0.0 draft → v1.1.0 after audit-071  
**Generated by**: ACP `/acp-audit` #071 + `/acp-proceed` Phase A.1
