# Task 143: Dashboard Shell (Metadata, Progress Bar, Next Steps)

<!-- @acp.meta.task
topic: dashboard, shell, metadata, progress, bar, next, steps
description: Task 143: Dashboard Shell (Metadata, Progress Bar, Next Steps)
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-143  
**Priority**: P0  
**Estimated Hours**: 3–4h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-142 (Search + Status Filter)

---

## Objective

Build the polished dashboard home page — project metadata header, overall completion progress bar, current milestone callout, and the next steps panel. Replace the temporary raw JSON display from task-139 with the final P0 landing view.

---

## Context

After tasks 137–142 implement the infrastructure and views, this task assembles the home page that users see first. It's the "at a glance" summary — one screen that tells the full project story: what it is, how far along it is, what's active, and what's next.

---

## Steps

### 1. Update root layout `app/routes/__root.tsx`

Replace the minimal shell with the full layout:

**Sidebar** (left, fixed width ~200px):
- App name: "ACP Visualizer"
- Navigation links:
  - 🏠 Dashboard (index)
  - 📊 Milestones (table/tree)
  - 🔍 Search
- Small footer: version from `data.project.version`

**Main area** (flex-1, scrollable):
- Top header bar: `SearchBar` (full width)
- `<Outlet />` below

**Color scheme**: neutral gray sidebar (`bg-gray-900 text-gray-100`), white main area.

### 2. Create `app/components/NextSteps.tsx`

```tsx
interface Props {
  items: string[];
}

export function NextSteps({ items }: Props) {
  if (!items.length) return null;
  return (
    <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
      <h2 className="text-sm font-semibold text-blue-900 mb-2">▶ Next Steps</h2>
      <ul className="space-y-1">
        {items.map((item, i) => (
          <li key={i} className="text-sm text-blue-800 font-mono">{item}</li>
        ))}
      </ul>
    </div>
  );
}
```

### 3. Create `app/components/ProjectHeader.tsx`

```tsx
import type { ProjectMetadata } from '../lib/types';
import { StatusBadge } from './StatusBadge';

export function ProjectHeader({ project }: { project: ProjectMetadata }) {
  return (
    <div className="border-b border-gray-200 pb-4 mb-6">
      <div className="flex items-center gap-3 mb-1">
        <h1 className="text-xl font-bold text-gray-900">{project.name}</h1>
        <StatusBadge status={project.status} />
        <span className="text-xs font-mono text-gray-400">v{project.version}</span>
      </div>
      <div className="flex gap-4 text-xs text-gray-500">
        <span>Started: {project.started}</span>
        <span>Current milestone: <strong>{project.current_milestone}</strong></span>
      </div>
      <p className="mt-2 text-sm text-gray-600">{project.description}</p>
    </div>
  );
}
```

### 4. Create `app/components/OverallProgress.tsx`

Compute overall completion across all milestones:

```tsx
import type { Milestone } from '../lib/types';
import { ProgressBar } from './ProgressBar';

export function OverallProgress({ milestones }: { milestones: Milestone[] }) {
  const total = milestones.length;
  const completed = milestones.filter((m) => m.status === 'completed').length;
  const inProgress = milestones.filter((m) => m.status === 'in_progress').length;
  const pct = total > 0 ? Math.round((completed / total) * 100) : 0;

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4">
      <div className="flex items-center justify-between mb-2">
        <h2 className="text-sm font-semibold text-gray-700">Overall Progress</h2>
        <span className="text-sm font-mono text-gray-500">{completed}/{total} milestones</span>
      </div>
      <ProgressBar value={pct} />
      <div className="flex gap-4 mt-2 text-xs text-gray-400">
        <span>✅ {completed} completed</span>
        <span>🔄 {inProgress} in progress</span>
        <span>⬚ {total - completed - inProgress} not started</span>
      </div>
    </div>
  );
}
```

### 5. Replace `app/routes/index.tsx` with the full home page

```tsx
import { useProgressData } from '../lib/data-source';
import { ProjectHeader } from '../components/ProjectHeader';
import { OverallProgress } from '../components/OverallProgress';
import { NextSteps } from '../components/NextSteps';

export default function Home() {
  const { data, error, loading } = useProgressData();
  if (loading) return <div className="p-6 text-gray-400 animate-pulse">Loading…</div>;
  if (error || !data) return <div className="p-6 text-red-500">Error: {error}</div>;

  const milestones = Object.values(data.milestones);

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <ProjectHeader project={data.project} />
      <OverallProgress milestones={milestones} />
      <NextSteps items={data.next_steps} />
    </div>
  );
}
```

### 6. Final visual pass

- Verify spacing, typography, and color consistency across all pages (Dashboard, Milestones, Search)
- Ensure no layout overflow on a 1440px desktop window
- Confirm sidebar navigation links highlight the active route

---

## Expected Output

### Files Created
- `app/components/NextSteps.tsx`
- `app/components/ProjectHeader.tsx`
- `app/components/OverallProgress.tsx`

### Files Modified
- `app/routes/index.tsx` — final home page (replaces raw JSON placeholder)
- `app/routes/__root.tsx` — full sidebar + header layout

---

## Verification

- [ ] Dashboard home shows project name, version, status, current milestone
- [ ] Overall progress shows correct `completed / total` milestone count and %
- [ ] Next steps panel renders all items from `data.next_steps`
- [ ] Sidebar navigation links work (Dashboard, Milestones, Search)
- [ ] Active nav link is visually highlighted
- [ ] No layout overflow at 1440px width
- [ ] Loading state shows graceful placeholder
- [ ] Error state shows readable error message
- [ ] `tsc --noEmit` passes

---

## User-Observable Acceptance

- Opening `localhost` shows the ACP project name, version badge, and a progress bar showing 25/25 milestones completed (once M25 is done) or 24/25 in progress
- The "▶ Next Steps" panel shows the current `next_steps` from progress.yaml
- Left sidebar has three clickable links; clicking "Milestones" navigates to the milestones view
- Editing `agent/progress.yaml` (e.g., changing a `next_steps` entry) causes the dashboard to refresh and show the updated content within ~1 second
