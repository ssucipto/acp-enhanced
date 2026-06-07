# Integrity Rules Catalogue — v1.0

> **Load control**: Load one category section at a time. Never load the entire file.
> **Version**: 1.0.0 | **Total rules**: 55 v1.0 + 15 deferred to v2.0 (M58)
> **Command**: /acp-integrity | **Skill**: @code-integrity

---

## Category 1 — Outbound Network Anomalies (CRITICAL)
**Script**: `acp.network-whitelist-validate.sh` | **Rules**: IG-01–IG-06 | **Standard**: OWASP A01:2025

| Rule ID | Rule | Severity | Detection |
|---------|------|----------|-----------|
| IG-01 | `fetch()`/`axios`/`http.request()` to non-whitelisted domain | CRITICAL | Script — grep + whitelist cross-ref |
| IG-02 | Network calls to raw IP addresses | CRITICAL | Script — IP regex |
| IG-03 | Base64-decoded strings immediately in network calls | CRITICAL | Script — pattern match |
| IG-04 | `eval()` of network-fetched content | CRITICAL | LLM — mixed deterministic/semantic |
| IG-05 | DNS lookups from env vars | HIGH | Script — grep + pattern |
| IG-06 | Outbound calls in catch blocks (exfil-on-error) | HIGH | Script — catch-block heuristic |

---

## Category 2 — Data Exfiltration Patterns (CRITICAL)
**Script**: `acp.network-whitelist-validate.sh` | **Rules**: IG-07–IG-13 | **Standard**: OWASP A02:2025, CWE-359

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-07 | `process.env` access → network call in same scope | CRITICAL |
| IG-08 | `fs.readFile` result → network call | CRITICAL |
| IG-09 | Clipboard access → network call | CRITICAL |
| IG-10 | Storage read → network call | HIGH |
| IG-11 | Auth tokens in logs/query strings/URLs | HIGH |
| IG-12 | PII in request body without encryption | HIGH |
| IG-13 | Screenshot APIs outside declared feature context | CRITICAL |

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
**Standard**: MITRE ATT&CK T1053, T1059, CWE-78 | **Rules**: IG-21–IG-26

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-21 | `child_process.exec()` with dynamic commands | CRITICAL |
| IG-22 | `fs.writeFile` to system paths | CRITICAL |
| IG-23 | Cron/scheduled task creation | HIGH |
| IG-24 | Self-modifying code | HIGH |
| IG-25 | Dynamic `require()`/`import()` from env/user input | HIGH |
| IG-26 | Process injection | CRITICAL |

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

## Category 8 — Taint Flow Analysis (HIGH) ⚠️ DEFERRED to v2.0 (M58)

> **Deferred**: Requires SAST-grade cross-file reasoning. LLM accuracy insufficient for `confidence: HIGH`. Will be re-evaluated after v1.0 production data.

| Rule ID | Source → Sink | Severity |
|---------|--------------|----------|
| IG-45 | User input → SQL/NoSQL query without parameterisation | CRITICAL |
| IG-46 | User input → shell command execution | CRITICAL |
| IG-47 | User input → file path without sanitisation | CRITICAL |
| IG-48 | User input → URL redirect without validation | HIGH |
| IG-49 | Environment variable → network call without validation | HIGH |
| IG-50 | Third-party library output → security decision without re-validation | HIGH |

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

## Category 10 — Memory & Context Integrity (CRITICAL) ⚠️ DEFERRED to v2.0 (M58)

> **Deferred**: 60–89% AUR documented in literature (LinkedIn Research, May 2026). 11–40% false negative rate. Semantic contradiction detection against `constraints.yml` requires deep reasoning not reliable enough for production use.

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-58 | Carryover entries with instruction-like text outside YAML schema | CRITICAL |
| IG-59 | Decision entries with agent-directive language | CRITICAL |
| IG-60 | Session memory contradicting `constraints.yml` hard rules | CRITICAL |
| IG-61 | Memory files with hidden Unicode (detection available v1.0 via unicode-scan.sh) | CRITICAL |
| IG-62 | Memory files modified by session with untrusted context | HIGH |

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

*Integrity Rules Catalogue v1.0 | ACP Enhanced | /acp-integrity | 2026-06-07*
