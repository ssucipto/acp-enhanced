---
id: integrity-001
date: 2026-07-15
scope: --self (AGENTS.md, agent/core, agent/skills, agent/scripts, .cursor, .github/workflows)
executor: copilot
mode: phase1
findings_total: 5
findings_critical: 0
findings_high: 2
findings_medium: 1
findings_low: 0
findings_info: 2
carryovers_created: 2
project_version: 6.25.1
---

# Integrity Scan: ACP Framework Self-Review

**Scan**: #001  
**Date**: 2026-07-15  
**Mode**: `--self` Phase 1 (script-backed)  
**Executor**: copilot  

---

## Summary

Phase 1 self-integrity scan: **no CRITICAL trustworthiness findings** in framework rule files. Unicode, entropy, and network-whitelist scanners report **clean** on `AGENTS.md`, `agent/core/`, `agent/skills/`, `agent/scripts/`, `.cursor/`, and `.github/workflows/`. CI workflows pass IG-67 (pinned checkout SHA) and IG-68 (`npm install --ignore-scripts`).

**Two HIGH operational gaps**: (1) `agent/manifest.yaml` has no `files:` SHA registry — 88 tracked paths fail IG-42 verify; (2) `acp.git-provenance.sh` team_members parser fails on macOS BSD `sed` (`\s` unsupported), causing false IG-37 author alerts despite correct `identity.yml` config.

**Verdict: TRUSTWORTHY with operational drift** — no hidden Unicode, exfiltration patterns, or CI injection in self scope; address manifest + provenance parser before next quarterly scan.

---

## Scanner Pipeline Results

| Scanner | Self targets | Result |
|---------|--------------|--------|
| `acp.unicode-scan.sh` | AGENTS.md, core, skills, scripts, .cursor, workflows | ✅ 0 findings |
| `acp.entropy-scan.sh` | Self paths | ✅ 0 findings |
| `acp.network-whitelist-validate.sh` | Self paths | ✅ 0 findings |
| `acp.pattern-scan.sh` | agent/scripts (excl. scanner FP) | ⚠️ Self-referential FP on `acp.pattern-scan.py` |
| `acp.manifest-hash.sh --verify` | Tracked framework files | ❌ 88 HIGH (IG-42) |
| `acp.git-provenance.sh` | Last 10 commits | ❌ 10 HIGH (IG-37 FP) + 3 MED (IG-34) |
| `acp.dependency-diff.sh` | Default | ✅ 0 findings |

---

## Finding Register

```yaml
findings:
  - id: INT-001
    file: agent/manifest.yaml
    line: 0
    rule: IG-42
    severity: HIGH
    confidence: HIGH
    verdict: FAIL
    category: acp-self-integrity
    message: "manifest.yaml has no files: sha256 block — 88 framework paths fail --verify"
    action: "Run acp.manifest-hash.sh --generate --output agent/manifest.yaml (or separate integrity manifest)"

  - id: INT-002
    file: agent/scripts/acp.git-provenance.sh
    line: 41
    rule: IG-37
    severity: HIGH
    confidence: HIGH
    verdict: FAIL
    category: git-provenance
    message: "BSD sed \\s in team_members parser fails on macOS — all commits flagged as unknown author"
    snippet: "sed 's/^\\s*-[[:space:]]*//'"
    action: "Use sed 's/^[[:space:]]*-[[:space:]]*//' or yaml_get for team_members"

  - id: INT-003
    file: agent/memory/audit-carryovers.md
    line: 0
    rule: IG-34
    severity: MEDIUM
    confidence: HIGH
    verdict: REVIEW
    category: git-provenance
    message: "3 recent commits touch agent/core|memory without task-ID in commit message"
    action: "Include route/task ID in security-path commits (convention)"

  - id: INT-004
    file: agent/scripts/acp.pattern-scan.py
    line: 1
    rule: IG-07
    severity: INFO
    confidence: HIGH
    verdict: FALSE_POSITIVE
    category: pattern-scan
    message: "Scanner detects its own pattern literals — exclude scanner from self-scan or add allowlist"

  - id: INT-005
    file: .github/workflows/ci.yaml
    line: 22
    rule: IG-67
    severity: INFO
    confidence: HIGH
    verdict: PASS
    category: github-actions
    message: "actions/checkout pinned to commit SHA 11bd71901bbe5b1630ceea73d27597364c9af683"
```

---

## Category Rollup (actionable)

| Sev | Count | Rules |
|-----|-------|-------|
| HIGH | 2 | IG-42, IG-37 (parser bug) |
| MEDIUM | 1 | IG-34 |
| CRITICAL | 0 | — |

---

## Self-Scope PASS Matrix

| Rule | Check | Status |
|------|-------|--------|
| IG-38 | Hidden Unicode in AGENTS.md/CLAUDE.md | ✅ |
| IG-39 | Hidden Unicode in core/skills/scripts | ✅ |
| IG-40 | constraints.yml vs ACP hard rules | ✅ (manual: no contradictions) |
| IG-51/52 | Literal prompt-injection phrases in commands | ✅ |
| IG-64/65 | Unsanitized PR title/body in CI | ✅ (not used) |
| IG-67 | Unpinned actions/checkout | ✅ pinned |
| IG-68 | npm install without --ignore-scripts | ✅ uses --ignore-scripts |

---

## Cross-Reference

| Source | Overlap |
|--------|---------|
| review-001 CR-001 | vitest CRITICAL CVE — supply chain (SC-14), separate from integrity self-scan |
| audit-084 | M63 deployment complete — no integrity blockers for v6.25.1 |

---

## E2E Regression Note

`e2e/acp.integrity.test.sh` — **61/62 pass**. Failure: `acp.network-whitelist-validate.sh` clean fixture `network-ig01-good.js` (fixture matrix B19). Track separately from self-scan.

---

## Recommendations

1. **P1**: Fix `acp.git-provenance.sh` team_members sed (INT-002) — macOS compatibility
2. **P1**: Regenerate manifest SHA registry or split integrity manifest from package manifest (INT-001)
3. **P2**: Add pattern-scan allowlist for `acp.pattern-scan.py` in `--self` mode
4. **P3**: Fix network-whitelist E2E fixture regression (B19)

---

**Scan complete.** 2 HIGH carryovers written.
