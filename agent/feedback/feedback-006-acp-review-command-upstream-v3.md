# ACP Enhanced — Field Feedback Report
## Submission: `/acp-review` command — Comprehensive Code Review & Standards Enforcement

**Report ID**: feedback-006  
**Version**: 3.0 (Executor Routing Update — Multi-Model Support)  
**Date**: 2026-06-07  
**Project**: ACP Enhanced (ssucipto/acp-enhanced) — internal framework initiative  
**ACP Version in use**: 6.10.0  
**Executor**: claude-sonnet  
**Category**: improvement — new command, new skill, standards enforcement, framework integration  
**Severity**: medium-high  
**Companion**: (none — initial proposal)  
**Supersedes**: feedback-006 v2.0 (2026-06-07)

**Submit to**: `https://github.com/ssucipto/acp-enhanced/issues`  
**Reference**: Prior art — `/acp-audit`, `/acp-design-spec` (feedback-005)

---

## Change Log (v2.0 → v3.0)

| Change | Reason |
|--------|--------|
| Executor routing expanded from 2 to 4 qualified models | Composer 2.5, DeepSeek V4 Pro, Kimi K2.6, Qwen3 235B all viable at similar price bands |
| DeepSeek V4 Flash and Flash-Max **explicitly disqualified** as executors | Insufficient cross-file reasoning and security rule depth for this task |
| Added §2.7 — Executor Selection Guide with cost/capability matrix | Gives ACP agents deterministic model selection logic |
| Added re-verification rule for Composer 2.5 reward-hacking tendency | Known training artifact — self-assessed "fixed" status is unreliable |
| Taxonomy updated with 4 task types mapped to specific executors | Replaces generic flash/pro mapping |
| Removed Flash-specific mitigations (complexity tagging, code examples, chunking protocol) | Only needed for Flash — qualified executors do not require these workarounds |

---

## Executive Summary

ACP Enhanced currently has no structured mechanism for enforcing **code consistency and standards** across a project's codebase. This proposal introduces:

1. **`agent/skills/code-review.md`** — structured ruleset aligned to OWASP Top 10:2025, OWASP MASVS v2, TypeScript 5.x strict mode, and SonarQube
2. **`agent/commands/acp.review.md`** — `/acp-review` slash command for on-demand or pre-commit review  
3. **`agent/specs/code-quality.standards.md`** — formal R<N> requirements for testable enforcement

**Qualified executors** (in capability order): Composer 2.5, DeepSeek V4 Pro, Kimi K2.6, Qwen3 235B A22B  
**Disqualified executors**: DeepSeek V4 Flash, DeepSeek V4 Flash-Max — insufficient cross-file reasoning for security and consistency review at the required depth.

---

## 1. Problem Statement

### 1.1 What is missing

| Gap | Impact |
|-----|--------|
| No command for **proactive code consistency checks** | Standards drift silently across sessions; agents enforce rules inconsistently |
| `/acp-audit` is investigation-first, task-scoped | Excellent for deep dives, not designed for codebase-wide rule enforcement |
| `/acp-audit --pre-impl` checks plan correctness only | Does not read existing code for style, safety, or error-handling compliance |
| No persistent ruleset agents can reference | Every agent session re-invents quality criteria differently |
| No carryover integration for quality debt | Review findings are not tracked across sessions — they disappear |
| No mobile-specific security coverage | Web rules do not cover local storage, deep links, or platform interaction risks |

### 1.2 Industry standards alignment

| Standard / Tool | Version | Relevance |
|-----------------|---------|-----------|
| **OWASP Top 10** | 2025 | Web application security — 10 risk categories, 589 CWEs |
| **OWASP MASVS** | v2.0 | Mobile security — 8 control groups |
| **TypeScript strict mode** | 5.x | `strictNullChecks`, `noImplicitAny`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes` |
| **ESLint / typescript-eslint** | v8+ | JS/TS static analysis |
| **Zod / io-ts** | Current | Runtime schema validation at API boundaries |
| **SonarQube** | Cloud | Cognitive complexity, duplication, dead code |
| **Google TypeScript Style Guide** | 2025 | Naming conventions, module patterns |
| **NIST SP 800-53** | Rev 5 | Secure coding — input validation, error handling |
| **CWE Top 25** | 2024 | Most dangerous software weaknesses |

---

## 2. Command Design — What to Ship

### 2.1 Core positioning

```
/acp-audit              →  agent/reports/   →  INVESTIGATE (deep dive, any subject)
/acp-audit --pre-impl   →  agent/reports/   →  PRE-IMPL GATE (plan + carryover check)
/acp-review             →  agent/reports/   →  ENFORCE (codebase-wide standards check)
/acp-design-spec        →  agent/reports/   →  INVENTORY (interface + data-flow spec)
```

### 2.2 Command invocation

```bash
# On-demand — review a single file
/acp-review src/services/auth.ts

