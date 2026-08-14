# Command: review

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-review` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-review` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-07  
**Status**: Active  
**Scripts**: acp.review-scan.sh, acp.review-measure.sh, acp.entropy-scan.sh, acp.gitleaks.sh, acp.dupehound.sh  

---

**Purpose**: Enforce code quality, security, and consistency standards across a project's codebase using a structured **64-rule** ruleset (54 core + 10 Appendix A) aligned to OWASP Top 10:2025, OWASP MASVS v2.0, TypeScript strict mode, and industry best practices.  
**Category**: Code Quality / Security  
**Frequency**: Per sprint, per PR, or pre-commit  

---

## Overview

`/acp-review` is a framework-level code review command that checks a project's codebase against a defined set of quality, security, and consistency rules. Unlike `/acp-audit` (deep-dive investigation) or `/acp-design-spec` (interface inventory), `/acp-review` enforces standards — it produces a structured findings report with rule IDs, severities, and fix suggestions.

**Command Positioning**:
```
/acp-audit           → agent/reports/   → INVESTIGATE (deep dive)
/acp-audit --pre-impl → agent/reports/  → PRE-IMPL GATE
/acp-review          → agent/reports/   → ENFORCE (standards check)
/acp-design-spec     → agent/reports/   → INVENTORY (interface spec)
```

## Language Scope

The v1.0.0 ruleset targets **TypeScript / JavaScript / Node.js** projects (React, React Native, Expo, Next.js, Express). This covers the primary audience for ACP Enhanced.

For Python, Go, Rust, or other languages, the structural review framework (output format, carryover integration, CI mode) still applies, but language-specific rules (TS-01–TS-13, NC-01–NC-09) will not fire. Language detection and ruleset expansion are planned for v2.0.0.

When the project contains `agent/commands/` — i.e., an ACP-enhanced project self-reviewing — Appendix A (ACP Self-Review Rules) automatically activates. Use `--self` to scan the standard ACP Enhanced paths without relying on `src/`.

> **Phase 1 Gate Policy (M70/M83)**: deterministic enforcement is now split across three shipped surfaces: **42 built-in scanner rules** in `acp.review-scan.sh` (EH, SC, TS, AP, NC, CH, SH, YM, and ACP deterministic subsets), **1 optional local-analyzer rule** (`SH-03` via `shellcheck` when installed), and **2 ACP structure rules** enforced by `/acp-validate` (`YM-03`, `ACP-02`). **Phase 2** agent review remains **required** for the other **19 semantic rules**. CI may run Phase 1 only; do not claim "64/64 automated."

| Phase | Rules | Executor | CI gate? |
|-------|-------|----------|----------|
| **Phase 1a** | 42 built-in deterministic | `acp.review-scan.sh` | Optional pre-merge |
| **Phase 1b** | 1 optional deterministic (`SH-03`) | `acp.review-scan.sh` + local analyzer | Optional pre-merge |
| **Phase 1c** | 2 ACP structural (`YM-03`, `ACP-02`) | `/acp-validate` | Optional pre-merge |
| **Phase 2** | 19 semantic | Agent (`/acp-review`) | Required before release |

## Phase 1 Measurement

Regenerate the deterministic scanner metrics with:

```bash
bash agent/scripts/acp.review-measure.sh --ci
```

| Metric | Current corpus-backed value |
|-------|-----------------------------|
| Corpus cases | **30** labelled files in `tests/fixtures/review-corpus/` (positive + negative pairs per rule family; `SH-03` rows run only when `shellcheck` is installed) |
| Rule-level TP rows | **47** on the current corpus (`acp.review-measure.sh` ALL row) |
| Aggregate recall | 100.0% |
| Aggregate precision | 100.0% |
| CI floor | Fails below 90.0% recall or 90.0% precision |

These figures are intentionally reproducible from `tests/fixtures/review-corpus/expected.yaml`, not hand-maintained prose.

### Wall-Clock Perf Gate (M85 task-303, audit-110)

Correctness gates cannot see performance regressions: the corpus above scored
100%/100% throughout an 18x scanner slowdown that audit-110 later traced to a
YAML-parsing cost. `acp.review-measure.sh --ci` now also times a single-file
scan (median of 5 runs) and fails the build if it exceeds `--perf-budget-ms`.

