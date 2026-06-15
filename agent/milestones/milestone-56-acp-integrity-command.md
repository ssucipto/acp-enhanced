# Milestone 56: `/acp-integrity` — AI Code Integrity & Malicious Code Detection (v1.0)

**Milestone**: M56  
**Version Target**: 6.12.0  
**Priority**: HIGH  
**Status**: completed  
**Started**: —  
**Target**: —  
**Estimated Weeks**: 1.5–2  
**Estimated Hours**: ~12  
**Feedback Source**: feedback-007 v2.0  
**Audit References**: audit-053 (suitability analysis), audit-054 (second-round consolidated)  
**Design Reference**: feedback-007 v2.0 + companion files (acp.integrity.md, acp.rule-file-audit.md)  

---

## 1. Goal

Ship v1.0 of `/acp-integrity` — a command that verifies AI-generated code **trustworthiness and provenance**, distinct from `/acp-review` which verifies code **quality**. v1.0 focuses on **deterministic pattern matching** (Phase 1) with bash script backing. Semantic analysis (taint flow, memory poisoning, prompt injection self-detection) is deferred to v2.0 (M58).

| Question | Command | Maturity |
|----------|---------|----------|
| "Is this code good?" | `/acp-review` | ✅ v1.0 shipped (M55) |
| "Is this code trustworthy — does it belong here?" | `/acp-integrity` | 🚧 v1.0 — this milestone |
| "Are my ACP rule files clean?" | `/acp-integrity --fast` | 🚧 alias — this milestone |

---

## 2. Industry Standards & Threat Model

### 2.1 Standards Compliance

| Standard | Version | Relevance | Rules Covered |
|----------|---------|-----------|---------------|
| OWASP Top 10:2025 | 2025 | Web application security | IG-01–IG-13, IG-21–IG-26 |
| OWASP LLM Top 10 | 2025 | LLM-specific threats | IG-51, IG-52, IG-55 (pattern match only) |
| NIST SP 800-53 Rev 5 | 2023 | Security & privacy controls | IG-01, IG-07, IG-33 |
| SLSA Framework | v1.0 | Supply chain integrity | IG-27–IG-32, IG-67–IG-70 |
| MITRE ATT&CK | v16 | Adversarial tactics | IG-21–IG-26 |
| MITRE ATLAS | 2025 | AI-specific threats | IG-58–IG-62 (deferred to v2.0) |
| Pillar Security | 2025 | Rules File Backdoor | IG-14–IG-16, IG-38–IG-39 |
| CSA Research Note | May 2026 | AI-powered CI injection | IG-64–IG-70 |

> **Version pinning**: All standards references include version and `last_verified` date. `acp-validate` warns when OWASP LLM Top 10 reference exceeds 12 months staleness (audit-054 NEW-054-03).

### 2.2 Threat Model

| Threat Vector | Real-World Evidence | v1.0 Coverage |
|--------------|---------------------|---------------|
| Rules File Backdoor (Unicode injection) | Pillar Security Mar 2025 | ✅ IG-14–IG-16, IG-38–IG-39 — `acp.unicode-scan.sh` |
| Obfuscated payloads | Phylum Unicode Report | ✅ IG-17–IG-20 — `acp.entropy-scan.sh` |
| Data exfiltration | OWASP A01:2025 | ✅ IG-07–IG-13 — `acp.network-whitelist-validate.sh` |
| Dependency typosquatting | Mini Shai-Hulud May 2026 | ✅ IG-27–IG-32 — `acp.dependency-diff.sh` |
| Git provenance anomalies | SLSA Level 2+ | ✅ IG-33–IG-37 — `acp.git-provenance.sh` |
| CI/CD agent injection | CSA Research May 2026 | ✅ IG-64–IG-70 |
| Prompt injection (literal) | OWASP LLM01:2025 | ⚠️ IG-51, IG-52, IG-55 only — pattern match |
| Prompt injection (semantic) | CVE-2025-68143/44/45 | ❌ Deferred to v2.0 (self-protection paradox) |
| Taint flow analysis | CWE-134, CWE-601 | ❌ Deferred to v2.0 (needs SAST) |
| Memory poisoning | LinkedIn Research May 2026 | ❌ Deferred to v2.0 (60–89% AUR, unreliable) |

