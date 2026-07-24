# Research: ACP Enhanced vs CodeRabbit & Aikido — Gap Analysis and Internal-Standard Roadmap

**Type**: Direction research (follow-up to research-acp-direction-mcp-2026.md)
**Date**: 2026-07-15
**Status**: Roadmap accepted as plan of record. **CodeRabbit**: M81 / **ADR-22** carve-out (CodeRabbit-only; Aikido not required). **Aikido + M76/M77**: still gated per **ADR-19** until explicitly re-planned. Aikido deferred for current user-base cost — not abandoned.
**Reframe**: ACP Enhanced is NOT a commercial product — it is the standardized development method for the startup (quality, reviewed, tested, secure-by-design). Question: how big is the gap vs CodeRabbit and Aikido, can/should we close it, and do we still need both services?

---

## 1. What the commercial tools actually are (verified July 2026)

**CodeRabbit** (~$24/dev/mo Pro; genuinely free tier incl. IDE/CLI reviews): LLM review + **40+ real engines** (ESLint/Biome/Ruff/Pylint/golangci-lint/Clippy/RuboCop; Brakeman SAST; TruffleHog secrets; Trivy IaC) in sandboxes; line-by-line PR comments, diagrams, one-click fixes; **path-specific instructions** and **pre-merge checks written in plain English**; Issue Planner (Feb 2026 beta); 2M+ repos, 13M+ PRs processed.

**Aikido** (free tier for small teams; SOC2/ISO27001): consolidated AppSec — SAST, DAST, **SCA with CVE feeds**, secrets, IaC, container scanning, CSPM, license risk, **runtime protection (Zen)**, malware-in-dependency detection; **AutoTriage cuts noise ~95%** via dedup + reachability analysis; Device Protection (May 2026): real-time malware blocking for npm/PyPI/Maven/NuGet + IDE-extension governance; 50k+ orgs.

## 2. Honest gap matrix

| Capability | ACP Enhanced today | CodeRabbit | Aikido | Gap & verdict |
|---|---|---|---|---|
| SAST detection depth | `acp.review-scan.sh` Phase 1 — heuristic bash; audit-070 proved false-assurance risk in v1 scanners | 40+ real engines | Full SAST + reachability | **Unclosable by design** (years + teams + feeds). BUY |
| Dependency/CVE (SCA) | `monthly-dependency-audit` recurring task, hand-rolled diff | — (Trivy partial) | Core strength: CVE feeds, reachability, malware, licenses | **Total gap.** BUY (Aikido) |
| Secrets | TruffleHog pinned in CI | TruffleHog integrated | Dedicated + monitoring | Parity via same engine — layered, no work needed |
| DAST / runtime / cloud / containers | Nothing (out of scope) | Nothing | DAST, Zen runtime, CSPM, containers | **Total gap.** BUY (Aikido) |
| PR review UX (comments, fixes, learnings) | `/acp-review` agent-run, no PR UI | Core strength | — | **Large.** BUY (CodeRabbit) |
| Alert triage/noise | Carryover ledger (manual honesty) | Review profiles | AutoTriage −95% | BUY, then **ingest into our ledger** |
| **Lifecycle governance** (plan→pre-impl audit→implement→closure audit→carryover verification→memory) | **Core strength** — self-contained tasks, audit-carryovers with `verified_in_audit`, closure-honesty protocol (audit-088 lesson), guardrails | Issue Planner (nascent, Feb 2026) | — | **Gap runs the OTHER way.** This is what neither sells |
| **Agent-context integrity** (unicode injection / hidden instructions in CLAUDE.md, AGENTS.md, .cursor/rules, MCP configs; AI-code provenance manifest) | **Unique** — /acp-integrity + manifest-hash | Blind | Device Protection covers packages/extensions, NOT repo rule files | **We're ahead; both tools blind.** BUILD/deepen |
| Org knowledge feedback (lessons → standards) | lessons.md/patterns.md → protocol | Per-bot "learnings" | — | Ours is org-wide method. BUILD |
| Repo/docs consistency validation | acp-validate.ts 30+ checks | — | — | Ours alone; out of their scope |