# On-demand — review a directory
/acp-review src/services/

# Full project review (defaults to src/)
/acp-review

# Focused — single category
/acp-review --rules error-handling
/acp-review --rules security
/acp-review --rules typescript
/acp-review --rules mobile          # MASVS v2 rules

# Platform scoping
/acp-review --scope web
/acp-review --scope mobile
/acp-review --scope all             # default

# CI/pre-commit — compact output, non-zero exit on HIGH/CRITICAL findings
/acp-review --ci

# Write HIGH+ findings to carryovers
/acp-review --carryover

# Structured YAML + prose report
/acp-review --report

# Include OWASP mapping in output
/acp-review --owasp

# Diff against previous review
/acp-review --baseline
```

### 2.3 Review rule categories — COMPLETE RULESET

> **Severity**: CRITICAL → HIGH → MEDIUM → LOW  
> **Scope**: [WEB] web apps, [MOB] mobile apps, [ALL] both/backend

---

#### Category 1 — Error Handling (CRITICAL priority)
**Standards**: OWASP A10:2025 — Mishandling of Exceptional Conditions, NIST SP 800-53 SI-11

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| EH-01 | Every `async` function must have `try/catch` or explicit `.catch()` handler | HIGH | ALL |
| EH-02 | `catch` blocks must not be empty — must log, rethrow, or return typed error | HIGH | ALL |
| EH-03 | `catch(e) { console.log(e) }` without rethrow or structured error return is a swallowed error | HIGH | ALL |
| EH-04 | `Promise.all()` must have `.catch()` or be inside `try/catch` | HIGH | ALL |
| EH-05 | Error responses must use consistent shape: `{ code: string, message: string, details?: unknown }` | MEDIUM | ALL |
| EH-06 | Route handlers (Express/Hono/Fastify) must call `next(err)` or return error response — never silent `return` | MEDIUM | WEB |
| EH-07 | `finally` blocks must not contain `return` — masks thrown errors | MEDIUM | ALL |
| EH-08 | Custom error classes must extend `Error`, set `this.name`, pass `options.cause` when wrapping | LOW | ALL |
| EH-09 | Global unhandled rejection handler must be registered: `process.on('unhandledRejection', ...)` | HIGH | WEB |
| EH-10 | React error boundaries must be present at top-level and around each major feature boundary | HIGH | WEB/MOB |
| EH-11 | Mobile: all network calls must handle offline/timeout states explicitly — never assume connectivity | HIGH | MOB |

> **A10:2025 note**: OWASP elevated "Mishandling of Exceptional Conditions" to a standalone Top 10 item in 2025. EH-01 to EH-11 directly address the 24 CWEs in this category.

---

#### Category 2 — TypeScript Strictness (HIGH priority)
**Standards**: TypeScript strict mode v5.x, Google TypeScript Style Guide 2025

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| TS-01 | No `any` in function parameters, return types, or variable declarations | HIGH | ALL |
| TS-02 | All exported functions must have explicit return type annotations | HIGH | ALL |
| TS-03 | `as any` casts require inline comment explaining why | MEDIUM | ALL |
| TS-04 | `!` non-null assertions require inline comment explaining the guarantee | MEDIUM | ALL |
| TS-05 | Use `interface` for extensible object shapes; use `type` for unions, intersections, mapped types | LOW | ALL |
| TS-06 | Use `const enum` or union literal types for closed value sets — avoid plain `enum` for tree-shaking | LOW | ALL |
| TS-07 | `unknown` preferred over `any` in catch clauses: `catch (e: unknown)` | MEDIUM | ALL |
| TS-08 | `strictNullChecks` — no implicit null/undefined access without guard | HIGH | ALL |
| TS-09 | Use `zod` or equivalent for runtime validation at all API boundaries and user input entry points | HIGH | ALL |
| TS-10 | Use `satisfies` operator (TS 4.9+) for config objects to preserve narrow types | LOW | ALL |
| TS-11 | Use branded/nominal types for domain identifiers: `UserId`, `OrderId` — prevents ID mixing | MEDIUM | ALL |
| TS-12 | Generate TypeScript types from source of truth: OpenAPI → types, Prisma/Firestore schema → types | MEDIUM | ALL |
| TS-13 | Enable `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` in `tsconfig.json` | MEDIUM | ALL |

---

#### Category 3 — Naming Conventions (MEDIUM priority)
**Standards**: Airbnb JS Style Guide, Google TypeScript Style Guide 2025

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| NC-01 | Variables and functions: `camelCase` | MEDIUM | ALL |
| NC-02 | Classes, interfaces, type aliases, React components: `PascalCase` | MEDIUM | ALL |
| NC-03 | Module-level immutable constants: `UPPER_SNAKE_CASE` | LOW | ALL |
| NC-04 | File names: `kebab-case.ts` for modules; `PascalCase.tsx` for React/React Native components | LOW | ALL |
| NC-05 | Boolean variables must use prefix: `is`, `has`, `can`, `should`, `will` | LOW | ALL |
| NC-06 | No single-character variable names outside `for` loop indices | LOW | ALL |
| NC-07 | No abbreviations in exported identifiers (`usr` → `user`, `cfg` → `config`) | LOW | ALL |
| NC-08 | Event handlers: prefix with `handle` (internal) or `on` (prop): `handleSubmit`, `onPress` | LOW | WEB/MOB |
| NC-09 | Custom hooks must begin with `use` prefix | MEDIUM | WEB/MOB |

---

#### Category 4 — API Response Consistency (HIGH priority)
**Standards**: Google API Design Guide, JSON:API spec, REST best practices

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| AP-01 | All success responses use consistent envelope: `{ data: T, meta?: M }` | HIGH | WEB |
| AP-02 | All error responses use: `{ error: { code: string, message: string, details?: unknown } }` | HIGH | WEB |
| AP-03 | HTTP status codes must be semantically correct — no `200` with `{ error: ... }` body | HIGH | WEB |
| AP-04 | Paginated responses include: `{ data: T[], meta: { page, pageSize, total } }` | MEDIUM | WEB |
| AP-05 | No raw database model objects in API responses — use DTOs / response mappers | MEDIUM | ALL |
| AP-06 | Timestamp fields in responses are ISO 8601 strings: `2026-06-07T09:00:00Z` | LOW | ALL |
| AP-07 | All public API endpoints must enforce rate limiting — document via `X-RateLimit-*` headers | HIGH | WEB |
| AP-08 | API versioning must be explicit — path prefix `/v1/` or header `Accept-Version` | MEDIUM | WEB |
| AP-09 | Auth tokens sent in `Authorization: Bearer <token>` header — never in query string | HIGH | ALL |

---

#### Category 5 — Code Health & Dead Code (MEDIUM priority)
**Standards**: SonarQube code smell taxonomy, Clean Code (Robert C. Martin), CWE-398

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
| CH-09 | Interactive elements must have accessible labels: `aria-label` (web) or `accessibilityLabel` (mobile) | MEDIUM | WEB/MOB |
| CH-10 | User-visible strings must not be hardcoded inline — use i18n keys for multi-locale apps | LOW | WEB/MOB |

---

#### Category 6 — Security Baseline (CRITICAL/HIGH priority)
**Standards**: OWASP Top 10:2025, OWASP MASVS v2.0, NIST SP 800-53 Rev 5

##### 6a — Injection & Input (OWASP A05:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-01 | No hardcoded secrets, tokens, passwords, or API keys in source files | CRITICAL | ALL |
| SC-02 | All user-supplied input validated before use — use `zod` schemas or equivalent | HIGH | ALL |
| SC-03 | `eval()`, `new Function()`, `setTimeout(string)`, `dangerouslySetInnerHTML` without sanitisation forbidden | HIGH | WEB |
| SC-04 | Database queries must use parameterised inputs or ORMs — no string concatenation | HIGH | WEB |
| SC-05 | Sensitive data (PII, tokens, passwords) must not appear in logs | HIGH | ALL |

##### 6b — Broken Access Control (OWASP A01:2025 — #1 risk)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-06 | Every API route accessing user data must verify requesting user is authorised for that resource | CRITICAL | WEB |
| SC-07 | Admin-only routes must check role before processing — never rely on obscure URLs alone | CRITICAL | WEB |
| SC-08 | CORS configuration must not use wildcard `*` in production | HIGH | WEB |
| SC-09 | SSRF — outbound URL targets from user input must be validated against an allowlist | HIGH | WEB |

##### 6c — Security Misconfiguration (OWASP A02:2025 — #2 risk)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-10 | Environment variables accessed via validated config module — not `process.env` directly | MEDIUM | ALL |
| SC-11 | HTTP security headers required in production: `CSP`, `X-Frame-Options`, `HSTS` | HIGH | WEB |
| SC-12 | Default credentials and example configs removed before production deployment | CRITICAL | ALL |
| SC-13 | Error responses must not expose stack traces, internal paths, or DB schema to clients | HIGH | ALL |

##### 6d — Software Supply Chain (OWASP A03:2025 — NEW 2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-14 | No dependencies with known HIGH/CRITICAL CVEs — enforce via `npm audit --audit-level=high` in CI | HIGH | ALL |
| SC-15 | Lock files (`package-lock.json` / `yarn.lock`) must be committed and kept in sync | HIGH | ALL |

##### 6e — Cryptographic Failures (OWASP A04:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-16 | Passwords hashed with `bcrypt`, `argon2`, or `scrypt` — never `md5`, `sha1`, or plain `sha256` | CRITICAL | ALL |
| SC-17 | Sensitive data at rest uses platform-appropriate encryption — AES-256-GCM minimum | HIGH | ALL |
| SC-18 | TLS 1.2+ enforced on all network communication — no HTTP fallback in production | HIGH | ALL |

##### 6f — Mobile Security (OWASP MASVS v2.0)

| Rule ID | Rule | MASVS Control | Severity | Scope |
|---------|------|--------------|----------|-------|
| SC-19 | Sensitive data not stored in `AsyncStorage` unencrypted — use `expo-secure-store` or `react-native-keychain` | MASVS-STORAGE | CRITICAL | MOB |
| SC-20 | Deep links / universal links must validate incoming URL scheme and parameters before acting | MASVS-PLATFORM | HIGH | MOB |
| SC-21 | Certificate pinning for critical backend APIs (bare workflow / custom dev client only) | MASVS-NETWORK | HIGH | MOB |
| SC-22 | Secrets and API keys must not be embedded in app bundle — use runtime config or secrets service | MASVS-CODE | CRITICAL | MOB |
| SC-23 | Biometric authentication uses platform APIs (`LocalAuthentication`) — not custom re-implementations | MASVS-AUTH | HIGH | MOB |

##### 6g — Security Logging & Alerting (OWASP A09:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-24 | Auth events (login, failure, logout, password reset) logged with timestamp and user ID | HIGH | ALL |
| SC-25 | Failed authorisation attempts logged and alertable | HIGH | ALL |

### 2.4 Output format

```yaml
# agent/reports/review-NNN.md
---
id: review-001
date: 2026-06-07
scope: src/services/
executor: composer-2.5
rules_applied: [error-handling, typescript, security, api-consistency]
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
    fix: "Log structured error and rethrow, or return typed error: { code, message }"

  - id: CR-002
    file: src/services/auth.ts
    line: 89
    rule: SC-16
    severity: CRITICAL
    owasp: A04:2025
    message: "Password hashed with MD5 — cryptographically broken"
    snippet: "crypto.createHash('md5').update(password)"
    fix: "Replace with: bcrypt.hash(password, 12) or argon2.hash(password)"
