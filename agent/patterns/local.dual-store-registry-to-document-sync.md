# Pattern: dual-store-registry-to-document-sync

<!-- @acp.meta.pattern
topic: pattern, dual-store-registry-to-document-sync
description: Pattern: dual-store-registry-to-document-sync
applies_to: testing, quality
status: active
updated: 2026-06-15
@acp.meta.end -->

**Date**: 2026-06-04
**Task Type**: architecture-design
**Code Ref**: agent/commands/acp.commit.md (steps 2b, 3b, 6b)

## Description

Dual-store architecture where a compact YAML registry (source of truth) is synced to human-readable markdown documents on every commit. Registry is optimized for diffing and version control; documents are optimized for agent and visualizer consumption. Sync is idempotent (skip unchanged, update changed) with an escape hatch (--no-sync). Repair tools provide bulk reconciliation. Pattern mirrors Git checkout (object store → working tree) and database checkpointing (WAL → data files).
