# Audit 077 — Cross-Agent Handoff Protocol (feedback-007 / FIFOZ field evidence)

**Audit ID**: audit-077  
**Date**: 2026-07-15  
**Auditor**: copilot (ACP Enhanced maintainers session)  
**Subject**: FIFOZ `feedback-007` + `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` vs current ACP Enhanced framework  
**Field audit**: FIFOZ `audit-245-cross-agent-handoff-acp-enhanced.md` (2026-07-13)  
**Mode**: Standard + upstream readiness (--pre-impl style for proposal acceptance)  
**Verdict**: **READY** — accept proposal for M67 implementation; submit upstream as feedback-007

---

## 1. Executive Summary

FIFOZ (Rygan/FIFOZ) runs a **production-grade same-repo multi-executor workflow**: Claude/Fable for planning and audit, Cursor Composer 2.5 for implementation. Nine persisted handoff files exist; the M51 exemplar (`handoff-cursor-composer25-m51-2026-07-13.md`) includes ADR locks, task sequences, git pins, and explicit scope guardrails — patterns that **contradict** the current `/acp-handoff` v1.0.0 command spec.

ACP Enhanced today optimizes for **cross-repo, problem-only** handoffs with no receiving protocol. FIFOZ compensates with tribal knowledge (`agent/wiki/cross-agent-handoff.md`). **Gap severity: HIGH** for teams using Claude + Cursor on one repo.

**Recommendation:** Implement **Cross-Agent Handoff Protocol v1** as **M67** (proposal §14 backlog). Until shipped, adopt FIFOZ wiki ritual as project-template documentation and import exemplar patterns into framework docs.

---

## 2. Files Analyzed

| Layer | ACP Enhanced (this repo) | FIFOZ (field evidence) |
|-------|--------------------------|------------------------|
| Command | `agent/commands/acp.handoff.md` v1.0.0 | Same (v2.14.2 install) |
| Resume | `agent/commands/acp.resume.md` — no handoff arg | `.cursor/skills/acp-resume/SKILL.md` |
| Routing | `agent/core/routing.yml` → `acp-handoff` suggests commit | Same pattern, not enforced |
| Proposal | `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` (imported) | Authoritative source |
| Feedback | `agent/feedback/feedback-007-cross-agent-handoff-protocol.md` (imported) | Submission brief |
| Field audit | — | `audit-245` (H1–H10 register) |
| Exemplar | — | `handoff-cursor-composer25-m51-2026-07-13.md` |
| Wiki ritual | `agent/wiki/cross-agent-handoff.md` (new, framework) | `agent/wiki/cross-agent-handoff.md` (FIFOZ pilot) |

---

## 3. Finding Register (upstream cross-check)

Maps FIFOZ audit-245 findings to **current ACP Enhanced** state (post v6.21.1):

| ID | Sev | Finding | ACP Enhanced today | Proposal addresses? |
|----|-----|---------|-------------------|---------------------|
| **H1** | HIGH | Command forbids implementation steps | `acp.handoff.md:125,247` — explicit "Do NOT include implementation steps" | ✅ `--mode executor` + template §4 |
| **H2** | HIGH | No `/acp-receive` | Command does not exist | ✅ New `acp.receive.md` §6 |
| **H3** | HIGH | Commit chain not enforced | `routing.yml:226-229` suggests commit; command silent | ✅ Outgoing ritual §7 |
| **H4** | MED | No git pin freshness on receive | No protocol | ✅ `/acp-receive` step 3 |
| **H5** | MED | Ad-hoc filenames | `handoff-{target}-{date}` only | ✅ `handoff-{to}-{scope}-{date}` |
| **H6** | MED | No return-path template | Not documented | ✅ Return handoff §9 |
| **H7** | MED | "Self-contained without source" conflicts with same-repo | `acp.handoff.md:273` | ✅ Mode split; executor assumes same repo |
| **H8** | LOW | Handoff usage undercounted in audits | audit-066 pattern | ✅ Wiki + `active_handoff` discoverability |
| **H9** | LOW | No `active_handoff` pointer | Not in `progress.schema.yaml` | ✅ §8 schema extension |
| **H10** | LOW | Cross-repo mixed in filename family | Single pattern | ✅ `--mode cross-repo` + optional `target-repo` in frontmatter (P2) |