```

### 2.5 Arguments

| Flag | Purpose |
|------|---------|
| `[path]` | File or directory; defaults to `src/` |
| `--rules <category>` | Limit to one category: `error-handling`, `typescript`, `naming`, `api`, `code-health`, `security`, `mobile` |
| `--severity <level>` | Minimum level: `critical`, `high`, `medium`, `low` |
| `--scope <web\|mobile\|all>` | Platform scoping (default: `all`) |
| `--ci` | Compact output, exit 1 on CRITICAL/HIGH findings |
| `--carryover` | Write HIGH+ to `agent/memory/audit-carryovers.md` |
| `--report` | Save structured YAML + prose to `agent/reports/review-NNN.md` |
| `--fix-suggestions` | Include inline fix per finding |
| `--baseline` | Diff against previous review |
| `--ignore <pattern>` | Exclude file pattern |
| `--owasp` | Include OWASP Top 10:2025 / MASVS v2 mapping in output |

### 2.6 Quality gates

1. **Findings reflect code, not intent** — agents must read actual file contents, never infer from task descriptions
2. **Security findings override `--severity` filter** — CRITICAL findings always reported regardless of flag
3. **No false negatives for EH-01/EH-02/SC-06** — flag with uncertainty note rather than skip
4. **`--carryover` creates one entry per finding**, not per file — granular tracking
5. **`--ci` exits 1 on CRITICAL or HIGH** — safe for pre-commit hooks and GitHub Actions
6. **Agents must never auto-fix** — report only; fixing is a separate routed task
7. **Mobile rules activate when `--scope mobile` or `--scope all`** and project detected as React Native/Expo (detection: `package.json` contains `react-native`, `expo`, or `@capacitor/core`)
8. **Re-verification required on `--carryover` resolution** — never mark `status: fixed` based on agent self-assessment alone; re-run `/acp-review` on the specific file

### 2.7 Executor Selection Guide

#### Qualified Executors

All four qualified executors can run the complete ruleset without architectural workarounds.

| Executor | Price (per 1M in/out) | Strength | Best for |
|----------|----------------------|----------|----------|
| **Composer 2.5** | $0.50 / $2.50 | Long-horizon agentic tasks, effort calibration, IDE-native | Full-project reviews, sustained 90-min sessions, Cursor-native workflow |
| **DeepSeek V4 Pro** | $0.44 / $0.87 | High reasoning quality, 1.6T parameter depth, cost-efficient | Cross-component consistency, multi-file security rules, API contract review |
| **Kimi K2.6** | ~$0.50 / ~$2.00 | Long-horizon coding, multi-language reliability, open-source | Reviews spanning Rust/Go/Python polyglot codebases; agent swarm patterns |
| **Qwen3 235B A22B** | $0.07 / $0.10 | Extreme cost efficiency, 262K context, hybrid reasoning | Budget-constrained full-project scans; high-volume CI pipelines |

> **Routing rule**: Use Composer 2.5 for Cursor-native workflows (it reads `.cursor/commands/` directly). Use DeepSeek V4 Pro via `acp-dispatch.ts` for OpenRouter-routed sessions. Use Qwen3 235B for high-volume or CI usage where cost is the primary constraint.

#### Disqualified Executors

| Executor | Why Disqualified |
|----------|-----------------|
| **DeepSeek V4 Flash** | 284B parameter model optimised for speed, not depth. Fails cross-file reasoning required for SC-06 (access control tracing), SC-09 (SSRF), CH-04 (cognitive complexity). High false-positive rate on TS-09/TS-11. Suitable for doc updates, simple bug fixes — not security or consistency review. |
| **DeepSeek V4 Flash-Max** | Flash-Max increases context window and throughput but does not improve reasoning depth. The cross-file analysis limitation is architectural, not context-length limited. Flash-Max will process more files but produce the same quality of findings per file — inadequate for OWASP-level security rules. |

> **Why Flash-Max still doesn't cut it**: The failures observed in Flash are not context-length problems — they are reasoning-depth problems. Flash-Max cannot trace an auth token from a route handler through middleware to a database call and identify a missing authorisation check (SC-06). More context does not fix this.

#### Per-Task Executor Mapping

```
/acp-review --rules naming,code-health    →  DeepSeek V4 Pro (pattern-matchable, low reasoning)
/acp-review --rules error-handling        →  DeepSeek V4 Pro or Composer 2.5
/acp-review --rules typescript            →  DeepSeek V4 Pro or Composer 2.5
/acp-review --rules api                   →  DeepSeek V4 Pro or Composer 2.5
/acp-review --rules security              →  Composer 2.5 (preferred) or DeepSeek V4 Pro
/acp-review --rules mobile (MASVS)        →  Composer 2.5 (preferred) or Kimi K2.6
/acp-review (full codebase, all rules)    →  Composer 2.5 (long-horizon strength)
/acp-review --ci (CI pipeline, high volume) → Qwen3 235B A22B (cost efficiency at scale)
```

---

## 3. Skill File Design — `agent/skills/code-review.md`

Loaded via `@code-review`. Must stay ≤ 500 tokens.

```markdown
# Skill: Code Review

