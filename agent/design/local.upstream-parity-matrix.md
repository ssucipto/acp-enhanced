# Upstream Feature Parity Matrix — ACP Enhanced vs upstream v7.2.1

<!--
@acp.meta.design
topic: upstream-parity-matrix
description: Feature parity analysis of ACP Enhanced vs upstream prmichaelsen/agent-context-protocol v7.2.1
status: active
updated: 2026-05-05
@acp.meta.end
-->

**ACP Enhanced version**: 6.3.0  
**Upstream version**: 7.2.1 (`prmichaelsen/agent-context-protocol`, branch `mainline`)  
**Comparison date**: 2026-05-05  
**Purpose**: Decision record for all upstream features — HAVE, PARTIAL, DIVERGED, PORT, or DEFER.

---

## Decision Key

| Decision | Meaning |
|----------|---------|
| **HAVE** | Local has the feature substantially equivalent to upstream. No action needed. |
| **PARTIAL** | Local has a subset of the feature. Gap is documented in the Notes column. |
| **DIVERGED** | Local has the feature but has intentionally extended or changed it beyond upstream. Supersedes upstream. |
| **PORT** | Upstream feature not in local. Should be ported. |
| **DEFER** | Upstream feature not in local. Decision: do not port now. Reason documented. |
| **LOCAL-ONLY** | ACP Enhanced extension with no upstream equivalent. Documents the divergence. |

---

## 1. Commands

### 1a. Commands — Shared (both upstream and local)

