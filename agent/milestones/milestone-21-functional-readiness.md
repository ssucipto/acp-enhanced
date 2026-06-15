# Milestone 21: Functional Readiness Audit

**Status**: Completed  
**Priority**: High  
**Created**: 2026-05-01  
**Milestone ID**: M21  
**Scope**: Phase 3 audit — functionality and new-project readiness  

---

## Overview

Third comprehensive audit of the ACP Enhanced project focusing on:
1. Whether a user can successfully onboard to a new project
2. Whether command directive headers are complete and functional (LLM-readable)
3. Whether package.yaml is fully consistent with what's on disk
4. Whether version numbers are in sync across all metadata files

Found 5 bug categories. All are blocking for a smooth new-project experience.

---

## Findings Summary

| ID | Severity | Category | Count | Description |
|----|----------|----------|-------|-------------|
| BUG-A | Critical | Command directive headers | 8 files | `@{namespace}-{command-name}` template placeholder never replaced with actual command name |
| BUG-B | Critical | Onboarding | 1 line | README.md bootstrap curl URL uses `main` branch — 404s since branch is `mainline` |
| BUG-C | High | Version consistency | 3 files | package.yaml, AGENT.md, identity.yml still show v6.2.1; M20 bumped to v6.2.2 |
| BUG-D | Medium | package.yaml completeness | 7 entries | 5 project registry scripts + 2 utility scripts exist on disk but missing from package.yaml scripts section |
| BUG-E | Low | CHANGELOG | 1 entry | No `[6.2.2]` release block — M20 changes have no changelog entry |

---

## Tasks

- [ ] task-76 — Fix 8 unfilled template placeholders in pretend-context lines
- [ ] task-77 — Fix README.md curl URL `main` → `mainline`
- [ ] task-78 — Bump version to 6.2.2 in package.yaml, AGENT.md, identity.yml
- [ ] task-79 — Add 7 missing scripts to package.yaml scripts section
- [ ] task-80 — Add CHANGELOG [6.2.2] block for M20 fixes

---

## Acceptance Criteria

- [ ] All 8 command files have correct command name in pretend-context line (not `@{namespace}-{command-name}`)
- [ ] `curl | bash` bootstrap in README.md works (mainline branch)
- [ ] `package.yaml`, `AGENT.md`, `agent/core/identity.yml` all read `6.2.2`
- [ ] All scripts that exist in `agent/scripts/` are listed in `package.yaml` scripts section
- [ ] `CHANGELOG.md` has a `## [6.2.2]` block documenting M20 fixes
