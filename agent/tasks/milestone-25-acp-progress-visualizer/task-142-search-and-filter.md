# Task 142: Search + Status Filter

<!-- @acp.meta.task
topic: search, status, filter
description: Task 142: Search + Status Filter
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-142  
**Priority**: P0  
**Estimated Hours**: 3–4h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-141 (Milestone Tree View)

---

## Objective

Implement fuse.js-powered search across all milestone and task names, and status-based filter controls that apply to both the table view and tree view simultaneously.

---

## Context

With 25+ milestones and 140+ tasks, finding a specific item by scrolling is impractical. Fuse.js provides fuzzy matching for quick keyword search. Status filtering lets users focus on "what's in progress right now" without noise from completed items.

---

## Steps

### 1. Create `app/lib/search.ts` — Fuse.js index configuration

```typescript
import Fuse from 'fuse.js';
import type { Milestone, Task } from './types';

export type SearchResult =
  | { type: 'milestone'; item: Milestone }
  | { type: 'task'; item: Task };

export function buildSearchIndex(
  milestones: Milestone[],
  tasks: Task[]
): Fuse<SearchResult> {
  const items: SearchResult[] = [
    ...milestones.map((m) => ({ type: 'milestone' as const, item: m })),
    ...tasks.map((t) => ({ type: 'task' as const, item: t })),
  ];
  return new Fuse(items, {
    keys: [
      { name: 'item.id',   weight: 0.3 },
      { name: 'item.name', weight: 0.7 },
    ],
    threshold: 0.35,
    includeScore: true,
  });
}
```

### 2. Create `app/components/SearchBar.tsx`

```tsx
interface Props {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
}

export function SearchBar({ value, onChange, placeholder = 'Search milestones and tasks…' }: Props) {
  return (
    <input
      type="search"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg font-mono
                 focus:outline-none focus:ring-2 focus:ring-blue-400 bg-white"
    />
  );
}
```

### 3. Create `app/components/FilterBar.tsx`

Status filter buttons: **All** | **In Progress** | **Completed** | **Not Started**

```tsx
type StatusFilter = 'all' | 'in_progress' | 'completed' | 'not_started';

interface Props {
  value: StatusFilter;
  onChange: (v: StatusFilter) => void;
}

const OPTIONS: { label: string; value: StatusFilter }[] = [
  { label: 'All', value: 'all' },
  { label: 'In Progress', value: 'in_progress' },
  { label: 'Completed', value: 'completed' },
  { label: 'Not Started', value: 'not_started' },
];

export function FilterBar({ value, onChange }: Props) {
  return (
    <div className="flex gap-1">
      {OPTIONS.map((opt) => (
        <button
          key={opt.value}
          onClick={() => onChange(opt.value)}
          className={`px-3 py-1.5 text-xs rounded-md font-medium transition-colors
            ${value === opt.value
              ? 'bg-blue-600 text-white'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
}
```

### 4. Wire search + filter into `milestones.tsx`

Add state at the route level:
```tsx
const [query, setQuery] = useState('');
const [filter, setFilter] = useState<StatusFilter>('all');
```

**Filter logic** (applied to both table and tree):
```typescript
const allMilestones = Object.values(data.milestones);
const filtered = allMilestones.filter((m) =>
  filter === 'all' || m.status === filter
);
```

**Search logic** (applied after filter, only when `query.length >= 2`):
- Build fuse index from `filtered` milestones + their tasks
- Run `fuse.search(query)`
- Show results grouped by type (milestones first, then tasks)
- When no query: show all filtered milestones in normal table/tree view

### 5. Create `app/routes/search.tsx` — dedicated search results page

When `query.length >= 2`, show a unified results list:

```
Search results for "visualizer" (3 results)

Milestones (1):
  M25  ACP Progress Visualizer          in_progress   0%

Tasks (2):
  task-137  Bootstrap Repository + TanStack Start   not_started
  task-138  YAML Parser + TypeScript Data Model      not_started
```

### 6. Add search bar to root layout header

The `SearchBar` lives in the top header (always visible). Typing in it:
- `< 2 chars`: no-op
- `>= 2 chars`: navigates to `/search?q=<query>` or shows inline results

---

## Expected Output

### Files Created
- `app/lib/search.ts` — Fuse.js index builder
- `app/components/SearchBar.tsx`
- `app/components/FilterBar.tsx`
- `app/routes/search.tsx`

### Files Modified
- `app/routes/milestones.tsx` — filter state + FilterBar + filtered data passed to table/tree
- `app/routes/__root.tsx` — SearchBar added to header

---

## Verification

- [ ] `buildSearchIndex` returns a Fuse instance with milestone + task items
- [ ] Search for "M24" returns the M24 milestone result
- [ ] Search for "bootstrap" returns task-137 result
- [ ] Search with `threshold: 0.35` handles minor typos (e.g., "visualzer" finds "visualizer")
- [ ] Filter "In Progress" shows only milestones with `status: in_progress`
- [ ] Filter "Completed" shows only completed milestones
- [ ] Filter "All" restores full list
- [ ] Search and filter compose correctly (search within filtered results)
- [ ] `tsc --noEmit` passes

---

## User-Observable Acceptance

- Typing "visualizer" in the search bar shows M25 and its tasks
- Typing "bootstrap" shows task-137 (Bootstrap Repository + TanStack Start)
- Clicking "Completed" filter shows only M1–M24 (all completed), not M25
- Clicking "In Progress" with M25 in progress shows only M25
- Clearing the search field restores the full filtered list
