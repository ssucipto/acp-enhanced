# Command: audit

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-audit` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-audit` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.1.0  
**Created**: 2026-03-15  
**Last Updated**: 2026-05-11  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Deep-dive investigation of a subject, producing a structured report in `agent/reports/`  
**Category**: Workflow  
**Frequency**: As Needed  

---

## Arguments

**CLI-Style Arguments**:
- `<subject>` (positional) - The subject to audit (topic, path, keyword, or description)
- `--output <path>` or `-o <path>` - Custom report output path (default: `agent/reports/`)
- `--pre-impl` - Pre-implementation readiness mode (see Step 3b)

**Natural Language Arguments**:
- `/acp-audit the install system` - Audit a named subject
- `/acp-audit src/auth/` - Audit a directory
- `/acp-audit everything related to sessions` - Audit by description
- `/acp-audit` - Infer subject from current context
- `/acp-audit --pre-impl route-022` - Pre-implementation audit of route-022 before starting work

**Argument Mapping**:
The agent infers intent from context:
1. If an explicit subject or path follows the command → audit that
2. If natural language describes a topic → derive subject from description
3. If no arguments → infer from current task, milestone, or recent conversation context
4. If still ambiguous → ask the user
5. If `--pre-impl` present → execute general audit AND Step 3b before generating report

---

## What This Command Does

This command performs a directed, deep investigation of a specific subject and produces a persistent, structured report. The subject can be anything — a feature area, a directory, a codebase pattern, a set of milestones, a refactoring target, or any topic that requires comprehensive understanding.

Unlike `/acp-init` (broad context loading) or `/acp-status` (quick snapshot), `/acp-audit` goes narrow and deep. It reads, analyzes, and cross-references everything relevant to the subject, then captures findings efficiently in a report with tables, code pointers, and key decisions.

Use this when you need a thorough understanding of a subject before acting — refactors, status reports, pattern alignment, scope analysis, or any situation where you need to see the full picture before making decisions.

---

## Prerequisites

- [ ] ACP installed in current directory (`agent/` directory exists)
- [ ] `agent/reports/` directory exists (create if not)

---

## Steps

### 0. Display Command Header

```
⚡ /acp-audit
  Deep-dive investigation of a subject, producing a structured report

  Usage:
    /acp-audit                     Infer subject from context
    /acp-audit <subject>           Audit a named subject or path
    /acp-audit --output <path>     Custom report output path
    /acp-audit --pre-impl <route>  Pre-implementation readiness check (adds Step 3b)

  Related:
    /acp-init      Broad context loading (not deep dives)
    /acp-status    Quick status snapshot
    /acp-validate  Schema and consistency validation
```

This step is informational only — do not wait for user input.

### 1. Parse Subject

Determine what to audit from the user's invocation.

**Actions**:
- Parse CLI arguments and natural language for the audit subject
- If no subject provided, infer from current conversation context (active task, recent discussion, open files)
- If still unclear, ask the user: "What would you like to audit?"

**Expected Outcome**: A clear subject string identified (e.g., "sessions", "src/auth/", "package install system")  

### 2. Determine Next Report Number

Find the next available audit report number.

**Actions**:
- List existing files in `agent/reports/` matching `audit-*`
- Parse the highest number
- Increment by 1

**Expected Outcome**: Next report number determined (e.g., 1 if no prior audits)  

### 3. Investigate

Perform the deep dive. The agent uses judgment on scope and depth based on the subject and user instructions.

**Actions**:
- Search the project for everything related to the subject (grep, glob, file reads)
- Include git history analysis — recent commits touching the subject, timeline of changes
- Read discovered files to understand their relationship to the subject
- Note code pointers (file:line references) for key locations
- Capture key decisions found in designs, clarifications, or code comments
- Identify open questions or ambiguities

