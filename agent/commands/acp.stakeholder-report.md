# Command: stakeholder-report

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-stakeholder-report` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-stakeholder-report` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.1.0  
**Created**: 2026-06-06  
**Last Updated**: 2026-06-06  
**Audit**: audit-071  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Generate a concise weekly or monthly stakeholder progress summary (RAG health, outcomes, decisions needed)  
**Category**: Documentation  
**Frequency**: Weekly (default) or monthly  

---

## Distinction From Other Commands

| Command | Output | Audience | Length |
|---------|--------|----------|--------|
| **`/acp-stakeholder-report`** | Executive progress summary | Board, investors, product owner | **1–2 pages** |
| [`/acp-report`](acp.report.md) | Full project status archive | Team, agents, project records | 5–15 pages |
| [`/acp-status`](acp.status.md) | Console snapshot | Developer (session) | ~20 lines |
| [`/acp-design-spec`](acp.design-spec.md) | Interface & data-flow spec | Engineering, QA | 10–30 pages |
| [`/acp-cost-report`](acp.cost-report.md) | AI token spend | Dev / ops | ~1 page |

**Rule**: Stakeholders get **outcomes and decisions**; `/acp-report` is the detail archive linked from the stakeholder report.

### Artefact naming (do not confuse)

| Pattern | Purpose | Example |
|---------|---------|---------|
| `stakeholder-report-YYYY-MM-DD.md` | **This command** — weekly/monthly exec summary | `stakeholder-report-2026-06-06.md` |
| `report-YYYY-MM-DD.md` | Full `/acp-report` archive | `report-2026-06-04.md` |
| `report-*-stakeholder-*.md` | **Roadmap / planning brief** (ad-hoc, not recurring) | `report-2026-05-30-stakeholder-m15-m16.md` |

**Prefer** `roadmap-brief-{subject}-{date}.md` for one-off planning docs to avoid collision with this command.

---

## Industry Standards Basis

Weekly stakeholder reports follow PMI, executive status, and ISO/IEC/IEEE 42010 **stakeholder viewpoint** practice:

| Element | Standard practice | Report section |
|---------|-------------------|----------------|
| RAG health indicator | Traffic light (Green / Amber / Red) | Header + Executive summary |
| Executive summary | 2–4 sentences, <300 words | § Executive summary |
| Accomplishments | Outcome bullets, not task IDs | § This period |
| Forward look | Next period focus (3–5 bullets) | § Next period |
| Risks & blockers | Honest + mitigation | § Blockers & risks |
| Decisions required | Actions from stakeholders | § Decisions & actions required |
| KPI snapshot | 2–4 metrics only | § Metrics at a glance |
| Detail on request | Link to full reports | § Detail available on request |
| Email subject line | `{Project}: {RAG} — {period}` (mobile scan) | Header `Suggested email subject` |
| Risk severity | High / Medium / Low on blockers | § Blockers & risks (optional column) |
| Schedule health | On track / at risk vs milestone % | § Metrics at a glance |

**Deliberately excluded**: full milestone tables, task inventories, audit counts, interface diagrams, ACP command stats, agent session jargon.

**Anti-patterns** (rewrite or omit in accomplishments):
- Task IDs (`task-177`, `CO-273`)
- ACP commands (`/acp-update`, `/acp-design-spec`)
- File paths and line counts unless audience is technical board
- ✅/❌ emoji task logs from `recent_work` — translate to outcomes

---

## Arguments

**CLI-Style Arguments**:
- `--period weekly|monthly` — Reporting window (default: `weekly`)
- `--since <YYYY-MM-DD>` — Window start (default: 7 or 30 days back, or day after last stakeholder report)
- `--audience executive|board|investor` — Tone (default: `executive`)
- `--rag green|amber|red` — Override auto RAG inference
- `--output <path>` or `-o <path>` — Custom output path
- `--no-delta` — Skip week-over-week comparison with prior stakeholder report

**Natural Language Arguments**:
- `/acp-stakeholder-report` — Weekly executive summary (default)
- `/acp-stakeholder-report monthly for board` — Monthly, board tone
- `/acp-stakeholder-report since 2026-06-01` — Custom window

