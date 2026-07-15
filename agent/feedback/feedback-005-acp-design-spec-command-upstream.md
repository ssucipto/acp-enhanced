# ACP Enhanced — Field Feedback Report
## Submission: `/acp-design-spec` command — framework distribution package

**Report ID**: feedback-005  
**Date**: 2026-06-06  
**Project**: FIFOZ (Rygan-Institute/FIFOZ) — field origin; intended for **ACP Enhanced** upstream  
**ACP Version in use**: 6.9.2  
**Executor**: cursor  
**Category**: improvement — new command, documentation standards, framework integration  
**Severity**: medium  
**Companion**: audit-070, design-spec-app-interfaces-m15-spine-v2.1.md  

**Submit to**: `https://github.com/ssucipto/acp-enhanced/issues`  
**Reference implementation**: `agent/commands/acp.design-spec.md` v1.1.0 (FIFOZ `develop` branch)

---

## Executive Summary

FIFOZ needed a **repeatable way to generate Application Interface & Data-Flow Design Specifications** — not project status reports (`/acp-report`) and not ad-hoc audits (`/acp-audit`). We created `/acp-design-spec`, validated it by producing a 19-section, 12-diagram spec for the M15 pay-profile spine (v2.1), and ran audit-070 to harden the command.

**Ask**: Adopt `acp.design-spec.md` v1.1.0 into the next ACP Enhanced release with the integration items in §5. The command is **stack-agnostic** (detects UI/store/API roots) but ships a **FIFOZ exemplar** as the reference output shape.

**Value proposition**: Gives agents a structured, industry-grounded template for interface inventory + data-flow docs — the artifact type QA teams and senior engineers actually need before device sign-off.

---

## 1. Problem Statement

### What was missing

| Gap | Impact |
|-----|--------|
| No command for **interface / data-flow specifications** | Agents improvised structure; specs drifted from code |
| `/acp-design-create` targets `agent/design/` planning docs | Wrong artifact for "what exists today" inventory |
| `/acp-report` is progress-focused | Stakeholders confuse status reports with design specs |
| `/acp-audit` is investigation-first | Excellent for verification, but no standard **output template** for interface docs |

### What FIFOZ produced (proof of concept)

| Artifact | Lines | Diagrams | Audits |
|----------|-------|----------|--------|
| `design-spec-app-interfaces-m15-spine-v2.1.md` | 731 | 12 Mermaid | audit-068, audit-069 |
| Command iterations | v1.0.0 → v1.1.0 | — | audit-070 |

---

## 2. Command Design — What to Ship

### 2.1 Core positioning

```
/acp-design-create  →  agent/design/     →  PLAN (what to build)
/acp-design-spec   →  agent/reports/    →  INVENTORY (what exists, how data flows)
/acp-report        →  agent/reports/    →  PROGRESS (milestone/task status)
/acp-audit         →  agent/reports/    →  INVESTIGATE (deep dive, any subject)
```

### 2.2 Industry standards synthesis

The command maps output sections to established practices (documented in the command file):

| Standard | Sections covered |
|----------|------------------|
| **arc42** §1, §3, §5–8, §11–12 | Summary, context, building blocks, runtime, security, debt, glossary |
| **C4 Model** L1–L3 | Context, containers, components |
| **IEEE 1016** | Interface view, interaction view, traceability |
| **ISO/IEC/IEEE 42010** | Stakeholders, viewpoints (interface, runtime, security, verification, evolution) |
| **DFD** L0–L2 | Context + process + store diagrams |
| **UML sequences** | Bootstrap, API flows |

**Deliberately excluded** from command scope (keep token-efficient):
- Full arc42 §10 quality scenarios → use `/acp-design-create`
- C4 L4 code-level → use `/acp-audit` on a module
- Formal threat-model document → link ADRs; §13 covers trust boundaries

### 2.3 Stable 19-section template

Section numbers are **stable across projects** (v1.1.0). Key sections that differentiated FIFOZ's exemplar from the v1.0.0 draft:

