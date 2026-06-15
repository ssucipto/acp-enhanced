---
id: route-182
title: Uniform output contract + severity-aware --ci across all six integrity scripts
task_type: bash-script-refactor
milestone: M64
complexity: medium
executor: copilot
context_required:
  - skills/scripts.md
  - skills/code-integrity.md
  - reports/audit-070-m55-m58-gateway-deep-dive.md
files_affected:
  - agent/scripts/acp.unicode-scan.sh
  - agent/scripts/acp.entropy-scan.sh
  - agent/scripts/acp.network-whitelist-validate.sh
  - agent/scripts/acp.manifest-hash.sh
  - agent/scripts/acp.git-provenance.sh
  - agent/scripts/acp.dependency-diff.sh
  - agent/skills/code-integrity.md
tokens_est: 9000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Make every integrity script emit ONE machine-parseable finding format that carries severity, and make `--ci` block only on CRITICAL/HIGH (as the command doc and skill already promise). This is what lets the LLM aggregate findings, lets CI gate correctly, and lets route-184 assert on output.

## Context

audit-070 F-070-05 (MED): the skill defines a canonical `findings:` YAML with severity+confidence, but no script emits it — each prints ad-hoc text (unicode `file:line:col U+XXXX — name`, entropy `file:line entropy=`, network `file:line IG-01 — …`) with no severity. F-070-06 (MED): `--ci` exits 1 on ANY finding regardless of severity, so MEDIUM-only signals (IG-30/31) and "postinstall present" break CI on normal projects. F-070-13 (LOW): unicode mis-attributes rule IDs.

## Steps

1. Define the canonical line format (match `/acp-review`):
   ```
   [SEVERITY] file:line ruleID — message
   ```
   where `SEVERITY ∈ {CRITICAL,HIGH,MEDIUM,LOW}`. Add a shared severity lookup (rule → severity) — a small bash assoc-array or a sourced `agent/scripts/lib/ig-severity.sh` generated from the wiki, so severity stays single-sourced.
2. Update all six scripts to emit findings in that format on stdout. Keep human summary on stderr.
3. Add/standardize a `--json` flag on all six emitting `{file,line,rule,severity,message}` objects (the skill's `findings:` shape minus the LLM-only `id/confidence/action`).
4. Implement severity-aware `--ci`: in `--ci` mode, exit 1 ONLY if at least one CRITICAL or HIGH finding exists; MEDIUM/LOW print but exit 0 (still surfaced).
5. Fix F-070-13 rule attribution in `acp.unicode-scan.sh`: zero-width → IG-14, bidi markers → IG-15, homoglyph (if/when implemented) → IG-16; emit the correct ruleID in both text and `--json`.
6. Update `agent/skills/code-integrity.md` output spec to state the canonical line format AND the `--json` schema, and the severity-gated `--ci` contract, so docs match behaviour.

## Expected Output

### Files Modified
- All six scripts — uniform `[SEVERITY] file:line ruleID — msg` output, `--json`, severity-aware `--ci`
- `agent/skills/code-integrity.md` — output + `--ci` contract updated

### Files Created (optional)
- `agent/scripts/lib/ig-severity.sh` — single-source rule→severity map

## Verification (double-verify)

- [ ] **Automated**: route-184 asserts each finding line matches `^\[(CRITICAL|HIGH|MEDIUM|LOW)\] .+:[0-9]+ IG-[0-9]+ — `
- [ ] **Automated**: a MEDIUM-only fixture (e.g. IG-30 caret version) exits 0 under `--ci`; a CRITICAL fixture exits 1
- [ ] **Manual**: `acp.dependency-diff.sh --ci <project-with-postinstall>` no longer fails CI on a MEDIUM-only signal
- [ ] `--json` output is valid JSON (`python3 -m json.tool`)
- [ ] `shellcheck --severity=error` clean on all six

## User-Observable Acceptance

- All `/acp-integrity` script output looks the same and includes severity.
- CI only goes red on CRITICAL/HIGH, eliminating MEDIUM-noise build failures.

## Addresses

audit-070 F-070-05 (MED), F-070-06 (MED), F-070-13 (LOW)