---

## What This Command Does

Produces a **stakeholder-appropriate** progress summary optimised for email, Notion, or board packs. Reads `progress.yaml` and recent session work but **filters** to business outcomes — not agent operational detail.

Use every Friday EOD, before board meetings, or when investors/product owners need a <2-minute read.

---

## Prerequisites

- [ ] ACP installed (`agent/` exists)
- [ ] `agent/progress.yaml` exists and is current (run `/acp-update` first if stale)
- [ ] `agent/reports/` exists (create if needed)

---

## Steps

### 0. Display Command Header

```
⚡ /acp-stakeholder-report
  Generate concise stakeholder progress summary (weekly/monthly)

  Usage:
    /acp-stakeholder-report                    Weekly executive summary (default)
    /acp-stakeholder-report --period monthly Monthly board summary
    /acp-stakeholder-report --audience board  Board tone
    /acp-stakeholder-report --rag amber       Override health indicator
    /acp-stakeholder-report --since <date>    Custom window start
    /acp-stakeholder-report --no-delta        Skip week-over-week section
    /acp-stakeholder-report -o <path>         Custom output path

  Related:
    /acp-report           Full project status archive (link from stakeholder report)
    /acp-update           Refresh progress.yaml before reporting
    /acp-cost-report      Weekly AI spend (pair on Fridays)
    /acp-design-spec      Technical interface spec (not weekly progress)
```

This step is informational only — do not wait for user input.

### 1. Resolve Reporting Window & Freshness

**Actions**:
- Set `--period` (default `weekly` → 7 days; `monthly` → 30 days)
- Find latest `agent/reports/stakeholder-report-*.md` (ignore `report-*-stakeholder-*` roadmap briefs)
- If prior stakeholder report exists: `--since` = day after prior report end date
- Else: `--since` = today minus period length
- End date = today
- Check `progress.yaml` header `Last Updated:` — if older than period + 3 days, warn: run `/acp-update` first

**Expected Outcome**: `Period: {since} – {end}` for header; staleness noted if applicable

### 2. Load Project State

**Actions**:
- Read `agent/progress.yaml`: project name, version, status, current_milestone, current_task
- Read `recent_work` entries within window
- If `recent_work` sparse in window: supplement from last 3 `agent/memory/sessions.md` entries (`done:` / `key_fact` only)
- Read `next_steps` and `current_blockers`
- Read current milestone `progress` % and `status` from `milestones:` list
- **Do not** dump full task tables

**Expected Outcome**: Filtered facts for stakeholder narrative

### 3. Infer RAG Health (unless `--rag` override)

**Rules** (apply in order):

| Rule | RAG |
|------|-----|
| `current_blockers` non-empty **or** current milestone has human gate on critical path | **Minimum 🟡 Amber** |
| No blockers; milestone progressing; no missed committed dates | 🟢 **Green** |
| Human gate or external dependency; documented mitigation path | 🟡 **Amber** |
| Critical blocker with no mitigation, or committed release date missed | 🔴 **Red** |

**Actions**:
- Map `current_blockers` to table rows: Item | Severity | Impact | Mitigation | Owner
- Severity: High (blocks release), Medium (blocks feature), Low (tracked)
- One-sentence RAG rationale in header (not only exec summary)

**Expected Outcome**: Honest health indicator — **never Green when `current_blockers` is non-empty**

### 4. Write Executive Summary

**Actions**:
- 2–4 sentences maximum; **count words — hard limit 300**
- Lead with RAG and headline **product/business** outcome
- Name top risk or blocker
- **No task IDs** in this section (e.g. say "device QA sign-off" not "task-177")
- Adjust tone for `--audience`:
  - `executive` — outcomes, trajectory, asks
  - `board` — strategic milestones, risk register summary
  - `investor` — product velocity, release targets, market gates

**Expected Outcome**: § Executive summary ≤300 words

### 5. This Period — Accomplishments

