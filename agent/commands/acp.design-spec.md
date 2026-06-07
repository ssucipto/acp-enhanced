# Command: design-spec

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-design-spec` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-design-spec` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.1.0  
**Created**: 2026-06-04  
**Last Updated**: 2026-06-06  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Generate a structured Application Interface & Data-Flow Design Specification from the live codebase  
**Category**: Documentation  
**Frequency**: Per milestone, major refactor, or pre-QA sign-off  

---

## Distinction From Other Commands

| Command | Output | When to use |
|---------|--------|-------------|
| **`/acp-design-spec`** | Interface & data-flow spec in `agent/reports/` | Document **how components connect** — routes, stores, APIs, flows, QA matrix |
| [`/acp-design-create`](acp.design-create.md) | Design doc in `agent/design/` from template | **Plan** a feature before coding — clarifications, decisions, acceptance criteria |
| [`/acp-report`](acp.report.md) | Project progress snapshot | Milestone/task status for stakeholders |
| [`/acp-audit`](acp.audit.md) | Investigation report | Deep dive; pair with `--audit` after spec generation |

**Rule**: Use `/acp-design-create` for *what to build*; use `/acp-design-spec` for *what exists and how data moves*.

---

## Industry Standards Basis

This command synthesizes widely used software design documentation practices. The output is **not** a full arc42 document — it is a **focused interface and data-flow spec** suitable for QA matrices, onboarding, and staging sign-off.

### Standards mapping (complete)

