# Command: integrity

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-integrity` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-integrity` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-07  
**Status**: Active  
**Scripts**: acp.unicode-scan.sh, acp.entropy-scan.sh, acp.manifest-hash.sh, acp.network-whitelist-validate.sh, acp.git-provenance.sh, acp.dependency-diff.sh  

---

**Purpose**: Verify AI-generated code **trustworthiness and provenance** — detect malicious patterns, hidden Unicode, exfiltration vectors, supply chain risks, and CI injection surfaces. Distinct from `/acp-review` which verifies code **quality**.  
**Category**: Security / Integrity  
**Frequency**: Pre-commit (--fast), weekly (--self), quarterly (full scan)  

---

## Positioning

| Command | Question | Maturity |
|---------|----------|----------|
| `/acp-review` | "Is this code good?" | ✅ v1.0 (M55) |
| `/acp-integrity` | "Is this code trustworthy — does it belong here?" | 🚧 v1.0 (M56) |
| `/acp-integrity --fast` | "Are my ACP rule files clean?" | 🚧 alias |

---

## Arguments

| Flag | Purpose |
|------|---------|
| `[path]` | File or directory; defaults to `src/` |
| `--rules <category>` | Limit to: `exfiltration`, `obfuscation`, `dependencies`, `git-provenance`, `network`, `persistence`, `prompt-injection`, `github-actions` |
| `--self` | Scan ACP framework files: `AGENTS.md`, `agent/core/`, `agent/skills/`, `agent/scripts/` |
| `--fast` | Alias for `--self` — Phase 1 only, V4 Pro eligible, pre-commit safe |
| `--origin <model>` | Declare code origin: `deepseek`, `composer`, `sonnet`. Disqualifies same-model executor |
| `--ci` | Compact output, exit 1 on CRITICAL or HIGH-confidence:HIGH findings |
| `--carryover` | Write CRITICAL/HIGH findings to `agent/memory/audit-carryovers.md` |
| `--report` | Save structured YAML to `agent/reports/integrity-NNN.md` |
| `--diff` | Compare ACP files against SHA-256 hashes in `agent/manifest.yaml` |
| `--phase1` | Run Phase 1 (pattern matching) only — scripts + literal grep |

---

## LLM/Script Boundary Rule

> **This is the foundational architectural principle for `/acp-integrity`.**

Before executing any rule, classify: **deterministic** (has a single correct answer from bytes, counts, or comparisons) → invoke companion bash script. **Semantic** (requires reasoning about meaning, intent, or context) → use LLM reasoning with `confidence: MEDIUM` ceiling.

**The rule**: No deterministic task may be handled by LLM reasoning alone. The LLM invokes scripts and interprets structured output — it does NOT perform byte-level scanning, entropy calculation, or git log parsing.

---

## Executor Selection

| Scope | Executor | Rationale |
|-------|----------|-----------|
| Full scan (default) | copilot | Phase 1 scripts + LLM reasoning |
| `--fast` / `--phase1` | deepseek-v4-pro | Scripts only — cost-efficient |
| `--origin deepseek` | copilot (not DeepSeek) | Conflict of interest |
| CI pipeline | deepseek-v4-pro → copilot on positives | Two-phase cost optimization |

**Disqualified**: Flash, Flash-Max — insufficient cross-file reasoning.

---

## Rules — 55 Rules Across 11 Categories

### Category 1 — Outbound Network Anomalies (CRITICAL)
**Script**: `acp.network-whitelist-validate.sh` | **OWASP A01:2025**

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-01 | `fetch()`/`axios`/`http.request()` to non-whitelisted domain | CRITICAL |
| IG-02 | Network calls to raw IP addresses | CRITICAL |
| IG-03 | Base64-decoded strings immediately in network calls | CRITICAL |
| IG-04 | `eval()` of network-fetched content | CRITICAL |
| IG-05 | DNS lookups from env vars | HIGH |
| IG-06 | Outbound calls in catch blocks (exfil-on-error) | HIGH |

### Category 2 — Data Exfiltration (CRITICAL)
**OWASP A02:2025, CWE-359**

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-07 | `process.env` → network call in same scope | CRITICAL |
| IG-08 | `fs.readFile` → network call | CRITICAL |
| IG-09 | Clipboard → network call | CRITICAL |
| IG-10 | Storage read → network call | HIGH |
| IG-11 | Auth tokens in logs/URLs | HIGH |
| IG-12 | PII without encryption wrapper | HIGH |
| IG-13 | Screenshot APIs outside feature context | CRITICAL |

