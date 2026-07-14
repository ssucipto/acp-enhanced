# Milestone 25: ACP Progress Visualizer (P0 MVP)

**Goal**: Build a standalone TanStack Start web application that renders ACP `progress.yaml` files as an interactive dashboard — table and tree views of milestones/tasks, with search, filtering, and auto-refresh.  
**Duration**: ~3 weeks (22–32 estimated agent-hours across 8 tasks)  
**Dependencies**: M24 (AGENT.md Completeness) — completed ✅  
**Status**: completed  
**Repository**: `agent-context-protocol-visualizer` (new repo — greenfield)  
**Design**: [`agent/design/visualizer.requirements.md`](../design/visualizer.requirements.md)  

---

## Overview

ACP's `progress.yaml` files grow large (1,800+ lines for this project) and are difficult to navigate in a text editor. Text-based status commands like `@acp.status` provide useful summaries but lack visual hierarchy, search, filtering, and real-time updates.

M25 delivers the P0 MVP: a browser-based, locally-run dashboard that reads `progress.yaml` from the filesystem and renders milestone/task data with expandable views, fuse.js-powered search, status-based filtering, and file-watcher auto-refresh.

**Scope**: P0 MVP only. P1 (kanban, GitHub remote loading, multi-project) = M26. P2 (Gantt, dependency graph) = M27.

---

## Tasks

| Task | Name | Est. Hours |
|------|------|-----------|
| task-137 | Bootstrap Repository + TanStack Start | 3–4h |
| task-138 | YAML Parser + TypeScript Data Model | 2–3h |
| task-139 | Server Route + File Watcher (auto-refresh) | 2–3h |
| task-140 | Milestone Table View | 4–6h |
| task-141 | Milestone Tree View | 4–6h |
| task-142 | Search + Status Filter | 3–4h |
| task-143 | Dashboard Shell (metadata, progress bar, next steps) | 3–4h |
| task-144 | @acp.visualize Command + ACP Integration | 1–2h |

---

## Deliverables

### Repository
- `agent-context-protocol-visualizer/` (new GitHub repo)
- Full TanStack Start project with Tailwind CSS and Vite build

### Application Features (P0)
- Project metadata display (name, version, status, current milestone)
- Milestone table view with sortable columns (`@tanstack/react-table`)
- Milestone tree view — expandable milestones → tasks hierarchy
- Status badges (color-coded: green/blue/gray)
- Overall completion percentage progress bar
- Next steps display
- Status filtering (all / in-progress / completed / not-started)
- Fuse.js search across milestones and tasks
- Local filesystem loading via TanStack Start server route
- File watcher auto-refresh (SSE when `progress.yaml` changes)
- `npm run dev` starts Vite dev server on localhost

### ACP Integration
- `agent/commands/acp.visualize.md` command file (in ACP core repo)
- Command launches dev server, opens browser, loads progress.yaml path

---

## Architecture

```
agent-context-protocol-visualizer/
├── app/
│   ├── routes/
│   │   ├── __root.tsx          # Root layout (sidebar, header)
│   │   ├── index.tsx           # Dashboard home (project overview)
│   │   ├── milestones.tsx      # Milestone views (table/tree)
│   │   ├── tasks.tsx           # Task detail views
│   │   └── search.tsx          # Global search results
│   ├── components/
│   │   ├── MilestoneTable.tsx  # @tanstack/react-table view
│   │   ├── MilestoneTree.tsx   # Expandable/collapsible tree
│   │   ├── TaskList.tsx        # Tasks within a milestone
│   │   ├── ProgressBar.tsx     # Overall completion %
│   │   ├── StatusBadge.tsx     # Color-coded status indicators
│   │   ├── SearchBar.tsx       # Fuse.js-powered search
│   │   ├── FilterBar.tsx       # Status filter controls
│   │   └── NextSteps.tsx       # Next steps display
│   └── lib/
│       ├── yaml-loader.ts      # YAML parsing + data normalization
│       ├── data-source.ts      # Filesystem data source
│       └── search.ts           # Fuse.js index configuration
├── server/
│   └── routes/
│       └── api/
│           └── progress.ts     # Server route: read progress.yaml from disk
├── app.config.ts
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | TanStack Start (React) |
| Styling | Tailwind CSS |
| Table | @tanstack/react-table |
| Search | fuse.js |
| YAML parsing | js-yaml |
| Build | Vite |
| Type checking | TypeScript |

---

## Success Criteria

- [ ] `npm run dev` starts successfully, dashboard loads at localhost
- [ ] progress.yaml data renders correctly in table and tree views
- [ ] Search finds milestones and tasks by name/ID
- [ ] Status filter correctly shows/hides items
- [ ] Dashboard auto-refreshes when progress.yaml is edited
- [ ] `@acp.visualize` command file exists and documents how to launch
- [ ] TypeScript types compile without errors

---

## Notes

- **Separate repo** — this milestone creates a new GitHub repository. Tasks are implemented there but tracked in this progress.yaml.
- **P0 only** — kanban (P1), Gantt (P2), GitHub remote loading (P1), and multi-project support (P1) are explicitly out of scope for M25.
- **Desktop-optimized** — no mobile responsiveness required for P0.
- **Visual design** — minimal admin dashboard (Linear/Vercel style), monospace data values, neutral gray palette with status accent colors.
