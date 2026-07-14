---
id: task-207
milestone: M68
title: E2E preserve behavioral tests (route-202)
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started:
completed:
route: route-202
audit_findings: [F-080-10, F-080-13, P-081-01, P-081-02, P-081-03]
---

## Objective

Regression-proof tier policy with behavioral E2E (not syntax-only — SC-080-06).

## Steps

1. Create `e2e/acp.version-update-preserve.test.sh` — temp dir, stub AGENTS.md, customized identity.yml, progress.yaml
2. **Offline upstream**: set `ACP_UPSTREAM_ROOT="${PROJECT_ROOT}"` or copy fixture tree — **no live git clone in CI** (P-081-03)
3. Assert identity + progress unchanged after update; acp commands refreshed
4. Assert third-party command namespace preserved (P-081-01)
5. Assert `local.*` skill preserved (P-081-02)
6. Create `e2e/acp.install-preserve.test.sh` — manifest with 2 packages, reinstall
7. Register suites in `domain.yml`; run in CI matrix (ubuntu, macOS, windows)
8. CRLF-safe assertions (`tr -d '\r'`) where needed

## Verification

- [ ] Both suites 100% pass locally
- [ ] ≥12 assertions in version-update-preserve suite
- [ ] CI passes without network for version-update preserve test

## User-Observable Acceptance

CI green on preserve tests; failure if blind `cp` reintroduced.

## Anti-shortcuts

- SC-080-06: behavioral tests required — syntax-only `bash -n` insufficient
- SC-080-01: route-079 re-close gated on this suite passing
