---
id: route-181
title: Truth pass — reconcile coverage tables across cmd/wiki/skill/script headers to actual implementation
task_type: docs-update
milestone: M64
complexity: medium
executor: copilot
context_required:
  - reports/audit-070-m55-m58-gateway-deep-dive.md
files_affected:
  - agent/commands/acp.integrity.md
  - agent/wiki/integrity-rules.md
  - agent/skills/code-integrity.md
  - agent/scripts/acp.unicode-scan.sh
  - agent/scripts/acp.entropy-scan.sh
  - agent/scripts/acp.network-whitelist-validate.sh
  - agent/scripts/acp.git-provenance.sh
  - agent/scripts/acp.dependency-diff.sh
  - agent/scripts/acp.manifest-hash.sh
tokens_est: 7000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Guarantee that documented coverage == executed coverage. After routes 179–180/183 land, update every coverage surface (command doc, wiki, skill table, and each script's "Covered rules" header) so that a rule is listed as **enforced** only if a route-184 fixture proves a script flags it. Anything still not implemented must be explicitly labelled `documented — not enforced (v1.1)` with the reason and target milestone.

## Context

audit-070 F-070-02/F-070-07: the skill "Rules Covered" table and script headers overstate coverage for 4 of 6 scripts (e.g. git-provenance claims IG-34/35 not implemented and omits IG-36; dependency-diff claims IG-29/32; network claims IG-05; unicode claims IG-16 homoglyphs). F-070-16: skill header says "≤800 tokens" while M56 deliverable specified ≤500. Truth-in-advertising is non-negotiable for a security tool.

## Steps

1. Build the authoritative coverage map: for each IG rule, record `{implemented_by_script | llm-only | deferred-v2.0 | documented-not-enforced}` based on the actual code after routes 179/180/183. Use route-184's fixture list as the source of truth for "implemented."
2. Update `agent/skills/code-integrity.md` "Script Table" so each script's "Rules Covered" lists ONLY rules with a passing fixture. Add a separate "Documented — not enforced (v1.1)" subsection for the rest.
3. Update each script's header `# Covered rules:` comment to match exactly (fix unicode IG-16 claim, git-provenance IG-34/35 vs IG-36, dependency-diff IG-29/32, network IG-05, etc.).
4. Update `agent/commands/acp.integrity.md` "55 Rules" section: annotate each rule row with an `Enforced?` column (`script` / `llm` / `not yet`) and correct the headline count to the real enforced number plus deferred.
5. Update `agent/wiki/integrity-rules.md` header counts (currently "55 v1.0 + 15 deferred") to the accurate post-v1.1 numbers.
6. Resolve the token-budget inconsistency (F-070-16): pick one budget (recommend ≤800 to match current content), update the M56 verification checklist line to match.
7. Add a short "Coverage Policy" note to the command doc: *no rule is advertised as enforced without a fixture in `e2e/acp.integrity.test.sh`.*

## Expected Output

### Files Modified
- Command doc, wiki, skill, and 6 script headers — coverage tables reconciled to reality
- `agent/milestones/milestone-56-acp-integrity-command.md` — token-budget checklist line corrected

## Verification (double-verify)

- [ ] **Automated**: a CI/check script (or route-184 assertion) cross-checks that every rule marked `script`/enforced in the skill table has a corresponding fixture file; fails if any enforced rule lacks a fixture
- [ ] **Manual**: diff the skill "Rules Covered" against `grep '# Covered rules' agent/scripts/*.sh` — they agree
- [ ] No rule is listed as enforced without a route-184 fixture
- [ ] Skill token budget statement consistent with M56 checklist

## User-Observable Acceptance

- A reader of the command/wiki/skill sees an accurate picture of what `/acp-integrity` actually enforces vs what is documented-only.

## Addresses

audit-070 F-070-02 (doc/truth side), F-070-07 (MED), F-070-16 (LOW)