**Actions**:
- Extract from `recent_work` / `sessions.md` in window
- Rewrite as **product or delivery outcome bullets** (max 5)
- Good: "Pay spine engineering complete; v2.0.1 ready for device QA"
- Bad: "✅ task-174 paytracker.test.tsx 12 tests"
- Bad: "ACP framework upgraded to 6.9.x" (process — omit unless `--audience board` and eng velocity is the topic)
- Translate agent logs: "Interface design documentation completed for QA handoff" not "/acp-design-spec command created"

**Expected Outcome**: § This period — accomplishments

### 6. Next Period — Focus

**Actions**:
- Derive from `next_steps` (max 5 bullets)
- Frame as stakeholder-visible outcomes
- Mark human-only items clearly: **HUMAN —** prefix

**Expected Outcome**: § Next period — focus

### 7. Blockers, Risks & Decisions

**Actions**:
- § Blockers & risks table: Item | Impact | Mitigation | Owner
- § Decisions & actions required: # | Decision needed | By when | From whom
- If blockers exist, decisions section must not be empty
- External deps (GCP, RevenueCat, legal) → owner = Product / HUMAN

**Expected Outcome**: Actionable tables for stakeholder meetings

### 8. Metrics at a Glance

**Actions**:
- Include **exactly 2–4 KPI rows** (hard limit — merge if needed), e.g.:
  - Current milestone + % + schedule (on track / at risk)
  - App version / release target
  - Key release gate (single row — combine staging + QA if both block)
  - Milestones complete (ratio) — optional 4th row only if additive
- Optional trend column: ↑ ↓ → vs prior stakeholder report (`--no-delta` skips)
- Do not add a 5th row — fold extras into narrative or full report link

**Expected Outcome**: § Metrics at a glance (≤4 rows)

### 9. Link to Detail

**Actions**:
- Link latest `/acp-report` if exists (`agent/reports/report-*.md`)
- Link design spec if milestone phase complete
- Link QA criteria doc if device gate active

**Expected Outcome**: § Detail available on request

### 10. Save Report

**Actions**:
- Filename: `agent/reports/stakeholder-report-YYYY-MM-DD.md`
- Follow **Report Structure** below
- Add **Suggested email subject**: `{PROJECT}: {🟢|🟡|🔴} {RAG label} — week ending {end date}`
- Footer: `Generated by: ACP /acp-stakeholder-report v1.1.0`

**Expected Outcome**: Report saved

### 11. Suggest Related Commands

**Actions**:
- If Friday or end of sprint: suggest `/acp-cost-report`
- If milestone just completed: suggest `/acp-report` for full archive
- Suggest `/acp-commit` if reporting closes a phase

**Expected Outcome**: User knows next steps

---

## Verification Checklist

- [ ] RAG indicator present; **not Green** when `current_blockers` non-empty
- [ ] RAG rationale one sentence in header
- [ ] Suggested email subject line present
- [ ] Executive summary ≤300 words, no task IDs
- [ ] ≤5 accomplishment bullets (product outcomes; no ACP jargon)
- [ ] ≤5 next-period bullets
- [ ] Blockers table populated when `current_blockers` non-empty (with Severity)
- [ ] Decisions section populated when blockers need stakeholder action
- [ ] Metrics **2–4 rows** (not 5+)
- [ ] Links to full `/acp-report` for detail
- [ ] Report ≤2 pages when rendered
- [ ] Saved to `agent/reports/stakeholder-report-*.md`

---

## Expected Output

### Files Created
- `agent/reports/stakeholder-report-YYYY-MM-DD.md`

### Console Output (example)

```
📊 Generating Stakeholder Progress Report

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Period: 2026-05-30 – 2026-06-06 (weekly)
Audience: executive
Health: 🟡 Amber

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Stakeholder Report Complete!

Saved to: agent/reports/stakeholder-report-2026-06-06.md

Pair with: /acp-report (full archive)
           /acp-cost-report (Friday AI spend)
```

---

## Report Structure (required template)

See `agent/templates/stakeholder-report.template.md` or:

```markdown
# {PROJECT} — Stakeholder Progress Report

**Period**: {start} – {end}
**Overall health**: 🟢 Green | 🟡 Amber | 🔴 Red
**RAG rationale**: {one sentence}
**Suggested email subject**: {PROJECT}: {RAG} — week ending {end}
**App version**: {version}
**Report type**: Weekly | Monthly stakeholder summary
**Audience**: executive | board | investor

## Executive summary
{2–4 sentences}

## This period — accomplishments
- {outcome bullet}

## Next period — focus
- {focus bullet}

## Blockers & risks
| Item | Severity | Impact | Mitigation | Owner |

## Decisions & actions required
| # | Decision needed | By when | From whom |

## Metrics at a glance
| Metric | Value | Trend |

## Changes since last report
{optional — omit with --no-delta}

## Detail available on request
- Full project status: agent/reports/report-{date}.md
```

---

## Examples

### Example 1: Friday weekly (default)

**Invocation**: `/acp-stakeholder-report`

**Result**: 1-page Amber report; staging gate and device QA called out; links to full report

### Example 2: Monthly board pack

**Invocation**: `/acp-stakeholder-report --period monthly --audience board`

**Result**: Slightly broader milestone trajectory; same brevity rules

### Example 3: After milestone complete

**Invocation**: `/acp-stakeholder-report --rag green`

**Result**: Green RAG with release announcement; links to design spec and full report

---

## Related Commands

- [`/acp-report`](acp.report.md) — Full project status archive (detail layer)
- [`/acp-update`](acp.update.md) — Refresh progress before reporting
- [`/acp-cost-report`](acp.cost-report.md) — Weekly AI token spend
- [`/acp-design-spec`](acp.design-spec.md) — Interface spec (not progress)
- [`/acp-commit`](acp.commit.md) — Session memory after reporting phase
- [`/acp-review`](acp.review.md) — Code quality & security review — include review health in stakeholder summary

---

## Troubleshooting

### Issue 1: Report too long

**Cause**: Copied full milestone tables from progress.yaml  
**Solution**: Outcomes only; link to `/acp-report` for tables

### Issue 2: All-green RAG with open blockers

**Cause**: Ignored `current_blockers`  
**Solution**: Re-run; apply RAG inference rules honestly

### Issue 3: Stakeholders ask for task-level detail

**Cause**: Wrong report type sent  
**Solution**: Send `/acp-report` or milestone roadmap brief; keep stakeholder report weekly

### Issue 4: Confused with roadmap brief filename

**Cause**: `report-2026-05-30-stakeholder-m15-m16.md` looks like this command's output  
**Solution**: Use `stakeholder-report-*.md` for weekly exec; rename one-off briefs to `roadmap-brief-*.md`

### Issue 5: Metrics table has 5+ rows

**Cause**: Too many KPIs copied from full report  
**Solution**: Merge gates into one row; max 4 metrics per verification checklist

---

## Security Considerations

### File Access
- **Reads**: `agent/progress.yaml`, last 3 `agent/memory/sessions.md` entries (optional), prior `stakeholder-report-*.md`, latest `report-*.md` (for links)
- **Writes**: `agent/reports/stakeholder-report-*.md`
- **Executes**: None

### Sensitive Data
- Do not include secrets, credentials, or internal cost figures unless audience-appropriate

---

## Upstream Integration Notes (ACP Enhanced maintainers)

When promoting to framework distribution:

1. Add `acp.stakeholder-report.md` to command package
2. Add `agent/templates/stakeholder-report.template.md`
3. Add `.cursor/commands` + `.opencode/commands` wrappers
4. Update `acp.report.md` Related Commands (Phase B)
5. Add `command_suggestions` in `routing.yml`
6. E2E smoke test in `e2e/`
7. Optional Visualizer: stakeholder report card / email export preset

---

## Notes

- **Cadence**: Same day each week (e.g. Friday EOD) builds stakeholder trust
- **Honesty**: Amber is preferable to false Green when human gates exist
- **FIFOZ exemplar**: `agent/reports/stakeholder-report-2026-06-06.md` (v1.1.0 conformant)
- **Audit**: audit-071 (v1.0.0 → v1.1.0)

---

**Namespace**: acp  
**Command**: stakeholder-report  
**Version**: 1.1.0  
**Created**: 2026-06-06  
**Last Updated**: 2026-06-06  
**Status**: Active  
**Compatibility**: ACP 6.9.0+  
**Author**: FIFOZ field contribution → ACP Enhanced