| § | Section | Why it matters |
|---|---------|----------------|
| 2 | Terminology | arc42 glossary; prevents ambiguous "interface" / "spine" language |
| 9 | Before-state architecture | Documents legacy silos before migration |
| 10 | Target-state architecture | Spine / integration diagram — primary onboarding artifact |
| 10.2 | Remediation task status | Links spec to milestone tasks with **code-verified** status |
| 11 | Requirements traceability | PG / story → interface mapping |
| 12.1 | Sign-out data boundary | Session hygiene — caught CO-285 in FIFOZ |
| 17 | Verification matrix | Device QA / integration sign-off |
| 19 | Mermaid rendering notes | Pairs with Visualizer; documents syntax traps |

### 2.4 Arguments (v1.1.0)

| Flag | Purpose |
|------|---------|
| `<subject>` | Scope slug for filename |
| `--milestone <id>` | Filter to milestone + requirements |
| `--supersedes <path>` | Version bump + changelog |
| `--narrow` | Feature-scoped spec (skip §9/§16) |
| `--audit` | Post-write code verification + audit-NNN report |
| `--draft` | Header status draft |
| `-o / --output` | Custom path |

### 2.5 Quality gates (critical for agent behaviour)

These rules prevented real bugs in FIFOZ audit-069:

1. **Traceability status reflects code, not `progress.yaml`** — task-174 was marked complete while spec still said "file missing"
2. **Do not hide destructive behaviour** — sign-out deleting Firestore docs documented as open debt
3. **Verification matrix includes regression rows** for known open bugs
4. **`--audit` uses same numbering algorithm as `/acp-audit` Step 2**

---

## 3. Issues Found in v1.0.0 (Fixed in v1.1.0)

| ID | Severity | Issue | Resolution |
|----|----------|-------|------------|
| DS-01 | HIGH | Template section numbers ≠ exemplar output | Aligned to 19-section structure |
| DS-02 | HIGH | No before/after architecture guidance | Steps 9–10 + §9/§10 template |
| DS-03 | HIGH | Confusion with `/acp-design-create` | Distinction table at top |
| DS-04 | MEDIUM | Hardcoded FIFOZ paths | Stack detection table |
| DS-05 | MEDIUM | Weak `--audit` integration | Step 17 + audit-NNN numbering |
| DS-06 | MEDIUM | progress.yaml status copied blindly | Code-truth rule |
| DS-07 | LOW | No upstream integration checklist | "Upstream Integration Notes" section |
| DS-08 | LOW | Missing ISO 42010 stakeholder viewpoints | Viewpoint table in command |

Full audit trail: `agent/reports/audit-070-acp-design-spec-command-review.md`

---

## 4. Suggested Upstream File Package

Copy into `acp-enhanced` distribution:

```
agent/commands/acp.design-spec.md          # v1.1.0 — main directive
agent/templates/design-spec.template.md    # Extract from Report Structure section (NEW)
.cursor/commands/acp-design-spec.md        # Thin wrapper (existing pattern)
.opencode/commands/acp-design-spec.md      # Thin wrapper
e2e/acp-design-spec.e2e.sh                 # Smoke test (NEW — see §5.3)
```

**Optional exemplar** (FIFOZ-licensed reference, not required in core package):
`agent/examples/design-spec-app-interfaces-exemplar.md` — abbreviated v2.1

---

## 5. Framework Integration Checklist (Requested)

### 5.1 `routing.yml` — command_suggestions

```yaml
acp-design-spec:
  - acp-audit: "Verify spec against codebase (--audit)"
  - acp-visualize: "Render Mermaid diagrams in Docs tab"
  - acp-commit: "Save session when spec completes a milestone phase"

acp-report:
  - acp-design-spec: "Generate interface spec (not progress report)"  # ADD

acp-design-create:
  - acp-design-spec: "Document implemented interfaces after build"  # ADD
```

### 5.2 `taxonomy.yml` — task type mapping