---

## 3. Architecture — LLM/Script Boundary Rule

> **Added per audit-053 GAP-053-03 + audit-054 formalization.** This is the foundational architectural principle for `/acp-integrity`.

Before executing any integrity rule, classify the task:

| Task Type | Definition | Tool | Confidence Ceiling |
|-----------|-----------|------|-------------------|
| **Deterministic** | Single correct answer derivable from bytes, counts, or comparisons | **Bash script** | HIGH |
| **Semantic** | Requires reasoning about meaning, intent, or context | **LLM reasoning** | MEDIUM |

**The rule**: No deterministic task may be handled by LLM reasoning alone. Every deterministic rule must have a companion bash script. The LLM's role is to **invoke scripts and interpret structured output** — not to perform byte-level analysis, entropy calculation, or git log parsing.

**Script-to-rule mapping (v1.0)**:

| Script | Rules Covered | Deterministic |
|--------|--------------|---------------|
| `acp.unicode-scan.sh` | IG-14, IG-15, IG-16, IG-38, IG-39, IG-61* | ✅ |
| `acp.entropy-scan.sh` | IG-17, IG-18 | ✅ |
| `acp.manifest-hash.sh` | `--diff` flag, IG-42 | ✅ |
| `acp.network-whitelist-validate.sh` | IG-01, IG-02, IG-03, IG-05, IG-06 | ✅ |
| `acp.git-provenance.sh` | IG-33, IG-34, IG-35, IG-37 | ✅ |
| `acp.dependency-diff.sh` | IG-27, IG-28, IG-29, IG-30, IG-31, IG-32 | ✅ |

> \* IG-61: Unicode detection in memory files works in v1.0 via `acp.unicode-scan.sh`. The full Category 10 memory integrity semantic analysis (IG-58–IG-62 context) is deferred to M58.

---

## 4. Deliverables

| # | Deliverable | Description | Route |
|---|-------------|-------------|-------|
| 1 | `agent/core/network_whitelist.yml` | Schema + bootstrap stub for outbound domain whitelist | 142 |
| 2 | `agent/core/identity.yml` update | Add `team_members:` field (2 lines) | 142 |
| 3 | `agent/scripts/acp.unicode-scan.sh` | Hidden Unicode byte scanner (bash + Python fallback) | 143 |
| 4 | `agent/scripts/acp.entropy-scan.sh` | Shannon entropy calculator (Python `math.log2`) | 143 |
| 5 | `agent/scripts/acp.manifest-hash.sh` | SHA-256 hash generator for `--diff` tamper detection | 144 |
| 6 | `agent/scripts/acp.network-whitelist-validate.sh` | Parses whitelist + scans for outbound calls | 144 |
| 7 | `agent/scripts/acp.git-provenance.sh` | Commit author verification against identity.yml | 145 |
| 8 | `agent/scripts/acp.dependency-diff.sh` | package-lock.json shadow dependency checker | 145 |
| 9 | `agent/wiki/integrity-rules.md` | Full ~44-rule catalogue (on-demand loading) | 146 |
| 10 | `agent/skills/code-integrity.md` | ≤500 tokens — boundary rule + script table + output spec | 146 |
| 11 | `agent/commands/acp.integrity.md` | Full command doc with Agent Directive, 11 categories | 147 |
| 12 | `.github/prompts/acp-integrity.prompt.md` | Prompt wrapper | 148 |
| 13 | `.opencode/commands/acp-integrity.md` | Opencode wrapper | 148 |
| 14 | `.github/prompts/acp-rule-file-audit.prompt.md` | Alias → `acp-integrity --self --fast` | 148 |
| 15 | `.opencode/commands/acp-rule-file-audit.md` | Same alias | 148 |
| 16 | `agent/routing/taxonomy.yml` | 1 task type: `code-integrity-scan` | 148 |
| 17 | `agent/core/routing.yml` | Command suggestions for acp-integrity | 148 |
| 18 | `package.yaml` | Entry for acp.integrity.md | 148 |
| 19 | `e2e/acp.integrity.test.sh` | 12+ assertions + Unicode fixture + false-positive baseline | 149 |
| 20 | Cross-links + version bump + CHANGELOG | Standard release process | 149 |

