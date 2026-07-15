# Audit Report: audit-054 — Second-Round Review of feedback-007 + audit-053
## `/acp-integrity` Command — Consolidated Position & Revised Implementation Scope

**Audit**: #054
**Date**: 2026-06-07
**Auditor**: Perplexity / Sonnet 4.6 (independent review pass)
**Subject**: Cross-review of feedback-007 v2.0 (proposal) and audit-053 (suitability analysis) — consolidated position, additional findings, and revised v1.0 scope recommendation
**Prior audits**: audit-053 (2026-06-07, primary suitability analysis)
**ACP version**: 6.10.0
**Project context**: FIFOZ — Rygan Institute. Composer 2.5 primary executor. Claude Sonnet 4.6+ required for deep analysis. DeepSeek not deployed.

---

## Purpose of This Audit

Audit-053 performed a thorough first-pass suitability analysis of feedback-007. This second-round audit does three things audit-053 did not:

1. **Validates audit-053's findings** — confirms, challenges, or refines each critical gap and inconsistency
2. **Adds new findings** that audit-053 missed
3. **Produces a consolidated, actionable implementation plan** for v1.0 and the deferred v2.0 roadmap

The result is the definitive internal reference document for the `acp-integrity` command before any milestone is opened.

---

## Validation of Audit-053 Findings

### GAP-053-01 — Agent Self-Protection Paradox — CONFIRMED, REFINED

**Audit-053 position**: IG-51–57 are unreliable because an LLM cannot detect adversarial content targeting itself before being influenced by it.

**This audit's position**: Confirmed as a structural limitation. The CVE evidence (CVE-2025-68143/44/45 from Anthropic's own MCP server) is a strong real-world anchor. However, audit-053's recommended fix — reframing IG-51–57 as "flag for human review, do not self-halt" — is the right resolution, not abandonment.

**Refinement**: There is a meaningful distinction between two sub-cases audit-053 collapses together:

- **Known-pattern flagging** (IG-51, IG-52, IG-55): Scanning for literal strings like "ignore previous instructions", "bypass security", HTML comment directives. This is essentially grep — deterministic, low false-negative risk for known patterns, and the agent's reasoning is not involved in the detection. **These rules are salvageable in v1.0.**
- **Semantic injection detection** (IG-53, IG-54, IG-56, IG-57): Asking the agent to reason about whether content "appears designed to manipulate agent behaviour." This is where the paradox fully applies — the agent's reasoning is precisely what the attacker controls. **These rules belong in v2.0 with appropriate caveats and must never claim HIGH confidence.**

**Revised recommendation**: Split Category 9. Move IG-51, IG-52, IG-55 (literal pattern matching) to Phase 1 / v1.0 as grep-equivalent checks backed by bash script. Keep IG-53, IG-54, IG-56, IG-57 (semantic judgment) in v2.0 with explicit `confidence: LOW` ceiling and human-review-only output.

---

### GAP-053-02 — Missing Script Infrastructure — CONFIRMED, SCOPE EXPANDED

**Audit-053 position**: 4 scripts missing. Command non-functional without them.

**This audit's position**: Confirmed and correct. Audit-053 identified the right 4 scripts. This audit adds two more that were missed:

| Script | Purpose | Missed by audit-053? |
|--------|---------|---------------------|
| `acp.unicode-scan.sh` | Hidden Unicode byte scanner | No — correctly identified |
| `acp.entropy-scan.sh` | Shannon entropy calculator | No — correctly identified |
| `acp.manifest-hash.sh` | SHA-256 hash generator for `--diff` | No — correctly identified |
| `acp.network-whitelist-validate.sh` | Network whitelist validator | No — correctly identified |
| **`acp.git-provenance.sh`** | **Commit author email verification against identity.yml team_members** | **Yes — missed** |
| **`acp.dependency-diff.sh`** | **package-lock.json shadow dependency checker** | **Yes — missed** |

The git provenance rules (IG-33–IG-37) require reading `agent/core/identity.yml` and cross-referencing against `git log --format="%ae"`. This is deterministic shell work, not LLM reasoning. Without `acp.git-provenance.sh`, IG-33–IG-37 cannot execute. Similarly, shadow dependency detection (IG-29–IG-31) requires parsing `package-lock.json` and comparing against `import` statements — shell + jq work that produces a reliable diff. The LLM cannot do this accurately from memory.

**Revised total scripts required for v1.0**: 6 bash scripts.

**Build order remains critical**: Scripts must be built and E2E tested BEFORE the command doc is written. This is the reverse of normal ACP pattern. Failing to respect this order will produce a command doc that describes capabilities that don't yet function — exactly the problem with the original feedback-007 proposal.

---

