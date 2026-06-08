# Command: review

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-review` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-review` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-07  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Enforce code quality, security, and consistency standards across a project's codebase using a structured 54-rule ruleset aligned to OWASP Top 10:2025, OWASP MASVS v2.0, TypeScript strict mode, and industry best practices.  
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

When the project contains `agent/commands/` — i.e., an ACP-enhanced project self-reviewing — Appendix A (ACP Self-Review Rules) automatically activates.

---

## Arguments

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

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| EH-01 | Every `async` function must have `try/catch` or explicit `.catch()` handler | HIGH | ALL |
| EH-02 | `catch` blocks must not be empty — must log, rethrow, or return typed error | HIGH | ALL |
| EH-03 | `catch(e) { console.log(e) }` without rethrow is a swallowed error | HIGH | ALL |
| EH-04 | `Promise.all()` must have `.catch()` or be inside `try/catch` | HIGH | ALL |
| EH-05 | Error responses must use consistent shape: `{ code: string, message: string, details?: unknown }` | MEDIUM | ALL |
| EH-06 | Route handlers must call `next(err)` or return error response — never silent `return` | MEDIUM | WEB |
| EH-07 | `finally` blocks must not contain `return` — masks thrown errors | MEDIUM | ALL |
| EH-08 | Custom error classes must extend `Error`, set `this.name`, pass `options.cause` | LOW | ALL |
| EH-09 | Global unhandled rejection handler registered: `process.on('unhandledRejection', ...)` | HIGH | WEB |
| EH-10 | React error boundaries at top-level and around each major feature boundary | HIGH | WEB/MOB |
| EH-11 | Mobile: all network calls handle offline/timeout states — never assume connectivity | HIGH | MOB |

---

### Category 2 — TypeScript Strictness (HIGH priority)
**Standard**: TypeScript strict mode v5.x, Google TypeScript Style Guide 2025

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| TS-01 | No `any` in function parameters, return types, or variable declarations | HIGH | ALL |
| TS-02 | All exported functions must have explicit return type annotations | HIGH | ALL |
| TS-03 | `as any` casts require inline comment explaining why | MEDIUM | ALL |
| TS-04 | `!` non-null assertions require inline comment explaining guarantee | MEDIUM | ALL |
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

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| NC-01 | Variables and functions: `camelCase` | MEDIUM | ALL |
| NC-02 | Classes, interfaces, type aliases, React components: `PascalCase` | MEDIUM | ALL |
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

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| AP-01 | Success responses use consistent envelope: `{ data: T, meta?: M }` | HIGH | WEB |
| AP-02 | Error responses use: `{ error: { code: string, message: string, details?: unknown } }` | HIGH | WEB |
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
**Standards**: OWASP Top 10:2025, OWASP MASVS v2.0, NIST SP 800-53 Rev 5

#### 6a — Secrets & Input (OWASP A05:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-01 | No hardcoded secrets, tokens, passwords, or API keys in source files | CRITICAL | ALL |
| SC-02 | All user-supplied input validated before use — `zod` schemas or equivalent | HIGH | ALL |
| SC-03 | `eval()`, `new Function()`, `setTimeout(string)`, `dangerouslySetInnerHTML` without sanitisation forbidden | HIGH | WEB |
| SC-04 | Database queries use parameterised inputs or ORMs — no string concatenation | HIGH | WEB |
| SC-05 | Sensitive data (PII, tokens, passwords) must not appear in logs | HIGH | ALL |

#### 6b — Access Control (OWASP A01:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-06 | Every API route accessing user data must verify requesting user is authorised | CRITICAL | WEB |
| SC-07 | Admin-only routes must check role before processing — never rely on obscure URLs | CRITICAL | WEB |
| SC-08 | CORS configuration must not use wildcard `*` in production | HIGH | WEB |
| SC-09 | SSRF — outbound URL targets from user input validated against allowlist | HIGH | WEB |

#### 6c — Security Misconfiguration (OWASP A02:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-10 | Environment variables accessed via validated config module — not `process.env` directly | MEDIUM | ALL |
| SC-11 | HTTP security headers required in production: `CSP`, `X-Frame-Options`, `HSTS` | HIGH | WEB |
| SC-12 | Default credentials and example configs removed before production deployment | CRITICAL | ALL |
| SC-13 | Error responses must not expose stack traces, internal paths, or DB schema | HIGH | ALL |

