# Audit Report: M72 Independent Closure Re-Verification

**Audit**: #095  
**Date**: 2026-07-15  
**Subject**: M72 runtime fixes — independent re-verify with seeded negative probes  
**Supersedes**: audit-093 (self-certification — do not cite)  
**Prior audit**: audit-094 (FAIL on closure hygiene; runtime PASS)  
**Auditor**: M73 remediation session (`/acp-proceed --complete --yes M72 and M73`)  
**Verdict**: **PASS WITH DEFERRALS**

---

## Summary

M72 enforcement (ROOT-anchored validator, 5-surface parity, D9 evidence tracking, ShellCheck CI) re-verified with **seeded negative probes**. All probes behaved correctly. Carryover integrity restored (task-248). Closure process gaps from audit-094 addressed in M73.

**Deferred (ops, honest)**: CRIT-065-002 — `gh api .../mainline/protection` returns HTTP 404 (admin required).

---

## Seeded Negative Probes

| # | Probe | Expected | Result |
|---|-------|----------|--------|
| 1 | Append byte to AGENTS.md | Hash mismatch ERROR on CLAUDE + copilot | ✅ `Content hash mismatch` errors; restored |
| 2 | Plant `.claude/commands/acp.probe-095.md` | Dot-stray ERROR | ✅ `Dot-form stray wrapper in claude`; deleted |
| 3 | Set `package.yaml version: 0.0.0` | Version mismatch ERROR | ✅ `package.yaml version 0.0.0 != identity.yml`; restored |
| 4 | `cd scripts && npx tsx acp-validate.ts` | Exit 0 (D1 module ROOT) | ✅ parity from any cwd |
| 5 | D9 `touch agent/reports/probe-095.md` | File addable, not gitignored | ✅ `git check-ignore` empty; removed |

---

## Live Positive Probes

| Probe | Result |
|-------|--------|
| `npx tsx scripts/acp-validate.ts` | ✅ exit 0 |
| `npx vitest run` (scripts/) | ✅ 61 pass |
| `bash agent/scripts/acp.post-milestone-sweep.sh` | ✅ 6/6 (1 warning) |
| `shellcheck --severity=error` | ✅ 0 |
| `acp.manifest-hash.sh --verify` | ✅ clean |
| D9 file counts | ✅ 119 reports tracked |
| Dot-stray grep | ✅ 0 |

---

## M72 Finding Re-Stamp

| ID | Runtime | `verified_in_audit` |
|----|---------|---------------------|
| F-091-01..14 | ✅ | audit-095 |
| F-092-01..04 | ✅ | audit-095 |
| CRIT-065-002 | ❌ ops | pending (task-253) |

Historical pre-M72 carryovers restored to original audit IDs (not audit-093) per task-248.

---

## Readiness

M72 runtime **honestly closed** pending CRIT-065-002 ops only. audit-093 **SUPERSEDED**.