| Upstream Command | Local Command | Decision | Notes |
|-----------------|---------------|----------|-------|
| `acp.artifact-glossary.md` | `agent/commands/acp.artifact-glossary.md` | **HAVE** | — |
| `acp.artifact-reference.md` | `agent/commands/acp.artifact-reference.md` | **HAVE** | — |
| `acp.artifact-research.md` | `agent/commands/acp.artifact-research.md` | **HAVE** | — |
| `acp.audit.md` | `agent/commands/acp.audit.md` | **HAVE** | General-purpose deep-dive investigation command, introduced upstream v5.22.0. Local has it. |
| `acp.clarification-address.md` | `agent/commands/acp.clarification-address.md` | **HAVE** | — |
| `acp.clarification-capture.md` | `agent/commands/acp.clarification-capture.md` | **HAVE** | — |
| `acp.clarification-create.md` | `agent/commands/acp.clarification-create.md` | **PARTIAL** | Local missing: `marker.mint` Driver Dispatch directive in stamping step (M19, v6.3.0+). Low priority — only relevant when `agent/driver.yaml` is present. |
| `acp.command-create.md` | `agent/commands/acp.command-create.md` | **HAVE** | Upstream skipped `marker.mint` wiring for this command (no `@acp.meta.command` stamp step). Local matches. |
| `acp.design-create.md` | `agent/commands/acp.design-create.md` | **PARTIAL** | Local missing: `marker.mint` Driver Dispatch directive in Step 5 (M19, v6.3.0+). Low priority — driver-only path. |
| `acp.design-reference.md` | `agent/commands/acp.design-reference.md` | **HAVE** | M16 Design Reference System. |
| `acp.handoff.md` | `agent/commands/acp.handoff.md` | **HAVE** | — |
| `acp.index.md` | `agent/commands/acp.index.md` | **HAVE** | M14 Key File Index management. |
| `acp.init.md` | `agent/commands/acp.init.md` | **PARTIAL** | Local missing: Workflow Override Directive (top-of-file `🔌 Driver Override Check`, M19 v1 pilot, v6.1.0+). Low priority — driver-only path. |
| `acp.package-create.md` | `agent/commands/acp.package-create.md` | **HAVE** | — |
| `acp.package-info.md` | `agent/commands/acp.package-info.md` | **HAVE** | — |
| `acp.package-install.md` | `agent/commands/acp.package-install.md` | **HAVE** | — |
| `acp.package-list.md` | `agent/commands/acp.package-list.md` | **HAVE** | — |
| `acp.package-publish.md` | `agent/commands/acp.package-publish.md` | **HAVE** | — |
| `acp.package-remove.md` | `agent/commands/acp.package-remove.md` | **HAVE** | — |
| `acp.package-search.md` | `agent/commands/acp.package-search.md` | **HAVE** | — |
| `acp.package-update.md` | `agent/commands/acp.package-update.md` | **HAVE** | — |
| `acp.package-validate.md` | `agent/commands/acp.package-validate.md` | **HAVE** | — |
| `acp.pattern-create.md` | `agent/commands/acp.pattern-create.md` | **PARTIAL** | Local missing: `marker.mint` Driver Dispatch directive in Step 5 (M19, v6.3.0+). Low priority — driver-only path. |
| `acp.plan.md` | `agent/commands/acp.plan.md` | **PARTIAL** | Local missing: Workflow Override Directive (M19 v1 pilot, v6.1.0+). Low priority — driver-only path. |
| `acp.proceed.md` | `agent/commands/acp.proceed.md` | **DIVERGED** | Local has all upstream features through v5.34.0 (`--stacked` mode, Step 3.5 full drift remediation). Local intentionally extended: triple-file architecture context, ACP Enhanced–specific ACP core loading protocol. **Local missing (deferred)**: `query.run` Driver Dispatch in Step 1 and Step A1 (M19, v6.3.0+); `capabilities.watcher` check (M19); Workflow Override Directive (M19 v1 pilot). All driver-only paths. |
| `acp.project-create.md` | `agent/commands/acp.project-create.md` | **HAVE** | — |
| `acp.project-info.md` | `agent/commands/acp.project-info.md` | **HAVE** | — |
| `acp.project-list.md` | `agent/commands/acp.project-list.md` | **HAVE** | — |
| `acp.project-remove.md` | `agent/commands/acp.project-remove.md` | **HAVE** | — |
| `acp.project-set.md` | `agent/commands/acp.project-set.md` | **HAVE** | — |
| `acp.project-update.md` | `agent/commands/acp.project-update.md` | **HAVE** | — |
| `acp.projects-restore.md` | `agent/commands/acp.projects-restore.md` | **HAVE** | — |
| `acp.projects-sync.md` | `agent/commands/acp.projects-sync.md` | **HAVE** | — |
| `acp.report.md` | `agent/commands/acp.report.md` | **HAVE** | Includes session deregistration on close. |
| `acp.resume.md` | `agent/commands/acp.resume.md` | **HAVE** | — |
| `acp.sessions.md` | `agent/commands/acp.sessions.md` | **DIVERGED** | Upstream uses `~/.acp/sessions.yaml` exclusively (M12). ACP Enhanced additionally uses `agent/memory/sessions.md` as an in-repo persistent session log. Upstream shell-based session tracking is HAVE; in-repo sessions log is LOCAL-ONLY extension. |
| `acp.spec.md` | `agent/commands/acp.spec.md` | **PARTIAL** | Local missing: `marker.mint` Driver Dispatch directive in stamping step (M19, v6.3.0+). Low priority — driver-only path. |
| `acp.status.md` | `agent/commands/acp.status.md` | **HAVE** | — |
| `acp.sync.md` | `agent/commands/acp.sync.md` | **PARTIAL** | Local has `acp.meta-scan.sh` invocation in Step 1.3 (HAVE). Local missing: `query.run` Driver Dispatch wrapping the meta-scan call (M19, v5.42.0+); `capabilities.watcher` check (M19); D-ID backfill Pass C in Step 1.4 (v5.41.0). |
| `acp.task-create.md` | `agent/commands/acp.task-create.md` | **PARTIAL** | Local missing: `marker.mint` Driver Dispatch directive (M19, v6.3.0+); Workflow Override Directive (M19 v1 pilot); fully-qualified `spec.<id>~<uuid>#FR-N` / `design.<id>~<uuid>#DR-N` reference format documentation in DR/FR sections (v7.1.0). |
| `acp.update.md` | `agent/commands/acp.update.md` | **HAVE** | — |
| `acp.validate.md` | `agent/commands/acp.validate.md` | **PARTIAL** | Local has Probes 1-3 (spec, design, clarification inlining) and Steps 1–11 (HAVE). Local missing: Step 11.5 Driver Bindings validation (4 DR6 rules: tool resolution, single MCP server, mint/query pairing, reachability) — M19, v6.2.0+. Driver-only path; only activates when `agent/driver.yaml` is present. |
| `acp.version-check.md` | `agent/commands/acp.version-check.md` | **HAVE** | — |
| `acp.version-check-for-updates.md` | `agent/commands/acp.version-check-for-updates.md` | **HAVE** | — |
| `acp.version-update.md` | `agent/commands/acp.version-update.md` | **HAVE** | — |
| `command.template.md` | `agent/commands/command.template.md` | **HAVE** | — |
| `git.commit.md` | `agent/commands/git.commit.md` | **HAVE** | — |
| `git.init.md` | `agent/commands/git.init.md` | **HAVE** | — |

### 1b. Commands — Local-Only (ACP Enhanced extensions)

