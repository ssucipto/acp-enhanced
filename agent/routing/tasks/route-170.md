---
id: route-170
title: Dependabot + package-lock.json + npm audit & secret-scan in CI
task_type: ci-cd-setup
milestone: M61
complexity: medium
executor: copilot
context_required:
  - wiki/architecture.md#dispatch-script-flow
files_affected:
  - .github/dependabot.yml
  - .github/workflows/ci.yaml
  - scripts/package-lock.json
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Harden the supply chain: enable Dependabot, commit a pinned `package-lock.json`, and add `npm audit` + secret scanning to CI.

## Context

3 npm deps and 3 pinned GitHub Actions are unmonitored (audit-065 M5); `scripts/package.json` uses `^` ranges with no lockfile (M7); CI has no SAST/secret scan (M8). These align with SLSA supply-chain and OWASP/CIS guidance.

## Steps

1. Run `cd scripts && npm install` to generate `scripts/package-lock.json`; commit it. Ensure `.gitignore` does not exclude it (add `!scripts/package-lock.json` if needed).
2. Create `.github/dependabot.yml`:
   - npm ecosystem rooted at `scripts/`, weekly schedule.
   - github-actions ecosystem, weekly (monitors pinned action SHAs).
3. Add to `ci.yaml`:
   - `npm audit --audit-level=high` step (in scripts/), non-blocking initially or with documented allowlist.
   - secret scan step (gitleaks or trufflehog) on the repo; block on findings.
4. Verify CI runs both steps; document any accepted advisories.

## Expected Output

### Files Created
- `.github/dependabot.yml`
- `scripts/package-lock.json`

### Files Modified
- `.github/workflows/ci.yaml` — npm audit + secret-scan steps

## Verification (double-verify)

- [ ] **Automated**: CI runs `npm audit` and secret-scan; a planted dummy secret is caught
- [ ] **Manual**: Dependabot config valid (GitHub Insights → Dependency graph → Dependabot)
- [ ] `npm ci` works against the committed lockfile

## User-Observable Acceptance

- Dependabot opens update PRs on schedule
- CI fails if a secret is committed; `npm audit` reported in logs

## Addresses

audit-065 M5, M7, M8 (consolidated register)
