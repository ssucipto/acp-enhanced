# Skills: code-integrity

> **Command binding**: `/acp-integrity`  
> **Task type**: `code-integrity-scan`  
> **Token budget**: ≤800 tokens  
> **Version**: v1.1 (M64)

---

## LLM/Script Boundary Rule

**Deterministic** → bash script (confidence HIGH). **Semantic** → LLM (confidence MEDIUM max). No deterministic task via LLM alone.

---

## Script Table (v1.1 — M64 truth)

| Script | Rules Enforced (script-backed) | Type |
|--------|------------------------------|------|
| `acp.unicode-scan.sh` | IG-14–16, IG-20, IG-38–39, IG-61 | Deterministic |
| `acp.entropy-scan.sh` | IG-17, IG-18 | Deterministic |
| `acp.network-whitelist-validate.sh` | IG-01–03, IG-05–06 | Deterministic |
| `acp.pattern-scan.sh` | IG-04, IG-07–13, IG-21–26 | Deterministic |
| `acp.dependency-diff.sh` | IG-27–32 | Deterministic |
| `acp.git-provenance.sh` | IG-33–34, IG-36–37 (IG-37 skips if `team_members` empty) | Deterministic |
| `acp.manifest-hash.sh` | IG-42 (`--verify`) | Deterministic |
| `acp.integrity-output.sh` | (library) uniform `[SEVERITY] file:line ruleID — msg` + `--json` + severity-aware `--ci` | Shared |

**Deferred v2.0 (LLM-only)**: IG-45–50 taint, IG-53–54/56–57 semantic injection, IG-58–62 memory poisoning.

---

## Output Contract (route-182)

```
[HIGH] path/file.ts:42 IG-17 — high-entropy string literal
```

`--ci` exits 1 only on **CRITICAL** or **HIGH** findings (MEDIUM/LOW are reported but non-blocking).

---

## Quality Gates

- Fixture matrix: `agent/benchmarks/fixtures/integrity/manifest.yaml`
- False-positive baseline: zero CRITICAL/HIGH on clean framework paths (E2E B20)
- Full catalogue: `agent/wiki/integrity-rules.md` (on-demand)