| Local Command | Decision | Purpose |
|---------------|----------|---------|
| `agent/commands/acp.commit.md` | **LOCAL-ONLY** | ACP Enhanced commit convenience wrapper. |
| `agent/commands/acp.cost-report.md` | **LOCAL-ONLY** | Cost analysis report command. |
| `agent/commands/acp.decide.md` | **LOCAL-ONLY** | `/acp-decide` equivalent for ADR capture. Not upstream — ACP Enhanced routing protocol command. |
| `agent/commands/acp.memory-sync.md` | **LOCAL-ONLY** | Syncs in-repo `agent/memory/` files. Part of ACP Enhanced's in-repo memory system. |
| `agent/commands/acp.preferences-create.md` | **LOCAL-ONLY** | ACP Enhanced preferences system (M6 local implementation). Upstream M6 implemented differently. |
| `agent/commands/acp.preferences-get.md` | **LOCAL-ONLY** | ACP Enhanced preferences system. |
| `agent/commands/acp.preferences-set.md` | **LOCAL-ONLY** | ACP Enhanced preferences system. |
| `agent/commands/acp.preferences-show.md` | **LOCAL-ONLY** | ACP Enhanced preferences system. |
| `agent/commands/acp.preferences-validate.md` | **LOCAL-ONLY** | ACP Enhanced preferences system. |
| `agent/commands/acp.route.md` | **LOCAL-ONLY** | `/acp-route` equivalent — ACP Enhanced task routing command. No upstream equivalent. |
| `agent/commands/acp.wiki-update.md` | **LOCAL-ONLY** | Updates `agent/wiki/` domain files. No upstream equivalent. |

---

## 2. Scripts

### 2a. Scripts — Shared

| Upstream Script | Local Script | Decision | Notes |
|----------------|--------------|----------|-------|
| `acp.common.sh` | `agent/scripts/acp.common.sh` | **HAVE** | — |
| `acp.install.sh` | `agent/scripts/acp.install.sh` | **HAVE** | — |
| `acp.meta-scan.sh` | `agent/scripts/acp.meta-scan.sh` | **PARTIAL** | Local missing: `--exclude-dir=drivers` flag added in upstream v7.1.0 (prevents scanner from recursing into driver-managed state). Not applicable until `agent/drivers/` exists locally, but should be added when porting driver system. |
| `acp.package-create.sh` | `agent/scripts/acp.package-create.sh` | **HAVE** | — |
| `acp.package-info.sh` | `agent/scripts/acp.package-info.sh` | **HAVE** | — |
| `acp.package-install.sh` | `agent/scripts/acp.package-install.sh` | **HAVE** | — |
| `acp.package-install-optimized.sh` | `agent/scripts/acp.package-install-optimized.sh` | **LOCAL-ONLY** | ACP Enhanced performance optimization. |
| `acp.package-list.sh` | `agent/scripts/acp.package-list.sh` | **HAVE** | — |
| `acp.package-publish.sh` | `agent/scripts/acp.package-publish.sh` | **HAVE** | — |
| `acp.package-remove.sh` | `agent/scripts/acp.package-remove.sh` | **HAVE** | — |
| `acp.package-search.sh` | `agent/scripts/acp.package-search.sh` | **HAVE** | — |
| `acp.package-update.sh` | `agent/scripts/acp.package-update.sh` | **HAVE** | — |
| `acp.package-validate.sh` | `agent/scripts/acp.package-validate.sh` | **HAVE** | — |
| `acp.project-info.sh` | `agent/scripts/acp.project-info.sh` | **HAVE** | — |
| `acp.project-list.sh` | `agent/scripts/acp.project-list.sh` | **HAVE** | — |
| `acp.project-remove.sh` | `agent/scripts/acp.project-remove.sh` | **HAVE** | — |
| `acp.project-set.sh` | `agent/scripts/acp.project-set.sh` | **HAVE** | — |
| `acp.project-update.sh` | `agent/scripts/acp.project-update.sh` | **HAVE** | — |
| `acp.projects-restore.sh` | `agent/scripts/acp.projects-restore.sh` | **HAVE** | — |
| `acp.projects-sync.sh` | `agent/scripts/acp.projects-sync.sh` | **HAVE** | — |
| `acp.sessions.sh` | `agent/scripts/acp.sessions.sh` | **HAVE** | M12 sessions infrastructure. 6 subcommands. |
| `acp.uninstall.sh` | `agent/scripts/acp.uninstall.sh` | **HAVE** | — |
| `acp.version-check.sh` | `agent/scripts/acp.version-check.sh` | **HAVE** | — |
| `acp.version-check-for-updates.sh` | `agent/scripts/acp.version-check-for-updates.sh` | **HAVE** | — |
| `acp.version-update.sh` | `agent/scripts/acp.version-update.sh` | **HAVE** | — |
| `acp.yaml-parser.sh` | `agent/scripts/acp.yaml-parser.sh` | **HAVE** | AST-based YAML parser. Full CRUD operations. |
| `acp.yaml-validate.sh` | `agent/scripts/acp.yaml-validate.sh` | **HAVE** | — |

### 2b. Scripts — Upstream Only (Missing from Local)