### Category 3 — Obfuscation & Hidden Instructions (CRITICAL)
**Scripts**: `acp.unicode-scan.sh`, `acp.entropy-scan.sh` | **Pillar Security 2025**

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-14 | Zero-width chars (U+200B/C/D, U+FEFF) | CRITICAL |
| IG-15 | Bidirectional text markers | CRITICAL |
| IG-16 | Unicode homoglyphs in identifiers | CRITICAL |
| IG-17 | Shannon entropy >4.5 bits/char | HIGH |
| IG-18 | Hex/base64 runtime decoding without comment | HIGH |
| IG-19 | Minified blocks in human-authored source | HIGH |
| IG-20 | AI-directive language in comments | CRITICAL |

### Category 4 — Persistence & Execution (HIGH)
**MITRE ATT&CK T1053, T1059**

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-21 | `child_process.exec()` with dynamic commands | CRITICAL |
| IG-22 | `fs.writeFile` to system paths | CRITICAL |
| IG-23 | Cron/scheduled task creation | HIGH |
| IG-24 | Self-modifying code | HIGH |
| IG-25 | Dynamic `require()`/`import()` | HIGH |
| IG-26 | Process injection | CRITICAL |

### Category 5 — Dependency & Supply Chain (HIGH)
**Script**: `acp.dependency-diff.sh` | **SLSA v1.0**

> ⚠️ SLSA Build Level 3 does NOT indicate code safety (Mini Shai-Hulud worm, May 2026).

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-27 | Typosquatting (Levenshtein 1–2 from top-1000) | HIGH |
| IG-28 | `postinstall`/`preinstall` executing shell | HIGH |
| IG-29 | Dependencies imported, absent from lockfile | HIGH |
| IG-30 | Unpinned versions for auth/crypto/session | MEDIUM |
| IG-31 | Lockfile >30 days stale | MEDIUM |
| IG-32 | New dependency without task ID | MEDIUM |

### Category 6 — Git Provenance (MEDIUM)
**Script**: `acp.git-provenance.sh`

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-33 | >200 lines to critical files without task ID | HIGH |
| IG-34 | Security file commit without task ID | MEDIUM |
| IG-35 | Files modified outside route `files_affected` | MEDIUM |
| IG-36 | Binary files without documented justification | HIGH |
| IG-37 | Author email not in `team_members` | HIGH |

### Category 7 — ACP Self-Integrity (CRITICAL)
**Scripts**: `acp.unicode-scan.sh`, `acp.manifest-hash.sh`

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-38 | Hidden Unicode in AGENTS.md/CLAUDE.md | CRITICAL |
| IG-39 | Hidden Unicode in agent/core/, .cursor/, .opencode/ | CRITICAL |
| IG-40 | constraints.yml contradicting ACP hard rules | CRITICAL |
| IG-41 | New agent/core/ files not in release manifest | HIGH |
| IG-42 | Scripts modified without version bump | HIGH |
| IG-43 | Skill files with "skip security" instructions | CRITICAL |
| IG-44 | Workflow actions not pinned to commit SHA | HIGH |

### Category 8 — Taint Flow ⚠️ DEFERRED to v2.0 (M58)
IG-45–IG-50 documented in `agent/wiki/integrity-rules.md`. Requires SAST-grade cross-file reasoning.

### Category 9 — Prompt Injection Surface (CRITICAL — partial)

> ⚠️ v1.0 detects literal known patterns only (grep-equivalent). Semantic detection deferred to v2.0. This is a best-effort screening tool, not a security boundary.

| Rule ID | Rule | v1.0 | Severity |
|---------|------|------|----------|
| IG-51 | Code comments with agent-directive phrases | ✅ | CRITICAL |
| IG-52 | Markdown HTML comment directives | ✅ | CRITICAL |
| IG-55 | `.env.example` with injection-like text | ✅ | MEDIUM |
| IG-63 | Multi-language injection fragments | ✅ | HIGH |
| IG-53 | API responses with instruction-like content | ❌ | HIGH |
| IG-54 | Test fixtures with agent-instruction strings | ❌ | HIGH |
| IG-56 | MCP configs with non-official tools | ❌ | HIGH |
| IG-57 | MCP tool descriptions with override language | ❌ | CRITICAL |

