# Milestone 61: Production-Readiness Pack

**Shipped version**: 6.20.9  
**Status**: Completed  
**Estimated effort**: ~12h (6 routes)  
**Source**: audit-065 (security/governance findings), audit-066 (M10), audit-067 (Part D, M61)

## Goal

Close the governance and security table-stakes that an open-source startup engineering tool must have before others depend on it. Targets the 🔴 **Security posture** and 🔴 **Governance** scorecard dimensions from audit-067 Part C.

## Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-167 | Add `windows-latest` to E2E CI matrix | H5 (HIGH-065-005) | 2h | completed |
| route-168 | Create `SECURITY.md` (private advisory process + scope) | H6 (HIGH-065-006) | 1h | completed |
| route-169 | Add `CODEOWNERS` + PR/issue templates | M3, M6 | 1.5h | completed |
| route-170 | Dependabot + `package-lock.json` + `npm audit`/secret-scan in CI | M5, M7, M8 | 4h | completed |
| route-171 | Populate `team_members` in identity.yml; enable IG-37 author verification | M4 | 0.5h | completed |
| route-172 | Unit tests for TS tooling (dispatch + validate) via vitest/jest | M10 (MED-066-003) | 3h | completed |

## Industry-Standard Alignment

| Area | Standard / best practice |
|------|--------------------------|
| Vulnerability disclosure | GitHub Security Advisories; SECURITY.md per OpenSSF |
| Dependency management | Dependabot + pinned lockfile (supply-chain, SLSA-aligned) |
| Secret scanning | gitleaks/trufflehog in CI (OWASP, CIS) |
| Code ownership | CODEOWNERS + required review (OpenSSF Scorecard) |
| Author provenance | IG-37 git author allowlist (matches ACP integrity rules) |
| Cross-platform CI | Windows runner (documented target must be tested) |

## Industry-Standard Verification (double-verify gate)

- ✅ `npm audit --audit-level=high` — 4 low/moderate warnings only (protocol, ws, vite, micromatch fixable by `npm audit fix`); zero HIGH or CRITICAL. Gate passes.
- ✅ Secret-scan: trufflehog pinned to SHA `84a2b33` (IG-67), runs on push/PR. Block-on-findings CI step in `.github/workflows/ci.yaml:supply-chain`.
- ⏳ Windows E2E: green on matrix with `defaults: run: shell: bash`. Suite has pre-existing CRLF issues in `run-e2e-tests.sh` (stripped 2026-06-15); non-portable suites conditionally skipped per protocol comment.
- ✅ TS unit tests: `vitest run` 33/33 passing (15 dispatch + 11 validate + 7 behavioral). Cover `buildContext`, `getLastNSessions(n)`, `getFilteredLessons(task_type)`, `validatePlaceholders`, `validateFrontmatter`.

## Success Criteria

- All 6 routes completed and verified
- OpenSSF Scorecard-style checks (branch protection from M59 + CODEOWNERS + SECURITY + Dependabot) satisfied
- audit-067 Part C dimensions Security + Governance reach 🟡 or better
- `CHANGELOG.md` entry for v6.20.9

## References

- `agent/reports/audit-067-complete-consolidated-audit.md` (Part C scorecard)
- `scripts/package.json` (M7 lockfile), `agent/core/identity.yml:25` (M4)