| Upstream Script | Decision | Reason |
|----------------|----------|--------|
| `acp.driver-yaml.sh` | **DEFER** | Parser for `agent/driver.yaml` with 8 helpers (presence detection, get-driver-name, get-binding, get-workflow, get-capability, list-bindings, list-workflows). Requires MCP server infrastructure. Defer until ACP Enhanced adopts a pluggable driver. |

### 2c. Scripts — Local-Only

| Local Script | Decision | Purpose |
|--------------|----------|---------|
| `agent/scripts/acp.preferences.sh` | **LOCAL-ONLY** | ACP Enhanced preferences system backend. |

---

## 3. System Features / Milestones

| Feature | Upstream Milestone | Local Status | Decision | Notes |
|---------|-------------------|-------------|----------|-------|
| **Metadata Markers** (`@acp.meta.*`) | M? (v5.38.0) | `agent/scripts/acp.meta-scan.sh` present; markers in local files | **HAVE** | 8 marker kinds, awk-based parser, machine-readable sentinel blocks. |
| **FR-IDs for specs** | v5.42.0 (R→FR rename) | Confirmed in prior audit | **HAVE** | Functional Requirement ID prefix. |
| **DR-IDs for designs** | v5.41.0 (D→DR rename) | Confirmed in prior audit | **HAVE** | Design Requirement ID prefix; `decisions:` → `design_requirements:` marker field. |
| **Markers supersede prose frontmatter** | v5.40.0 | Applied in local files | **HAVE** | Marker is authoritative source; prose `**Status**` removed from templates. |
| **Specs system** (`agent/specs/`) | v5.31.0 (M?) | `agent/specs/` exists; only 1 spec + template | **PARTIAL** | System present but not yet widely populated in ACP Enhanced project. |
| **Traceability (covers/incorporates/implements)** | v5.39.0 | Marker fields present in files | **HAVE** | Cross-ref chain: spec R-ID → task `covers:` → code `implements:`. |
| **Self-Containment Task Principle** | v5.37.0 | Enforced in `acp.task-create.md` | **HAVE** | Every snippet/requirement must be inlined verbatim in task body. |
| **Drift Remediation Protocol** (`@acp.proceed` Step 3.5) | v5.37.0 | `agent/commands/acp.proceed.md` Step 3.5 | **HAVE** | 7-part mechanical audit; mandatory Drift Remediation section; sub-agent spawn protocol. |
| **Self-Containment Probes** (`@acp.validate` Step 5.1) | v5.41.0 | Probes 1-3 in local `acp.validate.md` | **HAVE** | LLM reading-comprehension probes for spec/design/clarification inlining. |
| **Behavior Table in specs** | v5.32.0 | `agent/specs/spec.template.md` has it | **HAVE** | 4-column catalog with `undefined` rows and OQ-N cross-refs. |
| **Sessions System** (`~/.acp/sessions.yaml`) | M12 (v5.10.0) | `acp.sessions.sh`, `acp.sessions.md` | **HAVE** | Shell script 6 subcommands; PPID-based stale detection; E2E tests (16 tests). |
| **Key File Index** (`agent/index/`) | M14 | `agent/index/acp.core.yaml`, `local.main.yaml` | **HAVE** | Weighted entries for core commands; contextual `applies` fields. |
| **Clarification Capture System** | M15 (v5.12.0) | All 4 clarification commands present | **HAVE** | `--from-clar/--from-clars/--from-chat/--from-context` args; conflict resolution UX. |
| **Design Reference System** | M16 | `acp.design-reference.md` present | **HAVE** | — |
| **Index Semantic Entry Types** (`path: null`) | M18 (v5.29.0) | `agent/design/local.index-semantic-entry-types.md` present; local.main.yaml references it | **PARTIAL** | Design doc present. `kind: note` and `kind: directive` inline entries not fully populated in local index files. Port deferred until index needs inline directives. |
| **Pluggable Driver System** | M19 (v7.0.0) | Not present | **DEFER** | Requires `agent/driver.yaml`, `acp.driver-yaml.sh`, `agent/schemas/driver.schema.yaml`, `agent/driver.template.yaml`, `agent/drivers/` reserved dir, two pattern docs, and driver dispatch wiring in 11 commands. ACP Enhanced does not currently use an MCP driver. Defer until an MCP driver adoption is planned. |
| **`query.run` Driver Dispatch** | M19 (v6.3.0) | Not wired | **DEFER** | Deferred with driver system. Affects: `acp.sync.md` Step 1.3, `acp.proceed.md` Steps 1 and A1, `acp.validate.md` Probe 3. |
| **`marker.mint` Driver Dispatch** | M19 (v6.3.0) | Not wired | **DEFER** | Deferred with driver system. Affects 5 stamping commands. |
| **`workflow.run` Override Directive** | M19 (v6.1.0) | Not present | **DEFER** | Top-of-file v1 pilot in `acp.task-create`, `acp.plan`, `acp.init`. Deferred with driver system. |
| **`capabilities.watcher`** | M19 (v6.3.0) | Not present | **DEFER** | Stale-data guidance directive in `acp.sync`, `acp.validate`, `acp.proceed`. Deferred with driver system. |
| **`acp.validate` Step 11.5 — Driver Bindings** | M19 (v6.2.0) | Not present | **DEFER** | DR6 validation rules (tool resolution, single server, mint/query pairing, reachability). Deferred with driver system. |
| **Template Source Files** (`agent/files/` in packages) | M9 (v5.0.0) | `e2e/acp.template-files.test.sh` present; scripts support it | **HAVE** | Variable substitution, `.template` stripping, selective `--files` install. |
| **Experimental Features System** | M8 (v3.12.0) | `e2e/acp.experimental-features.test.sh` present | **HAVE** | `experimental: true` in package.yaml; `--experimental` flag; graduation detection. |
| **Global Package Installation** | M5 (v3.9.0) | `--global` flag in package commands; global functions in `acp.common.sh` | **HAVE** | `~/.acp/agent/` global installation path; namespace precedence (local > global). |
| **Project Registry** (`~/.acp/projects.yaml`) | M7 (v4.3.0) | All 6 project commands present; `projects.schema.yaml` | **HAVE** | Git origin tracking; `acp.projects-restore.md` present. |
| **Cross-Platform CI** | M13 (v5.28.6) | `run-e2e-tests.sh`; GitHub Actions CI | **HAVE** | Portable sed/date fixes; unified test runner. |
| **Benchmark Suite** | M11 (v4.4.0) | `agent/benchmarks/runner/` + `agent/benchmarks/suite/` | **PARTIAL** | 6 tasks present (hello-world, simple-cli-tool, medium-rest-api, complex-auth-system, legacy-refactor, order-pipeline). **Missing**: `saas-platform` 15-step benchmark (introduced upstream v5.9.0). See §6 below. |
| **YAML Parser with AST** | v3.5.0 | `agent/scripts/acp.yaml-parser.sh` | **HAVE** | Full CRUD: `yaml_parse`, `yaml_query`, `yaml_set`, `yaml_write`. Zero external deps. |
| **Progress Schema** | v6.0.0 (milestones→map) | `agent/schemas/progress.schema.yaml` | **HAVE** | Milestones as map keyed by ID; numeric `priority:` field. |
| **Fully-Qualified FR/DR Ref Format** | v7.1.0 | Not confirmed in task template | **PORT** | Task template should document `spec.<id>~<uuid>#FR-N` and `design.<id>~<uuid>#DR-N` formats for driver-bound projects. Low-priority for non-driver projects. |
| **Autonomous mode `query.run` dispatch** | v7.1.0 | Not present | **DEFER** | `acp.proceed.md` Step A1 `query.run` wrapping for driver-bound projects. Deferred with driver system. |
| **Stacked Worktree Mode** (`--stacked`) | v5.34.0 | `agent/commands/acp.proceed.md` A11 | **HAVE** | Full A11 section: chain creation, per-task `@git.commit`, merge approval prompt, cleanup, halt-and-preserve on failure. |
| **`@acp.proceed` Autonomous Mode** (`--complete`) | v5.1.0 | Local `acp.proceed.md` | **HAVE** | `--complete`, `--auto`, `--finish-milestone` flags. |
| **`@acp.spec` Interactive OQ Resolution** | v5.36.0 | Local `acp.spec.md` | **HAVE** | Phase 12 interactive OQ resolution; `--resolve-oqs` / `--no-interactive` flags. |
| **Clarification `--interactive` flag** | v5.35.0 | Local `acp.clarification-create.md` | **HAVE** | Transient-by-default mode; one-question-at-a-time; no file unless explicitly requested. |
| **Step 0 (Display Command Header)** | v5.30.0 | All 46+ command files | **HAVE** | Purpose, usage/args, related commands shown on invocation. |
| **Milestone `file:` field** | v5.21.0 | `agent/milestones/*.md` structure | **HAVE** | Milestones declare `file:` key in progress.yaml. |
| **Task `started` timestamp + `actual_hours`** | v5.19.0 | In task files and progress.yaml | **HAVE** | ISO 8601 `started`, auto-computed `actual_hours` from diff. |
| **Marker-based `@acp.sync` cross-referencing** | v5.39.0 | `acp.sync.md` Steps 1.3-1.6 | **HAVE** | Unclaimed requirements, unimplemented claims, duplicated claims, stale markers. |
| **`@acp.sync` D-ID backfill (Pass C)** | v5.41.0 | Not confirmed | **PORT** | Pass C scans legacy designs for candidate atomic units and proposes D-IDs. Low priority — run `@acp.sync` to check if already present. |
| **History scrub / driver-agnostic convention** | v6.0.0 | Applied locally (no specific-driver refs) | **HAVE** | ACP Enhanced has never named specific drivers in docs. |