## When to load
- /acp-review command execution
- task_type: code-review-targeted or code-review-full or code-review-security

## Priority order (enforce strictly, all qualified executors)
1. CRITICAL — SC-01, SC-06, SC-12, SC-16, SC-19, SC-22: secrets, access control, crypto, mobile storage
2. HIGH — EH-01, EH-02, EH-09, EH-10: unhandled async, empty catch, error boundary
3. HIGH — SC-02, SC-04, SC-14: injection, supply chain CVEs
4. HIGH — TS-01, TS-08, TS-09: any types, null safety, missing runtime validation
5. HIGH — AP-01, AP-02, AP-03, AP-07, AP-09: API envelope, status codes, auth headers
6. MEDIUM — CH-01, CH-03, CH-04, TS-02, TS-07: complexity, TODOs, error types
7. LOW — naming, import order, minor conventions

## Output discipline
- Always include: file, line, rule ID, severity, OWASP ref (if applicable), one-line message, fix
- Group: CRITICAL → HIGH → MEDIUM → LOW
- For scope > 20 files: category summary first, then per-file HIGH+ findings
- NEVER auto-apply fixes — report only

## Executor note
- Composer 2.5: calibrates effort automatically; no special instruction needed
- DeepSeek V4 Pro: reliable on all categories; prefer for OpenRouter dispatch
- Kimi K2.6: strong on polyglot codebases and long-horizon sessions
- Qwen3 235B: cost-efficient; use for CI/high-volume; may need re-run on SC-06/SC-09
- Flash / Flash-Max: DO NOT USE for this skill — disqualified

