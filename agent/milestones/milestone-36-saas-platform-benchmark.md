# Milestone 36: saas-platform Benchmark Port

<!-- @acp.meta.milestone
topic: benchmark, saas-platform, e2e, security, express
description: Port the upstream saas-platform benchmark suite (security flaw remediation scenario) into ACP Enhanced's benchmark runner.
tasks: task-181..task-183
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Port the upstream `saas-platform` benchmark scenario (introduced v5.9.0) into ACP Enhanced's benchmark suite — 20 intentionally-buggy Express files, 15-step ACP vs 15-step baseline comparison, security flaw detection as the test scenario.  
**Duration**: 1 week  

---

## Overview

Upstream ACP added the `saas-platform` benchmark in v5.9.0 as a realistic multi-file security remediation scenario. It provides:
- **20 seed files**: Intentionally-buggy Express.js routes with OWASP Top 10 violations (SQL injection, missing auth, XSS, insecure headers, etc.)
- **30 prompts**: 15 ACP-guided steps + 15 direct-instruction baseline steps
- **Verification**: A `verify_saas_platform()` function that checks security flaw removal

ACP Enhanced already has the benchmark runner infrastructure (`agent/benchmarks/runner/`, `agent/benchmarks/suite/`). This milestone ports just the saas-platform scenario into that existing infrastructure.

---

## Deliverables

### 1. Benchmark Seed Files (20 buggy Express routes)
- `agent/benchmarks/suite/saas-platform/seed/` — 20 intentionally-vulnerable Express.js files

### 2. Benchmark Prompt Config
- `agent/benchmarks/suite/saas-platform/acp-prompts.yaml` — 15 ACP-guided benchmark prompts
- `agent/benchmarks/suite/saas-platform/baseline-prompts.yaml` — 15 baseline direct-instruction prompts

### 3. Verification Function
- `agent/benchmarks/suite/saas-platform/verify.sh` — checks that all OWASP violations are remediated

### 4. GitHub Actions Integration
- `.github/workflows/benchmarks.yml` updated (or created) with saas-platform step

---

## Success Criteria

- [ ] 20 seed files in `agent/benchmarks/suite/saas-platform/seed/` each contain ≥1 deliberate OWASP flaw
- [ ] `verify.sh` identifies all flaws in unmodified seed files (expect all fail)
- [ ] `verify.sh` passes against a manually-remediated version of seed files
- [ ] Benchmark runner (`agent/benchmarks/runner/`) can execute saas-platform scenario end-to-end
- [ ] GitHub Actions workflow step added for saas-platform benchmark

---

## Key Files to Create/Update

```
agent/benchmarks/suite/saas-platform/
├── seed/                   (new — 20 buggy Express files)
│   ├── auth.js
│   ├── users.js
│   └── ... (18 more)
├── acp-prompts.yaml        (new — 15 ACP benchmark prompts)
├── baseline-prompts.yaml   (new — 15 baseline prompts)
└── verify.sh               (new — security flaw checker)
.github/workflows/
└── benchmarks.yml          (new or update)
```

---

## Tasks

1. [task-181-saas-platform-seed-files.md](../tasks/milestone-36-saas-platform-benchmark/task-181-saas-platform-seed-files.md) — Create 20 intentionally-buggy Express seed files (OWASP flaws)
2. [task-182-saas-platform-prompt-config.md](../tasks/milestone-36-saas-platform-benchmark/task-182-saas-platform-prompt-config.md) — Create acp-prompts.yaml and baseline-prompts.yaml (30 prompts total)
3. [task-183-saas-platform-verify-and-ci.md](../tasks/milestone-36-saas-platform-benchmark/task-183-saas-platform-verify-and-ci.md) — Write verify.sh and wire into GitHub Actions benchmarks workflow

---

## Risks and Mitigation

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| Seed files are complex to make realistic but intentionally broken | Medium | Medium | Use minimal Express apps; focus on 5–6 OWASP categories max |
| Upstream benchmark prompts not publicly available | Low | Low | Generate equivalent prompts from OWASP remediation scenarios |

---

**Next Milestone**: M25 (ACP Progress Visualizer — not yet started)  
**Blockers**: None  
**Notes**: Low priority. Only begin if benchmark coverage is a current goal. The seed files contain deliberately insecure code — they are test fixtures, not deployable software.
