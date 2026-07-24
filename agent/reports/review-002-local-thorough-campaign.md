---
id: review-002
date: 2026-07-24
scope: scripts/ + agent/scripts/ (CodeRabbit CLI since v6.27.0) + Phase 1 acp.review-scan
executor: cursor
rules_applied: [phase1-scan, coderabbit-cli-chunked]
findings_total: 7
findings_critical: 0
findings_high: 3
findings_medium: 1
findings_low: 3
carryovers_created: 7
project_version: 6.28.2
campaign: M82
---

# Code Review: ACP Enhanced — Local Thorough Campaign (M82)

**Review**: #002  
**Date**: 2026-07-24  
**Scope**: Layered local review — ACP Phase 1 scanner + chunked CodeRabbit CLI (`--base v6.27.0`)  
**Executor**: cursor  

---

## Summary

Ops campaign (**M82**) to thoroughly review this repo **without** waiting for the M81 ADR-22 PR findings fixture.

| Layer | Result |
|-------|--------|
| Branch sync | `develop` merged `origin/mainline` (`9eb4854`) |
| Phase 1 `acp.review-scan.sh` | 1 HIGH — SH-01 on `acp.coderabbit.sh` (**false positive** for sourced lib; tracked as F-M82-05) |
| CodeRabbit CLI `scripts/` | 2 major → F-M82-01, F-M82-02 |
| CodeRabbit CLI `agent/scripts/` | 1 major + 1 minor → F-M82-03, F-M82-04 |
| CodeRabbit CLI `e2e/` + `.github/workflows/` | **Blocked** (rate limit / hang) → F-M82-06 residual |
| npm audit (scripts/) | high js-yaml → F-M82-07; vitest already ^3.2.7 |

**Gate honesty**: Planned ≥3 completed CLI chunks; **2 completed** due to CodeRabbit rate limits. Residual tracked (F-M82-06). Campaign still produced actionable HIGH findings.

**ADR-22 / M81**: This campaign does **not** satisfy `tests/fixtures/coderabbit-findings-sample.json`. CLI `--agent` JSON ≠ PR-comment export.

Artifacts: [`coderabbit-local-2026-07-24/`](coderabbit-local-2026-07-24/MANIFEST.md) · Playbook: [`coderabbit-local-thorough-review.md`](../wiki/coderabbit-local-thorough-review.md)

---

## Findings (carryover IDs)

| ID | Sev | File | One-liner |
|----|-----|------|-----------|
| F-M82-01 | medium | `scripts/acp-validate.ts` | Relative `ACP_SCHEMAS_DIR` cwd-sensitive |
| F-M82-02 | high | `scripts/acp-validate.ts` | `gh api` via shell `execSync` |
| F-M82-03 | high | `acp.project-update.sh` | tags query outside ADD_TAGS loop |
| F-M82-04 | low | `acp.post-milestone-sweep.sh` | total token budget message gap |
| F-M82-05 | low | `acp.review-scan.sh` | SH-01 vs sourced libraries |
| F-M82-06 | low | campaign MANIFEST | deferred e2e/workflows CLI chunks |
| F-M82-07 | high | `scripts/package.json` | js-yaml npm audit high |

Rejected / not carried: inventing a full-repo CodeRabbit scan; treating CLI JSON as M81 fixture.

---

## Next

1. Fix HIGH carryovers (F-M82-02, F-M82-03, F-M82-07) in a follow-up patch milestone or hotfix.
2. Re-run blocked CLI chunks when rate limit clears (F-M82-06).
3. Unblock **M81** separately with PR findings fixture.