**Guidance**:
- Cast the net as wide or narrow as the user's instructions imply
- Use judgment on which files to read in full vs. summarize
- Use judgment on whether to note specific functions/line ranges
- Do NOT check for inconsistencies between entities (that's `/acp-validate`)
- The goal is understanding, not validation

**Expected Outcome**: Comprehensive understanding of the subject across the project  

### 3b. Pre-Implementation Readiness Protocol (--pre-impl only)

This step runs ONLY when the `--pre-impl` flag is passed. It extends the investigation with a structured readiness check before implementation begins. Skip this step entirely for standard audits.

**Purpose**: Catch implementation gaps that are invisible in planning but cause bugs or rework once coding starts — wrong field names, missing imports, mismatched API shapes, stale carryovers.

**Actions**:

**Phase 1 — Plan Correctness**
- Verify the route/task file exists and acceptance criteria are unambiguous
- Confirm `files_affected` list is complete and all listed files exist (or will be created)
- Check for any open questions or deferred decisions that would block implementation

**Phase 2 — Code Cross-Reference** (key phase — do not skip)
For each file listed in `files_affected`, read the actual file and verify:
- Field names match exactly (no assumption — read the actual schema or model)
- Enum/constant values are valid members of the actual definition
- Import paths and file references exist in the codebase
- HTTP methods, route paths, and response shapes match the actual implementation
- Any content being added does not conflict with existing content in the file

**Phase 3 — Carryover Check**
Read the `carryovers:` list from `agent/memory/audit-carryovers.md` (if the file exists):
- If file does not exist → skip silently
- If `carryovers: []` or all entries are `status: fixed` → note "No open carryovers"
- If any entries have `status: pending` → surface them as blocking items in the report

**Phase 4 — Operational Completeness**
- Confirm the task has a corresponding route file if required by convention
- Confirm version bump and CHANGELOG entry are planned if this task completes a milestone
- Confirm wiki/docs updates are planned if the task introduces a new protocol concept

**Report additions** (append to standard report when `--pre-impl` was used):

```markdown
## Pre-Implementation Readiness ({subject})

**Mode**: --pre-impl  

### Phase 1 — Plan Correctness
| Check | Result | Notes |
|-------|--------|-------|
| Route/task file complete | ✅ / ⚠️ / ❌ | {note} |
| files_affected accurate | ✅ / ⚠️ / ❌ | {note} |
| Open blockers | ✅ None / ❌ {list} | |

### Phase 2 — Code Cross-Reference
| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| {path} | {what was verified} | ✅ / ❌ | {note} |

### Phase 3 — Carryover Check
| Carryover | Severity | Status | Blocks? |
|-----------|----------|--------|---------|
| {finding_id}: {finding} | {severity} | pending | Yes / No |

### Phase 4 — Operational Completeness
| Check | Result | Notes |
|-------|--------|-------|
| Route file exists | ✅ / ❌ | {note} |
| Version bump planned | ✅ / N/A | {note} |
| Wiki update planned | ✅ / N/A | {note} |

### Phase Summary
| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | {N} | {critical/high/medium/low/none} |
| Phase 2 — Code Cross-Reference | {N} | {critical/high/medium/low/none} |
| Phase 3 — Carryover Check | {N} | {critical/high/medium/low/none} |
| Phase 4 — Operational Completeness | {N} | {critical/high/medium/low/none} |
| **Total** | **{N}** | |

### Readiness Verdict
**READY** / **BLOCKED** — {one-sentence summary}
```

**Expected Outcome**: Implementation gaps and stale carryovers identified before any code is written

### 4. Generate Report

Create a structured report capturing findings efficiently.

**Actions**:
- Create `agent/reports/audit-{N}-{subject-slug}.md`
- Subject slug: kebab-case, derived from subject (e.g., "package install system" → "package-install-system")
- Use tables and structured data over prose
- Use `file_path:line_number` format for code pointers (IDE-clickable)

**Report structure** (adapt sections based on what the investigation found — not all sections required):

```markdown
# Audit Report: {subject}

**Audit**: #{N}  
**Date**: {date}  
**Subject**: {subject description}  

## Summary

{1-2 paragraphs: what was investigated, key takeaways}

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| path/to/file | source/doc/config/test | brief note |

## Key Findings

| Finding | Location | Notes |
|---------|----------|-------|
| {finding} | file:line | {context} |

## Key Decisions

- {decision found in design docs, clarifications, or code}

## Code Pointers

| Location | Description |
|----------|-------------|
| file:line | {what this code does relevant to subject} |

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| {date} | {short hash} | {message} |

## Recommendations

1. {recommendation}
```

**Expected Outcome**: Report file created with structured findings  

**Carryover write** (ALL modes — standard and --pre-impl):
After the report is created, check if any findings are actionable and unresolved:
- For each finding that requires a follow-up fix in a future session:
  - Append an entry to the `carryovers:` list in `agent/memory/audit-carryovers.md`
  - Set `status: pending`, `fix_applied_date: null`, `verified_in_audit: null`
  - If `agent/memory/audit-carryovers.md` does not exist, create it using the schema at the top of this command's Steps section as a guide
- If all findings are informational only (no action required) → skip this write silently

**Expected Outcome**: Actionable unresolved findings written to audit-carryovers.md for future session pickup

### 5. Report Success

Display what was produced.

**Output**:
```
Audit Complete!

Report: agent/reports/audit-{N}-{subject-slug}.md
Subject: {subject}
Files analyzed: {count}
Findings: {count}
Code pointers: {count}

Next steps:
- Review the audit report
- Use findings to inform your next action
```

**Expected Outcome**: User knows audit is complete and where to find the report  

---

## Verification

- [ ] Subject identified (explicit or inferred)
- [ ] Investigation covered relevant files across the project
- [ ] Report created in `agent/reports/audit-{N}-{subject-slug}.md`
- [ ] Report uses tables and structured data, not walls of prose
- [ ] Code pointers use `file:line` format
- [ ] Git history included where relevant
- [ ] If `--pre-impl`: Steps 3b phases completed and readiness verdict included in report
- [ ] Actionable unresolved findings appended to `agent/memory/audit-carryovers.md` (or skipped if all informational)
- [ ] No files modified other than the new report (and audit-carryovers.md if findings written)

---

## Expected Output

### Files Created
- `agent/reports/audit-{N}-{subject-slug}.md` - Audit report

### Files Modified
- `agent/memory/audit-carryovers.md` (appended, if actionable findings exist)

### Console Output
```
Audit Complete!

Report: agent/reports/audit-1-sessions-system.md
Subject: sessions system
Files analyzed: 12
Findings: 8
Code pointers: 15
```

---

## Examples

### Example 1: Audit a Feature Area

**Context**: Need to understand the sessions system before making changes  

**Invocation**: `/acp-audit sessions`  

**Result**: Agent searches for "sessions" across the project, reads the design doc, milestone, tasks, shell script, command file, progress.yaml entries. Produces `agent/reports/audit-1-sessions-system.md` with tables of files, findings, and code pointers.  

### Example 2: Audit a Directory

**Context**: Need to understand what's in src/auth/ before a refactor  

**Invocation**: `/acp-audit src/auth/`  

**Result**: Agent reads all files in src/auth/, traces imports and references from other parts of the codebase, checks git history for recent changes. Produces a report with file inventory, key code pointers, and recommendations.  

### Example 3: Audit from Context

**Context**: Currently working on task-37 (Preference Loading Infrastructure), want to understand the full scope  

**Invocation**: `/acp-audit`  

**Result**: Agent infers "preferences system" from current task context, investigates the design doc, all 8 planned tasks, related clarifications, and any existing code. Produces a report capturing the full scope.  

### Example 4: Audit with Natural Language

**Context**: Need to understand how package installation works end-to-end  

**Invocation**: `/acp-audit everything related to how packages get installed`  

**Result**: Agent searches for install-related code, reads acp.install.sh, package management design, related commands and tasks. Produces a comprehensive report.  

---

## Related Commands

- [`/acp-init`](acp.init.md) - Broad context loading (use for session start, not deep dives)
- [`/acp-status`](acp.status.md) - Quick status snapshot (use for "where are we?", not "what is X?")
- [`/acp-validate`](acp.validate.md) - Schema and consistency validation (use for correctness checks, not investigation)
- [`/acp-review`](acp.review.md) - Standards enforcement — code quality, security, OWASP (use when audit finds a pattern needing systematic check)
- [`/acp-integrity`](acp.integrity.md) - Code trustworthiness & provenance verification (use when audit finds suspicious or foreign code)

---

## Troubleshooting

### Issue 1: Subject too broad

**Symptom**: Investigation returns hundreds of files, report is unwieldy  

**Cause**: Subject like "." or "everything" matches too much  

**Solution**: Narrow the subject. Use a more specific topic or path.  

### Issue 2: No results found

**Symptom**: Investigation finds nothing related to the subject  

**Cause**: Subject doesn't match any files or content in the project  

**Solution**: Try different keywords, check spelling, or provide a path instead of a topic.  

---

## Security Considerations

### File Access
- **Reads**: Any file in the project (scoped by subject relevance)
- **Writes**: `agent/reports/audit-{N}-{subject-slug}.md` only
- **Executes**: `git log` for history analysis

### Network Access
- **APIs**: None
- **Repositories**: Local git only (no remote operations)

### Sensitive Data
- **Secrets**: Never include secrets or credentials in audit reports
- **Credentials**: If audit discovers credential files, note their existence but do not include contents

---

## Key Design Decisions

### Scope

| Decision | Choice | Rationale |
|---|---|---|
| Audit target | Any subject (agent/, src/, ., anything) | Designed for ACP consumers, not ACP itself — must work on any project content |
| Use case | General-purpose (refactors, status, alignment, etc.) | Not limited to impact analysis — any situation requiring deep understanding |
| Investigation scope | Inferred from user instructions | Agent uses judgment; no hardcoded entity types or directories |

### Output

| Decision | Choice | Rationale |
|---|---|---|
| Output mode | Read-only, report to file | Audit investigates and reports; does not modify project files |
| Report location | `agent/reports/audit-{N}-{subject}.md` | Sequence-numbered, not date-based, with subject in filename |
| Report format | Tables and structured data over prose | Draft spec emphasized efficiency; tables are scannable and dense |

### Boundaries

| Decision | Choice | Rationale |
|---|---|---|
| Consistency checking | Not in scope | That's `/acp-validate`'s job — audit is for understanding, not validation |
| Git history | Included | Useful context for understanding a subject's evolution |
| Distinction from init/status | Narrow/deep vs. broad/shallow vs. snapshot | Each command has a distinct purpose; audit's differentiator is depth + persistent report |

---

## Notes

- The agent uses judgment throughout — depth, file reading, code pointer granularity are all context-dependent
- Reports are meant to be efficient and scannable, not exhaustive prose
- Audit reports are standalone files — they are not tracked in progress.yaml
- The `agent/reports/` directory may contain other report types; audit reports are prefixed with `audit-`
- This is a read-only command — it never modifies existing project files

---

---

## Changelog

### v1.1.0 — 2026-05-11
- Added `--pre-impl` flag: pre-implementation readiness mode (Step 3b)
  - Phase 1: Plan Correctness — route/task file, files_affected, open blockers
  - Phase 2: Code Cross-Reference — verify field names, enums, imports, HTTP methods against actual codebase
  - Phase 3: Carryover Check — reads `agent/memory/audit-carryovers.md` carryovers list
  - Phase 4: Operational Completeness — version bump, wiki update, route file checks
  - Report extended with `## Pre-Implementation Readiness` section and readiness verdict
- Added carryover write step (Step 4, all modes): actionable findings appended to `agent/memory/audit-carryovers.md`
- Updated Verification checklist and Expected Output to reflect audit-carryovers.md writes

### v1.0.0 — 2026-03-15
- Initial release

---

**Namespace**: acp  
**Command**: audit  
**Version**: 1.1.0  
**Created**: 2026-03-15  
**Last Updated**: 2026-03-15  
**Status**: Active  
**Compatibility**: ACP 5.21.0+  
**Author**: ACP Project  
