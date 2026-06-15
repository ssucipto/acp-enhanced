# Task 140: Milestone Table View

<!-- @acp.meta.task
topic: milestone, table, view
description: Task 140: Milestone Table View
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-140  
**Priority**: P0  
**Estimated Hours**: 4–6h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-139 (Server Route + File Watcher)

---

## Objective

Implement the milestone table view using `@tanstack/react-table` — a sortable, compact data table showing all milestones with their status, progress, task counts, and estimated duration. This is the primary "at a glance" view for the dashboard.

---

## Context

The table view is the P0 workhorse. Users scanning 25+ milestones need to quickly sort by status, priority, or completion percentage. `@tanstack/react-table` provides headless table primitives — this task adds the visual layer on top with Tailwind.

---

## Steps

### 1. Create `app/components/StatusBadge.tsx`

```tsx
const COLORS = {
  completed:   'bg-green-100 text-green-800',
  in_progress: 'bg-blue-100 text-blue-800',
  not_started: 'bg-gray-100 text-gray-600',
};

export function StatusBadge({ status }: { status: string }) {
  const cls = COLORS[status as keyof typeof COLORS] ?? COLORS.not_started;
  return (
    <span className={`px-2 py-0.5 rounded text-xs font-mono font-medium ${cls}`}>
      {status.replace('_', ' ')}
    </span>
  );
}
```

### 2. Create `app/components/ProgressBar.tsx`

```tsx
export function ProgressBar({ value }: { value: number }) {
  return (
    <div className="flex items-center gap-2">
      <div className="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
        <div
          className="h-full bg-blue-500 rounded-full transition-all"
          style={{ width: `${value}%` }}
        />
      </div>
      <span className="text-xs text-gray-500 font-mono w-8 text-right">{value}%</span>
    </div>
  );
}
```

### 3. Create `app/components/MilestoneTable.tsx`

Use `@tanstack/react-table` with the following columns:

| Column | Field | Sortable |
|--------|-------|----------|
| ID | `id` (e.g. M25) | Yes |
| Name | `name` | Yes |
| Status | `status` | Yes |
| Progress | `progress` | Yes |
| Tasks | `tasks_completed / tasks_total` | Yes (by tasks_completed) |
| Priority | `priority` | Yes |
| Est. Weeks | `estimated_weeks` | No |
| Started | `started` | Yes |
| Completed | `completed` | Yes |

Implementation requirements:
- Clicking column headers toggles sort ascending/descending
- Arrow indicators (↑ ↓) show current sort direction
- Rows are clickable (no action required in P0 — reserve for P1 detail drawer)
- Alternating row shading (`bg-white` / `bg-gray-50`)
- `StatusBadge` in the Status column
- `ProgressBar` in the Progress column
- Compact row height (no padding waste)
- Sticky column headers on scroll

### 4. Create route `app/routes/milestones.tsx`

```tsx
import { useProgressData } from '../lib/data-source';
import { MilestoneTable } from '../components/MilestoneTable';

export default function MilestonesPage() {
  const { data, error, loading } = useProgressData();
  if (loading) return <p className="p-4 text-gray-500">Loading…</p>;
  if (error || !data) return <p className="p-4 text-red-500">Error: {error}</p>;
  const milestones = Object.values(data.milestones);
  return (
    <div className="p-4">
      <h1 className="text-lg font-semibold mb-4">Milestones</h1>
      <MilestoneTable milestones={milestones} />
    </div>
  );
}
```

### 5. Add navigation link to root layout

Add a "Milestones" nav link to `__root.tsx` sidebar so users can switch to the table view.

### 6. Verify rendering with real data

Open `http://localhost:3000/milestones` and confirm:
- All 25 M24 milestones render
- Sorting by progress works correctly
- Status badges render with correct colors
- Progress bars fill proportionally

---

## Expected Output

### Files Created
- `app/components/StatusBadge.tsx`
- `app/components/ProgressBar.tsx`
- `app/components/MilestoneTable.tsx`
- `app/routes/milestones.tsx`

### Files Modified
- `app/routes/__root.tsx` — navigation link added

---

## Verification

- [ ] `MilestoneTable` renders all milestones from live `useProgressData` hook
- [ ] Clicking column headers sorts rows correctly (ascending/descending)
- [ ] Sort direction arrows display on active column
- [ ] `StatusBadge` shows correct color for completed / in_progress / not_started
- [ ] `ProgressBar` fills proportionally to `progress` value
- [ ] `/milestones` route accessible from navigation
- [ ] Table handles 25+ rows without layout overflow
- [ ] `tsc --noEmit` passes

---

## User-Observable Acceptance

- Navigating to `/milestones` shows all milestones in a sortable table
- Clicking "Progress" column header sorts milestones from 0% → 100%
- M24 (completed, 100%) shows a full green progress bar and a green "completed" badge
- Clicking "Status" column header groups completed milestones together
