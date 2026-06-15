# Integrity Rules Catalogue — v1.1 (M64 truth pass)

> **Load control**: Load one category section at a time. Never load the entire file.
> **Version**: 2.0.0 | **Total rules**: 70 | **Script-backed**: 44 across 9 scripts + output lib | **Phase 2 (M58)**: Cat 8/10 active, Cat 9 semantic LLM
> **Command**: /acp-integrity | **Skill**: @code-integrity
> **Fixtures**: `agent/benchmarks/fixtures/integrity/manifest.yaml`

---

## Category 1 — Outbound Network Anomalies (CRITICAL)
**Script**: `acp.network-whitelist-validate.sh` | **Rules**: IG-01–IG-03, IG-05–IG-06 | **Standard**: OWASP A01:2025

| Rule ID | Rule | Severity | Detection |
|---------|------|----------|-----------|
| IG-01 | `fetch()`/`axios`/`http.request()` to non-whitelisted domain | CRITICAL | ✅ Script — whitelist cross-ref |
| IG-02 | Network calls to raw IP addresses | CRITICAL | ✅ Script — IP regex |
| IG-03 | Base64-decoded strings immediately in network calls | CRITICAL | ✅ Script — pattern match |
| IG-04 | `eval()` of network-fetched content | CRITICAL | ✅ Script — `acp.pattern-scan.sh` |
| IG-05 | DNS lookups from env vars | HIGH | ✅ Script — pattern |
| IG-06 | Outbound calls in catch blocks (exfil-on-error) | HIGH | ✅ Script — catch-block heuristic |

---

## Category 2 — Data Exfiltration Patterns (CRITICAL)
**Script**: `acp.pattern-scan.sh` | **Rules**: IG-07–IG-13 | **Standard**: OWASP A02:2025, CWE-359

| Rule ID | Rule | Severity | Detection |
|---------|------|----------|-----------|
| IG-07 | `process.env` access → network call in same scope | CRITICAL | ✅ Script — pattern-scan |
| IG-08 | `fs.readFile` result → network call | CRITICAL | ✅ Script — pattern-scan |
| IG-09 | Clipboard access → network call | CRITICAL | ✅ Script — pattern-scan |
| IG-10 | Storage read → network call | HIGH | ✅ Script — pattern-scan |
| IG-11 | Auth tokens in logs/query strings/URLs | HIGH | ✅ Script — pattern-scan |
| IG-12 | PII in request body without encryption | HIGH | ✅ Script — pattern-scan |
| IG-13 | Screenshot APIs outside declared feature context | CRITICAL | ✅ Script — pattern-scan |

---

## Category 3 — Obfuscation & Hidden Instructions (CRITICAL)
**Scripts**: `acp.unicode-scan.sh`, `acp.entropy-scan.sh` | **Rules**: IG-14–IG-20 | **Standard**: Pillar Security 2025

| Rule ID | Rule | Severity | Detection |
|---------|------|----------|-----------|
| IG-14 | Zero-width chars: U+200B/C/D, U+FEFF | CRITICAL | Script — unicode-scan.sh |
| IG-15 | Bidirectional text markers: U+202A–U+202E, U+2066–U+2069 | CRITICAL | Script — unicode-scan.sh |
| IG-16 | Unicode homoglyphs in identifiers | CRITICAL | Script — unicode-scan.sh |
| IG-17 | Shannon entropy >4.5 bits/char | HIGH | Script — entropy-scan.sh |
| IG-18 | Hex/base64 decoded at runtime without comment | HIGH | Script — entropy-scan.sh (pattern) |
| IG-19 | Minified blocks in human-authored source | HIGH | LLM — mixed deterministic/semantic |
| IG-20 | AI-directive language in comments | CRITICAL | Script — unicode-scan.sh (grep) |

---

## Category 4 — Persistence & Execution (HIGH)
**Script**: `acp.pattern-scan.sh` | **Standard**: MITRE ATT&CK T1053, T1059, CWE-78 | **Rules**: IG-21–IG-26

| Rule ID | Rule | Severity | Detection |
|---------|------|----------|-----------|
| IG-21 | `child_process.exec()` with dynamic commands | CRITICAL | ✅ Script — pattern-scan |
| IG-22 | `fs.writeFile` to system paths | CRITICAL | ✅ Script — pattern-scan |
| IG-23 | Cron/scheduled task creation | HIGH | ✅ Script — pattern-scan |
| IG-24 | Self-modifying code | HIGH | ✅ Script — pattern-scan |
| IG-25 | Dynamic `require()`/`import()` from env/user input | HIGH | ✅ Script — pattern-scan |
| IG-26 | Process injection | CRITICAL | ✅ Script — pattern-scan |

---

## Category 5 — Dependency & Supply Chain (HIGH)
**Script**: `acp.dependency-diff.sh` | **Rules**: IG-27–IG-32 | **Standard**: SLSA v1.0

> ⚠️ **SLSA Provenance Paradox**: SLSA Build Level 3 attestation does NOT indicate code safety. The Mini Shai-Hulud worm (May 2026) shipped malicious code with valid SLSA provenance. Do not reduce severity of IG-27–IG-32 based on SLSA compliance.

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-27 | Typosquatting (Levenshtein 1–2 from top-1000) | HIGH |
| IG-28 | `postinstall`/`preinstall` scripts executing shell | HIGH |
| IG-29 | Dependencies imported but absent from lockfile | HIGH |
| IG-30 | Unpinned versions for auth/crypto/session packages | MEDIUM |
| IG-31 | Lockfile >30 days stale vs source changes | MEDIUM |
| IG-32 | New dependency without task ID in commit | MEDIUM |

