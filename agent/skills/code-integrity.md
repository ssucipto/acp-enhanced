# Skills: code-integrity

> **Command binding**: `/acp-integrity`  
> **Task type**: `code-integrity-scan`  
> **Token budget**: ≤800 tokens  

---

## LLM/Script Boundary Rule

Before executing any integrity rule, classify: **deterministic** (single correct answer from bytes/counts/comparisons) → use bash script. **Semantic** (requires reasoning about meaning/intent) → use LLM with `confidence: MEDIUM` ceiling. Deterministic tasks MUST delegate to scripts.

---

## Script Table

| Script | Rules Covered | Type |
|--------|--------------|------|
| `acp.unicode-scan.sh` | IG-14–IG-16, IG-38–IG-39, IG-61 (IG-20 AI-directive grep) | Deterministic |
| `acp.entropy-scan.sh` | IG-17, IG-18 (hex/base64 patterns) | Deterministic |
| `acp.manifest-hash.sh` | `--diff`, IG-42 (SHA-256 verify) | Deterministic |
| `acp.network-whitelist-validate.sh` | IG-01–IG-03, IG-05–IG-06 | Deterministic |
| `acp.git-provenance.sh` | IG-33–IG-35, IG-37 | Deterministic |
| `acp.dependency-diff.sh` | IG-27–IG-32 | Deterministic |

---

## Confidence Ceilings

| Detection Method | Max Confidence |
|-----------------|---------------|
| Script-backed (byte scan, hash, diff) | HIGH |
| LLM pattern match (known phrases) | HIGH |
| LLM semantic analysis (intent, context) | MEDIUM |
| LLM taint flow / memory (deferred v2.0) | LOW |

---

## Output Format

```yaml
findings:
  - id: INT-NNN
    file: path/to/file
    line: N
    rule: IG-XX
    severity: CRITICAL|HIGH|MEDIUM|LOW
    confidence: HIGH|MEDIUM|LOW
    category: category-name
    message: "one-line description"
    action: "recommended remediation"
```

---

## Quality Gates

- Script-backed findings: `confidence: HIGH`
- LLM-reasoned findings: `confidence: MEDIUM` maximum
- Never auto-fix — report only
- False-positive baseline: zero CRITICAL/HIGH on clean ACP codebase
- `--ci` exits 1 on CRITICAL or HIGH-confidence:HIGH findings
- Full rule catalogue: `agent/wiki/integrity-rules.md` (load on-demand)

---

## Deferred to v2.0 (M58)

- Category 8: Taint flow (IG-45–IG-50) — needs SAST-grade analysis
- Category 9 partial: Semantic injection (IG-53/54/56/57) — self-protection paradox
- Category 10: Memory poisoning (IG-58–IG-62) — 11–40% FNR documented