## Carryover integration
- /acp-review --carryover → agent/memory/audit-carryovers.md (existing schema)
- status: fixed ONLY after re-run of /acp-review confirms finding resolved
- Carryovers surface at Step 4.4 (AGENTS.md) every session
```

---

## 4. Spec File Design — `agent/specs/code-quality.standards.md`

| R# | Requirement | Category | OWASP | Testable by |
|----|-------------|----------|-------|-------------|
| R1 | All async functions have explicit error handling | EH-01 | A10:2025 | `/acp-review --rules error-handling` |
| R2 | No `any` in exported function signatures | TS-01 | — | `/acp-review --rules typescript` |
| R3 | All API endpoints return consistent response envelope | AP-01, AP-02 | — | `/acp-review --rules api` |
| R4 | No hardcoded credentials in source files | SC-01 | A02:2025 | `/acp-review --rules security` |
| R5 | No empty catch blocks | EH-02 | A10:2025 | `/acp-review --rules error-handling` |
| R6 | All TODO comments reference a task ID | CH-01 | — | `/acp-review --rules code-health` |
| R7 | Cognitive complexity ≤ 10 per function | CH-04 | — | `/acp-review --rules code-health` |
| R8 | All user input validated at API boundary | SC-02, TS-09 | A05:2025 | `/acp-review --rules security` |
| R9 | Passwords hashed with bcrypt/argon2 minimum | SC-16 | A04:2025 | `/acp-review --rules security` |
| R10 | Every protected API route enforces authorisation check | SC-06 | A01:2025 | `/acp-review --rules security` |
| R11 | No HIGH/CRITICAL CVEs in dependencies | SC-14 | A03:2025 | `npm audit` + `/acp-review --rules security` |
| R12 | Mobile: sensitive data in secure storage only | SC-19 | MASVS-STORAGE | `/acp-review --rules mobile` |

---

## 5. Framework Integration Checklist

### 5.1 `routing.yml` — command_suggestions

```yaml
acp-review:
  - acp-audit: "Deep-dive into a specific finding from the review"
  - acp-carryover-query: "Query pending review carryovers"
  - acp-commit: "Commit session after fixing review findings"