---

## 5. v1.0 Ruleset — 55 Rules Across 9 Active + 2 Deferred Categories

### Category 1 — Outbound Network Anomalies (CRITICAL)
**Script**: `acp.network-whitelist-validate.sh` | **Rules**: IG-01–IG-06

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-01 | `fetch()`/`axios`/`http.request()` to non-whitelisted domain | CRITICAL |
| IG-02 | Network calls to raw IP addresses | CRITICAL |
| IG-03 | Base64-decoded strings immediately in network calls | CRITICAL |
| IG-04 | `eval()` of network-fetched content | CRITICAL |
| IG-05 | DNS lookups from env vars | HIGH |
| IG-06 | Outbound calls in catch blocks (exfil-on-error) | HIGH |

### Category 2 — Data Exfiltration Patterns (CRITICAL)
**Script**: `acp.network-whitelist-validate.sh` | **Rules**: IG-07–IG-13

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-07 | `process.env` access → network call in same scope | CRITICAL |
| IG-08 | `fs.readFile` result → network call | CRITICAL |
| IG-09 | Clipboard access → network call | CRITICAL |
| IG-10 | Storage read → network call | HIGH |
| IG-11 | Auth tokens in logs/query strings/URLs | HIGH |
| IG-12 | PII in request body without encryption | HIGH |
| IG-13 | Screenshot APIs outside declared feature context | CRITICAL |

### Category 3 — Obfuscation & Hidden Instructions (CRITICAL)
**Scripts**: `acp.unicode-scan.sh`, `acp.entropy-scan.sh` | **Rules**: IG-14–IG-20

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-14 | Zero-width chars: U+200B/C/D, U+FEFF | CRITICAL |
| IG-15 | Bidirectional text markers: U+202A–U+202E, U+2066–U+2069 | CRITICAL |
| IG-16 | Unicode homoglyphs in identifiers | CRITICAL |
| IG-17 | Shannon entropy >4.5 bits/char in source strings | HIGH |
| IG-18 | Hex/base64 decoded at runtime without comment | HIGH |
| IG-19 | Minified blocks in human-authored source | HIGH |
| IG-20 | AI-directive language in comments | CRITICAL |

### Category 4 — Persistence & Execution (HIGH)
**Script**: `acp.network-whitelist-validate.sh` | **Rules**: IG-21–IG-26

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-21 | `child_process.exec()` with dynamic commands | CRITICAL |
| IG-22 | `fs.writeFile` to system paths | CRITICAL |
| IG-23 | Cron/scheduled task creation | HIGH |
| IG-24 | Self-modifying code | HIGH |
| IG-25 | Dynamic `require()`/`import()` from env/user input | HIGH |
| IG-26 | Process injection | CRITICAL |

### Category 5 — Dependency & Supply Chain (HIGH)
**Script**: `acp.dependency-diff.sh` | **Rules**: IG-27–IG-32

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-27 | Typosquatting (Levenshtein 1–2 from top-1000) | HIGH |
| IG-28 | `postinstall`/`preinstall` scripts executing shell | HIGH |
| IG-29 | Dependencies imported but absent from lockfile | HIGH |
| IG-30 | Unpinned versions for auth/crypto/session packages | MEDIUM |
| IG-31 | Lockfile >30 days stale vs source changes | MEDIUM |
| IG-32 | New dependency without task ID in commit | MEDIUM |

> ⚠️ **SLSA Provenance Paradox** (audit-053 corrected, audit-054 confirmed): SLSA Build Level 3 attestation does NOT indicate code safety. The Mini Shai-Hulud worm (May 2026) shipped malicious code with valid SLSA provenance. IG-27–IG-32 severity must not be reduced based on SLSA compliance.