---

## 4. Schemas and Configuration Files

| File | Upstream | Local | Decision | Notes |
|------|----------|-------|----------|-------|
| `agent/schemas/package.schema.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/schemas/progress.schema.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/schemas/projects.schema.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/schemas/driver.schema.yaml` | ✓ | ✗ | **DEFER** | Formal schema for `agent/driver.yaml`. Deferred with driver system. |
| `agent/driver.yaml` | ✓ (per-project) | ✗ | **DEFER** | Per-project driver binding file. Deferred with driver system. |
| `agent/driver.template.yaml` | ✓ | ✗ | **DEFER** | Annotated template for driver.yaml. Deferred with driver system. |
| `agent/manifest.template.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/progress.template.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/package.template.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/projects.template.yaml` | ✓ | ✓ | **HAVE** | — |
| `agent/sessions.template.yaml` | ✓ | ✓ | **HAVE** | — |

---

## 5. Patterns

### 5a. Patterns — Shared

| Pattern | Decision | Notes |
|---------|----------|-------|
| `local.library-services.md` | **HAVE** | TypeScript service-layer pattern. Present in `agent/patterns/typescript/`. |
| `bootstrap.template.md` | **HAVE** | — |
| `pattern.template.md` | **HAVE** | — |

### 5b. Patterns — Upstream Only (Missing from Local)