acp-audit:
  - acp-review: "Run codebase-wide standards check before deep-dive"   # ADD

acp-audit--pre-impl:
  - acp-review: "Check existing code quality before implementing on top"  # ADD
```

### 5.2 `taxonomy.yml` — task type mapping (v3.0)

```yaml
code-review-targeted:
  description: Single file or small directory review
  skill: code-review.md
  executor: deepseek-v4-pro          # cost-efficient for narrow scope
  fallback_executor: composer-2.5
  risk: low
  tokens_est: 800
  context_required: [skills/code-review.md]

code-review-full:
  description: Cross-component codebase-wide review
  skill: code-review.md
  executor: composer-2.5             # long-horizon strength
  fallback_executor: deepseek-v4-pro
  risk: medium
  tokens_est: 2400
  context_required: [skills/code-review.md, wiki/architecture.md]

code-review-security:
  description: Security-focused review — OWASP full ruleset
  skill: code-review.md
  executor: composer-2.5             # cross-file reasoning required
  fallback_executor: kimi-k2.6
  risk: high
  tokens_est: 3000
  context_required: [skills/code-review.md, wiki/architecture.md]

code-review-ci:
  description: CI pipeline / high-volume automated review
  skill: code-review.md
  executor: qwen3-235b-a22b          # extreme cost efficiency at scale
  fallback_executor: deepseek-v4-pro
  risk: low
  tokens_est: 600
  context_required: [skills/code-review.md]
  note: "Re-run with composer-2.5 if SC-06/SC-09 findings need verification"