**Bottom line**: on *detection*, the gap is enormous and permanently so — CodeRabbit and Aikido each embed engine ecosystems and threat-intel feeds that a solo-maintained bash/TS toolkit can never honestly replicate (audit-070's false-assurance finding is the internal proof). On *process governance and AI-agent supply chain*, ACP is ahead of both, and that's precisely what an internal engineering standard needs to own.

## 3. Answer: do we still need CodeRabbit + Aikido?

**Strategy unchanged: buy detection, build governance.** For the **current ACP Enhanced user base**:

- **CodeRabbit — yes** (free tier available): PR review + engines; integrate via **M81 / ADR-22**.
- **Aikido — deferred** (cost/complexity vs user base): SCA/CVE/runtime depth still valuable later; **not required** to ship CodeRabbit governance. ADR-19 remains the gate when Aikido is adopted.

Long-term ideal remains both tools; short-term is CodeRabbit-only without pretending Aikido is free.
## 4. How to NARROW the gap (integration, not reimplementation)

The gap that matters isn't detection — it's that today the commercial tools and ACP don't talk. Close that:

1. **Policy → tools**: The 64-rule `/acp-review` ruleset becomes a *policy map*, each rule assigned an owner: CodeRabbit engine / Aikido scanner / ACP script / manual. ACP patterns + lessons **generate `.coderabbit.yaml`** (path instructions + plain-English pre-merge checks) — org knowledge flows into every PR review automatically.
2. **Findings → ledger**: `acp.findings-import.sh` ingests Aikido/CodeRabbit findings into `audit-carryovers.md` (severity mapping, dedup) so ONE accountability loop exists, with closure-audit verification (`verified_in_audit`) applying to commercial findings too.
3. **Recurring tasks rewired**: `monthly-dependency-audit` → Aikido SCA ingest; `weekly-code-review` → CodeRabbit analytics + open-findings check.
4. **Golden path**: `acp.project-create`/bootstrap scaffolds every new startup repo with ACP + `.coderabbit.yaml` + Aikido CI + branch protection + pinned actions + SECURITY.md — *new repos are compliant by default*.
5. **Deepen the moat**: `/acp-integrity` focuses where both tools are blind — agent rule-file injection scanning, MCP config scanning, AI-code provenance. M58 Phase 2 is now unblocked (ADR-10 gate cleared) and aligns exactly here.

## 5. Recommended roadmap

| Milestone | Title | Deliverables | Est. | Status |
|---|---|---|---|---|
| **M78** | CodeRabbit optionality foundation | Pref toggle, detection, E2E, wiki | ~13h | ✅ shipped v6.28.0 (ADR-21) |
| **M81** | CodeRabbit integration (CodeRabbit-only) | ADR-22, policy map lite, findings-import `--input`, review wiring | ~20h | 📋 planned — fixture gate for 270–274 |
| **M74** (deferred) | Full policy spine + Aikido | Full 64-rule map; Aikido owner rows | ~8h | Gated ADR-19 until Aikido |
| **M75** (partial → M81) | Tool integration | Generator + dual import | — | CodeRabbit half → M81; Aikido half deferred |
| **M76** | Golden path | ACP + CR + Aikido scaffold | ~12h | Gated ADR-19 |
| **M77** | AI supply-chain moat | Rule-file/MCP injection hardening | ~20h | Gated ADR-19 |
| **cont.** | Quarterly overlap audit | Policy-map vs tool configs | 1h/qtr | After M81 |

**Next action for CodeRabbit consumers:** commit sanitized findings to `tests/fixtures/coderabbit-findings-sample.json`, then `/acp-proceed task-270`. **Do not** start with `/acp-plan M74` unless adopting Aikido.

MCP-server work from the previous research note is **deferred, not dead**.

## Sources

- CodeRabbit features/pricing 2026 — coderabbit.ai, max-productive.ai review, weavai.app reviews, vibecoding.app review
- Aikido platform/AutoTriage/Device Protection 2026 — aikido.dev/platform, appsecsanta.com review, thectoclub.com review