| Upstream Pattern | Decision | Reason |
|-----------------|----------|--------|
| `local.driver-dispatch-directive.md` | **DEFER** | Canonical in-step ext-point dispatch directive snippet (driver-agnostic, strict-binding-first, explicit-error fallthrough). Deferred with driver system. |
| `local.workflow-override-directive.md` | **DEFER** | Canonical top-of-file workflow-override directive. Deferred with driver system. |

### 5c. Patterns — Local-Only

| Local Pattern | Decision | Purpose |
|--------------|----------|---------|
| `local.command-naming-convention.md` | **LOCAL-ONLY** | ACP Enhanced command naming convention documentation (M34). |
| `local.e2e-testing-pattern.md` | **LOCAL-ONLY** | ACP Enhanced E2E test authoring pattern. |
| `local.e2e-testing.md` | **LOCAL-ONLY** | ACP Enhanced E2E testing guidelines. |
| `local.tracked-untracked-directories.md` | **LOCAL-ONLY** | Documents git-tracked vs gitignored directory conventions. |

---

## 6. Design Documents

### 6a. Design Docs — Shared

| Design Doc | Decision | Notes |
|-----------|----------|-------|
| `acp-commands-design.md` | **HAVE** | — |
| `acp-package-development-system.md` | **HAVE** | — |
| `acp-package-management-system.md` | **HAVE** | — |
| `acp-preferences-system.md` | **HAVE** | ACP Enhanced uses this as basis for its preferences implementation. |
| `design.template.md` | **HAVE** | — |
| `global-acp-installation.md` | **HAVE** | — |
| `global-package-installation.md` | **HAVE** | — |
| `install-local-patterns-feature.md` | **HAVE** | — |
| `local.acp-code-design.md` | **HAVE** | — |
| `local.acp-template-source-files.md` | **HAVE** | M9 template source files design. |
| `local.artifact-commands-system.md` | **HAVE** | — |
| `local.benchmark-suite.md` | **HAVE** | — |
| `local.clarification-capture-system.md` | **HAVE** | M15 clarification capture design. |
| `local.cross-platform-ci.md` | **HAVE** | M13 CI design. |
| `local.design-reference-system.md` | **HAVE** | M16 design reference design. |
| `local.experimental-features-system.md` | **HAVE** | M8 experimental features design. |
| `local.index-semantic-entry-types.md` | **HAVE** | M18 inline entry types design. |
| `local.key-file-index-system.md` | **HAVE** | M14 key file index design. |
| `local.projects-yaml-feature.md` | **HAVE** | — |
| `local.script-command-binding.md` | **HAVE** | Script-command binding system design. |
| `local.sessions-system.md` | **HAVE** | M12 sessions system design. |
| `requirements.template.md` | **HAVE** | — |
| `visualizer.requirements.md` | **HAVE** | — |
| `yaml-parser-design.md` | **HAVE** | — |

### 6b. Design Docs — Upstream Only

| Upstream Design Doc | Decision | Reason |
|--------------------|----------|--------|
| `local.pluggable-driver-system.md` | **DEFER** | Full M19 design document (Future Considerations, DR1-DR16, non-goals). Deferred with driver system. |

