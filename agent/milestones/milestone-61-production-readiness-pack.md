# Milestone 61: Production-Readiness Pack

**Target version**: 6.20.8  
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

- `npm audit --audit-level=high` returns clean (or documented exceptions)
- Secret-scan runs on PR and blocks on findings
- Windows E2E job green
- TS unit tests cover `buildContext` budget enforcement + `updateRoutingYml` non-destructiveness (cross-check with route-159)

## Success Criteria

- All 6 routes completed and verified
- OpenSSF Scorecard-style checks (branch protection from M59 + CODEOWNERS + SECURITY + Dependabot) satisfied
- audit-067 Part C dimensions Security + Governance reach 🟡 or better
- `CHANGELOG.md` entry for v6.16.0

## References

- `agent/reports/audit-067-complete-consolidated-audit.md` (Part C scorecard)
- `scripts/package.json` (M7 lockfile), `agent/core/identity.yml:25` (M4)
