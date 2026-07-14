---
id: route-202
title: E2E — version-update preserve + install reinstall behavioral tests
task_type: testing
milestone: M68
complexity: medium
executor: copilot
context_required:
  - design/safe-install-update-policy.md
  - patterns/local.e2e-testing.md
files_affected:
  - e2e/acp.version-update-preserve.test.sh
  - e2e/acp.install-preserve.test.sh
  - agent/wiki/domain.yml
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Behavioral E2E (not grep-only): temp project with customized identity.yml + progress.yaml; mock or fixture upstream; assert preserve on default update. Reinstall test for manifest merge.

## Acceptance criteria

- [ ] `e2e/acp.version-update-preserve.test.sh` — ≥12 assertions, 100% pass
- [ ] `e2e/acp.install-preserve.test.sh` — manifest merge + core preserve
- [ ] Suites registered in `agent/wiki/domain.yml` test_suites
- [ ] CRLF-safe assertions where needed (Windows)
- [ ] Offline upstream fixture (`ACP_UPSTREAM_ROOT` or local copy) — no live git clone in CI (P-081-03)
- [ ] Assert third-party command namespace preserved (P-081-01)
- [ ] Assert `local.*` skill preserved on update (P-081-02)
- [ ] Assert `progress.yaml` unchanged (F-080-13)

## Addresses

audit-080 F-080-10, F-080-13; P-081-01, P-081-02, P-081-03; SC-080-06
