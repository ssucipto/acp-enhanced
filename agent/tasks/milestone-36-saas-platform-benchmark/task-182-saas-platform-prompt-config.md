---
id: task-182
milestone: M36
title: Create saas-platform acp-prompts.yaml and baseline-prompts.yaml
status: not_started
priority: 1
complexity: medium
estimated_hours: 2.5
created: 2026-05-05
started:
completed:
---

<!-- @acp.meta.task
topic: create, saas-platform, acp-promptsyaml, and, baseline-promptsyaml
description: Create saas-platform acp-prompts.yaml and baseline-prompts.yaml
milestone: M36
status: draft
updated: 2026-05-05
@acp.meta.end -->


## Objective

Create two benchmark prompt configuration files for the saas-platform suite:
1. `agent/benchmarks/suite/saas-platform/acp-prompts.yaml` — 15 ACP-guided review prompts
2. `agent/benchmarks/suite/saas-platform/baseline-prompts.yaml` — 15 matched direct-instruction prompts

## Context

The benchmark compares ACP-guided vs baseline approaches on the same seed codebase (task-181). Both files have 15 matched prompts — each `acp-prompts.yaml` prompt has a semantically equivalent `baseline-prompts.yaml` counterpart. The runner scores each approach on how many OWASP violations are detected and correctly remediated.

## Implementation

### `acp-prompts.yaml` format:
```yaml
benchmark: saas-platform
approach: acp-guided
version: 1.0.0
prompts:
  - id: P001
    category: auth
    seed_files: [auth-controller.js, session-manager.js]
    prompt: |
      /acp-review --security --owasp
      Focus on the authentication controller and session manager.
      Use the ACP security review protocol.
    expected_detections: [A07-session-expiry, A02-weak-token]
    
  - id: P002
    category: injection
    seed_files: [user-service.js, query-builder.js]
    prompt: |
      /acp-review --security
      Scan for injection vulnerabilities using ACP's SQL injection probe.
    expected_detections: [A03-sql-injection, A03-nosql-injection]
```

Create 15 prompts covering: authentication (3), injection (3), access control (3), config/crypto (2), mixed OWASP (2), remediation verification (2).

### `baseline-prompts.yaml` format:
```yaml
benchmark: saas-platform
approach: baseline
version: 1.0.0
prompts:
  - id: P001
    category: auth
    seed_files: [auth-controller.js, session-manager.js]
    prompt: |
      Review this authentication code for security vulnerabilities.
      List any issues you find.
    expected_detections: [A07-session-expiry, A02-weak-token]
```

Each baseline prompt has the same `id`, `category`, `seed_files`, and `expected_detections` as its ACP counterpart. Only the `prompt:` text differs (no `/acp-` commands, no ACP protocol references).

## Expected Output

### Files Created
- `agent/benchmarks/suite/saas-platform/acp-prompts.yaml`
- `agent/benchmarks/suite/saas-platform/baseline-prompts.yaml`

## Verification
- [ ] Both files have exactly 15 prompts
- [ ] Matched prompts have same `id`, `category`, `seed_files`, `expected_detections`
- [ ] ACP prompts use `/acp-` command invocations
- [ ] Baseline prompts do NOT use ACP commands
- [ ] Both files are valid YAML

## User-Observable Acceptance
Running `python3 -c "import yaml; data=yaml.safe_load(open('agent/benchmarks/suite/saas-platform/acp-prompts.yaml')); print(len(data['prompts']))"` returns `15`. Same for baseline.