| Metric | Value |
|-------|-------|
| Single-file scan (measured 2026-07-31, isolated `acp.review-scan.sh` call) | 103ms (was 199ms pre-Phase-1, ~2950ms pre-audit-110) |
| Default budget (`--perf-budget-ms`) | **450ms** — ~4.4x headroom over the isolated figure; not tuned to sit just above it |
| What the gate actually times | The full `acp.review-measure.sh` subprocess path (`bash` + script sourcing overhead included), typically 300-360ms locally — still comfortably under budget |
| CI floor | Fails when the median exceeds the budget; failure message names the budget, the observed median, and audit-110 |

Regenerate with `bash agent/scripts/acp.review-measure.sh --ci` — the timing line prints on every run, not only on failure, so drift is visible before it breaks a build.

## Ruleset Size

| Layer | Count | Rule prefixes |
|-------|-------|----------------|
| Core rules (Categories 1–6) | **54** | EH, TS, NC, AP, CH, SC |
| Appendix A (ACP self-review) | **10** | SH, YM, ACP |
| **Total distinct rule IDs** | **64** | v1.0.0 |

> **19 semantic rules** still require Phase 2 agent review. CI may run Phase 1 only; do not claim **64/64** automated enforcement.

## Rule Ownership

`/acp-review` is the **code-quality and application-security** surface. It intentionally does **not** own every ACP integrity or framework-structure concern.

| Surface | Owns | Notes |
|---------|------|-------|
| `acp.review-scan.sh` | **42 built-in** Phase 1 rules across EH, SC, TS, AP, NC, CH, SH, YM, and ACP families; **optional `SH-03`** via `shellcheck` | Full rule-id list: `agent/wiki/coderabbit-policy-map-lite.md` § Phase 1 |
| `/acp-review` agent pass | **19 semantic** review rules | Release gate; covers A06 design review and the bulk of MASVS / code-health reasoning |
| `/acp-validate` | `YM-03`, `ACP-02` | ACP framework structure and parity checks; automated, but not part of the scanner |
| `/acp-integrity` | OWASP A08:2025 integrity and provenance ownership | Tampering, hidden Unicode, exfiltration, dependency trust, and other `IG-*` checks belong to the trust surface |

## Standards Coverage

| OWASP Top 10:2025 | Status | Primary coverage | Rationale |
|-------------------|--------|------------------|-----------|
| A01 Broken Access Control | Covered | `SC-06`–`SC-09` | Route authz, admin guards, CORS, and SSRF checks live in review rules |
| A02 Security Misconfiguration | Covered | `SC-10`–`SC-13` | Config validation, headers, default creds, and error leakage are review concerns |
| A03 Supply Chain Failures | Covered | `SC-14`–`SC-15` | Dependency CVEs and lockfile discipline stay under `/acp-review` |
| A04 Cryptographic Failures | Covered | `SC-16`–`SC-18` | Hashing, encryption at rest, and TLS posture are review rules |
| A05 Injection | Partially covered | `SC-02`–`SC-04` | Input validation and dangerous sinks are covered here; hardcoded secrets are **not** counted as injection |
| A06 Insecure Design | Deliberately not covered by scanner | Phase 2 agent review | Threat modeling and design flaws require semantic/design review, not deterministic scanning |
| A07 Authentication Failures | Partially covered | `SC-23`, `SC-24`, `SC-25` | Auth handling/logging signals exist, but credential-strength/session-policy checks remain Phase 2/manual |
| A08 Software and Data Integrity Failures | Owned by `/acp-integrity` | `IG-*` integrity rules | Trust/provenance and tamper detection are the companion command's responsibility |
| A09 Security Logging and Alerting Failures | Covered | `SC-24`–`SC-25` | Review owns auth-event and authz-failure logging expectations |
| A10 Mishandling of Exceptional Conditions | Covered | `EH-01`–`EH-11` | Error-handling category maps directly here |

## ACP Enhanced Self-Review Recipe

When reviewing this repository (no `src/` directory), use:

```
/acp-review --self --rules typescript,security,code-health --report
/acp-validate
/acp-integrity --self --fast
```

Or run the deterministic scanner directly:

```bash
bash agent/scripts/acp.review-scan.sh --ci scripts/ agent/scripts/
```