---

## Category 6 — Git Provenance & Commit Anomalies (MEDIUM)
**Script**: `acp.git-provenance.sh` | **Rules**: IG-33–IG-37 | **Standard**: NIST SP 800-53 CM-3

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-33 | Single commit >200 lines to auth/crypto/data-access without task file | HIGH |
| IG-34 | Security-critical file commits without linked task ID | MEDIUM |
| IG-35 | Files modified outside declared `files_affected` in route | MEDIUM |
| IG-36 | Binary files committed without documented justification | HIGH |
| IG-37 | Commit author email not matching identity.yml `team_members` | HIGH |

---

## Category 7 — ACP Self-Integrity (CRITICAL)
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

---

## Category 8 — Taint Flow Analysis (HIGH) — Phase 2 (M58 v2.0)

**Script**: `acp.taint-scan.sh` (heuristic prep + obvious-sink detection) | **Rules**: IG-45–IG-50 | **Standard**: OWASP A03:2025, CWE-134/601

> **Confidence ceiling**: MEDIUM max for LLM cross-file reasoning; script-backed obvious sinks may report at HIGH severity but never auto-fail CI at HIGH confidence for taint rules. All Phase 2 taint findings carry `verdict: REQUIRES_HUMAN_REVIEW`.

| Rule ID | Source → Sink | Severity | Detection | Max Confidence |
|---------|--------------|----------|-----------|----------------|
| IG-45 | User input → SQL/NoSQL query without parameterisation | CRITICAL | ✅ Script — taint-scan (obvious concat) + LLM cross-file | MEDIUM |
| IG-46 | User input → shell command execution | CRITICAL | ✅ Script — taint-scan (exec/spawn + interpolation) + LLM | MEDIUM |
| IG-47 | User input → file path without sanitisation | CRITICAL | ✅ Script — taint-scan heuristic + LLM | MEDIUM |
| IG-48 | User input → URL redirect without validation | HIGH | ✅ Script — taint-scan heuristic + LLM | MEDIUM |
| IG-49 | Environment variable → network call without validation | HIGH | ✅ Script — taint-scan heuristic + LLM | MEDIUM |
| IG-50 | Third-party library output → security decision without re-validation | HIGH | LLM semantic only | LOW |

---

## Category 9 — Prompt Injection Surface (CRITICAL — partial v1.0)

> ⚠️ **Agent self-protection limitation**: v1.0 detects literal known patterns only — equivalent to `grep`. Semantic injection detection is deferred to v2.0 with `confidence: LOW` ceiling. This is a best-effort screening tool, not a security boundary.

| Rule ID | Rule | v1.0? | Severity | Confidence |
|---------|------|-------|----------|------------|
| IG-51 | Code comments with agent-directive phrases | ✅ v1.0 | CRITICAL | HIGH |
| IG-52 | Markdown HTML comment directives | ✅ v1.0 | CRITICAL | HIGH |
| IG-55 | `.env.example` with injection-like text | ✅ v1.0 | MEDIUM | MEDIUM |
| IG-63 | Multi-language injection fragments | ✅ v1.0 | HIGH | MEDIUM |
| IG-53 | API responses with instruction-like content | ❌ v2.0 | HIGH | LOW |
| IG-54 | Test fixtures with agent-instruction strings | ❌ v2.0 | HIGH | LOW |
| IG-56 | MCP configs invoking non-official tools | ❌ v2.0 | HIGH | LOW |
| IG-57 | MCP tool descriptions with override language | ❌ v2.0 | CRITICAL | LOW |

---

## Category 10 — Memory & Context Integrity (CRITICAL) — Phase 2 (M58 v2.0)

**Script**: `acp.memory-scan.sh` (prep for LLM) + `acp.unicode-scan.sh` (IG-61) | **Rules**: IG-58–IG-62 | **Standard**: MITRE ATLAS AML.T0054

> **Confidence ceiling**: LOW for semantic memory analysis (11–40% FNR documented). IG-61 hidden Unicode remains script-backed at HIGH. No LOW-confidence memory finding creates audit carryovers.

| Rule ID | Rule | Severity | Detection | Max Confidence |
|---------|------|----------|-----------|----------------|
| IG-58 | Carryover entries with instruction-like text outside YAML schema | CRITICAL | LLM — memory-scan prep | LOW |
| IG-59 | Decision entries with agent-directive language | CRITICAL | LLM — memory-scan prep | LOW |
| IG-60 | Session memory contradicting `constraints.yml` hard rules | CRITICAL | LLM — memory-scan prep | LOW |
| IG-61 | Memory files with hidden Unicode | CRITICAL | ✅ Script — unicode-scan.sh | HIGH |
| IG-62 | Memory files modified by session with untrusted context | HIGH | LLM — git-provenance + memory-scan | LOW |

---

## Category 11 — GitHub Actions & CI Agent Injection (HIGH)
**Standard**: CSA Research Note May 2026 | **Rules**: IG-64–IG-70

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-64 | Workflow steps using untrusted PR title data | CRITICAL |
| IG-65 | Workflow steps passing issue body to AI agents | CRITICAL |
| IG-66 | AI agent steps with `permissions: write-all` | HIGH |
| IG-67 | `actions/checkout` not pinned to commit SHA | HIGH |
| IG-68 | `npm install` in CI without `--ignore-scripts` | HIGH |
| IG-69 | AI agent CI steps writing to repo without human approval | HIGH |
| IG-70 | SLSA attestation as sole trust basis | HIGH |

---

*Integrity Rules Catalogue v2.0 | ACP Enhanced | /acp-integrity | 2026-06-15*
