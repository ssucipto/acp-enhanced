# M58 Memory Poisoning UX Pattern

<!-- @acp.meta.artifact
topic: memory-poisoning, code-integrity, IG-58, IG-59, IG-60, IG-62, confidence-ceiling
last_verified: 2026-06-15
confidence: high
status: active
updated: 2026-06-15
@acp.meta.end -->

**Type**: research  
**Created**: 2026-06-15  
**Route**: 155 (companion to taint-flow calibration)  
**Category**: Security / Code Integrity Phase 2

---

## Executive Summary

Memory poisoning rules (IG-58–IG-62) are **screening tools**, not security boundaries. Documented false-negative rates of **11–40%** require a UX that never implies certainty. This document defines the output format, carryover policy, and human-review workflow for Phase 2 memory findings.

**Key decisions:**

1. All semantic memory findings use `verdict: REQUIRES_HUMAN_REVIEW` and `max_confidence: LOW` (except IG-61 script-backed Unicode at HIGH).
2. **LOW-confidence findings do NOT create audit carryovers** — avoids alert fatigue from unverifiable signals.
3. `acp.memory-scan.sh` prepares structured YAML for LLM comparison; it does not emit blocking findings.

---

## Unverifiable Finding Output Format

When `/acp-integrity --rules memory` (Phase 2) flags content:

```yaml
finding:
  rule: IG-58
  file: agent/memory/audit-carryovers.md
  line: 42
  severity: CRITICAL          # impact if real
  confidence: LOW             # certainty ceiling — never HIGH for semantic memory
  verdict: REQUIRES_HUMAN_REVIEW
  message: "Instruction-like text outside YAML schema in carryover entry"
  detection: llm-semantic
  script_prep: acp.memory-scan.sh
```

**Console one-liner** (for agent self-protection protocol):

```
INJECTION-RISK: agent/memory/sessions.md — potential adversarial content, human review required
```

The reviewing agent **CONTINUES** to the next file — never self-halts on flagged memory content.

---

## Carryover Policy

| Confidence | Creates carryover? | CI `--ci` exit 1? | Rationale |
|------------|-------------------|-------------------|-----------|
| HIGH (IG-61 only) | Yes, if CRITICAL | Yes | Script-backed Unicode — deterministic |
| LOW (IG-58–60, IG-62) | **No** | No | FNR too high; human triage only |
| MEDIUM | N/A for memory | No | Memory rules capped at LOW |

Per milestone-58 §10: when memory scan FNR > 50%, Cat 10 ships as **experimental** with prominent FNR warning. Current literature estimates (11–40% FNR) support shipping with LOW ceiling but not with carryover automation.

---

## Human Review Workflow

1. **Triage queue**: LOW findings appear in `--report` output only; no auto-carryover.
2. **Reviewer action**: Confirm or dismiss each finding manually.
3. **Confirmed poison**: Developer edits memory file, runs `/acp-validate`, commits fix.
4. **False positive**: No tracking artifact required — dismiss in report notes.

---

## acp.memory-scan.sh Contract

The prep script outputs:

```yaml
phase2: memory-scan
verdict_hint: REQUIRES_HUMAN_REVIEW
max_confidence: LOW
constraints_hard_rules: [...]
memory_files: [{file, bytes, preview}, ...]
```

LLM analysis compares `memory_files` previews against `constraints_hard_rules` for IG-58–60 contradictions. IG-62 adds git-provenance context (session with untrusted context) — deferred to full `/acp-integrity --phase2` orchestration.

---

## Recommendations

1. **Never claim "memory clean"** after Phase 2 scan — use "no findings above LOW confidence" (Priority: High)
2. **Run quarterly-deep-scan** via recurring task (now unblocked post-M58) (Priority: Medium)
3. **IG-61 remains the only blocking memory rule** in `--ci` mode (Priority: High)

---

## Limitations

- No empirical FNR measurement in route-155 — literature-based ceilings only
- Cross-session provenance (IG-62) requires git history integration not in prep script
- Preview truncated to 500 bytes — LLM may miss poison beyond preview window

---

## Sources

1. `agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md` §7, §10
2. `agent/wiki/integrity-rules.md` Category 10
3. MITRE ATLAS AML.T0054 — Memory poisoning