### Category 6 — Git Provenance & Commit Anomalies (MEDIUM)
**Script**: `acp.git-provenance.sh` | **Rules**: IG-33–IG-37

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-33 | Single commit >200 lines to auth/crypto/data-access without task file | HIGH |
| IG-34 | Security-critical file commits without linked task ID | MEDIUM |
| IG-35 | Files modified outside declared `files_affected` in route | MEDIUM |
| IG-36 | Binary files committed without documented justification | HIGH |
| IG-37 | Commit author email not matching identity.yml `team_members` | HIGH |

### Category 7 — ACP Self-Integrity (CRITICAL)
**Scripts**: `acp.unicode-scan.sh`, `acp.manifest-hash.sh` | **Rules**: IG-38–IG-44

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-38 | Hidden Unicode in `AGENTS.md`, `CLAUDE.md`, copilot-instructions | CRITICAL |
| IG-39 | Hidden Unicode in `agent/core/`, `.cursor/commands/`, `.opencode/commands/` | CRITICAL |
| IG-40 | Instructions in `constraints.yml` contradicting ACP hard rules | CRITICAL |
| IG-41 | New files in `agent/core/` not in upstream release manifest | HIGH |
| IG-42 | `acp-bootstrap.sh` or `agent/scripts/` modified without version bump | HIGH |
| IG-43 | Skill files containing "skip security" or "suppress finding" instructions | CRITICAL |
| IG-44 | GitHub Actions workflow steps not pinned to commit SHA | HIGH |

### Category 8 — Taint Flow Analysis (HIGH)
> ⚠️ **DEFERRED to v2.0 (M58)**. Requires SAST-grade cross-file reasoning. LLM accuracy insufficient for `confidence: HIGH`. Rules IG-45–IG-50 documented in `agent/wiki/integrity-rules.md` as deferred.

### Category 9 — Prompt Injection Surface (CRITICAL — partial, v1.0)
**Script**: `acp.unicode-scan.sh` (literal pattern match only)

| Rule ID | Rule | v1.0? | Severity | Confidence Ceiling |
|---------|------|-------|----------|-------------------|
| IG-51 | Code comments with agent-directive phrases | ✅ v1.0 | CRITICAL | HIGH (literal grep) |
| IG-52 | Markdown HTML comment directives `<!-- AI: -->` | ✅ v1.0 | CRITICAL | HIGH (literal grep) |
| IG-55 | `.env.example` with prompt-injection-like text | ✅ v1.0 | MEDIUM | MEDIUM |
| IG-63 | Multi-language injection fragments (Mandarin/Arabic/Portuguese) | ✅ v1.0 | HIGH | MEDIUM |
| IG-53 | API responses with instruction-like content | ❌ v2.0 | HIGH | LOW (semantic) |
| IG-54 | Test fixtures with agent-instruction strings | ❌ v2.0 | HIGH | LOW (semantic) |
| IG-56 | MCP configs invoking non-official tools | ❌ v2.0 | HIGH | LOW (semantic) |
| IG-57 | MCP tool descriptions with override language | ❌ v2.0 | CRITICAL | LOW (semantic) |

> **Agent self-protection limitation** (audit-053 GAP-053-01, audit-054 confirmed): v1.0 rules detect **literal known patterns** only — equivalent to `grep`. Semantic injection detection is deferred to v2.0 with `confidence: LOW` ceiling. The agent does NOT self-halt — it flags and continues. This is a best-effort screening tool, not a security boundary.

### Category 10 — Memory & Context Integrity (CRITICAL)
> ⚠️ **DEFERRED to v2.0 (M58)**. 60–89% AUR documented in literature means 11–40% false negative rate. Semantic contradiction detection against `constraints.yml` requires Composer 2.5/Sonnet deep reasoning. Rules IG-58–IG-62 documented in wiki as deferred.

### Category 11 — GitHub Actions & CI Agent Injection (HIGH)
**Script**: N/A (LLM reasoning — structured config files) | **Rules**: IG-64–IG-70

