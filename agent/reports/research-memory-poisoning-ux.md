# Research: Memory Poisoning UX Pattern (M58 / Route 155)

**Date**: 2026-07-15  
**Milestone**: M58 — `/acp-integrity` v2.0 (Category 10: IG-58–IG-62)  
**Status**: Complete — UX pattern approved for route 156 implementation

---

## 1. Purpose

Design how `/acp-integrity` Phase 2 presents **unverifiable** and **low-confidence** memory integrity findings without causing alert fatigue or false assurance. Complements taint-flow calibration in `research-taint-flow-calibration.md`.

---

## 2. Problem Statement

Memory poisoning detection (IG-58–IG-62) faces documented accuracy limits:

| Source | Finding | Implication |
|--------|---------|-------------|
| LinkedIn Research (May 2026) | 60–89% attack success rate against agent memory | Defenders see partial signal at best |
| M58 milestone design | 11–40% FNR for semantic memory checks | "Clean scan" is not credible |
| MITRE ATLAS AML.T0054 | Memory poisoning as adversarial ML tactic | Findings are probabilistic, not binary |
| NIST AI 100-2 E2025 | Runtime poisoning detection immature | LOW confidence ceiling mandatory |

**UX challenge**: Present honest uncertainty without (a) panic, (b) alert fatigue, or (c) false "all clear" signals.

---

## 3. Carryover Policy

### 3.1 Decision: LOW-confidence findings do **NOT** create carryovers

| Confidence | Create carryover? | Rationale |
|------------|-------------------|-----------|
| HIGH (script-backed, e.g. IG-61 Unicode) | ✅ Yes | Deterministic — same as v1.0 |
| MEDIUM | ⚠️ Optional — user flag `--carryover` only | Human must opt in |
| LOW (IG-58–60, IG-62, all Cat 9) | ❌ **No** | Alert fatigue; 11–40% FNR means carryover queue fills with unactionable items |

**Exception**: If the same LOW finding appears in **3 consecutive quarterly scans**, promote to a single informational note in `agent/progress.yaml → notes` (not `audit-carryovers.md`).

### 3.2 Alignment with existing carryovers

Current pending carryovers (audit-062, F-062-01–05) are **medium severity implementation gaps** — appropriate for carryover tracking. Memory poisoning LOW findings are a different class: *screening alerts*, not *action items*.

---

## 4. Output Format — "Unverifiable Finding" Pattern

### 4.1 Terminal output (human-readable)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MEMORY-SCREENING: agent/memory/sessions.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Rule:     IG-60 — Session memory contradicting constraints.yml
  Severity: CRITICAL (screening only)
  Confidence: LOW
  Verdict:  REQUIRES_HUMAN_REVIEW

  Signal:   Entry dated 2026-05-01 suggests "skip acp-commit at session end"
            which contradicts constraints.yml → never_skip_acp_commit

  ⚠️  UNVERIFIABLE — This finding is probabilistic.
      Documented false-negative rate: 11–40% (literature).
      A missing finding does NOT mean memory is clean.

  Recommended action:
    1. Read the cited session entry manually
    2. Compare against agent/core/constraints.yml hard rules
    3. If confirmed adversarial: revert entry, rotate executor, audit git history
    4. Do NOT auto-modify memory files from this scan

  Carryover: NOT created (confidence LOW — see M58 carryover policy)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 4.2 Structured YAML (for `--report`)

```yaml
findings:
  - rule_id: IG-60
    category: memory-poisoning
    file: agent/memory/sessions.md
    line: 42
    severity: CRITICAL
    confidence: LOW
    verdict: REQUIRES_HUMAN_REVIEW
    unverifiable: true
    fnr_reference: "11-40% (LinkedIn Research May 2026; M58 milestone design)"
    signal: "Session entry suggests skipping acp-commit — contradicts never_skip_acp_commit"
    carryover_created: false
    carryover_reason: "LOW confidence — screening only per research-memory-poisoning-ux.md"
    recommended_actions:
      - "Manual review of cited entry"
      - "Cross-check constraints.yml"
      - "Do not auto-modify memory from scan"
```

### 4.3 Self-protection protocol (Cat 9 crossover)

When IG-53/54/56/57 fire during the same scan:

```
INJECTION-RISK: agent/memory/lessons.md — potential adversarial content
  → Agent CONTINUES to next file (no self-halt)
  → Finding logged with confidence LOW
  → Content NOT interpreted or summarised in output
```

---

## 5. Conveying 11–40% FNR Without Panic

### 5.1 Language rules (mandatory in route 156 docs)

| ❌ Never say | ✅ Always say |
|-------------|--------------|
| "Memory is clean" | "No screening signals detected this scan" |
| "Confirmed poisoning" | "Possible contamination — human review required" |
| "Critical vulnerability found" | "Critical-severity screening alert (LOW confidence)" |
| "Fix immediately" | "Review manually; see recommended actions" |

### 5.2 Scan summary footer (always appended for Cat 10)

```
Memory screening summary (Cat 10):
  Signals detected: {N}
  Confidence ceiling: LOW (except IG-61 Unicode = HIGH via script)
  Carryovers created: {M}  ← expect M=0 for LOW-only scans

  ⓘ Memory scans are screening tools, not security boundaries.
    False negatives of 11–40% are documented. Run IG-61 (Unicode)
    separately for deterministic byte-level checks.
```

### 5.3 Developer guidance — "What to do if you see this finding"

1. **Don't panic** — LOW confidence means the scanner is uncertain by design.
2. **Read the cited file** — open the exact path/line; do not trust the scanner's paraphrase alone.
3. **Check git provenance** — `git log -1 -- path` to see who/when modified the memory file.
4. **Compare hard rules** — open `agent/core/constraints.yml`; contradictions are the highest-signal case.
5. **For IG-61 (Unicode)** — treat as HIGH confidence; run `acp.unicode-scan.sh` to corroborate.
6. **Do not auto-fix** — memory files are agent-authored; automated deletion causes data loss.
7. **Escalate if confirmed** — if manual review confirms adversarial content, create a manual ADR in `decisions.md` and revert via git.

---

## 6. Experimental Mode (FNR > 50% gate)

Per M58 §10: if memory scan FNR exceeds 50% in future calibration, Cat 10 ships as **experimental**:

```yaml
phase2_status:
  cat8_taint_flow: active
  cat9_semantic_injection: active
  cat10_memory_poisoning: experimental  # prominent FNR warning in all outputs
```

Current research: semantic contradiction detection (IG-60) estimated FNR ~30% — **below 50% gate**. Ship as active with LOW confidence ceiling, not experimental.

---

## 7. Verification Checklist

- [x] Memory poisoning UX pattern document with carryover policy
- [x] Output format for "possible memory contamination" defined (terminal + YAML)
- [x] References research (LinkedIn May 2026, MITRE ATLAS, NIST AI 100-2)
- [x] Developer guidance section complete
- [x] FNR communicated honestly without panic-inducing language

---

## 8. Implementation Handoff (Route 156)

Route 156 must embed:
1. This carryover policy in `acp.integrity.md` Phase 2 section
2. Terminal + YAML formats in `code-integrity.md` skill (≤800 tokens — use abbreviated form)
3. `integrity-rules.md` Cat 10 confidence ceilings
4. E2E assertion: LOW finding does NOT append to `audit-carryovers.md`

---

*Route 155 deliverable | M58 research phase | ACP Enhanced v6.12.1 → v6.13.0*