For fixture corpora or intentionally bad samples, opt back into excluded paths:

```bash
bash agent/scripts/acp.review-scan.sh --include-tests tests/fixtures/review-corpus/
```

---

## Arguments

| Flag | Purpose |
|------|---------|
| `[path]` | File or directory; defaults to `src/` when present, else project root |
| `--self` | ACP Enhanced self-review: `scripts/`, `agent/scripts/`, `agent/commands/`, `e2e/` |
| `--include-tests` | Include default-excluded paths matching `*test*`, `*spec*`, `*fixture*`, `*__mocks__*`, `*.generated.*`, `*.min.js` |
| `--rules <category>` | Limit to one category: `error-handling`, `typescript`, `naming`, `api`, `code-health`, `security`, `mobile` |
| `--severity <level>` | Minimum level: `critical`, `high`, `medium`, `low` |
| `--scope <web\|mobile\|all>` | Platform scoping (default: `all`) |
| `--ci` | Compact output, exit 1 on CRITICAL/HIGH findings |
| `--carryover` | Write HIGH+ to `agent/memory/audit-carryovers.md` |
| `--report` | Save structured YAML + prose to `agent/reports/review-NNN.md` |
| `--fix-suggestions` | Include inline fix per finding |
| `--baseline <file>` | Suppress findings already present in a baseline file (`rule + file + normalized snippet hash`) |
| `--write-baseline <file>` | Write the current findings to a reusable baseline file |
| `--diff` | Review only files changed since last commit (or named ref) — uses `git diff --name-only` |
| `--owasp` | Include OWASP Top 10:2025 / MASVS v2 mapping in output |
| `--ignore <pattern>` | Exclude file pattern |

---

## Review Rules

### Severity Legend
- **CRITICAL**: Security vulnerability, data loss risk, or blocking CI gate
- **HIGH**: Likely to cause bugs, security gaps, or operational issues
- **MEDIUM**: Code smell, maintainability risk, or convention violation
- **LOW**: Style inconsistency, minor improvement opportunity

### Scope Legend
- **[ALL]**: All project types
- **[WEB]**: Web applications
- **[MOB]**: Mobile applications (React Native/Expo)

---

### Category 1 — Error Handling (CRITICAL priority)
**Standard**: OWASP A10:2025 — Mishandling of Exceptional Conditions

| Rule ID | Rule | Severity | Scope | Phase 1 |
|---------|------|----------|-------|---------|
| EH-01 | Every `async` function must have `try/catch` or explicit `.catch()` handler | HIGH | ALL | **Y** |
| EH-02 | `catch` blocks must not be empty — must log, rethrow, or return typed error | HIGH | ALL | **Y** |
| EH-03 | `catch(e) { console.log(e) }` without rethrow is a swallowed error | HIGH | ALL | N |
| EH-04 | `Promise.all()` must have `.catch()` or be inside `try/catch` | HIGH | ALL | N |
| EH-05 | Error responses must use consistent shape: `{ code: string, message: string, details?: unknown }` | MEDIUM | ALL | N |
| EH-06 | Route handlers must call `next(err)` or return error response — never silent `return` | MEDIUM | WEB | N |
| EH-07 | `finally` blocks must not contain `return` — masks thrown errors | MEDIUM | ALL | N |
| EH-08 | Custom error classes must extend `Error`, set `this.name`, pass `options.cause` | LOW | ALL | N |
| EH-09 | Global unhandled rejection handler registered: `process.on('unhandledRejection', ...)` | HIGH | WEB | N |
| EH-10 | React error boundaries at top-level and around each major feature boundary | HIGH | WEB/MOB | N |
| EH-11 | Mobile: all network calls handle offline/timeout states — never assume connectivity | HIGH | MOB | N |

---

### Category 2 — TypeScript Strictness (HIGH priority)
**Standard**: TypeScript strict mode v5.x, Google TypeScript Style Guide 2025

