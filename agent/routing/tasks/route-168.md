---
id: route-168
title: Create SECURITY.md (vulnerability disclosure process + scope)
task_type: docs-update
milestone: M61
complexity: low
executor: copilot
context_required:
  - wiki/integrity-rules.md
files_affected:
  - SECURITY.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Add a `SECURITY.md` defining the vulnerability disclosure process and security scope, per OpenSSF/GitHub best practice for open-source tooling.

## Context

No SECURITY.md or disclosure process exists (audit-065 HIGH-065-006). Production-dependable tooling must give researchers a private reporting path.

## Steps

1. Create `SECURITY.md` at repo root with:
   - **Reporting a vulnerability**: use GitHub private security advisories (preferred); fallback contact.
   - **Supported versions**: which versions receive security fixes.
   - **Scope**: in-scope (bootstrap/install scripts, dispatch.ts, bash scripts, command docs that execute) vs out-of-scope (instance data, third-party deps tracked by Dependabot).
   - **Response targets**: acknowledgement and triage timeframes.
   - **Disclosure policy**: coordinated disclosure expectations.
2. Link SECURITY.md from README and CONTRIBUTING.md (route-166).
3. Reference the `/acp-integrity` rule catalogue (`agent/wiki/integrity-rules.md`) as the project's internal security baseline.

## Expected Output

### Files Created
- `SECURITY.md`

## Verification (double-verify)

- [ ] **Automated**: GitHub recognizes SECURITY.md (appears in repo Security tab) — confirm after push
- [ ] **Manual**: all required sections present; links resolve from README/CONTRIBUTING

## User-Observable Acceptance

- Repo Security tab shows a published security policy
- A would-be reporter has a clear private path

## Addresses

audit-065 HIGH-065-006 (consolidated register H6)
