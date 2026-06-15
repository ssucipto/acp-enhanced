---
id: route-161
title: Wire acp-validate.ts into CI + fix ci-validate.sh command-doc no-op
task_type: ci-cd-setup
milestone: M59
complexity: medium
executor: copilot
context_required:
  - wiki/architecture.md#command-script-binding
files_affected:
  - .github/workflows/ci.yaml
  - scripts/ci-validate.sh
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Make CI actually validate command-doc structure. (1) Run `acp-validate.ts` in CI. (2) Fix `ci-validate.sh`'s frontmatter check, which is a no-op for command files because it gates on a `---` first line that command docs (starting with `# Command:`) never have.

## Context

CI runs only `ci-validate.sh` (YAML + frontmatter). `acp-validate.ts` (placeholder + frontmatter-field checks) is never invoked. And `ci-validate.sh:46` `head -1 | grep '^---$'` skips every command file. Net: no automated structural conformance check exists — this is the root cause of HIGH-065-002 (missing `## Steps`) and MED-065-003 (missing `## Verification`). Found in audit-066 (HIGH-066-005/006).

## Steps

1. Add a CI step in `ci.yaml` validate job: `cd scripts && npm install --ignore-scripts && npx ts-node acp-validate.ts` (after the existing node setup).
2. Fix `ci-validate.sh` command-doc validation:
   - Replace the `^---$` gate with command-doc structure checks: presence of `# Command:`, `**Namespace**:`, `**Version**:`, `**Scripts**:`, `## Steps`, `## Verification`.
   - Report each missing section with file path; exit 1 on any.
3. Run locally — confirm it now flags `acp.integrity.md`/`acp.review.md` (missing `## Steps`) and the 5 commands missing `## Verification` (these get fixed in M62 route-174; until then the check may be set to warn or the known-exceptions allowlisted with a TODO referencing route-174).
4. Decide gate vs warn for the known pre-existing gaps to avoid blocking CI before M62 — recommend: warn now, hard-fail after route-174.

## Expected Output

### Files Modified
- `.github/workflows/ci.yaml` — runs acp-validate.ts
- `scripts/ci-validate.sh` — real command-doc structure validation

## Verification (double-verify)

- [ ] **Automated**: a deliberately malformed command doc (remove `## Steps`) makes CI fail
- [ ] **Manual**: `bash scripts/ci-validate.sh` locally lists structural results for command docs (not "SKIP")
- [ ] acp-validate.ts runs green in CI for conformant files

## User-Observable Acceptance

- CI log shows acp-validate.ts executing
- Introducing a malformed command doc in a PR turns the CI check red

## Addresses

audit-066 HIGH-066-005, HIGH-066-006 (consolidated register H2, H3)