| Rule ID | Rule | Severity | Scope | Phase 1 |
|---------|------|----------|-------|---------|
| TS-01 | No `any` in function parameters, return types, or variable declarations | HIGH | ALL | **Y** |
| TS-02 | All exported functions must have explicit return type annotations | HIGH | ALL | **Y** |
| TS-03 | `as any` casts require inline comment explaining why | MEDIUM | ALL | N |
| TS-04 | `!` non-null assertions require inline comment explaining guarantee | MEDIUM | ALL | N |
| TS-05 | Use `interface` for extensible shapes; `type` for unions, intersections | LOW | ALL |
| TS-06 | Use `const enum` or union literals — avoid plain `enum` for tree-shaking | LOW | ALL |
| TS-07 | `unknown` preferred over `any` in catch clauses: `catch (e: unknown)` | MEDIUM | ALL |
| TS-08 | `strictNullChecks` — no implicit null/undefined access without guard | HIGH | ALL |
| TS-09 | Use `zod` or equivalent for runtime validation at all API boundaries | HIGH | ALL |
| TS-10 | Use `satisfies` operator (TS 4.9+) for config objects | LOW | ALL |
| TS-11 | Use branded/nominal types for domain IDs: `UserId`, `OrderId` | MEDIUM | ALL |
| TS-12 | Generate types from source of truth: OpenAPI → types, Prisma schema → types | MEDIUM | ALL |
| TS-13 | Enable `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` | MEDIUM | ALL |

---

### Category 3 — Naming Conventions (MEDIUM priority)
**Standard**: Airbnb JS Style Guide, Google TypeScript Style Guide 2025

| Rule ID | Rule | Severity | Scope | Phase 1 |
|---------|------|----------|-------|---------|
| NC-01 | Variables and functions: `camelCase` | MEDIUM | ALL | **Y** |
| NC-02 | Classes, interfaces, type aliases, React components: `PascalCase` | MEDIUM | ALL | N |
| NC-03 | Module-level immutable constants: `UPPER_SNAKE_CASE` | LOW | ALL |
| NC-04 | File names: `kebab-case.ts` for modules; `PascalCase.tsx` for React components | LOW | ALL |
| NC-05 | Boolean variables use prefix: `is`, `has`, `can`, `should`, `will` | LOW | ALL |
| NC-06 | No single-character variable names outside `for` loop indices | LOW | ALL |
| NC-07 | No abbreviations in exported identifiers (`usr` → `user`, `cfg` → `config`) | LOW | ALL |
| NC-08 | Event handlers: prefix `handle` (internal) or `on` (prop) | LOW | WEB/MOB |
| NC-09 | Custom hooks must begin with `use` prefix | MEDIUM | WEB/MOB |

---

### Category 4 — API Response Consistency (HIGH priority)
**Standard**: Google API Design Guide, JSON:API spec

| Rule ID | Rule | Severity | Scope | Phase 1 |
|---------|------|----------|-------|---------|
| AP-01 | Success responses use consistent envelope: `{ data: T, meta?: M }` | HIGH | WEB | **Y** |
| AP-02 | Error responses use: `{ error: { code: string, message: string, details?: unknown } }` | HIGH | WEB | N |
| AP-03 | HTTP status codes must be semantically correct — no `200` with `{ error: ... }` | HIGH | WEB |
| AP-04 | Paginated responses include `{ data: T[], meta: { page, pageSize, total } }` | MEDIUM | WEB |
| AP-05 | No raw database model objects in API responses — use DTOs / response mappers | MEDIUM | ALL |
| AP-06 | Timestamp fields in responses are ISO 8601: `2026-06-07T09:00:00Z` | LOW | ALL |
| AP-07 | Public API endpoints must enforce rate limiting — document via `X-RateLimit-*` headers | HIGH | WEB |
| AP-08 | API versioning must be explicit — path prefix `/v1/` or header `Accept-Version` | MEDIUM | WEB |
| AP-09 | Auth tokens sent in `Authorization: Bearer <token>` — never in query string | HIGH | ALL |

---

### Category 5 — Code Health & Dead Code (MEDIUM priority)
**Standard**: SonarQube code smell taxonomy, Clean Code (Robert C. Martin)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| CH-01 | No `TODO` or `FIXME` without linked task ID: `// TODO: task-042` | MEDIUM | ALL |
| CH-02 | Commented-out code blocks removed unless preceded by `// KEEP:` with reason | MEDIUM | ALL |
| CH-03 | Functions exceeding 50 lines reviewed for decomposition | MEDIUM | ALL |
| CH-04 | Cognitive complexity > 10 per function flagged (SonarQube threshold) | MEDIUM | ALL |
| CH-05 | No duplicate code blocks > 10 lines — extract to shared utility | LOW | ALL |
| CH-06 | `console.log` / `console.debug` must not appear in production code paths | LOW | ALL |
| CH-07 | Unused imports must be removed | LOW | ALL |
| CH-08 | Unused exported functions annotated `// @deprecated` or removed | LOW | ALL |
| CH-09 | Interactive elements have accessible labels: `aria-label` (web) or `accessibilityLabel` (mobile) | MEDIUM | WEB/MOB |
| CH-10 | User-visible strings not hardcoded inline — use i18n keys for multi-locale apps | LOW | WEB/MOB |

