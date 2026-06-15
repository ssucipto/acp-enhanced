---
id: task-181
milestone: M36
title: Create saas-platform benchmark seed files (OWASP fixtures)
status: not_started
priority: 1
complexity: medium
estimated_hours: 2
created: 2026-05-05
started:
completed:
---

## Objective

Create `agent/benchmarks/suite/saas-platform/seed/` with 20 intentionally-buggy Express.js files containing OWASP Top 10 violations for use as benchmark test fixtures.

## Context

The saas-platform benchmark tests ACP-guided code review vs direct-instruction review on a codebase with known security issues. The seed files are TEST FIXTURES — they are deliberately insecure so the benchmark can measure how well each approach catches vulnerabilities.

**These files must NEVER be used in production. They exist only as benchmark inputs.**

The seed directory should have a prominent `README.md` warning.

## Implementation

Create the directory `agent/benchmarks/suite/saas-platform/seed/` with:

### README.md
```markdown
# BENCHMARK SEED FILES — DELIBERATELY INSECURE

<!-- @acp.meta.task
topic: benchmark, seed, files, deliberately, insecure
description: Create saas-platform benchmark seed files (OWASP fixtures)
milestone: M36
status: draft
updated: 2026-05-05
@acp.meta.end -->



These files contain intentional OWASP Top 10 security vulnerabilities for
benchmark testing purposes ONLY.

**DO NOT use these files in production.**
**DO NOT copy code from these files into real applications.**

These files are inputs to the ACP benchmark suite. The benchmark measures
how well AI-guided code review detects and fixes these vulnerabilities.
```

### 20 Express.js files with OWASP violations

Cover at minimum:
- **A01 Broken Access Control**: Missing authorization middleware (3 files)
- **A02 Cryptographic Failures**: Hardcoded secrets, MD5 passwords (2 files)
- **A03 Injection**: SQL concatenation, NoSQL injection patterns (4 files)
- **A04 Insecure Design**: Missing rate limiting, missing CORS (2 files)
- **A05 Security Misconfiguration**: Debug mode, default creds, verbose errors (2 files)
- **A06 Vulnerable Components**: Express without helmet, outdated auth (1 file)
- **A07 Auth Failures**: No session expiry, weak token generation (2 files)
- **A09 Logging Failures**: Sensitive data in logs (1 file)
- **A10 SSRF**: URL from user input passed to fetch (1 file)
- **Cross-cutting**: Mixed violations file (2 files)

Each file should have a comment block at the top listing the specific violations it contains, e.g.:
```javascript
// BENCHMARK FIXTURE — DELIBERATELY INSECURE
// Violations in this file:
// - A03: SQL injection via string concatenation (line 24)
// - A01: Missing authentication middleware (line 8)
```

## Expected Output

### Files Created
- `agent/benchmarks/suite/saas-platform/seed/README.md`
- `agent/benchmarks/suite/saas-platform/seed/auth-controller.js` (+ 19 more .js files)

### Minimum: 20 JS files + 1 README

## Verification
- [ ] README has DELIBERATELY INSECURE warning
- [ ] All 20 files have comment block listing their violations
- [ ] Coverage spans ≥8 of the OWASP Top 10 categories
- [ ] No real passwords or real connection strings in the files

## User-Observable Acceptance
Running `grep -r "BENCHMARK FIXTURE" agent/benchmarks/suite/saas-platform/seed/*.js | wc -l` returns 20 (all files have the warning comment). The benchmark runner (`verify.sh` from task-183) can scan these files and verify violations are present.