> **Note**: Renumbered from IG-63→IG-70 to IG-64→IG-70 per audit-054 INC-053-04. IG-63 moved to Category 9.

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-64 | Workflow steps using `${{ github.event.pull_request.title }}` unsanitized | CRITICAL |
| IG-65 | Workflow steps passing `${{ github.event.issue.body }}` to AI agents | CRITICAL |
| IG-66 | AI agent steps with `permissions: write-all` | HIGH |
| IG-67 | `actions/checkout` not pinned to commit SHA | HIGH |
| IG-68 | `npm install` in CI without `--ignore-scripts` | HIGH |
| IG-69 | AI agent CI steps writing to repo without human approval | HIGH |
| IG-70 | SLSA attestation as sole trust basis — no behavioral analysis | HIGH |

---

## 6. Remediation Playbook

> **Added per audit-054 NEW-054-01.** Every finding severity level has a prescribed response.

| Severity | Response | Timeline |
|----------|----------|----------|
| **CRITICAL** | Stop all AI agent sessions. Quarantine affected file. Do not commit. Rotate credentials accessible during sessions since file was last verified clean. Create INT-NNN carryover. | Immediate |
| **HIGH** | Freeze affected component. Create INT-NNN carryover. Do not merge PR until resolved. | Within current session |
| **MEDIUM** | Create carryover. Address within current milestone. | Within milestone |
| **LOW** | Create carryover or note in session. Address when convenient. | Within 2 milestones |

---

## 7. Tasks (8 Routes, ~12h)

| Route | Task | Deliverable | Phase | Hours | Depends On |
|-------|------|-------------|-------|-------|------------|
| 142 | M56-001 | `network_whitelist.yml` + `identity.yml` team_members | P0 | 0.5 | — |
| 143 | M56-002 | `acp.unicode-scan.sh` + `acp.entropy-scan.sh` | P0 | 2.5 | — |
| 144 | M56-003 | `acp.manifest-hash.sh` + `acp.network-whitelist-validate.sh` | P0 | 2 | 142 |
| 145 | M56-004 | `acp.git-provenance.sh` + `acp.dependency-diff.sh` | P0 | 2.5 | 142 |
| 146 | M56-005 | `integrity-rules.md` wiki + `code-integrity.md` skill (≤500 tokens) | P1 | 1.5 | 143, 144, 145 |
| 147 | M56-006 | `acp.integrity.md` command doc (Agent Directive, 11 categories, remediation playbook, boundary rule) | P1 | 2 | 146 |
| 148 | M56-007 | Wrappers + aliases + taxonomy + routing + package.yaml | P1 | 0.75 | 147 |
| 149 | M56-008 | E2E test (12+ assertions) + cross-links + version bump 6.12.0 + CHANGELOG | P2 | 1.5 | 147, 148 |

### Build Order (Non-Negotiable)

```
Route 142 ──┐
             ├──→ Route 146 (wiki + skill)
Route 143 ──┤         │
Route 144 ──┤         ├──→ Route 147 (command doc)
Route 145 ──┘         │         │
                                ├──→ Route 148 (wrappers + integration)
                                │         │
                                └─────────┴──→ Route 149 (E2E + release)
```

**Why scripts first**: Unlike `/acp-review` (pure LLM reasoning), `/acp-integrity` depends on bash scripts for core functionality. Building scripts first and E2E testing them independently prevents the command doc from describing capabilities that don't yet function — the exact problem with the original feedback-007 proposal (audit-053 GAP-053-02).

---

## 8. False-Positive Baseline Test

> **Added per audit-054 NEW-054-04.** This is a non-negotiable quality gate.

The `e2e/acp.integrity.test.sh` must include a false-positive baseline assertion:

```
assert_finding_count CRITICAL 0  # ACP Enhanced codebase on clean commit
assert_finding_count HIGH 0      # must produce zero CRITICAL/HIGH findings
```

This test runs on every CI push. A failing test means a rule is producing noise — fix the rule before merging. A security tool that flags 30 findings on a clean codebase is not usable.