---

### Category 6 — Security Baseline
**Standards**: OWASP Top 10:2025, OWASP ASVS, OWASP MASVS v2.0, NIST SP 800-53 Rev 5, CWE-798

#### 6a — Secret Hygiene (CWE-798 / OWASP ASVS)

| Rule ID | Rule | Severity | Scope | Phase 1 |
|---------|------|----------|-------|---------|
| SC-01 | No hardcoded secrets, tokens, passwords, or API keys in source files | CRITICAL | ALL | **Y** |
| SC-05 | Sensitive data (PII, tokens, passwords) must not appear in logs | HIGH | ALL | N |

#### 6b — Injection (OWASP A05:2025)

| Rule ID | Rule | Severity | Scope | Phase 1 |
|---------|------|----------|-------|---------|
| SC-02 | All user-supplied input validated before use — `zod` schemas or equivalent | HIGH | ALL | N |
| SC-03 | `eval()`, `new Function()`, `setTimeout(string)`, `dangerouslySetInnerHTML` without sanitisation forbidden | HIGH | WEB |
| SC-04 | Database queries use parameterised inputs or ORMs — no string concatenation | HIGH | WEB |

#### 6c — Access Control (OWASP A01:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-06 | Every API route accessing user data must verify requesting user is authorised | CRITICAL | WEB |
| SC-07 | Admin-only routes must check role before processing — never rely on obscure URLs | CRITICAL | WEB |
| SC-08 | CORS configuration must not use wildcard `*` in production | HIGH | WEB |
| SC-09 | SSRF — outbound URL targets from user input validated against allowlist | HIGH | WEB |

#### 6d — Security Misconfiguration (OWASP A02:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-10 | Environment variables accessed via validated config module — not `process.env` directly | MEDIUM | ALL |
| SC-11 | HTTP security headers required in production: `CSP`, `X-Frame-Options`, `HSTS` | HIGH | WEB |
| SC-12 | Default credentials and example configs removed before production deployment | CRITICAL | ALL |
| SC-13 | Error responses must not expose stack traces, internal paths, or DB schema | HIGH | ALL |

#### 6e — Supply Chain (OWASP A03:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-14 | No dependencies with known HIGH/CRITICAL CVEs — enforce via `npm audit --audit-level=high` | HIGH | ALL |
| SC-15 | Lock files committed and kept in sync for reproducible builds. Phase 1 raises SC-15 when no lockfile exists, or when one exists but is **untracked and not gitignored** (an accident that breaks `npm ci`). A deliberately gitignored lockfile is exempt — framework/protocol projects where lockfiles are development-only (M55 G-001). Outside a git work tree the rule asserts nothing. | HIGH | ALL |

#### 6f — Cryptography (OWASP A04:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-16 | Passwords hashed with `bcrypt`, `argon2`, or `scrypt` — never `md5`, `sha1`, `sha256` | CRITICAL | ALL |
| SC-17 | Sensitive data at rest uses platform-appropriate encryption — AES-256-GCM minimum | HIGH | ALL |
| SC-18 | TLS 1.2+ enforced on all network communication — no HTTP fallback in production | HIGH | ALL |

#### 6g — Mobile Security (OWASP MASVS v2.0)

| Rule ID | MASVS Control | Rule | Severity | Scope |
|---------|--------------|------|----------|-------|
| SC-19 | MASVS-STORAGE | No sensitive data in `AsyncStorage` unencrypted — use `expo-secure-store` | CRITICAL | MOB |
| SC-20 | MASVS-PLATFORM | Deep links validate incoming URL scheme and parameters before acting | HIGH | MOB |
| SC-21 | MASVS-NETWORK | Certificate pinning for critical APIs (bare workflow / custom dev client only) | HIGH | MOB |
| SC-22 | MASVS-CODE | Secrets/API keys not embedded in app bundle — use runtime config or secrets service | CRITICAL | MOB |
| SC-23 | MASVS-AUTH | Biometric auth uses platform APIs (`LocalAuthentication`) — not custom | HIGH | MOB |

