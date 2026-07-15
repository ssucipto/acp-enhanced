# Plan Amendment: M68 — audit-080 + audit-081 Integration

**Amendment date**: 2026-07-15  
**Prior plan**: `09738f5` plan(M68) from audit-080  
**Trigger**: audit-081 pre-impl readiness + user `/acp-plan` amend request  

---

## What changed

| Area | Before | After |
|------|--------|-------|
| Source audits | audit-080 only | audit-080 + audit-081 |
| Finding coverage | F-080-01..11 | F-080-01..12 + P-081-01..03 |
| Shortcuts | SC-080-01..04 | SC-080-01..06 |
| route-199 AC | 5 items | 8 items (+P-081-01,02,08) |
| route-202 AC | 4 items | 7 items (+P-081-01,02, F-080-13) |
| route-203 depends | route-199 | **route-202** (E2E gate) |
| route-204 priority | P2 | **P0** (blocks tag) |
| Effort estimate | 18–22h | 20–24h |
| Carryover closure | 11 items | **15 items** |

---

## Complete finding → route matrix

See `agent/milestones/milestone-68-safe-install-update-policy.md` § Audit traceability.

---

## Shortcuts addressed

| ID | M47/v6.9.0 mistake | M68 prevention |
|----|-------------------|--------------|
| SC-080-01 | route-079 doc-only complete | E2E + shell before `completed:` |
| SC-080-02 | CHANGELOG without script | v6.24.0 reconciliation |
| SC-080-03 | Blind `cp` globs | Helper API + validate guard |
| SC-080-04 | Manifest `cat >` | Tier D merge |
| SC-080-05 | Doc contradicts itself | Single tier table |
| SC-080-06 | Syntax-only tests | ≥12 behavioral assertions |

---

## Pre-conditions (from audit-081)

1. Upstream SHA, not `is_file_modified` (P-081-07) — route-198
2. Third-party commands preserved (P-081-01) — route-199
3. `local.*` skills skip on update (P-081-02) — route-199
4. Offline E2E fixture (P-081-03) — route-202
5. route-079 re-close after route-202 (P-081-04) — route-203
6. Validate guard before tag (SC-080-03) — route-204 → route-205

---

## Next action

```
/acp-proceed --complete --yes M68
```