```yaml
design-spec:
  skill: docs.md  # or new skills/design-spec.md if split
  executor: cursor
  risk: low
```

### 5.3 E2E smoke test (constraints.yml compliance)

`e2e/acp-design-spec.e2e.sh` should verify:

- [ ] `agent/commands/acp.design-spec.md` exists
- [ ] Contains `🤖 Agent Directive` block
- [ ] Contains `Scripts:` field
- [ ] Contains `## Verification Checklist`
- [ ] Report Structure lists §1–§19
- [ ] Related Commands includes `acp.design-create` distinction
- [ ] `.cursor/commands/acp-design-spec.md` wrapper exists

### 5.4 `acp.report.md` — Related Commands addition

```markdown
- [`/acp-design-spec`](acp.design-spec.md) — Interface & data-flow specification (not progress)
```

### 5.5 Version bump

- Command version: **1.1.0**
- Framework compatibility: **ACP 6.9.3+** (suggested)
- CHANGELOG entry under "New Commands"

---

## 6. Relationship to Visualizer

Design specs are **Mermaid-heavy**. FIFOZ production experience:

| Visualizer issue | Spec section | Fixed in |
|------------------|--------------|----------|
| Silent Mermaid failure | §19 | Visualizer `fad4492` (feedback-003) |
| Dev server SIGABRT | §19 note | Visualizer v1.5.3+ (feedback-004) |
| Stadium node `/api/foo/` syntax | §19 traps | Spec authoring rule |

**Recommendation**: In Visualizer Docs tab, add optional document type badge `design-spec` when filename matches `design-spec-*.md` — enables TOC presets (show §17 matrix first for QA users).

---

## 7. Comparison to `/acp-report` Structure

Both commands share ACP conventions (directive header, steps, verification, security, examples). Intentional differences:

| Aspect | `/acp-report` | `/acp-design-spec` |
|--------|---------------|-------------------|
| Primary input | `progress.yaml` | Live codebase |
| Output focus | Status, blockers, stats | Interfaces, flows, traceability |
| Diagrams | Optional | Required (≥5 full / ≥3 narrow) |
| Versioning | Date filename | Semantic `v{N}` + `--supersedes` |
| Pair command | `/acp-update` | `/acp-audit --audit` |

---

## 8. Prioritized Backlog for ACP Enhanced Team

| Priority | Item | Effort |
|----------|------|--------|
| **P0** | Merge `acp.design-spec.md` v1.1.0 into upstream | Low |
| **P0** | Add cursor/opencode wrappers + package.yaml entry | Low |
| **P1** | Ship `design-spec.template.md` | Low |
| **P1** | E2E smoke test | Medium |
| **P1** | `routing.yml` command_suggestions | Low |
| **P2** | `taxonomy.yml` task_type + optional `skills/design-spec.md` | Medium |
| **P2** | Cross-link in `acp.report.md`, `acp.design-create.md` | Low |
| **P3** | Visualizer `design-spec` document type preset | Medium |
| **P3** | Abbreviated exemplar in `agent/examples/` | Low |

---

## 9. Files to Attach to GitHub Issue

When filing upstream:

1. `agent/commands/acp.design-spec.md` (v1.1.0)
2. `agent/reports/audit-070-acp-design-spec-command-review.md`
3. `agent/reports/design-spec-app-interfaces-m15-spine-v2.1.md` (reference output)
4. This file (`feedback-005`)

---

## 10. Acceptance Criteria (Upstream Done Definition)

- [ ] `/acp-design-spec` available in fresh `acp-package-install` projects
- [ ] E2E test passes on macOS + Linux CI
- [ ] `acp.report.md` Related Commands lists design-spec
- [ ] No naming collision confusion with `acp-design-create` in docs index
- [ ] Template file ships for agents that cannot read full command doc

---

**Report type**: Framework contribution — new command  
**Contact context**: FIFOZ M15.1 remediation; 70 audits; daily Cursor + ACP Enhanced 6.9.2  
**Generated by**: ACP `/acp-audit` #070 + `/acp-feedback` workflow