### 6c. Design Docs — Local-Only

| Local Design Doc | Decision | Purpose |
|-----------------|----------|---------|
| `preferences-best-practices.md` | **LOCAL-ONLY** | ACP Enhanced preferences system best practices. |

---

## 7. E2E Tests

### 7a. E2E Tests — Shared

| Test File | Decision | Notes |
|-----------|----------|-------|
| `e2e/acp.command-docs.test.sh` | **HAVE** | — |
| `e2e/acp.experimental-features.test.sh` | **HAVE** | — |
| `e2e/acp.index.test.sh` | **HAVE** | — |
| `e2e/acp.package-info.test.sh` | **HAVE** | — |
| `e2e/acp.package-install-list.test.sh` | **HAVE** | — |
| `e2e/acp.package-list.test.sh` | **HAVE** | — |
| `e2e/acp.package-remove.test.sh` | **HAVE** | — |
| `e2e/acp.package-search.test.sh` | **HAVE** | — |
| `e2e/acp.package-update.test.sh` | **HAVE** | — |
| `e2e/acp.plan-with-preferences.test.sh` | **HAVE** | ACP Enhanced: preferences integration test. |
| `e2e/acp.project-info.test.sh` | **HAVE** | — |
| `e2e/acp.project-list.test.sh` | **HAVE** | — |
| `e2e/acp.project-remove.test.sh` | **HAVE** | — |
| `e2e/acp.project-set.test.sh` | **HAVE** | — |
| `e2e/acp.project-update.test.sh` | **HAVE** | — |
| `e2e/acp.project-workflow.test.sh` | **HAVE** | — |
| `e2e/acp.projects-sync.test.sh` | **HAVE** | — |
| `e2e/acp.script-command-binding.test.sh` | **HAVE** | — |
| `e2e/acp.sessions.test.sh` | **HAVE** | 16 tests covering M12 sessions. |
| `e2e/acp.template-files.test.sh` | **HAVE** | M9 template source files tests. |
| `e2e/acp.version.test.sh` | **HAVE** | — |

### 7b. E2E Tests — Upstream Only

| Upstream Test | Decision | Notes |
|--------------|----------|-------|
| `e2e/acp.driver-yaml.test.sh` | **DEFER** | 18 tests for M19 `acp.driver-yaml.sh` parser helpers. Deferred with driver system. |

### 7c. E2E Tests — Local-Only

| Local Test | Decision | Purpose |
|-----------|----------|---------|
| `e2e/acp.drafts.test.sh` | **LOCAL-ONLY** | Tests ACP Enhanced `agent/drafts/` system (M30). |
| `e2e/acp.opencode-commands.test.sh` | **LOCAL-ONLY** | Tests triple-file architecture `.opencode/commands/` sync. |

---

## 8. Benchmark Suite

| Benchmark Task | Upstream | Local | Decision | Notes |
|---------------|----------|-------|----------|-------|
| `hello-world` | ✓ | ✓ | **HAVE** | Simple shell script benchmark. |
| `simple-cli-tool` | ✓ | ✓ | **HAVE** | 3-step CSV-to-JSON CLI benchmark. |
| `medium-rest-api` | ✓ | ✓ | **HAVE** | 4-step Express CRUD API benchmark. |
| `complex-auth-system` | ✓ | ✓ | **HAVE** | 5-step JWT auth benchmark. |
| `legacy-refactor` | ✓ | ✓ | **HAVE** | 6-step refactoring from messy seed. |
| `order-pipeline` | ✓ | ✓ | **HAVE** | 7-step event-driven pipeline benchmark. |
| `saas-platform` | ✓ | ✗ | **PORT** | 15-step expert-complexity dual-seed benchmark. 20 buggy Express/Node.js seed files; 32 ACP documentation overlay files; 30 step prompts (15 ACP + 15 baseline); covers analysis through security hardening. Introduced upstream v5.9.0. |

---

## 9. Local-Only Infrastructure (ACP Enhanced Extensions)

These features exist only in ACP Enhanced and have no upstream equivalent. Documented for completeness.

