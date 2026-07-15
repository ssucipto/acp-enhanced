---
id: review-001
date: 2026-07-15
scope: scripts/ + agent/scripts/ + e2e/ (post-M63 v6.25.1)
executor: copilot
rules_applied: [error-handling, typescript, security, code-health, appendix-a]
findings_total: 9
findings_critical: 1
findings_high: 4
findings_medium: 3
findings_low: 1
carryovers_created: 5
project_version: 6.25.1
---

# Code Review: ACP Enhanced — Post-M63 v6.25.1

**Review**: #001  
**Date**: 2026-07-15  
**Scope**: `scripts/` (TypeScript tooling), `agent/scripts/` (bash), recent M63 E2E  
**Executor**: copilot  

---

## Summary

First structured `/acp-review` after M63 deployment. **No CRITICAL runtime security issues in shipped framework code.** M63 coverage changes (tier3 loop, `validateCommandE2eCoverage`) follow project conventions. Primary concerns are **dev dependency CVEs** (vitest/vite in `scripts/package.json`) and **TypeScript `any` usage** in validation/dispatch tooling. One bash script (`acp.package-search.sh`) remains exempt from `set -euo pipefail` by documented exception.

**Gate**: 1 CRITICAL + 4 HIGH findings — address HIGH+ before next production tag; vitest upgrade is dev-CI scoped.

---

## Findings

```yaml
findings:
  - id: CR-001
    file: scripts/package.json
    line: 21
    rule: SC-14
    severity: CRITICAL
    owasp: A03:2025
    message: "vitest ^1.6.0 — npm audit CRITICAL GHSA-5xrq (arbitrary file read/execute when UI server listening)"
    fix: "Upgrade vitest to >=3.2.6 (or latest 3.x); run npm audit fix; CI uses vitest run only — mitigate by not exposing UI in CI"

  - id: CR-002
    file: scripts/package.json
    line: 21
    rule: SC-14
    severity: HIGH
    owasp: A03:2025
    message: "Transitive vite <=6.4.2 — GHSA-fx2h high severity path traversal on Windows"
    fix: "Upgrade vitest/vite chain via npm audit fix; verify scripts/ tests still pass"

  - id: CR-003
    file: scripts/acp-validate.ts
    line: 298
    rule: TS-01
    severity: HIGH
    message: "Widespread any — loadYaml<any>, Record<string, any> in taxonomy/config/progress parsers (15+ sites)"
    snippet: "const taxonomy = loadYaml<any>(TAXONOMY_PATH);"
    fix: "Define YamlTaxonomy, YamlConfig, ProgressYaml interfaces; replace any casts"

  - id: CR-004
    file: scripts/acp-dispatch.ts
    line: 294
    rule: TS-01
    severity: HIGH
    message: "catch (err: any) — typed as any instead of unknown"
    snippet: "} catch (err: any) {"
    fix: "catch (err: unknown) { const msg = err instanceof Error ? err.message : String(err); ... }"

  - id: CR-005
    file: agent/scripts/acp.package-search.sh
    line: 6
    rule: SH-01
    severity: HIGH
    message: "Missing set -euo pipefail + trap ERR — only script with documented exclusion"
    snippet: "# Note: set -euo pipefail disabled because while loop runs in subshell"
    fix: "Refactor while-loop error handling to allow pipefail, or add explicit ERR trap without -e"

  - id: CR-006
    file: agent/scripts/acp.project-list.sh
    line: 99
    rule: CH-01
    severity: MEDIUM
    message: "TODO without linked task ID"
    snippet: "# TODO: Tag filtering (requires array parsing)"
    fix: "Link to route/task or remove; use // TODO: task-NNN format"

  - id: CR-007
    file: scripts/acp-validate.ts
    line: 893
    rule: TS-02
    severity: MEDIUM
    message: "Dynamic require('child_process') inside validateGitTagsExist — CJS in ESM module"
    fix: "Use top-level import { execSync } from 'child_process' (already used elsewhere in file)"

  - id: CR-008
    file: e2e/acp.review.test.sh
    line: 128
    rule: SC-01
    severity: LOW
    message: "Fixture secrets in E2E test file — intentional negative test for SC-01 scanner"
    fix: "No action — test fixture only; ensure scanner excludes e2e fixtures"

  - id: CR-009
    file: scripts/acp-dispatch.ts
    line: 191
    rule: POSITIVE
    severity: INFO
    message: "updateRoutingYml() now regex-replaces session block only — audit-066 HIGH-066-001 regression fixed"
    fix: "N/A"
```

---

## Category Rollup

| Category | CRIT | HIGH | MED | LOW |
|----------|------|------|-----|-----|
| Security (SC-14) | 1 | 1 | 0 | 0 |
| TypeScript (TS-01/02) | 0 | 2 | 1 | 0 |
| Shell (SH-01) | 0 | 1 | 0 | 0 |
| Code Health (CH-01) | 0 | 0 | 1 | 0 |
| Info | 0 | 0 | 0 | 1 |

---

## M63 Amendment Review (targeted)

| Check | Result |
|-------|--------|
| `validateCommandE2eCoverage` options API | ✅ `repoRoot`/`commandsDir` — no `any` in new code |
| tier3 E2E dynamic loop | ✅ `is_tier2_slug`, meta-assertion 58 |
| Vitest coverage tests | ✅ 3 cases; no `process.chdir` |
| Agent Directive grep -qi | ✅ tier2/tier3 |

---

## Positive Observations

- `updateRoutingYml` partial update preserves `context_modes` / `command_suggestions` (audit-066 closed)
- 36/37 `acp.*.sh` use `set -euo pipefail`; most have `trap ERR`
- `scripts/tsconfig.json` has `strict: true`
- M63 E2E suites 100% pass (tier2 52, tier3 259, parity 8)
- No empty catch blocks in TypeScript tooling
- Test fixture secrets isolated to `e2e/acp.review.test.sh` negative cases

---

## Recommendations

1. **P0**: `cd scripts && npm audit fix` — upgrade vitest/vite (CR-001, CR-002)
2. **P1**: TypeScript strictness pass on `acp-validate.ts` (CR-003)
3. **P2**: `err: unknown` in dispatch catch (CR-004)
4. **P3**: Resolve `acp.package-search.sh` pipefail debt or document permanent exception in wiki

---

## OWASP Mapping (--owasp)

| Finding | OWASP Top 10:2025 |
|---------|-------------------|
| CR-001, CR-002 | A03 Software Supply Chain Failures |
| CR-003, CR-004 | A10 Mishandling of Exceptional Conditions (typing) |

---

**Review complete.** 5 HIGH+ carryovers written to `audit-carryovers.md`.