```

### 5.3 Pre-commit hook integration (opt-in)

```bash
# .git/hooks/pre-commit (addition to existing ACP hook)
if [ "${ACP_REVIEW_ON_COMMIT:-false}" = "true" ]; then
  echo "[ACP] Running pre-commit code review (--ci --severity high)..."
fi
```

Opt-in via `agent/core/constraints.yml`:
```yaml
hooks:
  pre_commit_review: false          # true = blocking review on commit
  pre_commit_severity: high
  pre_commit_scope: all             # web | mobile | all
  pre_commit_executor: deepseek-v4-pro  # cost-efficient for staged-file scope
```

### 5.4 E2E smoke test — `e2e/acp.review.test.sh`

```bash
assert_file_exists "agent/commands/acp.review.md"
assert_file_exists "agent/skills/code-review.md"
assert_file_exists "agent/specs/code-quality.standards.md"
assert_contains "agent/commands/acp.review.md" "🤖 Agent Directive"
assert_contains "agent/commands/acp.review.md" "## Verification Checklist"
assert_contains "agent/skills/code-review.md" "EH-01"
assert_contains "agent/skills/code-review.md" "SC-01"
assert_contains "agent/skills/code-review.md" "SC-06"
assert_contains "agent/routing/taxonomy.yml" "code-review-targeted"
assert_contains "agent/routing/taxonomy.yml" "code-review-security"
assert_wrapper_exists ".cursor/commands/acp-review.md"
assert_wrapper_exists ".opencode/commands/acp-review.md"
```

### 5.5 Cross-link additions

- `AGENTS.md` Step 3 skill routing → add: `Code quality / security review → agent/skills/code-review.md`
- `agent/commands/acp.audit.md` → Related Commands: add `/acp-review`
- `agent/commands/acp.audit--pre-impl.md` → Related Commands: add `/acp-review`
- `README.md` Slash Commands table → add `/acp-review` row

### 5.6 Version bump

- Command: **1.0.0** | Skill: **1.0.0** | Spec: **1.0.0**
- Framework compatibility: **ACP 6.10.0+**
- CHANGELOG: "New Commands", "New Skills", "New Specs"

---

## 6. Issues to Resolve Before Shipping

| ID | Severity | Issue | Proposed Resolution |
|----|----------|-------|---------------------|
| CR-01 | HIGH | Agent must not auto-fix — risk of unintended changes | Explicit "No Auto-Fix" rule in skill file and command directive |
| CR-02 | HIGH | Large codebase token overrun | Chunked review by executor: 10 files/turn (V4 Pro), unlimited (Composer 2.5 / Kimi K2.6) |
| CR-03 | MEDIUM | Rule overlap: `/acp-review` EH-* vs `/acp-audit` | Disambiguation table in both command files |
| CR-04 | MEDIUM | `--ci` output format for GH Actions parsing | Compact schema: `[SEVERITY] file:line ruleID — message` |
| CR-05 | MEDIUM | macOS/Linux hook compatibility | Follow existing ACP hook patterns — no `date +%N`, no GNU-only sed |
| CR-06 | LOW | Rule ID namespace collision with project custom rules | ACP core = two-letter prefix; project custom = `X-` prefix |
| CR-07 | LOW | `--baseline` needs previous report path convention | Store last review path in `agent/routing/ledger.md` under `reviews:` key |
| CR-08 | MEDIUM | Mobile rule detection (RN vs web) | Auto-detect via `package.json`: `react-native`, `expo`, `@capacitor/core` |
| CR-09 | MEDIUM | OWASP field requires executor to know mapping | Embed OWASP mapping table in skill file within 500-token budget |
| CR-10 | LOW | SC-21 cert pinning complex on Expo managed workflow | Skill note: applies to bare workflow / custom dev client only |
| CR-11 | LOW | CH-09 accessibility requires component awareness | Scope to: flag `<TouchableOpacity>` / `<Pressable>` without `accessibilityLabel` for manual review |

---

## 7. Relationship to Existing Audit System

| Aspect | `/acp-audit` | `/acp-review` |
|--------|-------------|----------------|
| Trigger | Task-scoped investigation | Codebase-wide standards check |
| Input | Route file + specific question | File/directory + ruleset |
| Scope | One feature, one component | All source files in scope |
| Output | Free-form audit report | Structured findings YAML + prose |
| OWASP mapping | Ad hoc | Explicit per finding |
| Carryover integration | Via `audit-carryovers.md` | `--carryover` → same file |
| Frequency | Per task, per milestone | Per sprint, per PR, or pre-commit |
| Executor | Task-specific | Routing per §2.7 |

---

## 8. Platform Portability

The ruleset is **production-grade for web apps, mobile apps (React Native/Expo), and Node.js backends**.

| Platform | Coverage |
|----------|----------|
| **Web (React, Next.js, Remix)** | All EH, TS, NC, AP, CH rules; full SC security set including SC-11 (HTTP headers) |
| **Mobile (React Native, Expo)** | All EH, TS, NC rules; AP rules where applicable; full MASVS v2 SC-19 to SC-23 |
| **Backend (Node.js, Cloud Run, Hono, Fastify)** | All categories; AP rules mandatory; SC-06/SC-07 access control critical |

Rules tagged `[WEB]` or `[MOB]` activate automatically via `--scope` flag. No false positives when run against a standard TypeScript project regardless of platform.

---

## 9. Suggested Upstream File Package

```
agent/commands/acp.review.md              # v1.0.0 — main directive
agent/skills/code-review.md              # v1.0.0 — rules (≤ 500 tokens)
agent/specs/code-quality.standards.md    # v1.0.0 — R1–R12
agent/templates/review-report.template.md # YAML + prose output template
.cursor/commands/acp-review.md           # Thin wrapper
.opencode/commands/acp-review.md         # Thin wrapper
e2e/acp.review.test.sh                   # 12-assertion smoke test
```

---

## 10. Prioritised Backlog for ACP Enhanced Team

| Priority | Item | Effort |
|----------|------|--------|
| **P0** | `agent/skills/code-review.md` — all 6 categories, ≤ 500 tokens, executor routing note | Medium |
| **P0** | `agent/commands/acp.review.md` — slash command, all flags | Medium |
| **P1** | `agent/specs/code-quality.standards.md` — R1–R12 with OWASP refs | Low |
| **P1** | `taxonomy.yml` — 4 new task types with executor + fallback fields | Low |
| **P1** | `routing.yml` — command_suggestions cross-links | Low |
| **P1** | E2E smoke test `acp.review.test.sh` (12 assertions) | Medium |
| **P2** | Pre-commit hook opt-in (`constraints.yml` flag) | Medium |
| **P2** | Cross-links: `acp.audit.md`, `AGENTS.md`, `README.md` | Low |
| **P2** | `review-report.template.md` output template | Low |
| **P3** | `--baseline` comparison + ledger integration | High |
| **P3** | Visualizer integration — review findings panel | High |

---

## 11. Files to Attach to GitHub Issue

1. `agent/skills/code-review.md` (if pre-drafted)
2. `agent/specs/code-quality.standards.md` (if pre-drafted)
3. This file (`feedback-006 v3.0`)

---

## 12. Acceptance Criteria (Upstream Done Definition)

- [ ] `/acp-review` available after fresh `acp-bootstrap.sh` install
- [ ] `agent/skills/code-review.md` invocable via `@code-review` in chat
- [ ] Skill file ≤ 500 tokens, includes executor routing note (Flash disqualified)
- [ ] `agent/specs/code-quality.standards.md` contains R1–R12 with OWASP references
- [ ] E2E test passes on macOS + Linux CI (12 assertions)
- [ ] `AGENTS.md` Step 3 skill routing table includes `code-review.md` row
- [ ] `taxonomy.yml` contains all 4 task types with fallback executors
- [ ] `acp.audit.md` Related Commands references `/acp-review`
- [ ] `--ci` exits non-zero on CRITICAL/HIGH findings
- [ ] `--carryover` writes to `audit-carryovers.md` using existing schema
- [ ] `--scope mobile` activates SC-19 to SC-23 (MASVS v2) rules
- [ ] Output includes `owasp:` field per finding when `--owasp` flag used
- [ ] Re-verification rule enforced: `status: fixed` only after `/acp-review` re-run confirms
- [ ] Flash and Flash-Max explicitly named as disqualified in skill file

---

**Report type**: Framework contribution — new command + skill + spec (v3.0 — multi-model executor routing)  
**Qualified executors**: Composer 2.5, DeepSeek V4 Pro, Kimi K2.6, Qwen3 235B A22B  
**Disqualified executors**: DeepSeek V4 Flash, DeepSeek V4 Flash-Max  
**Standards basis**: OWASP Top 10:2025, OWASP MASVS v2, TypeScript 5.x strict, SonarQube, NIST SP 800-53 Rev 5  
**Generated by**: ACP feedback-006 v3.0 — executor routing update pass
