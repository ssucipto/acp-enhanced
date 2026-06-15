---
id: route-147
title: "M56-006: acp.integrity.md — full command doc with Agent Directive"
task_type: command-doc-write
milestone: M56
complexity: high
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, route-146, audit-053, audit-054]
files_affected: [agent/commands/acp.integrity.md]
tokens_est: 10000
created: 2026-06-07
completed: 2026-06-08
---

# Route 147: acp.integrity.md Command Document

## Objective

Create the full command document wrapping all 6 scripts, the skill file, and the wiki rule catalogue. This is the integration layer — scripts do the work, the command doc tells the agent how to invoke them.

## Expected Output

### Files Created
- `agent/commands/acp.integrity.md`

## Required Sections

1. **Agent Directive** header (standard ACP convention)
2. **Purpose**: "Verify code trustworthiness and provenance — is this code trustworthy, does it belong here?"
3. **Positioning**: Clear distinction from `/acp-review`
4. **Arguments table**: `[path]`, `--rules`, `--origin`, `--self`, `--fast`, `--ci`, `--carryover`, `--report`, `--diff`, `--phase1`
5. **LLM/Script Boundary Rule** — the architectural principle (from audit-054)
5. **Categories 1–11**: Rule tables with script binding (55 rules total)
7. **Explicitly deferred**: Categories 8, partial 9, 10 → "Deferred to v2.0 (M58)"
8. **Remediation Playbook** — CRITICAL/HIGH/MEDIUM/LOW response steps (audit-054 NEW-054-01)
9. **Standards References** — version-pinned table with `last_verified` (audit-054 NEW-054-03)
10. **Executor Selection**: Composer 2.5 (preferred), Sonnet 4.6+ (Phase 2 only, deferred)
11. **Output Format**: YAML findings schema with `confidence`, `taint_source`, `taint_sink` fields
12. **Quality Gates**: False-positive baseline, LLM/Script boundary enforcement, confidence ceilings
13. **Verification Checklist**
14. **Related Commands**: acp-review, acp-audit, acp-validate

## Key Design Decisions

- **Phase 1 only for v1.0**: No Phase 2 (Sonnet) — all rules are script-backed deterministic or LLM-reasoned with `confidence: MEDIUM` ceiling
- **`--fast` flag**: Alias for `--self` — scans ACP rule files only, Phase 1 pattern matching, V4 Pro eligible
- **Agent self-protection**: v1.0 does NOT self-halt on IG-51/IG-52/IG-55. Flags and continues. Document this limitation honestly.
- **`--origin` default**: composer-2.5 (our standard executor, per OQ-1 decision)

## Verification

- [ ] Agent Directive header present
- [ ] LLM/Script Boundary Rule section present
- [ ] Remediation Playbook section present with CRITICAL/HIGH/MEDIUM/LOW response steps
- [ ] Standards References table with version pinning and `last_verified` dates
- [ ] All 55 v1.0 rules documented with rule IDs, severities, and script bindings
- [ ] Deferred rules (Cat 8, 9 partial, 10) explicitly documented as v2.0 (M58)
- [ ] Arguments table includes `--fast`, `--origin`, `--self`, `--phase1`
- [ ] Executor selection: Composer 2.5 preferred; Flash/Flash-Max disqualified
- [ ] Output format includes `confidence:` and `taint_source:`/`taint_sink:` fields
- [ ] Related Commands cross-links to acp-review, acp-audit, acp-validate
- [ ] Verification Checklist section present

## User-Observable Acceptance

- `/acp-integrity --self --fast` scans ACP rule files for Unicode and directive injection
- `/acp-integrity src/` runs full Phase 1 scan on project source
- Command doc clearly documents what v1.0 can and cannot detect