### GAP-053-03 — ACP Architecture Mismatch — CONFIRMED, PRINCIPLE FORMALISED

**Audit-053 position**: ACP is an LLM-dispatch framework, not a SAST tool. Deterministic tasks should use deterministic tools.

**This audit's position**: Confirmed. This audit formalises it as a rule that should be added to the `acp-integrity` command doc's Agent Directive section:

> **The LLM/Script Boundary Rule**: Before executing any integrity rule, classify the task as deterministic (has a single correct answer derivable from bytes, counts, or comparisons) or semantic (requires reasoning about meaning, intent, or context). Deterministic tasks MUST be delegated to the companion bash script. Semantic tasks are handled by LLM reasoning with `confidence: MEDIUM` or lower ceiling. No deterministic task may be handled by LLM reasoning alone.

This boundary rule, stated explicitly in the command doc, prevents future rule additions from silently crossing the boundary. It also gives reviewers a clear test when proposing new rules for v2.0.

---

### GAP-053-04 — Bundled Scope Creep — CONFIRMED, DEFERRED ITEMS PRIORITISED

**Audit-053 position**: 4 bundled features should be split into separate milestones.

**This audit's position**: Confirmed. Proposed milestone assignments:

| Feature | Milestone | Rationale |
|---------|-----------|-----------|
| `acp-integrity` v1.0 command | **M56** | Core deliverable — ship first |
| `acp-integrity` v2.0 (taint flow, memory) | **M58** | Needs v1.0 stable + script foundation |
| Recurring tasks scheduler | **M57** | Independent feature, no dependency on integrity |
| Pre-commit hook framework (constraints.yml) | **M57** | Pairs naturally with recurring tasks |
| `identity.yml` team_members schema | **M56** | Small enough to bundle — needed for `acp.git-provenance.sh` to function |

The `team_members` field is the exception to the "split everything" rule: it is a two-line addition to `identity.yml` schema, required for a core v1.0 script to function, and has no independent feature complexity. Bundling it into M56 is correct.

---

### INC-053-01 — Rule Count Mismatch — CONFIRMED

**Verdict**: 70 rules, 11 categories. "10 categories" in the proposal header is a documentation error. The command doc should state "11 categories" from v1.0 onward, even if only Categories 1–7 and partial 9 and 11 ship in v1.0. Documenting the full category structure at the start prevents numbering confusion when v2.0 adds Categories 8, 10, and the remaining 9 rules.

---

### INC-053-02 — Executor Conflict for `--origin` — CONFIRMED, RYGAN-SPECIFIC NOTE

**Verdict**: The audit's resolution is correct — `--origin X` means ALL phases require a non-X executor. For Rygan specifically: since DeepSeek is not deployed, the `--origin deepseek` path is an academic concern. The `--origin` flag is more immediately relevant for specifying `--origin composer` or `--origin sonnet` in contexts where the same Anthropic model family generated code and is being asked to audit it. The independence principle applies within the Anthropic family for Phase 2 deep analysis.

**Addition not in audit-053**: The command doc should specify the default behaviour when `--origin` is omitted. Recommended default: assume Composer 2.5 origin (our standard executor) and require Sonnet 4.6+ for Phase 2. This should be the hardcoded Rygan baseline in `agent/core/routing.yml` under integrity task types.

---

### INC-053-03 — Redundant Sub-command — PARTIALLY DISAGREE

**Audit-053 position**: Merge `acp-rule-file-audit` into `acp-integrity --self --fast`. Don't create separate taxonomy types.

**This audit's position**: Agree on the taxonomy — one taxonomy type, not two. Disagree on discoverability. A named alias `acp-rule-file-audit` with its own `.githubprompts` wrapper and `.opencode` file is low-cost and high-value for pre-commit hook ergonomics. A developer writing a git hook wants:

```
acp-rule-file-audit --ci
```

Not:

```
acp-integrity --self --fast --ci
```

The named alias communicates intent, reduces hook configuration errors, and is consistent with how ACP exposes other focussed sub-operations. **Keep the alias. Remove the separate command doc and separate taxonomy entry.** The alias file is 3 lines: `Read and execute agent/commands/acp.integrity.md with flags --self --fast`.

---

### INC-053-04 — IG-63 Mis-categorized — CONFIRMED

**Verdict**: IG-63 (multi-language injection evasion) belongs in Category 9 (Prompt Injection Surface), not Category 11 (GitHub Actions). Move to Category 9, renumber Category 11 as IG-63→IG-70 becoming IG-64→IG-70 (7 rules). Update category descriptions accordingly.

---

### INC-053-05 — `network_whitelist.yml` Not Defined — CONFIRMED, SCHEMA PROPOSED

**Verdict**: Confirmed gap. Proposed minimal schema for v1.0:

```yaml
# agent/core/network_whitelist.yml
# Schema: list of approved outbound network targets
# Generated by acp-bootstrap.sh — customise for your project
version: "1.0"
approved_hosts:
  - "*.googleapis.com"
  - "*.firebase.google.com"
  - "*.firebaseio.com"
approved_ip_ranges: []     # CIDR notation
dynamic_hosts_allowed: false  # Set true only with documented rationale in decisions.md
last_reviewed: "YYYY-MM-DD"
reviewed_by: ""
```

Bootstrap creates this stub. `acp-validate` checks that `last_reviewed` is not older than 90 days and that `reviewed_by` is non-empty. IG-01 reads this file before scanning — if the file doesn't exist, IG-01 outputs a WARNING (not a finding) and skips network call analysis.

---

## New Findings (Not in Audit-053)

### NEW-054-01 — MEDIUM — No Rollback / Remediation Guidance

The command doc drafts describe findings comprehensively but provide no guidance on what to do after a finding is confirmed. For a code quality tool like `acp-review`, this is fine — findings become tasks. For an integrity tool, some findings (e.g., confirmed Unicode injection in AGENTS.md, shadow dependency with malicious postinstall) require immediate specific actions: quarantine the file, roll back the commit, notify team members.

**Recommendation**: Add a `## Remediation Playbook` section to the command doc with response steps for each severity level:
- **CRITICAL**: Stop all AI agent sessions immediately. Quarantine affected file. Do not commit until file is clean. Rotate any credentials that were accessible during sessions since the file was last verified clean.
- **HIGH**: Freeze the affected component. Create an INT-NNN carryover. Do not merge until resolved.
- **MEDIUM/LOW**: Create carryover. Address within current milestone.

This section directly parallels the `acp-audit` command's remediation guidance and is consistent with ACP conventions.

---

### NEW-054-02 — MEDIUM — Skill File Token Budget Violation Risk

Audit-053 correctly specifies `agent/skills/code-integrity.md` at ≤500 tokens for v1.0 (Phase 1 only). The current skill file draft loads the full 70-rule catalogue. At 70 rules with descriptions, this is approximately 2,800–3,500 tokens — exceeding the Layer 2 skill budget (max 1,000 tokens per `agent/core/constraints.yml`).

**Recommendation**: The skill file for v1.0 must contain only:
- The LLM/Script Boundary Rule (one paragraph)
- The 6 script names and their trigger rules (one table)
- Output format spec (YAML findings schema — ~15 lines)
- Confidence ceiling rules by category (one table)

The full rule catalogue (IG-01–IG-44) belongs in a wiki section (`agent/wiki/integrity-rules.md`), loaded on-demand only when the agent needs to explain a specific finding. This is consistent with the wiki's "load section-by-section" design.

---

### NEW-054-03 — LOW — No Version Pinning for Threat Reference Sources

The proposal cites specific threat reports (Pillar Security Rules File Backdoor, CrowdStrike DeepSeek-R1 analysis, OWASP LLM Top 10 2025). These are point-in-time documents. The OWASP LLM Top 10 is updated annually; the threat landscape evolves. The command doc should record the reference versions used when the rules were written, and `acp-validate --stale` should warn when the OWASP LLM Top 10 reference is more than 12 months old.

**Recommendation**: Add a `## Standards References` table to the command doc with `version` and `last_verified` fields per reference. Wire `acp-validate --stale` to check the `last_verified` date against a 365-day threshold.

---

### NEW-054-04 — LOW — E2E Test Coverage Gap for False Positive Rate

Audit-053 specifies "10+ assertions (structural + Unicode fixture)" for `e2e/acp.integrity.test.sh`. This covers functional correctness but not false positive rate — a critical quality metric for a security tool. A command that flags 30 findings on a clean codebase is not usable.

**Recommendation**: Add a false-positive baseline test. The ACP Enhanced codebase itself should produce zero CRITICAL and zero HIGH findings when scanned with `acp-integrity --self` on a clean commit. The E2E test should assert this: `assert_finding_count CRITICAL 0` and `assert_finding_count HIGH 0`. This test runs on every CI push and catches rule regressions that produce noise.

---

## Consolidated v1.0 Scope (Revised from Audit-053)

### What Ships in M56 (v1.0 — ~8 routes, ~12h estimated)