#### 6h — Security Logging (OWASP A09:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-24 | Auth events (login, failure, logout, password reset) logged with timestamp + user ID | HIGH | ALL |
| SC-25 | Failed authorisation attempts logged and alertable | HIGH | ALL |

---

## Output Format

```yaml
# agent/reports/review-NNN.md
---
id: review-001
date: 2026-06-07
scope: src/services/
executor: composer-2.5
rules_applied: [error-handling, typescript, security]
findings_total: 14
findings_critical: 1
findings_high: 4
findings_medium: 6
findings_low: 3
carryovers_created: 5
---

findings:
  - id: CR-001
    file: src/services/auth.ts
    line: 47
    rule: EH-02
    severity: HIGH
    owasp: A10:2025
    message: "catch block is empty — error is swallowed silently"
    snippet: "} catch (e) {}"
    fix: "Log structured error and rethrow, or return typed error"
```

---

## Quality Gates

1. **Findings reflect code, not intent** — agents must read actual file contents
2. **Security findings override `--severity` filter** — CRITICAL always reported
3. **No false negatives for EH-01/EH-02/SC-06** — flag with uncertainty note
4. **`--carryover` creates one entry per finding** — granular tracking
5. **`--ci` exits 1 on CRITICAL or HIGH** — safe for pre-commit hooks
6. **Agents must never auto-fix** — report only; fixing is a separate routed task
7. **Mobile rules activate when `--scope mobile`** and project detected as React Native/Expo
8. **Re-verification required on carryover resolution** — never self-assess as fixed

---

## Executor Selection

**Qualified executors** (in capability order):

| Executor | Best For |
|----------|----------|
| Composer 2.5 | Full-project reviews, Cursor-native workflow, long-horizon |
| DeepSeek V4 Pro | Cross-component consistency, OpenRouter dispatch, cost-efficient |
| Kimi K2.6 | Polyglot codebases, long-horizon sessions |
| Qwen3 235B A22B | CI/high-volume, extreme cost efficiency |

**Disqualified**: DeepSeek V4 Flash, DeepSeek V4 Flash-Max — insufficient cross-file reasoning for security and consistency review.

**Per-task routing**:
```
--rules naming,code-health         → DeepSeek V4 Pro
--rules error-handling,typescript  → DeepSeek V4 Pro or Composer 2.5
--rules security                   → Composer 2.5 (preferred)
--rules mobile (MASVS)             → Composer 2.5 or Kimi K2.6
--ci (CI pipeline)                 → Qwen3 235B A22B
full codebase, all rules           → Composer 2.5
```

---

## Steps

1. **Invoke the command**: Run `/acp-review` with the desired rule set (`--rules <category>`, `--self`, or default).
2. **Run Phase 1 scanner** (optional, recommended for CI): `bash agent/scripts/acp.review-scan.sh [--ci] [path]` — 42 built-in deterministic rules across EH, SC, TS, AP, NC, CH, SH, YM, and ACP families, plus optional `SH-03` via `shellcheck`.
3. **Scan the codebase**: The agent examines project files against the 64-rule framework aligned to OWASP Top 10:2025 and TypeScript strict mode.
4. **Produce findings**: Generate a structured findings report with rule IDs, severities (CRITICAL/HIGH/MEDIUM/LOW), file locations, and fix suggestions.
5. **Prioritize fixes**: CRITICAL and HIGH findings should be addressed before commit. MEDIUM findings before PR merge. LOW findings tracked for next sprint.
6. **Verify**: Run the **Verification Checklist** at the bottom of this document to confirm the review completed correctly.

**`--self` path resolution**: When `--self` is passed, scan these paths in order: `scripts/`, `agent/scripts/`, `agent/commands/`, `e2e/`. Skip missing directories silently.

---

## Default Exclusions

To avoid high-noise false positives from test data, the deterministic scanner skips these path patterns by default:

- `*test*`
- `*spec*`
- `*fixture*`
- `*__mocks__*`
- `*.generated.*`
- `*.min.js`

Use `--include-tests` when scanning labelled corpora, intentionally bad fixtures, or generated samples that are part of review verification.

---

## Scanner Limitations

Phase 1 TypeScript/JavaScript rules use a **character-walker** (`acp.review-scan-ts.py`) that strips comments and string literals before regex matching. It is **not** an AST or tree-sitter analyzer (F-105-02). Implications:

- Rules cannot reason about scope, types, imports, or control flow.
- Complex signatures, nested generics, and semantic equivalents may be missed or approximated.
- Corpus metrics (`acp.review-measure.sh`) validate the **fixture set**, not production-scale recall.

Upgrade path (only if fixture FP rate rises): tree-sitter or TypeScript compiler API integration — deferred to backlog.

---

## CodeRabbit Augmentation (when `coderabbit_active`)

When `bash agent/scripts/acp.coderabbit.sh active` returns true (preference enabled **and** config file present):

| Phase | Behavior |
|-------|----------|
| **Phase 1** | **Never deferred** — all deterministic scanner rules still run via `acp.review-scan.sh` |
| **Phase 2** | For policy-map rows with `owner: coderabbit` or `both`, add annotation: “also covered by CodeRabbit — verify via PR review or `bash agent/scripts/acp.findings-import.sh --input …`” |
| **ACP-owned Phase 2** | Always run — review remains valid standalone when CodeRabbit is inactive |

Import path (M81 — fixture committed at `tests/fixtures/coderabbit-findings-sample.json`):

```bash
bash agent/scripts/acp.findings-import.sh --input tests/fixtures/coderabbit-findings-sample.json
```

Phase 1 deterministic rules are **never** deferred to CodeRabbit (F-101-07). Weekly `progress.yaml` recurring task stays `command: /acp-review --report --carryover` — CodeRabbit behavior lives in this doc, not a step list (F-101-02). Do **not** invent `/acp-findings-import` (F-101-06).

See `agent/wiki/coderabbit-policy-map-lite.md` and `agent/wiki/coderabbit-integration.md`.

---

## Optional Tool Delegation

`SH-03` is delegated to `shellcheck` when it is installed locally. The scanner runs the normal `shellcheck -f gcc -S warning` pass, then promotes quote-safety findings `SC2046`, `SC2068`, and `SC2086` from a filtered style-level pass into `SH-03` findings. Sourced-library allowlists match `SH-01` so utility libraries and `e2e/` helpers do not create known-benign noise.

`SC-01` keeps a small always-on fallback for structured prefixes and obvious secret assignments, then layers optional `gitleaks` findings on top when `integrations.gitleaks.enabled` is `auto`/`true` and the local binary is present. The scanner also reuses `acp.entropy-scan.sh --review-sc01` for high-entropy secret-like assignments; entropy complements prefix patterns and does not replace them.

`CH-05` is delegated to `dupehound` when `integrations.dupehound.enabled` is `auto`/`true` and the local binary is present. Findings are emitted as `CH-05 / MEDIUM`; in `--ci` they stay non-blocking because only CRITICAL/HIGH findings fail the scanner.

When an optional analyzer is absent, the scanner stays silent and that rule remains a Phase 2/manual review concern.

---

## False-Positive Controls

`/acp-review` now ships the minimum controls needed to adopt the scanner on an existing codebase without disabling whole rules:

- `--baseline <file>` suppresses previously accepted findings by `rule + file + normalized snippet hash`, so unrelated line shifts do not invalidate the entry.
- `--write-baseline <file>` writes the current findings into a reusable baseline file. Only findings that are still **active** are captured: a finding suppressed by a disabled `rule_override` or by an inline `acp-review-ignore` comment is **not** written to the baseline, so removing that comment later re-surfaces the issue instead of leaving it permanently hidden behind the baseline. Findings suppressed by an **existing** `--baseline` are still carried forward, so re-baselining never drops previously accepted entries.
- Inline suppression is supported on the same line or the immediately preceding line:

```ts
// acp-review-ignore: SC-01 - seeded fixture credential
const token = "ghp_example_fixture_token";
```

```sh
# acp-review-ignore: SH-03 - deliberate unquoted expansion in test fixture
echo $HOME
```

