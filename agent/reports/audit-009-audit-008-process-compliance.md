# Audit Report: audit-008 Process Compliance

**Audit**: #009  
**Date**: 2026-05-09  
**Subject**: Did audit-008 (feedback-001 knowledge preservation) follow the proper ACP Enhanced process?  

---

## Summary

Audit-009 investigates whether the work performed in commit `4e00a90` (audit-008, feedback-001 fixes)
followed proper ACP Enhanced process — specifically: routing, milestoning, session commits, changelog,
progress tracking, AGENT.md updates, and wiki synchronisation.

**Verdict: 6 compliance gaps found.** The audit-008 work was technically sound and its outcomes were
correct, but it was executed without following the ACP process that governs all significant work in
this repository. Ironically, some of the very gaps mirror the issues audit-008 was designed to fix
(missing proactive session entry, no knowledge trail left by the session).

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/reports/audit-008-feedback-001-knowledge-preservation.md` | report | Subject of compliance review |
| `agent/routing/tasks/route-001.md` – `route-012.md` | routing | Confirms highest route is 012 |
| `agent/milestones/milestone-37-audit-007-fixes.md` | milestone | Confirms highest milestone is 37 |
| `agent/memory/sessions.md` | memory | No entry for 2026-05-09 audit-008 session |
| `CHANGELOG.md` | changelog | Latest entry is [6.4.12] — no audit-008 entry |
| `agent/progress.yaml` | config | version: 6.3.0 (actual 6.4.12), stale milestone |
| `AGENTS.md` / `CLAUDE.md` | protocol | Mid-Session Commit Triggers added ✅ |
| `AGENT.md` | human guide | No proactive commit protocol mention ❌ |
| `agent/wiki/architecture.md` | wiki | No proactive commit protocol mention ❌ |
| `agent/wiki/domain.yml` | wiki | No proactive commit protocol mention ❌ |
| `agent/core/constraints.yml` | core | 6 new knowledge-preservation rules added ✅ |
| `agent/commands/acp.commit.md` | command | v1.0.0 → v1.1.0 updated ✅ |
| `agent/memory/lessons.md` | memory | acp-knowledge-gap postmortem prepended ✅ |

---

## Key Findings

| # | Finding | Location | Severity |
|---|---------|----------|----------|
| F1 | No `/acp-route` run before audit-008 work — no route file exists for the work | `agent/routing/tasks/` (route-012 is highest) | Medium |
| F2 | No session entry in `sessions.md` for audit-008 session (2026-05-09) | `agent/memory/sessions.md` | High |
| F3 | `progress.yaml` stale: version 6.3.0, current_milestone M25-complete, description from M24 era | `agent/progress.yaml:6` | High |
| F4 | CHANGELOG.md has no entry for commit `4e00a90` protocol changes | `CHANGELOG.md` (latest: [6.4.12]) | High |
| F5 | `AGENT.md` not updated with Mid-Session Commit Triggers or proactive commit protocol | `AGENT.md` | Medium |
| F6 | `agent/wiki/architecture.md` and `agent/wiki/domain.yml` not updated for new protocol | `agent/wiki/` | Low |

---

## Key Decisions

- **R1 (ADOPT)**: Add 7-trigger proactive commit table to context loading protocol in all three agent entry files → DONE in commit `4e00a90`
- **R2 (ADOPT)**: Replace `never_skip_acp_commit` rule in `constraints.yml` with 6 granular knowledge-preservation rules → DONE
- **R3 (ADOPT)**: Bump `acp.commit.md` to v1.1.0 with phase-boundary frequency and proactive trigger list → DONE
- **R4 (ADOPT)**: Prepend high-priority `acp-knowledge-gap` postmortem to `lessons.md` → DONE
- **R5 (REJECT)**: Rename `/acp-commit` → `/acp-checkpoint` — too invasive, deferred indefinitely

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `AGENTS.md:29` | Mid-Session Commit Triggers section (7 triggers, added in audit-008) |
| `agent/core/constraints.yml:30` | 6 new knowledge-preservation constraint rules |
| `agent/commands/acp.commit.md:1` | v1.1.0 — frequency: phase boundary AND session end |
| `agent/memory/lessons.md:1` | acp-knowledge-gap lesson (priority: high, date: 2026-05-09) |
| `agent/reports/audit-008-feedback-001-knowledge-preservation.md:1` | Full audit-008 report |
| `agent/progress.yaml:6` | version: 6.3.0 (STALE — should be 6.4.12+) |
| `agent/memory/sessions.md` (end) | Last entry is 2026-05-06 — no 2026-05-09 audit-008 entry |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-09 | `4e00a90` | fix(protocol): proactive commit triggers — feedback-001 knowledge preservation (8 files) |
| 2026-05-06 | `ee065b8` | chore(memory): acp-commit — M25 session + tanstack pattern |
| 2026-05-06 | `4cdd98d` | chore(memory): acp-commit — status + Q&A session |

**Note**: The `4e00a90` commit touched 8 files. Per the new Mid-Session Commit Triggers rule (added in
that same commit), a `git commit` touching more than 5 files = phase boundary → session entry required.
The rule was adopted but not applied retroactively to the session that created it.

---

## Recommendations

### Immediate (Compliance Fixes)

1. **[DONE → audit-009]** Create route file `agent/routing/tasks/route-013.md` — retroactive routing for audit-008 feedback-001 work
2. **[DONE → audit-009]** Create `agent/milestones/milestone-38-protocol-knowledge-preservation.md` — milestone for feedback-001 implementation
3. **[DONE → audit-009]** Write `agent/memory/sessions.md` entry for 2026-05-09 audit-008 session
4. **[DONE → audit-009]** Add CHANGELOG.md entry `[6.4.13]` for commit `4e00a90` protocol changes
5. **[DONE → audit-009]** Update `agent/progress.yaml`: version → 6.4.13, current_milestone → all-complete, description → current state
6. **[DONE → audit-009]** Update `AGENT.md` with Mid-Session Commit Triggers reference and proactive commit protocol
7. **[DONE → audit-009]** Update `agent/wiki/architecture.md` and `agent/wiki/domain.yml` with proactive commit protocol

### Process

8. **Before starting any significant work**, run `/acp-route` to create a route file — even for audit work
9. **After any commit touching >5 files**, immediately write a `sessions.md` entry (per Mid-Session Commit Triggers rule)
10. **After any CHANGELOG-worthy commit**, update CHANGELOG.md in the same commit or immediately after

---

## Findings Summary

| # | Finding | Severity | Status |
|---|---------|----------|--------|
| F1 | No route file for audit-008 work | Medium | Fixed (route-013) |
| F2 | No sessions.md entry for 2026-05-09 | High | Fixed |
| F3 | progress.yaml stale (version, milestone, description) | High | Fixed |
| F4 | CHANGELOG.md missing [6.4.13] entry | High | Fixed |
| F5 | AGENT.md not updated with proactive commit protocol | Medium | Fixed |
| F6 | Wiki not updated for proactive commit protocol | Low | Fixed |
