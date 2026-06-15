---
id: route-155
title: "M58-001: Research — taint-flow accuracy calibration + memory poisoning UX"
task_type: design-document
milestone: M58
complexity: high
executor: copilot
context_required: [milestones/milestone-58-acp-integrity-v2-semantic-analysis.md, agent/commands/acp.integrity.md, agent/wiki/integrity-rules.md]
files_affected: [agent/reports/research-taint-flow-calibration.md, agent/reports/research-memory-poisoning-ux.md]
tokens_est: 12000
created: 2026-06-08
completed: 2026-06-15
---

# Route 155: Research Phase — Accuracy Calibration & UX Design

## Objective

Before building Phase 2, calibrate LLM accuracy for the three deferred categories. This research determines what confidence levels are honest and what the developer experience should be.

## Expected Output

### Files Created
- `agent/reports/research-taint-flow-calibration.md` — TPR/FPR/FNR per rule
- `agent/reports/research-memory-poisoning-ux.md` — "Unverifiable finding" UX pattern

## Research Task 1: Taint-Flow Calibration

1. Select 5–10 known taint-flow vulnerabilities from OWASP Benchmark or CVE database
2. Implement them in a small TypeScript codebase (Express API with SQLite)
3. Run `/acp-integrity --rules taint-flow` with Composer 2.5
4. Run ESLint with `@typescript-eslint` + security plugin
5. Compare per-rule: True Positives, False Positives, False Negatives
6. Output: accuracy table that becomes the `confidence:` ceiling reference

## Research Task 2: Memory Poisoning UX

Design how "unverifiable" findings are presented to developers:
1. Should `confidence: LOW` findings create carryovers? (Recommend: NO — alert fatigue)
2. What output format for "possible memory contamination"?
3. How to convey 11–40% FNR honestly without causing panic?
4. Developer guidance: "What to do if you see this finding"

## Verification

- [ ] Taint-flow calibration report with per-rule accuracy table (TPR, FPR, FNR)
- [ ] Memory poisoning UX pattern document with carryover policy
- [ ] Both reports reference specific CVEs and research papers
- [ ] Confidence levels are justified by calibration data
- [ ] **Go/no-go recommendation**: explicit threshold-based decision (TPR ≥60% → proceed; <40% → halt)

## User-Observable Acceptance

- Research reports exist and inform the M58 implementation
- Confidence ceilings are backed by data, not assumptions