### Category 10 — Memory Integrity ⚠️ DEFERRED to v2.0 (M58)
IG-58–IG-62. 60–89% AUR, 11–40% FNR. Unicode detection (IG-61) available in v1.0 via `acp.unicode-scan.sh`.

### Category 11 — GitHub Actions & CI Injection (HIGH)
**CSA Research Note May 2026**

| Rule ID | Rule | Severity |
|---------|------|----------|
| IG-64 | `${{ github.event.pull_request.title }}` unsanitized | CRITICAL |
| IG-65 | `${{ github.event.issue.body }}` to AI agents | CRITICAL |
| IG-66 | AI agent steps with `permissions: write-all` | HIGH |
| IG-67 | `actions/checkout` not pinned to SHA | HIGH |
| IG-68 | `npm install` without `--ignore-scripts` | HIGH |
| IG-69 | AI CI steps writing to repo without approval | HIGH |
| IG-70 | SLSA attestation as sole trust basis | HIGH |

---

## Remediation Playbook

| Severity | Response | Timeline |
|----------|----------|----------|
| **CRITICAL** | Stop all AI agent sessions. Quarantine affected file. Do not commit. Rotate credentials accessible since last verified clean. | Immediate |
| **HIGH** | Freeze affected component. Create INT-NNN carryover. Do not merge until resolved. | Within session |
| **MEDIUM** | Create carryover. Address within current milestone. | Within milestone |
| **LOW** | Create carryover or note in session. | Within 2 milestones |

---

## Standards References

| Standard | Version | Last Verified | Rules |
|----------|---------|---------------|-------|
| OWASP Top 10 | 2025 | 2026-06-07 | IG-01–IG-13, IG-21–IG-26 |
| OWASP LLM Top 10 | 2025 | 2026-06-07 | IG-51, IG-52, IG-55 |
| NIST SP 800-53 Rev 5 | 2023 | 2026-06-07 | IG-01, IG-07, IG-33 |
| SLSA Framework | v1.0 | 2026-06-07 | IG-27–IG-32, IG-67–IG-70 |
| MITRE ATT&CK | v16 | 2026-06-07 | IG-21–IG-26 |
| Pillar Security Rulz | 2025 | 2026-06-07 | IG-14–IG-16, IG-38–IG-39 |
| CSA Research Note | May 2026 | 2026-06-07 | IG-64–IG-70 |

> `acp-validate` warns when OWASP LLM Top 10 reference exceeds 12 months staleness.

---

## Output Format

```yaml
# agent/reports/integrity-NNN.md
findings:
  - id: INT-001
    file: path/to/file
    line: 47
    rule: IG-14
    severity: CRITICAL
    confidence: HIGH
    category: obfuscation
    message: "Zero-width joiner (U+200D) at character position 847"
    action: "Remove character. Verify against manifest hash."
```

---

## Quality Gates

1. Script-backed findings must have `confidence: HIGH`
2. LLM-reasoned findings capped at `confidence: MEDIUM`
3. Never auto-fix — report only
4. False-positive baseline: zero CRITICAL/HIGH on clean ACP codebase
5. `--ci` exits 1 on CRITICAL or HIGH-confidence:HIGH

---

## Related Commands

- [`/acp-review`](acp.review.md) — Code quality & security standards enforcement
- [`/acp-audit`](acp.audit.md) — Deep-dive a specific integrity finding
- [`/acp-validate`](acp.validate.md) — ACP framework structure validation
- [`/acp-commit`](acp.commit.md) — Save session after addressing findings

---

## Verification Checklist

- [ ] All 6 scripts exist, pass `bash -n`, and have `set -euo pipefail`
- [ ] `acp.unicode-scan.sh` detects U+200B/U+200D in fixture files
- [ ] `acp.entropy-scan.sh` correctly flags high-entropy base64 strings
- [ ] `acp.manifest-hash.sh --verify` passes on unmodified files
- [ ] `acp.network-whitelist-validate.sh` flags non-whitelisted domains
- [ ] `acp.git-provenance.sh` verifies commit authors against identity.yml
- [ ] `acp.dependency-diff.sh` detects shadow dependencies
- [ ] False-positive baseline: zero CRITICAL/HIGH on clean ACP codebase
- [ ] `--fast` flag scans ACP rule files only
- [ ] Deferred rules (Cat 8, Cat 9 partial, Cat 10) explicitly documented
- [ ] Remediation Playbook present
- [ ] Standards References table with version pinning