**New upstream-only findings (audit-077):**

| ID | Sev | Finding | Evidence |
|----|-----|---------|----------|
| **U1** | MED | `acp-resume` chains init+proceed but never loads handoff files | `acp.resume.md` — no handoff argument |
| **U2** | LOW | No `agent/proposals/` or `agent/feedback/` dirs until this audit | Framework had no intake path for field specs |
| **U3** | LOW | Wiki has no cross-agent handoff page | `agent/wiki/` — 4 files, none on handoff |

---

## 4. What Works Today (preserve)

| Pattern | FIFOZ exemplar | Framework action |
|---------|----------------|------------------|
| Disk persistence in `agent/reports/` | 9/9 handoffs | Default **disk** for executor mode |
| Git branch + commit pin | M51 handoff L6–7 | Mandatory frontmatter fields |
| ADR "do not re-litigate" | M51 L29–36 | Template §4 locked decisions |
| Task dependency sequence | M51 L45–47 | Template §4 plan reference |
| What NOT to do | M51 L50–56 | Template §4 guardrails |
| Audit-only vs implement mode | Claude M47 handoff | Template §4 assignment |
| `@` attach in Cursor | Operational | Document in wiki; no transport layer in v1 |

---

## 5. Gaps vs ACP Design Intent

| ACP v1.0 design choice | Multi-executor reality (FIFOZ + expected) | Resolution |
|------------------------|-------------------------------------------|------------|
| Handoff = narrow problem, no steps | Executor handoff = milestone package | **Dual mode** — do not break cross-repo default |
| Chat-primary delivery | Rich file pointers to tasks/ADRs | Executor mode: **disk required** |
| No receiving command | `@handoff` + manual git check | **`/acp-receive`** |
| No lifecycle | Stale handoffs, no superseded | Frontmatter `status` + `active_handoff` |
| Report vs handoff boundary unclear | Teams confuse `/acp-report` | Wiki table: report = session summary; handoff = transfer |

---

## 6. Pre-Implementation Readiness (proposal v1)

| Phase | Result | Notes |
|-------|--------|-------|
| Plan correctness | ✅ | Proposal §4–§10 complete; acceptance criteria §13 testable |
| Evidence | ✅ | FIFOZ audit-245 + M51 exemplar + 9 handoff corpus |
| Code cross-reference | ✅ | `acp.handoff.md` conflicts confirmed at L125, L247 |
| Open blockers | ✅ None for **writing** M67; capacity scheduling only |
| Carryovers | N/A | Framework enhancement, not FIFOZ CO |

### Readiness Verdict

**READY** — Accept `feedback-007` and implement M67 per plan below. FIFOZ local wiki remains valid pilot until `/acp-version-update` delivers v2 handoff.

---

## 7. Implementation Plan — M67 Cross-Agent Handoff Protocol

**Target version:** v6.23.0  
**Estimated effort:** ~25–30h (8 routes)  
**Depends on:** None (orthogonal to M63 test coverage)

### Route map

| Route | Priority | Deliverable | Effort | Acceptance |
|-------|----------|-------------|--------|------------|
| **route-190** | P0 | `acp.handoff.md` v2 — `--mode executor\|cross-repo`, `--to`, executor template §4, outgoing ritual | M | Executor handoff fails verify if git pin missing |
| **route-191** | P0 | New `acp.receive.md` — path/`--latest`, git drift warn, session gap warn, checklist | M | E2E: drift warning on wrong SHA |
| **route-192** | P1 | Extend `acp.resume.md` — optional handoff path → receive steps then resume | S | `/acp-resume @handoff.md` loads receive banner |
| **route-193** | P1 | `progress.yaml` `active_handoff` + `progress.schema.yaml` + validate rule + wiki + wrappers sync | M | validate passes; wiki published |
| **route-194** | P2 | `HANDOFF-LATEST.md` copy, superseded frontmatter automation, git ancestry validate (optional) | S | Deferred if M67 timeboxed |