#### 6d — Supply Chain (OWASP A03:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-14 | No dependencies with known HIGH/CRITICAL CVEs — enforce via `npm audit --audit-level=high` | HIGH | ALL |
| SC-15 | Lock files committed and kept in sync for reproducible builds. May be gitignored in framework/protocol projects where lockfiles are development-only.) | HIGH | ALL |

#### 6e — Cryptography (OWASP A04:2025)

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SC-16 | Passwords hashed with `bcrypt`, `argon2`, or `scrypt` — never `md5`, `sha1`, `sha256` | CRITICAL | ALL |
| SC-17 | Sensitive data at rest uses platform-appropriate encryption — AES-256-GCM minimum | HIGH | ALL |
| SC-18 | TLS 1.2+ enforced on all network communication — no HTTP fallback in production | HIGH | ALL |

#### 6f — Mobile Security (OWASP MASVS v2.0)

| Rule ID | MASVS Control | Rule | Severity | Scope |
|---------|--------------|------|----------|-------|
| SC-19 | MASVS-STORAGE | No sensitive data in `AsyncStorage` unencrypted — use `expo-secure-store` | CRITICAL | MOB |
| SC-20 | MASVS-PLATFORM | Deep links validate incoming URL scheme and parameters before acting | HIGH | MOB |
| SC-21 | MASVS-NETWORK | Certificate pinning for critical APIs (bare workflow / custom dev client only) | HIGH | MOB |
| SC-22 | MASVS-CODE | Secrets/API keys not embedded in app bundle — use runtime config or secrets service | CRITICAL | MOB |
| SC-23 | MASVS-AUTH | Biometric auth uses platform APIs (`LocalAuthentication`) — not custom | HIGH | MOB |

#### 6g — Security Logging (OWASP A09:2025)

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

## Appendix A — ACP Self-Review Rules

Auto-activated when `agent/commands/` is detected in the project root.

| Rule ID | Rule | Severity |
|---------|------|----------|
| SH-01 | All `.sh` files use `set -euo pipefail` with `trap ERR` | HIGH |
| SH-02 | No BSD/GNU sed incompatibility — `sed -i ''` on macOS only | HIGH |
| SH-03 | No unquoted variables in scripts | MEDIUM |
| SH-04 | No `trap cleanup EXIT` inside sourced functions (subshell inheritance risk) | CRITICAL |
| YM-01 | All YAML files parse cleanly — no unquoted `{}` braces in flow sequences | HIGH |
| YM-02 | All Markdown frontmatter parses as valid YAML | MEDIUM |
| YM-03 | Version fields consistent across 8+ version-bearing files | HIGH |
| AP-01 | Command docs have `🤖 Agent Directive` header | MEDIUM |
| AP-02 | Every command has an E2E test file | MEDIUM |
| AP-03 | Scripts follow naming convention `acp.{name}.sh` | LOW |

---

## Related Commands

- `/acp-audit` — Deep-dive investigation of a specific finding
- `/acp-audit --pre-impl` — Pre-implementation check before building on reviewed code
- `/acp-carryover-query` — Query pending review carryovers
- `/acp-validate` — Check ACP framework structure (schemas, sessions, versions). Differs from `/acp-review` which checks user project code quality.
- `/acp-repair-tools` — Resolve carryover findings from reviews
- `/acp-commit` — Commit session after fixing review findings
- `/acp-integrity` — Verify code trustworthiness and provenance (companion to review — quality vs trust)

---

## Verification Checklist

- [ ] All 54 rules documented with rule IDs, severities, and scopes
- [ ] Output format spec included with example YAML
- [ ] Quality gates documented (8 rules)
- [ ] Executor selection guide with disqualification rationale
- [ ] Appendix A: 10 ACP self-review rules with auto-activation logic
- [ ] `--diff` flag documented
- [ ] Language Scope section present
- [ ] SC-15 lockfile qualifier present
- [ ] Agent Directive header present