| Deliverable | Detail | Status |
|-------------|--------|--------|
| `agent/commands/acp.integrity.md` | Categories 1–7, partial 9 (IG-51, IG-52, IG-55 only), Category 11 (IG-64–IG-70 renumbered). ~44 rules total. | To build |
| `agent/scripts/acp.unicode-scan.sh` | Bash + Python fallback. Covers IG-14–IG-16, IG-38–IG-39 | To build |
| `agent/scripts/acp.entropy-scan.sh` | Shannon entropy via Python `math.log2`. Covers IG-17 | To build |
| `agent/scripts/acp.manifest-hash.sh` | SHA-256 of tracked files vs stored hashes. Covers `--diff` | To build |
| `agent/scripts/acp.network-whitelist-validate.sh` | Parses `network_whitelist.yml` + scans for outbound calls. Covers IG-01–IG-05 | To build |
| `agent/scripts/acp.git-provenance.sh` | `git log --format="%ae"` vs identity.yml team_members. Covers IG-33–IG-37 | To build — **new, missed by audit-053** |
| `agent/scripts/acp.dependency-diff.sh` | `package-lock.json` vs import statements via jq. Covers IG-29–IG-31 | To build — **new, missed by audit-053** |
| `agent/core/network_whitelist.yml` | Bootstrap stub + schema (see NEW-054-01 schema) | To build |
| `agent/core/identity.yml` | Add `team_members` field (2 lines) | Small addition |
| `agent/skills/code-integrity.md` | ≤500 tokens. Boundary rule + script table + output spec only | To build |
| `agent/wiki/integrity-rules.md` | Full rule catalogue for on-demand loading — NOT in skill file | To build |
| `agent/routing/taxonomy.yml` | 1 task type: `code-integrity-scan` | To add |
| `.githubprompts/acp-rule-file-audit.prompt.md` | Alias → `acp-integrity --self --fast` | To build |
| `.opencode/commands/acp-rule-file-audit.md` | Same alias | To build |
| `e2e/acp.integrity.test.sh` | 10+ structural assertions + Unicode fixture + false-positive baseline | To build |
| ACP version bump | 6.10.0 → 6.11.0 | On merge |

**Build order (non-negotiable)**:
1. `identity.yml` team_members field + `network_whitelist.yml` schema
2. All 6 bash scripts — E2E tested independently
3. `agent/wiki/integrity-rules.md` (rule catalogue)
4. `agent/skills/code-integrity.md` (slim skill)
5. `agent/commands/acp.integrity.md` (wraps scripts + skill)
6. Alias files + taxonomy entry
7. Full E2E suite including false-positive baseline test

---

### What is Explicitly Deferred

| Feature | Target | Blocker |
|---------|--------|---------|
| Taint flow analysis (IG-45–IG-50) | M58 | Needs SAST-grade cross-file reasoning; LLM accuracy insufficient for `confidence: HIGH` |
| Semantic injection detection (IG-53, IG-54, IG-56, IG-57) | M58 | Agent self-protection paradox unresolved; `confidence: LOW` ceiling required |
| Memory poisoning detection (IG-58–IG-62) | M58 | 11–40% false negative rate documented in literature; needs UX for "unverifiable" findings |
| Recurring tasks scheduler | M57 | Independent feature; no dependency on integrity command |
| Pre-commit hook framework | M57 | Pairs with recurring tasks; both need AGENTS.md Step 4.5 work |
| CI/CD pipeline enforcement (block PRs on integrity scan) | M57 | Depends on pre-commit hook framework |

---

## Open Questions for Decision Before M56 Opens

| # | Question | Recommended Answer | Decision Needed From |
|---|----------|-------------------|---------------------|
| OQ-1 | Should `--origin` default to `composer-2.5` or require explicit flag? | Default to `composer-2.5` — our standard executor | Lead dev |
| OQ-2 | Should Phase 2 (Sonnet 4.6+) be in v1.0 at all, even for taint flow? | No — defer entirely. Phase 1 only for v1.0 | Lead dev |
| OQ-3 | Should `acp-rule-file-audit` be an alias or be merged into `--self --fast` with no alias? | Keep alias for ergonomics; remove separate command doc | Lead dev |
| OQ-4 | Does the false-positive baseline test run on every CI push or only weekly? | Every push — integrity of the tool itself is non-negotiable | Lead dev |

---

## Summary Verdict

**feedback-007 proposal**: ACCEPT with major scope reduction as specified above. The research is strong, the architecture is sound at the concept level, and the distinction from `acp-review` is correct and valuable.

**audit-053**: ACCURATE. All 4 critical gaps and all 5 inconsistencies are valid. Two additional script gaps were missed (git provenance and dependency diff). The `acp-rule-file-audit` alias position is the only point of disagreement — keep the alias, remove the separate taxonomy type.

**Recommended next step**: Open M56 using the build order above. Do not begin command doc authoring until all 6 scripts are complete and their E2E tests pass.

---

*Audit-054 | Rygan Institute — FIFOZ | ACP Enhanced v6.10.0 | 2026-06-07*
*Cross-references: feedback-007 v2.0 · audit-053 · acp.integrity.md draft · acp.rule-file-audit.md draft*