---

## 9. Verification Checklist

- [ ] All 6 bash scripts exist, have `set -euo pipefail`, and pass shellcheck
- [ ] `acp.unicode-scan.sh` detects U+200B, U+200C, U+200D, U+FEFF in fixture files
- [ ] `acp.entropy-scan.sh` correctly calculates Shannon entropy for known-high-entropy strings
- [ ] `acp.manifest-hash.sh` produces SHA-256 hashes matching `shasum -a 256`
- [ ] `acp.network-whitelist-validate.sh` correctly flags non-whitelisted domains
- [ ] `acp.git-provenance.sh` correctly cross-references `git log --format="%ae"` against `identity.yml`
- [ ] `acp.dependency-diff.sh` detects shadow dependencies not in `package-lock.json`
- [ ] `agent/wiki/integrity-rules.md` contains all 55 rules with correct severities
- [ ] `agent/skills/code-integrity.md` ≤500 tokens
- [ ] `agent/skills/code-integrity.md` includes LLM/Script Boundary Rule
- [ ] `agent/commands/acp.integrity.md` has Agent Directive header
- [ ] `agent/commands/acp.integrity.md` includes Remediation Playbook section
- [ ] `agent/commands/acp.integrity.md` includes `## Standards References` table with version pinning
- [ ] `agent/commands/acp.integrity.md` explicitly documents v2.0 deferred rules (Cat 8, 9 partial, 10)
- [ ] `acp-rule-file-audit` alias files exist (prompt + opencode) — 3-line wrappers
- [ ] 1 taxonomy entry: `code-integrity-scan` (no separate `rule-file-audit` type)
- [ ] `package.yaml` entry for acp.integrity.md
- [ ] E2E: 12+ structural assertions
- [ ] E2E: Unicode fixture test (U+200B hidden in AGENTS.md copy)
- [ ] E2E: False-positive baseline — zero CRITICAL, zero HIGH on clean ACP codebase
- [ ] E2E: `--fast` flag + `--self` flag documented and testable
- [ ] All cross-links: acp.review.md, acp.audit.md, acp.validate.md, acp.commit.md
- [ ] Version bumped to 6.12.0 across all 8 version-bearing files
- [ ] CHANGELOG entry (Keep a Changelog `### Added` format)
- [ ] `acp-validate` passes (version consistency + cross-references)
- [ ] `acp-sync` run (wrapper parity + domain.yml counts)

---

## 10. Explicitly Deferred to Future Milestones

| Feature | Target | Rationale |
|---------|--------|-----------|
| Taint flow analysis (IG-45–IG-50) | M58 | Needs SAST-grade cross-file reasoning; LLM accuracy insufficient |
| Semantic injection detection (IG-53, IG-54, IG-56, IG-57) | M58 | Agent self-protection paradox — `confidence: LOW` ceiling required |
| Memory poisoning detection (IG-58–IG-62) | M58 | 11–40% false negative rate; needs UX for "unverifiable" findings |
| Recurring tasks scheduler | M57 | Independent feature — no dependency on integrity |
| Pre-commit hook framework | M57 | Pairs with recurring tasks; needs AGENTS.md Step 4.5 |
| CI/CD pipeline enforcement | M57 | Depends on pre-commit hook framework |

---

## 11. Open Questions (Resolved)

| # | Question | Decision |
|---|----------|----------|
| OQ-1 | Default `--origin` to `composer-2.5`? | **Yes** — our standard executor |
| OQ-2 | Any Phase 2 (Sonnet) in v1.0? | **No** — Phase 1 only for v1.0. Defer Phase 2 to M58 |
| OQ-3 | Keep `acp-rule-file-audit` alias? | **Yes** — 3-line wrappers for pre-commit hook ergonomics. No separate command doc or taxonomy type |
| OQ-4 | False-positive baseline on every CI push? | **Yes** — tool integrity is non-negotiable |

---

*Milestone 56 | ACP Enhanced v6.12.0 | feedback-007 v2.0 + audit-053 + audit-054 | 2026-06-07*
