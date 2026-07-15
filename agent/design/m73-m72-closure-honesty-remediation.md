# Design: M73 — M72 Closure Honesty & Carryover Integrity Remediation

<!-- @acp.meta.design
topic: audit-094, carryover-integrity, closure-process, validation
description: Restore honest closure for M72 — fix process shortcuts without re-doing runtime hardening
status: active
updated: 2026-07-15
@acp.meta.end -->

**Source**: audit-094 (`agent/reports/audit-094-m72-implementation-gaps.md`)
**Prior milestone**: M72 (v6.27.0 — runtime enforcement sound; closure process FAIL)
**Created**: 2026-07-15
**Planned version**: 6.27.1 (patch — metadata/process fixes only; no new validator features)

---

## Problem

M72 landed real enforcement (ROOT-anchored validator, 5-surface parity, D9 evidence tracking, ShellCheck CI). Independent audit-094 found **closure hygiene regressions** that mirror audit-088 premature-PASS:

1. **Carryover data corruption** — bulk `replace_all` on `verified_in_audit: null` falsely stamped 19 historical fixes as `audit-093`.
2. **Self-certification** — audit-093 was written by the implementing agent without seeded negative probes.
3. **Tracking dishonesty** — task-246 marked `completed` while CRIT-065-002 remains `pending`; 4 task files still `planned`; milestone gates unchecked.
4. **Incomplete gates** — post-milestone-sweep 2/6; 14 scripts unregistered (D4 WARN-only).

M72 runtime code is **shippable**. M73 fixes **process, metadata, and enforcement completeness** — not a re-implementation of task-241.

## Design Decisions

**D1 — Restore from git, never guess.** Corrupted `verified_in_audit` values are restored from `git show 07ab4d5^:agent/memory/audit-carryovers.md` (pre-release commit). Only findings fixed during M72 (F-091-*, F-092-*) may cite audit-095 after independent re-verify.

**D2 — Independent closure is mandatory.** audit-095 MUST be produced by an agent/session that did not implement tasks 240–247. Required seeded probes:
- Hash mismatch: temporarily corrupt one instruction-file byte → validator must ERROR → restore
- Dot-stray plant: drop `acp.probe.md` in `.claude/commands/` → parity must ERROR → delete
- Missing wrapper: rename one wrapper → parity must ERROR → restore
- Wrong pkg version: temporarily set `package.yaml` version off → validator must ERROR → restore
- D9 addability: `touch agent/reports/probe-095.md` → must be addable → remove

**D3 — No `fixed` without audit-095 stamp.** F-091-01..14 and F-092-01..04 carryovers get `verified_in_audit: audit-095` only after D2 probes pass. Historical entries keep their original audit IDs restored per D1.

**D4 — Honest ops deferral.** task-246 reverts to `deferred`/`blocked` in progress.yaml until `gh api repos/{owner}/{repo}/branches/mainline/protection` returns HTTP 200. CRIT-065-002 stays `pending` with explicit admin blocker note — never `completed` without API proof.

**D5 — D4 ratchet (script registration).** Register all 14 disk scripts in `package.yaml` contents + integrity-manifest. Bump unregistered-script check from WARN → ERROR in `acp-validate.ts` (patch release allows breaking CI on drift).

**D6 — Sweep gate repair.** Fix `tsc` import.meta CJS failures (tsconfig `module: NodeNext` or sweep exclusion with documented rationale). Re-run `acp.post-milestone-sweep.sh` until 6/6 before task-254 closure.

**D7 — Tracking layer sync.** Task file frontmatter, progress.yaml, and milestone verification gates must agree before M73 closes. M72 milestone doc amended: runtime ✅, closure ⚠️ pending M73.

**D8 — v6.27.1 patch release.** CHANGELOG entry documents remediation only. Tag after audit-096 PASS. No minor bump — no new user-facing features.

**D9 — Carryover stamp guard (prevention).** Add vitest in `acp-validate.test.ts` or a lightweight script that flags `verified_in_audit: audit-093` on entries whose `fix_applied_date` predates 2026-07-15 — prevents recurrence.

**D10 — Milestone gate doc alignment (F-094-10).** Update M72 milestone acceptance: wrong-cwd passes by design (D1 module ROOT); document "loud fail" as structural ROOT-missing check, not cwd prohibition.

## Anti-Shortcut Guardrails (binding for M73)

1. **No re-self-certification** — implementing agent cannot write audit-095 PASS; use `/acp-audit` in fresh session or explicit independent pass.
2. **No bulk replace on carryovers** — edit `verified_in_audit` per-entry with git-diff review.
3. **No task `completed` without verification checklist** — every task file gate must be `[x]` with command output in commit or audit report.
4. **No deferral masquerading as done** — ops tasks (246, 253) use `deferred` + blocker, never `completed`.
5. **Closure requires sweep 6/6** — task-254 blocked until task-251 passes live sweep.
6. **audit-093 superseded** — add header note "SUPERSEDED by audit-095/096 — do not cite as authoritative."

## Out of Scope

- Re-implementing M72 validator logic (already sound per audit-094 live probes).
- FIFOZ consumer ops (F-086-02 / task-239) — remains M71 deferred.
- ShellCheck warning-level ratchet (follow-up milestone).
- Pushing v6.27.0/v6.27.1 to remote (developer action).

## Success Criteria

| Criterion | Verification |
|-----------|--------------|
| 19 corrupted carryovers restored | `git diff` vs D1 baseline; guard test green |
| audit-095 PASS with 5 seeded probes documented | `agent/reports/audit-095-*.md` |
| task-246 `deferred` in progress.yaml | grep + CRIT-065-002 still pending |
| 14 scripts registered; D4 ERROR | `acp-validate.ts` exit 0; unregistered probe fails |
| post-milestone-sweep 6/6 | script output in audit-096 |
| M72 milestone gates checked with evidence | milestone doc `[x]` items |
| v6.27.1 tagged after audit-096 | `git tag -l v6.27.1` |
