# Milestone 59: Critical-Fix & CI Integrity Track

**Shipped version**: 6.14.0  
**Status**: completed  
**Completed**: 2026-06-15  
**Estimated effort**: ~10h (6 routes)  
**Source**: audit-065, audit-066, audit-067 (consolidated register Part B)

## Goal

Stop active correctness bugs and make the CI pipeline trustworthy. Three of these routes fix **silent** defects: a data-loss bug in dispatch, a broken package install, and a CI that doesn't actually validate structure. This milestone must ship before any feature work or external adoption.

## Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-159 | Fix `updateRoutingYml()` full-overwrite → surgical session-block update + regression test | H1 (HIGH-066-001) | 2h | completed |
| route-160 | Add 13 missing commands to `package.yaml` + CI count-guard | H8 (HIGH-067-001) | 2h | completed |
| route-161 | Wire `acp-validate.ts` into CI + fix `ci-validate.sh` command-doc no-op | H2/H3 (HIGH-066-005/006) | 3h | completed |
| route-162 | Enable branch protection on `mainline` + `develop` | C1 (CRIT-065-002) | 0.25h | completed (docs; manual GitHub enable pending) |
| route-163 | `OPENROUTER_API_KEY` preflight check in dispatch | M9 (MED-066-002) | 0.5h | completed |
| route-164 | Fix `AGENTS.md` version header + add version-header check to `/acp-validate` | M12 (MED-067-002) | 1h | completed |

## Industry-Standard Verification (double-verify gate)

Each route must satisfy BOTH:
1. **Automated proof**: a passing test or CI check that would FAIL before the fix (regression-first).
2. **Manual proof**: a documented before/after command output in the route's User-Observable Acceptance.

Milestone-level exit criteria:
- ✅ `npm test` (new) green for dispatch regression (route-159)
- ✅ CI job fails on a deliberately malformed command doc (route-161 proof)
- ✅ `package.yaml` command count == command file count, enforced in CI (route-160)
- ⏳ Branch protection visibly enabled (screenshot/settings link in route-162) — docs complete; manual GitHub enable pending

## Success Criteria

- All 6 routes completed and verified per the double-verify gate
- `/acp-validate` passes clean
- No regression in existing E2E suite
- `CHANGELOG.md` entry for v6.14.0
- Carryovers H1, H2, H3, H8, C1, M9, M12 marked `fixed` with `verified_in_audit` set

## References

- `agent/reports/audit-067-complete-consolidated-audit.md` (Part B canonical register, Part D roadmap)
- `agent/reports/audit-066-second-round-validation-and-deep-gaps.md`
- `scripts/acp-dispatch.ts:191-195` (H1), `package.yaml` (H8), `scripts/ci-validate.sh:46` (H3)