- A suppression **must include a reason**. Missing reasons are reported as a `LOW` finding and do **not** suppress the original issue.
- Text output always prints a suppression summary. `--json` includes `summary.suppressed_total`, `summary.suppressed_baseline`, `summary.suppressed_inline`, and `summary.suppressed_rule_override`.
- **Per-rule overrides** — project preference `review.rule_overrides` maps rule IDs to `enabled: false` and/or `severity: LOW|MEDIUM|HIGH|CRITICAL`. Disabled rules are suppressed project-wide; severity overrides apply before baseline/inline checks. Example:

```yaml
# agent/preferences/acp.default.yaml
acp:
  review:
    rule_overrides:
      NC-01:
        enabled: false
      CH-03:
        severity: LOW
```

See [review-legacy-adoption.md](../wiki/review-legacy-adoption.md) for the baseline → tighten adoption workflow.

These controls are shared with `/acp-integrity` through `agent/scripts/acp.integrity-output.sh`.

---

## Rule Authoring Checklist (Phase 1)

When adding or changing a deterministic rule in `acp.review-scan.sh`, follow
[`agent/patterns/local.rule-verification-discipline.md`](../patterns/local.rule-verification-discipline.md):

1. Write the **invariant** in one sentence (not a correlate).
2. Implement a probe that asserts that invariant (e.g. resolve modules — do not treat `scripts/node_modules/` existence as “YAML rules can run”).
3. Ship a **true-positive fixture** and a **false-positive fixture** (comments/strings/vendored trees).
4. Setup failures must **skip or fail-closed in `--ci`**, never emit the rule as a finding.
5. Document the rule ID in this file’s tables and keep `review_rg_dir` / `find` excludes aligned.

---

## Appendix A — ACP Self-Review Rules

Auto-activated when `agent/commands/` is detected in the project root.

| Rule ID | Rule | Severity | Phase 1 |
|---------|------|----------|---------|
| SH-01 | All `.sh` files use `set -euo pipefail` with `trap ERR` | HIGH | **Y** |
| SH-02 | No BSD/GNU sed incompatibility — `sed -i ''` on macOS only | HIGH | N |
| SH-03 | No unquoted variables in scripts (delegated to `shellcheck` when available) | MEDIUM |
| SH-04 | No `trap cleanup EXIT` inside sourced functions (subshell inheritance risk) | CRITICAL |
| YM-01 | All YAML files parse cleanly — no unquoted `{}` braces in flow sequences | HIGH |
| YM-02 | All Markdown frontmatter parses as valid YAML | MEDIUM |
| YM-03 | Version fields consistent across 8+ version-bearing files | HIGH |
| ACP-01 | Command docs have `🤖 Agent Directive` header | MEDIUM |
| ACP-02 | Every command has an E2E test file | MEDIUM |
| ACP-03 | Scripts follow naming convention `acp.{name}.sh` | LOW |

---

## Related Commands

- `/acp-audit` — Deep-dive investigation of a specific finding
- `/acp-audit --pre-impl` — Pre-implementation check before building on reviewed code
- `/acp-carryover-query` — Query pending review carryovers
- `/acp-validate` — Check ACP framework structure (schemas, sessions, versions). Differs from `/acp-review` which checks user project code quality.
- `/acp-repair-tools` — Resolve carryover findings from reviews
- `/acp-commit` — Commit session after fixing review findings
- `/acp-integrity` — Verify code trustworthiness and provenance (companion to review — quality vs trust; owns OWASP A08:2025 integrity coverage)

---

## Verification Checklist

- [ ] All 64 rules documented (54 core + 10 Appendix A) with rule IDs, severities, and scopes
- [ ] Output format spec included with example YAML
- [ ] Quality gates documented (8 rules)
- [ ] Executor selection guide with disqualification rationale
- [ ] Appendix A: 10 ACP self-review rules with auto-activation logic
- [ ] `--diff` flag documented
- [ ] `--baseline` / `--write-baseline` and inline suppression reason requirement documented
- [ ] Language Scope section present
- [ ] Standards Coverage table lists all 10 OWASP 2025 categories
- [ ] Rule ownership between `/acp-review`, `/acp-validate`, and `/acp-integrity` documented
- [ ] SC-15 lockfile qualifier present
- [ ] Agent Directive header present
