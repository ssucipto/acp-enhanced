# Task 138: YAML Parser + TypeScript Data Model

<!-- @acp.meta.task
topic: yaml, parser, typescript, data, model
description: Task 138: YAML Parser + TypeScript Data Model
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-138  
**Priority**: P0  
**Estimated Hours**: 2–3h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-137 (Bootstrap Repository)

---

## Objective

Implement the TypeScript interfaces and YAML parsing utility (`yaml-loader.ts`) that transforms raw `progress.yaml` content into strongly-typed application data.

---

## Context

All dashboard views depend on a reliable, typed data layer. This task establishes the canonical TypeScript interfaces for the progress data model and the `yaml-loader.ts` utility that normalises raw YAML into those types. Subsequent tasks (server route, table, tree, search) all import from this layer.

---

## Steps

### 1. Create TypeScript interfaces in `app/lib/types.ts`

```typescript
export interface ProgressData {
  project: ProjectMetadata;
  milestones: Record<string, Milestone>;
  tasks: Record<string, Task[]>;
  recent_work: WorkEntry[];
  next_steps: string[];
  notes: string[];
}

export interface ProjectMetadata {
  name: string;
  version: string;
  started: string;
  status: 'in_progress' | 'completed' | 'not_started';
  current_milestone: string;
  description: string;
}

export interface Milestone {
  id: string;           // injected key (e.g. "M25") not in raw YAML
  name: string;
  priority: number;
  status: 'completed' | 'in_progress' | 'not_started';
  progress: number;
  started: string | null;
  completed: string | null;
  estimated_weeks: string;
  tasks_completed: number;
  tasks_total: number;
  file: string;
  notes: string;
}

export interface Task {
  id: string;
  name: string;
  priority: number;
  status: 'completed' | 'in_progress' | 'not_started';
  started: string | null;
  file: string;
  estimated_hours: string;
  actual_hours: number | null;
  completed_date: string | null;
  notes: string;
  milestoneId: string;  // injected — which milestone this task belongs to
}

export interface WorkEntry {
  date: string;
  description: string;
  items: string[];
}
```

### 2. Create `app/lib/yaml-loader.ts`

```typescript
import yaml from 'js-yaml';
import type { ProgressData, Milestone, Task } from './types';

export function parseProgressYaml(raw: string): ProgressData {
  const doc = yaml.load(raw) as Record<string, unknown>;

  // Normalise milestones: inject 'id' from the YAML key
  const milestonesRaw = (doc.milestones ?? {}) as Record<string, unknown>;
  const milestones: Record<string, Milestone> = {};
  for (const [id, data] of Object.entries(milestonesRaw)) {
    milestones[id] = { id, ...(data as object) } as Milestone;
  }

  // Normalise tasks: inject 'milestoneId' from the YAML key
  const tasksRaw = (doc.tasks ?? {}) as Record<string, unknown[]>;
  const tasks: Record<string, Task[]> = {};
  for (const [milestoneId, taskList] of Object.entries(tasksRaw)) {
    tasks[milestoneId] = (taskList ?? []).map((t) => ({
      milestoneId,
      ...(t as object),
    })) as Task[];
  }

  return {
    project: doc.project as ProgressData['project'],
    milestones,
    tasks,
    recent_work: (doc.recent_work as WorkEntry[]) ?? [],
    next_steps: (doc.next_steps as string[]) ?? [],
    notes: (doc.notes as string[]) ?? [],
  };
}
```

### 3. Write unit tests in `app/lib/yaml-loader.test.ts`

Cover:
- Valid progress.yaml parses without error
- `milestones` keys have `id` field injected
- `tasks` items have `milestoneId` injected
- Empty `recent_work` / `next_steps` / `notes` default to `[]`
- Invalid YAML throws a descriptive error

Use the project's test runner (Vitest, configured by TanStack Start, or add Vitest manually).

### 4. Verify types compile

```bash
npm run typecheck
```

No TypeScript errors.

---

## Expected Output

### Files Created
- `app/lib/types.ts` — TypeScript interfaces for the full progress data model
- `app/lib/yaml-loader.ts` — YAML parsing + normalisation utility
- `app/lib/yaml-loader.test.ts` — Unit tests

### Files Modified
- N/A

---

## Verification

- [ ] `app/lib/types.ts` defines all 6 interfaces (ProgressData, ProjectMetadata, Milestone, Task, WorkEntry + `tasks` structure)
- [ ] `Milestone.id` and `Task.milestoneId` are injected by the parser (not in raw YAML)
- [ ] `parseProgressYaml` handles missing optional arrays gracefully (defaults to `[]`)
- [ ] Unit tests pass (`npm test` or `npx vitest`)
- [ ] `npm run typecheck` passes with zero errors

---

## User-Observable Acceptance

N/A — this is a library module with no direct UI. Acceptance is via unit tests passing and TypeScript compiling cleanly. Subsequent tasks (task-139 server route, task-140 table) consume this module and provide observable UI.