### Build order

```
route-190 (handoff v2)
    → route-191 (receive)
        → route-192 (resume integration)
            → route-193 (schema + wiki + parity)
                → route-194 (P2 polish)
```

### Per-route file checklist

**route-190 — handoff v2**
- [ ] `agent/commands/acp.handoff.md` — version 2.0.0
- [ ] `.github/prompts/acp-handoff.prompt.md`, `.opencode/commands/acp-handoff.md`, `.cursor/commands/acp-handoff.md`
- [ ] `package.yaml` entry if missing
- [ ] `agent/core/routing.yml` — `acp-receive` suggestions
- [ ] E2E: `e2e/acp.handoff.test.sh` — structural + executor template sections

**route-191 — receive**
- [ ] `agent/commands/acp.receive.md`
- [ ] Wrapper parity (prompt + opencode + cursor)
- [ ] E2E: `e2e/acp.receive.test.sh` — git drift fixture

**route-192 — resume**
- [ ] `agent/commands/acp.resume.md` — Step 0 handoff path
- [ ] `agent/commands/acp.resume.md` cross-link in header

**route-193 — schema + wiki**
- [ ] `agent/schemas/progress.schema.yaml` — `active_handoff` block
- [ ] `scripts/acp-validate.ts` — optional active_handoff file exists
- [ ] `agent/wiki/cross-agent-handoff.md` — framework ritual + mermaid §11
- [ ] `agent/wiki/architecture.md` — one section link
- [ ] Import exemplar reference (FIFOZ M51 path as external example, not copied)

**route-194 — P2**
- [ ] Handoff command writes `HANDOFF-LATEST.md`
- [ ] Superseded marking on `supersedes:` field
- [ ] Git ancestry: pinned SHA is ancestor of HEAD

### Verification gates (milestone exit)

- [ ] `/acp-handoff --mode executor` generates all proposal §4 sections
- [ ] `/acp-handoff --mode cross-repo` preserves v1.0.0 behaviour
- [ ] `/acp-receive` warns on git drift and session date gap
- [ ] `active_handoff` written on executor save
- [ ] `/acp-resume @handoff.md` runs receive checklist
- [ ] 69×3 command parity maintained
- [ ] CHANGELOG v6.22.0 entry
- [ ] FIFOZ can close feedback-007 after `acp-version-update`

---

## 8. Local Pilot (until M67 ships)

Projects like FIFOZ should:

1. Follow `agent/wiki/cross-agent-handoff.md` ritual (commit → handoff disk → git pin verify on receive)
2. Use filename convention `handoff-{to}-{scope}-{YYYY-MM-DD}.md`
3. Use proposal §4 template manually for executor handoffs
4. Track upstream via `feedback-007` until framework release

ACP Enhanced template install should ship `agent/wiki/cross-agent-handoff.md` after M67 route-193.

---

## 9. Carryovers

None filed — this is greenfield framework work. Post-M67: add FIFOZ feedback-007 closure to `agent/memory/audit-carryovers.md` if needed.

---

## 10. Related

| Artifact | Path |
|----------|------|
| Proposal (upstream) | `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` |
| Feedback brief | `agent/feedback/feedback-007-cross-agent-handoff-protocol.md` |
| FIFOZ field audit | `../Rygan/FIFOZ/agent/reports/audit-245-cross-agent-handoff-acp-enhanced.md` |
| FIFOZ exemplar | `../Rygan/FIFOZ/agent/reports/handoff-cursor-composer25-m51-2026-07-13.md` |
| Milestone plan | `agent/milestones/milestone-67-cross-agent-handoff-protocol.md` |
| Wiki (framework) | `agent/wiki/cross-agent-handoff.md` |
| Current handoff cmd | `agent/commands/acp.handoff.md:125,247` |

---

*Audit-077 | ACP Enhanced v6.21.1 | feedback-007 intake | READY for M67*
