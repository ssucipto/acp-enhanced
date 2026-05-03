# Milestone 23: ACP Enhanced Identity

**Status**: Completed  
**Priority**: 5  
**Milestone**: M23  
**Started**: 2026-05-01  
**Completed**: 2026-05-01  

## Overview

AGENT.md was distributed as original prmichaelsen/agent-context-protocol documentation.
This milestone rebrands it to ACP Enhanced, makes the fork relationship explicit, and adds
a comprehensive "What's New" section so new users immediately understand what they're
getting beyond the baseline.

## Tasks

| ID | Title | Status |
|----|-------|--------|
| task-129 | Update title, metadata, and overview | ✅ Completed |
| task-130 | Add ACP Enhanced — What's New section | ✅ Completed |
| task-131 | Rewrite Table of Contents (14 → 24 entries) | ✅ Completed |
| task-132 | Expand Core Commands list (6 → 40+ entries, 10 categories) | ✅ Completed |

## Success Criteria

- [x] Title reads "Agent Context Protocol Enhanced (ACP Enhanced)"
- [x] Fork-of and Maintained-by metadata present
- [x] "What's New" section covers all 15 ACP Enhanced enhancements
- [x] ToC includes all 24 body sections
- [x] Core Commands categorized and complete

## Changes Made

### task-129: Title, Metadata, Overview
- `# Agent Context Protocol (ACP)` → `# Agent Context Protocol Enhanced (ACP Enhanced)`
- Added: `**Fork of**: prmichaelsen/agent-context-protocol`
- Added: `**Maintained by**: ssucipto/acp-enhanced`
- Overview paragraph rewritten to introduce ACP Enhanced as a fork and extension
- "What is ACP?" → "What is ACP Enhanced?" (section rename + body update)
- "How to Use the Agent Pattern" → "How to Use ACP Enhanced" (section rename)

### task-130: ACP Enhanced — What's New Section
New section inserted after Overview, containing:
- 15-row table of all ACP Enhanced capabilities with milestone-tagged "Since" column
- "What the Original ACP Provides" subsection explaining the upstream baseline
- Backward compatibility statement

Enhancements documented:
1. Context Loading Protocol (`agent/` framework, 6-step deterministic protocol)
2. Package Management (50+ commands, 28 scripts, manifest, schema validation)
3. Preferences System (4-level hierarchy, configurables, presets, CLI overrides)
4. Project Registry (global `~/.acp/projects.yaml`, project switching)
5. Sessions System (multi-agent visibility via `~/.acp/sessions.yaml`)
6. Key File Index (`agent/index/`, weight-based loading, `@acp.init` integration)
7. Clarification Capture (`@acp.clarification-*`, deduplication, synthesis)
8. Design Reference System (`@acp.design-reference`, D-IDs, task cross-referencing)
9. Artifact Commands (research, glossary, reference — plan→execute→synthesize)
10. Metadata Markers (`@acp.meta.*` sentinels, R<N>/D<N> IDs, `@acp.sync`)
11. Specs System (`agent/specs/`, formal R<N> requirements, Spec Coverage in tasks)
12. Benchmark Suite (`agent/benchmarks/`, ACP vs baseline, LLM evaluator, HTML reports)
13. YAML Parser (pure-bash, AST, path expressions, zero dependencies)
14. Cross-platform CI (GitHub Actions, ubuntu+macos matrix)
15. Index Semantic Entry Types (`kind: note`, `kind: directive`, inline path-null entries)

### task-131: Table of Contents
Expanded from 14 entries to 24 entries. Missing sections added:
- ACP Enhanced — What's New (new)
- ACP Commands
- ACP Preferences System
- Global Package Discovery
- Project Registry System
- Sessions System
- Experimental Features
- Benchmark Suite
- Template Source Files
- Sample Prompts
- Conclusion (inline)

### task-132: Core Commands Expansion
Replaced 6-command flat list with 40+ commands in 10 categories:
- Workflow (7 commands)
- Planning (6 commands)
- Clarification (3 commands)
- Artifacts (3 commands)
- Package Management — ACP Enhanced (9 commands)
- Preferences — ACP Enhanced (4 commands)
- Project Registry — ACP Enhanced (7 commands)
- Sessions — ACP Enhanced (1 command)
- Key File Index — ACP Enhanced (1 command)
- Version & Sync (5 commands)

Each ACP Enhanced category is labeled *(ACP Enhanced)* to distinguish from baseline.