| Standard | What we borrow | Report section |
|----------|----------------|----------------|
| **[arc42](https://arc42.org/) §1** | Introduction, goals, constraints | §1 Executive summary |
| **arc42 §3** | Context and scope | §3 System context |
| **arc42 §5** | Building block view | §4–§5 interface inventories |
| **arc42 §6** | Runtime view | §7 data flows, §12 lifecycle |
| **arc42 §7** | Deployment view (optional) | §3.1 Deployment & environments |
| **arc42 §8** | Cross-cutting concepts | §13 encryption, §12 session |
| **arc42 §11** | Risks and technical debt | §15 debt register |
| **arc42 §12** | Glossary | §2 Terminology |
| **[C4 Model](https://c4model.com/)** | L1 Context, L2 Containers, L3 Components | §3, §4–§5 |
| **[IEEE 1016](https://standards.ieee.org/standard/1016-2009.html)** (SDS) | Design entities, interface/interaction views, traceability | §4–§7, §11 |
| **[ISO/IEC/IEEE 42010](https://www.iso.org/standard/74207.html)** | Stakeholders, viewpoints, concerns | Header metadata; §1, §11, §17 |
| **DFD (Yourdon)** | Context (L0), processes (L1), stores (L2) | §3, §6–§7 Mermaid |
| **UML** | Sequence diagrams for runtime paths | §7, §12 |
| **Threat modeling (lite)** | Trust boundaries, data classification | §13 |

### ISO 42010 viewpoints (explicit)

Document these **concerns** in the spec — one row per viewpoint in the header `Audience:` field:

| Viewpoint | Stakeholder | Primary sections |
|-----------|-------------|------------------|
| **Interface** | Developers, QA | §4–§7 |
| **Runtime / interaction** | Developers, SRE | §7, §12 |
| **Security / privacy** | Security, compliance | §13 |
| **Verification** | QA, release manager | §17 |
| **Evolution** | Tech lead, PM | §15–§16 |

**Exemplar output (FIFOZ):** `agent/feedback/design-spec-app-interfaces-m15-spine-v2.1.md` (reference only — not shipped in distribution)

---

## Arguments

**CLI-Style Arguments**:
- `<subject>` (positional) — Scope slug (e.g. `m15-spine`, `auth-flow`, `paytracker-ocr`)
- `--milestone <id>` — Filter to milestone tasks and requirements (e.g. `M15`, `M15.1`)
- `--output <path>` or `-o <path>` — Custom output path
- `--supersedes <path>` — Prior spec path for changelog and version bump
- `--audit` — After write, verify against codebase; produce `audit-NNN-design-spec-{subject}.md`
- `--narrow` — Feature-scoped spec (skip §9 before-state, §16 preview unless requested)
- `--draft` — Set header `Status: draft` (skip verification matrix sign-off language)

**Natural Language Arguments**:
- `/acp-design-spec M15 pay profile spine interfaces`
- `/acp-design-spec for milestone 16 health module`
- `/acp-design-spec` — Infer scope from current task, milestone, or conversation

**Argument Mapping**:
1. Explicit subject or milestone → use it
2. Natural language topic → derive `subject` slug (kebab-case)
3. No args → infer from context; if ambiguous, ask once
4. `--audit` → execute Step 11 with next audit number (same algorithm as `/acp-audit` Step 2)
5. `--supersedes` → read prior spec; increment minor version; add changelog table

---

## What This Command Does

Produces a **durable interface specification** documenting:

- UI routes and navigation shell (including tab/stack patterns)
- State stores and persistence boundaries
- Backend endpoints touched by the scope
- Data-flow diagrams (Mermaid)
- Before/after architecture (when documenting a migration spine)
- Requirements traceability with **verified** status
- Verification matrix for device or integration QA
- Known dual paths and technical debt

Use before QA sign-off, when onboarding engineers to a feature spine, or when planning the next milestone's interface extensions.

---

## Prerequisites

- [ ] ACP installed (`agent/` exists)
- [ ] `agent/reports/` exists (create if needed)
- [ ] Scope code present in repo

**Stack detection** (adapt paths — do not assume FIFOZ layout):

| Layer | Common paths | Detect |
|-------|--------------|--------|
| Mobile / web UI routes | `frontend/app/`, `src/app/`, `app/` | Glob `**/_layout.tsx`, `**/page.tsx` |
| Client state | `frontend/store/`, `src/stores/` | Glob `*Store.ts`, `*store.ts` |
| API server | `backend/`, `server/`, `api/` | Grep route decorators / `app.get` / `APIRouter` |
| Persistence | Firestore paths, SQL models, Prisma schema | Read constants / ORM files |

Record detected roots in §18 file index.

---

## Steps

### 0. Display Command Header

```
⚡ /acp-design-spec
  Generate Application Interface & Data-Flow Design Specification

  Usage:
    /acp-design-spec <subject>              Named scope (e.g. m15-spine)
    /acp-design-spec --milestone M15.1      Milestone-scoped spec
    /acp-design-spec --supersedes <path>    Version bump from prior spec
    /acp-design-spec --narrow <feature>     Feature-scoped (smaller spec)
    /acp-design-spec --output <path>        Custom output path
    /acp-design-spec --audit                Verify against codebase after write
    /acp-design-spec --draft                Draft status (no sign-off language)

  Related:
    /acp-design-create  Plan features (agent/design/) — not interface inventory
    /acp-audit          Deep investigation; --audit flag or run separately
    /acp-report         Project status (not interface design)
    /acp-visualize      Render Mermaid in ACP Visualizer Docs tab
```

This step is informational only — do not wait for user input.

### 1. Define Scope & Metadata

**Actions**:
- Resolve `subject` slug (e.g. `app-interfaces-m15-spine`)
- Resolve milestone(s) if `--milestone` provided
- Read `agent/progress.yaml` and package manifest for app version
- Read relevant milestone docs under `agent/milestones/`
- If `--supersedes`: read prior spec; set version `v{N+0.1}` or `v{N+1}` per magnitude of change
- Note related audits and open carryovers from `agent/memory/audit-carryovers.md` filtered to scope
- Set header fields: `Stakeholders`, `Status` (`draft` | `review` | `approved`), `Concerns` (viewpoints)

**Expected Outcome**: Scope boundary documented in spec header

### 2. Build Terminology Glossary (arc42 §12)

**Actions**:
- Define domain terms used in the spec (interface, spine, snapshot, source of truth, dual path, mirror, etc.)
- Align terms with `agent/wiki/domain.yml` if present — load **one section only**
- Avoid duplicating full domain model; link to wiki for entity definitions

**Expected Outcome**: §2 Terminology table (minimum 5 terms)

### 3. Inventory UI Interfaces (C4 L3 / IEEE interface view)

**Actions**:
- Glob route files under detected UI root
- Distinguish **navigation shell patterns** (tab re-exports, nested layouts, modal stacks)
- Map each route → primary state modules → user-visible purpose → data source
- Note auth-gated vs public routes
- Tag requirements IDs (PRD feature IDs, user stories) if available

**Investigation patterns**:
```bash
# Example — adapt paths to project
glob: frontend/app/**/*.tsx
grep: "export { default }" frontend/app/
grep: "useRouter|Stack.Screen" frontend/app/
```

**Expected Outcome**: §4 route tables + optional navigation diagram (§4.3 pattern subsection if applicable)

### 4. Inventory State & Persistence (arc42 §5)

**Actions**:
- List state modules in scope
- Per module: public API, read/write paths, persistence collection/table, encryption class
- Document bootstrap subscriptions (root layout, tab layout)
- Document sign-out / session teardown if auth in scope
- Note **dual read/write paths** (e.g. mirror vs authority store)

**Expected Outcome**: §5 store table + §5.2 dual paths + §5.3 cross-store relationships

### 5. Map Persistence Layer (DFD data stores)

**Actions**:
- Document database paths / tables / buckets used by scope
- Classify: authoritative vs denormalized snapshot vs cache
- Map each path → writing module → consuming screens

**Expected Outcome**: §6 persistence map (Firestore, SQL, local storage, etc.)

### 6. Inventory Backend APIs (C4 L2 container boundary)

**Actions**:
- Grep server entrypoints for routes used by frontend scope
- Classify: CRUD, calculation, OCR/ML, auth-only, webhook
- Note dual paths (REST vs direct DB from client) — flag as debt in §15
- Document request auth pattern (JWT, API key, session cookie)

**Expected Outcome**: §7 API catalog + sequence diagrams for critical flows

### 7. Map Data Flows (arc42 §6 / DFD L0–L2)

**Actions**:
- Identify 5–12 critical flows for scope (pay loop, auth bootstrap, OCR, sync, sign-out, etc.)
- Create Mermaid `flowchart` or `sequenceDiagram` per flow
- Follow **Mermaid syntax rules** (see §19 template in output)

**Minimum diagram set** (full scope):

- [ ] §3 System context (C4 L1 / DFD L0)
- [ ] Navigation or tab shell (if multi-route app)
- [ ] Primary user journey (scope-specific)
- [ ] §12 Bootstrap / session lifecycle
- [ ] §12.1 Sign-out data boundary (if auth in scope)
- [ ] §10 target architecture spine (if migration spec)
- [ ] §9 before-state (optional — skip with `--narrow`)

**Expected Outcome**: Diagrams embedded in §3, §7, §9–§12 as appropriate

### 8. Document Client Engines (if applicable)

**Actions**:
- List offline calculation modules, workers, or WASM boundaries
- Map inputs/outputs and consumers

**Expected Outcome**: §8 table — omit section entirely if N/A (e.g. API-only backend scope)

### 9. Before / After Architecture (migration specs)

**Actions**:
- If documenting a milestone spine or refactor: §9 **before** (siloed / legacy) + §10 **after** (target)
- Include gap register table mapping requirement IDs → affected interfaces
- §10.1 milestone deliverables → interfaces; §10.2 remediation task status

**Skip when**: `--narrow` or greenfield feature with no legacy state

**Expected Outcome**: §9–§10 with at least one Mermaid diagram each (full scope)

### 10. Traceability (IEEE 1016 / ISO 42010)

**Actions**:
- Map product gaps, user stories, or milestone tasks → interfaces
- **Status column**: `fixed` | `partial` | `open` — verify against **code**, not `progress.yaml` alone
- Link verification criterion per row
- If `progress.yaml` says complete but code disagrees, spec wins — flag in §15

**Expected Outcome**: §11 traceability table

### 11. Security & Cross-Cutting (arc42 §8)

**Actions**:
- Document encryption boundaries and field-level classification
- Note server-side plaintext exposure (OCR, logging, third-party APIs)
- Reference ADRs from `agent/memory/decisions.md` by ID only
- Mark trust boundaries on §3 context diagram (client / cloud / third-party)

**Expected Outcome**: §13 encryption & security table

### 12. Aggregation & Composite UIs (if applicable)

**Actions**:
- Document dashboard, setup progress, or composite views that read multiple stores
- Include truth-condition tables (when is a domain "configured"?)

**Expected Outcome**: §14 — omit if N/A

### 13. Technical Debt & Dual Paths (arc42 §11)

**Actions**:
- List REST vs DB duplicates, dead code, open CO-* from carryovers
- **Do not hide known bugs** — document actual behaviour (e.g. destructive sign-out)
- Link each row to audit ID or carryover ID

**Expected Outcome**: §15 debt register

### 14. Next Scope Preview (optional)

**Actions**:
- Document planned interfaces not yet implemented
- Mark clearly as **not implemented** — no aspirational status `fixed`

**Expected Outcome**: §16 preview table

### 15. Verification Matrix (QA viewpoint)

**Actions**:
- 8–15 cross-interface flows for device or integration QA
- Link to criteria doc if exists under `docs/`
- Include **regression rows** for known open bugs (e.g. sign-out data loss)
- Each row: flow name, interfaces touched, pass criterion

**Expected Outcome**: §17 verification matrix

### 16. Assemble & Write Document

**Actions**:
- Follow **Report Structure** below — section numbers are stable; mark N/A sections omitted with note in changelog
- Filename: `design-spec-{subject}-v{N}.md` (prefer versioned names over date-only)
- Default path: `agent/reports/`
- Include changelog when `--supersedes` set
- Add §18 file reference index and §19 Mermaid rendering notes
- Footer: `Generated by: ACP /acp-design-spec`

**Expected Outcome**: Spec saved to `agent/reports/`

### 17. Optional Verification (`--audit`)

**Actions** (same rigour as `/acp-audit`):
- Determine next `audit-NNN` number from `agent/reports/audit-*`
- Cross-check every store path, route, persistence path, and API against code
- Create `audit-NNN-design-spec-{subject}.md` with verdict and gap table
- If gaps found: bump spec version (patch) or write `v{N+0.1}` file
- Update `agent/memory/audit-carryovers.md` for new CO-* findings
- Set spec header `Audit: audit-NNN`

**Expected Outcome**: Audit reference in spec header; carryovers updated if needed

### 18. Suggest Visualizer & Related Commands

**Actions**:
- If ACP Visualizer is installed: remind user `/acp-visualize --update` to view diagrams in Docs tab
- Note Visualizer ≥ `fad4492` for Mermaid 11; v1.5.3+ for dev server stability
- Suggest `/acp-commit` if spec gates a milestone phase

**Expected Outcome**: User can render (if Visualizer installed) and archive the spec

---

## Verification Checklist

- [ ] Header includes stakeholders, status, standards mapping, supersedes link
- [ ] §2 Terminology defines domain terms used in spec
- [ ] §3 System context diagram present (full scope)
- [ ] All routes in scope listed with state dependencies
- [ ] All state modules in scope listed with persistence boundaries
- [ ] §6 persistence map complete for scope
- [ ] At least 5 Mermaid diagrams (full scope) or 3 (`--narrow`)
- [ ] §11 traceability with **code-verified** status column
- [ ] Sign-out / session lifecycle documented (if auth in scope)
- [ ] §15 debt register includes open carryovers
- [ ] §17 verification matrix with pass criteria
- [ ] §18 file index lists code roots and source milestone/audit docs
- [ ] §19 Mermaid syntax traps documented
- [ ] Spec saved under `agent/reports/`
- [ ] If `--audit`: audit report number assigned and referenced

---

## Expected Output

### Files Created
- `agent/reports/design-spec-{subject}-v{N}.md` — primary deliverable
- `agent/reports/audit-NNN-design-spec-{subject}.md` — if `--audit` or gaps found

### Console Output (example)

```
📐 Generating Application Interface & Data-Flow Design Specification

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scope: m15-spine (M15, M15.1)
App version: 2.0.1
Status: review

Inventorying routes...        ✓ 14 routes
Inventorying stores...        ✓ 16 stores
Persistence paths...          ✓ 9 collections
Backend API routes...         ✓ 28 endpoints
Data-flow diagrams...         ✓ 12 Mermaid blocks
Traceability rows...          ✓ 10 (code-verified)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Design Spec Complete!

Saved to: agent/reports/design-spec-{subject}-v{N}.md (exemplar: agent/feedback/design-spec-app-interfaces-m15-spine-v2.1.md)

Next: /acp-visualize --update  (view diagrams, if Visualizer installed)
      /acp-audit design-spec   (optional deeper verification)
      /acp-commit              (if milestone phase complete)
```

---

## Report Structure (required template)

Section numbers are **stable** across projects. Omit sections only when truly N/A; note omission in changelog.

```markdown
# {PROJECT} — Application Interface & Data-Flow Design Specification (v{N})

**Version**: {N}
**Generated**: {YYYY-MM-DD}
**Status**: draft | review | approved
**Supersedes**: {prior spec path or "—"}
**Audit**: {audit-NNN or "pending"}
**App version**: {from package manifest / progress.yaml}
**Scope**: {one-line scope}
**Stakeholders**: {developers, QA, security, PM — as applicable}
**Related**: {milestones, audits}
**Audience**: {detail design, QA sign-off, onboarding}
**Standards mapping**: arc42 §1–8, §11–12; C4 L1–L3; IEEE 1016; ISO 42010; DFD L0–L2

### Changelog (required when superseding)

## 1. Executive summary
## 2. Terminology
## 3. System context
### 3.1 Deployment & environments (optional — arc42 §7)
## 4. Interface inventory — screens (presentation)
### 4.1 Navigation shell
### 4.2 Stack / modal routes (if applicable)
### 4.3 Shell patterns (tab re-export, nested layout, etc.)
## 5. Interface inventory — state stores
### 5.1 Store catalog
### 5.2 Dual read/write paths (if any)
### 5.3 Cross-store data relationships
## 6. Persistence map (Firestore / DB / storage)
## 7. Backend API catalog & data flows
## 8. Client calculation engines (omit if N/A)
## 9. Before-state architecture (omit with --narrow)
### 9.1 Gap register
## 10. Target-state architecture
### 10.1 Milestone deliverables → interfaces
### 10.2 Remediation / follow-up interface changes
## 11. Requirements traceability
## 12. Bootstrap & session lifecycle
### 12.1 Sign-out data boundary
## 13. Encryption & security boundaries
## 14. Aggregation / composite interfaces (omit if N/A)
## 15. Known residual dual paths & technical debt
## 16. Next scope preview — planned interfaces
## 17. Verification matrix
## 18. File reference index
## 19. Mermaid rendering notes
```

---

## Examples

### Example 1: Milestone spine spec (full)

**Invocation**: `/acp-design-spec --milestone M15.1 app-interfaces-m15-spine --supersedes agent/reports/design-spec-app-interfaces-m15-spine-v2.md --audit`

**Result**: Full spec like v2.1; `audit-069` style verification report

### Example 2: Single feature scope (narrow)

**Invocation**: `/acp-design-spec --narrow paytracker-ocr`

**Result**: §4 paytracker routes, `financeStore`, OCR API, offline queue — skips §9/§16

### Example 3: Pre-milestone planning

**Invocation**: `/acp-design-spec --milestone M16 m16-health-interfaces --draft`

**Result**: §16 expanded; §10 partial target; status `draft`

### Example 4: Greenfield microservice

**Invocation**: `/acp-design-spec auth-session-flow`

**Result**: No §8/§9; §6 SQL or Redis; §12 session lifecycle focus

---

## Related Commands

- [`/acp-design-create`](acp.design-create.md) — Feature design docs in `agent/design/` (planning, not inventory)
- [`/acp-audit`](acp.audit.md) — Deep investigation; companion to `--audit`
- [`/acp-report`](acp.report.md) — Project status report (progress, not interfaces)
- [`/acp-visualize`](acp.visualize.md) — Render spec diagrams in Visualizer (if installed)
- [`/acp-validate`](acp.validate.md) — Schema validation before publishing spec
- [`/acp-commit`](acp.commit.md) — Session memory when spec completes a phase
- [`/acp-review`](acp.review.md) — Check code quality against spec assumptions after generating spec

---

## Troubleshooting

### Issue 1: Spec drifts from code within days

**Cause**: Rapid implementation without spec update  
**Solution**: Re-run with `--supersedes` and `--audit`; bump version; log carryovers

### Issue 2: Mermaid diagrams fail in Visualizer

**Cause**: Invalid syntax or stale Visualizer  
**Solution**: Follow §19 traps; if Visualizer installed, upgrade to ≥ fad4492; use `/acp-visualize --update`

### Issue 3: Scope too large for one session

**Cause**: Whole-app spec without milestone filter  
**Solution**: Use `--milestone` or `--narrow`; split by feature spine

### Issue 4: progress.yaml disagrees with code

**Cause**: Task marked complete before verification  
**Solution**: Spec §11 status reflects **code truth**; open CO in §15; never copy task status blindly

### Issue 5: Confusion with `/acp-design-create`

**Cause**: Both commands contain "design"  
**Solution**: `design-create` → `agent/design/` planning doc; `design-spec` → `agent/reports/` interface inventory

---

## Security Considerations

### File Access
- **Reads**: UI routes, state modules, server routes, `agent/milestones/`, `agent/memory/audit-carryovers.md`, `agent/progress.yaml`, optional `agent/wiki/domain.yml` (one section)
- **Writes**: `agent/reports/design-spec-*.md`, optional `agent/reports/audit-*.md`, optional `audit-carryovers.md`
- **Executes**: None

### Sensitive Data
- Documents encryption boundaries; does not export keys, credentials, or decrypted field values

---

## Upstream Integration Notes (ACP Enhanced maintainers)

When promoting this command to the framework distribution:

1. Add `acp.design-spec.md` to command package and `package.yaml`
2. Add `.cursor/commands/acp-design-spec.md` and `.opencode/commands/acp-design-spec.md` wrappers
3. Add `command_suggestions.acp-design-spec` entry in `routing.yml`
4. Add E2E smoke test in `e2e/` (verify directive header, report structure sections, `--audit` numbering)
5. Add `task_type: design-spec` → skill mapping in `taxonomy.yml`
6. Cross-link from `acp.report.md` Related Commands
7. Ship optional `agent/templates/design-spec.template.md` extracted from Report Structure above

---

## Notes

- Prefer **versioned filenames** (`-v2.1.md`) when superseding; retain prior versions for history
- Pair with `/acp-audit` when spec gates QA sign-off
- Traceability status must reflect **verified** code behaviour
- Exemplar project paths (FIFOZ): `frontend/store/`, `frontend/app/`, `backend/server.py`

---

**Namespace**: acp  
**Command**: design-spec  
**Version**: 1.1.0  
**Created**: 2026-06-04  
**Last Updated**: 2026-06-06  
**Status**: Active  
**Compatibility**: ACP 6.9.0+  
**Author**: FIFOZ field contribution → ACP Enhanced
