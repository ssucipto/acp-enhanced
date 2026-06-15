# Task 141: Milestone Tree View

<!-- @acp.meta.task
topic: milestone, tree, view
description: Task 141: Milestone Tree View
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-141  
**Priority**: P0  
**Estimated Hours**: 4–6h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-140 (Milestone Table View)

---

## Objective

Implement the milestone tree view — an expandable/collapsible hierarchy that shows milestones at the top level and reveals their tasks when expanded. This view is the primary way to drill into task-level detail.

---

## Context

The table view (task-140) gives a milestone-level overview. The tree view adds depth — users can expand a milestone to see its individual tasks with status, hours, and dates. This is essential for "what's in this milestone?" questions that the flat table can't answer.

---

## Steps

### 1. Create `app/components/TaskList.tsx`

Renders a list of tasks within a milestone's expanded row:

```tsx
import type { Task } from '../lib/types';
import { StatusBadge } from './StatusBadge';

export function TaskList({ tasks }: { tasks: Task[] }) {
  if (!tasks.length) return (
    <p className="text-xs text-gray-400 italic pl-4 py-2">No tasks defined</p>
  );
  return (
    <ul className="divide-y divide-gray-100">
      {tasks.map((task) => (
        <li key={task.id} className="flex items-start gap-3 px-4 py-2 hover:bg-gray-50">
          <span className="font-mono text-xs text-gray-400 w-20 shrink-0 pt-0.5">
            {task.id}
          </span>
          <span className="flex-1 text-sm text-gray-800">{task.name}</span>
          <StatusBadge status={task.status} />
          <span className="text-xs text-gray-400 font-mono w-16 text-right shrink-0">
            {task.estimated_hours}h est.
          </span>
          {task.actual_hours != null && (
            <span className="text-xs text-gray-400 font-mono w-16 text-right shrink-0">
              {task.actual_hours}h actual
            </span>
          )}
        </li>
      ))}
    </ul>
  );
}
```

### 2. Create `app/components/MilestoneTree.tsx`

State: a `Set<string>` of expanded milestone IDs, toggled by clicking the milestone row.

Each milestone row shows:
- Expand/collapse chevron (`▶` / `▼`)
- Milestone ID badge (`M25`)
- Milestone name
- StatusBadge
- Progress (inline bar + %)
- `tasks_completed / tasks_total`

When expanded, render `<TaskList tasks={tasksForMilestone} />` below the row.

```tsx
import { useState } from 'react';
import type { Milestone, Task } from '../lib/types';
import { StatusBadge } from './StatusBadge';
import { ProgressBar } from './ProgressBar';
import { TaskList } from './TaskList';

interface Props {
  milestones: Milestone[];
  tasks: Record<string, Task[]>;
}

export function MilestoneTree({ milestones, tasks }: Props) {
  const [expanded, setExpanded] = useState<Set<string>>(new Set());

  const toggle = (id: string) =>
    setExpanded((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });

  return (
    <div className="divide-y divide-gray-200 border border-gray-200 rounded-lg overflow-hidden">
      {milestones.map((m) => {
        const isOpen = expanded.has(m.id);
        const milestoneTaskList = tasks[m.id] ?? [];
        return (
          <div key={m.id}>
            {/* Milestone header row */}
            <button
              className="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 text-left"
              onClick={() => toggle(m.id)}
            >
              <span className="text-gray-400 w-4 shrink-0">{isOpen ? '▼' : '▶'}</span>
              <span className="font-mono text-xs text-gray-500 w-10 shrink-0">{m.id}</span>
              <span className="flex-1 text-sm font-medium text-gray-800">{m.name}</span>
              <StatusBadge status={m.status} />
              <div className="w-32 shrink-0">
                <ProgressBar value={m.progress} />
              </div>
              <span className="text-xs text-gray-400 font-mono w-16 text-right shrink-0">
                {m.tasks_completed}/{m.tasks_total} tasks
              </span>
            </button>
            {/* Expanded task list */}
            {isOpen && (
              <div className="bg-gray-50 border-t border-gray-100">
                <TaskList tasks={milestoneTaskList} />
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
```

### 3. Add "Expand All / Collapse All" controls

Add two buttons above the tree:
- **Expand All**: adds all milestone IDs to the expanded set
- **Collapse All**: clears the expanded set

### 4. Add tree view tab to `milestones.tsx` route

Add a tab bar with two options: **Table** | **Tree**

```tsx
const [view, setView] = useState<'table' | 'tree'>('table');
```

Render `<MilestoneTable>` or `<MilestoneTree>` based on `view`. Default to `'table'`.

### 5. Verify with real data

- Expand M24 — confirm 4 tasks render with correct status/hours
- Expand M19 — confirm 5 tasks render
- Expand a milestone with no tasks — confirm "No tasks defined" message
- Expand All, then Collapse All — verify both work

---

## Expected Output

### Files Created
- `app/components/TaskList.tsx`
- `app/components/MilestoneTree.tsx`

### Files Modified
- `app/routes/milestones.tsx` — tab bar added (Table | Tree), MilestoneTree rendered

---

## Verification

- [ ] `MilestoneTree` renders all milestones as collapsed rows by default
- [ ] Clicking a milestone row expands/collapses it with chevron change
- [ ] Expanded row shows `TaskList` with all tasks for that milestone
- [ ] Tasks show: ID, name, StatusBadge, estimated_hours, actual_hours (if set)
- [ ] "No tasks defined" message appears for milestones with empty task lists
- [ ] "Expand All" / "Collapse All" buttons work correctly
- [ ] Table | Tree tab bar switches between views
- [ ] `tsc --noEmit` passes

---

## User-Observable Acceptance

- On `/milestones` (Tree tab), clicking "M24 — AGENT.md Completeness" expands to show tasks 133–136 with their statuses
- Task 133 shows `completed` badge; task-136 shows `completed` badge
- Clicking M24 again collapses it
- "Expand All" opens every milestone simultaneously; "Collapse All" closes them all