| Feature | Location | Description |
|---------|----------|-------------|
| **Triple-file architecture** | `.github/copilot-instructions.md`, `.github/prompts/`, `.opencode/commands/` | Each command has a canonical `agent/commands/acp.NAME.md` plus auto-synced prompt files for VS Code Copilot and OpenCode. Upstream has only `agent/commands/`. |
| **Skills system** | `agent/skills/` | Skill files with domain-specific expertise loaded by executor role. No upstream equivalent. |
| **Routing system** | `agent/routing/` | Task routing taxonomy, rules, and task route files (`route-NNN.md`). Powers `/acp-route` command. No upstream equivalent. |
| **Configurables** | `agent/configurables/` | Project-level configurable settings. No upstream equivalent. |
| **In-repo memory** | `agent/memory/` | `sessions.md`, `lessons.md`, `decisions.md`, `patterns.md` as persistent in-repo memory files. Upstream sessions live in `~/.acp/sessions.yaml` (shell-based). |
| **Drafts system** | `agent/drafts/` | Working drafts directory (M30). `acp.plan.md` creates drafts here. |
| **Preferences system** | `agent/preferences/`, `agent/schemas/`, `agent/scripts/acp.preferences.sh` | Project-level preference presets and user overrides. 5 preference commands. |
| **Core protocol files** | `agent/core/identity.yml`, `agent/core/constraints.yml`, `agent/core/routing.yml` | ACP Enhanced context loading protocol files (see copilot-instructions.md). |
| **Wiki** | `agent/wiki/` | `domain.yml`, `architecture.md` — project-level knowledge base. |
| **In-repo task routing docs** | `agent/specs/local.acp-code-plugin-api.md` | ACP Enhanced spec for VS Code plugin integration. |

---

## 10. Summary Statistics

| Category | Total Items | HAVE | PARTIAL | DIVERGED | PORT | DEFER | LOCAL-ONLY |
|----------|-------------|------|---------|----------|------|-------|------------|
| Shared commands | 46 | 35 | 9 | 2 | 0 | 0 | — |
| Local-only commands | 11 | — | — | — | — | — | 11 |
| Scripts (shared) | 27 | 26 | 1 | 0 | 0 | 0 | — |
| Scripts (upstream-only) | 1 | — | — | — | — | 1 | — |
| Scripts (local-only) | 2 | — | — | — | — | — | 2 |
| System features | 36 | 24 | 3 | 0 | 2 | 7 | — |
| Schemas/config files | 11 | 8 | 0 | 0 | 0 | 3 | — |
| Patterns (shared) | 3 | 3 | 0 | 0 | 0 | 0 | — |
| Patterns (upstream-only) | 2 | — | — | — | — | 2 | — |
| Patterns (local-only) | 4 | — | — | — | — | — | 4 |
| Design docs (shared) | 24 | 24 | 0 | 0 | 0 | 0 | — |
| Design docs (upstream-only) | 1 | — | — | — | — | 1 | — |
| Design docs (local-only) | 1 | — | — | — | — | — | 1 |
| E2E tests (shared) | 21 | 21 | 0 | 0 | 0 | 0 | — |
| E2E tests (upstream-only) | 1 | — | — | — | — | 1 | — |
| E2E tests (local-only) | 2 | — | — | — | — | — | 2 |
| Benchmark tasks | 7 | 6 | 0 | 0 | 1 | 0 | — |
| **TOTALS** | **197** | **147** | **13** | **2** | **3** | **15** | **20** |

---

## 11. PORT Action Items

Items marked PORT should be completed in M29 follow-up tasks (task-156 compatibility audit):

1. **`saas-platform` benchmark** — 15-step dual-seed benchmark. Source: `agent/benchmarks/suite/saas-platform/` in upstream. High-value empirical test for ACP methodology vs baseline at enterprise complexity.

2. **`@acp.sync` D-ID backfill (Pass C)** — Step 1.4 Pass C: scan legacy designs for candidate D-ID atomic units, propose labels for user approval. Validate by running `@acp.sync` against local design docs.

3. **Fully-qualified FR/DR reference format documentation** — Update task template to document `spec.<id>~<uuid>#FR-N` and `design.<id>~<uuid>#DR-N` formats. Relevant only for driver-bound projects but harmless to document for forward-compatibility.

---

## 12. DEFER Rationale — Pluggable Driver System (M19)

All 15 DEFER decisions above trace back to a single root decision: **ACP Enhanced does not currently use or plan to use a pluggable MCP driver**.

**Why defer:**
- The driver system requires a running MCP server (`workflow.run`, `marker.mint`, `query.run` dispatch paths only activate when `agent/driver.yaml` is present and bound).
- ACP Enhanced operates in VS Code Copilot and local contexts where MCP server infrastructure is not required.
- The backward-compat invariant holds: all driver dispatch directives check "is `agent/driver.yaml` present?" first. Projects without `driver.yaml` see zero behavior change. Adding the dispatch directives without the infrastructure adds dead code with no benefit.
- The driver system is a substantial addition (~11 commands wired, 1 script, 1 schema, 2 patterns, 1 design doc, 18 E2E tests).

**Re-open trigger:** If ACP Enhanced adopts an MCP driver, create a dedicated porting milestone and pull all 15 DEFER items in at once. The upstream design doc (`local.pluggable-driver-system.md`) is the canonical reference.

---

*Generated by task-155 (M29 Upstream Integration Audit). Maintainer: update this matrix after each upstream version bump or new ACP Enhanced milestone.*
