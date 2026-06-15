# Task 137: Bootstrap Repository + TanStack Start

<!-- @acp.meta.task
topic: bootstrap, repository, tanstack, start
description: Task 137: Bootstrap Repository + TanStack Start
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-137  
**Priority**: P0  
**Estimated Hours**: 3–4h  
**Started**: 2026-05-06  
**Completed**: 2026-05-06  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  

---

## Objective

Create the `agent-context-protocol-visualizer` GitHub repository and initialize a working TanStack Start application with Tailwind CSS, TypeScript, and a functional local dev server.

---

## Context

M25 delivers a standalone browser-based dashboard for ACP `progress.yaml` files. This task bootstraps the new repository and build toolchain so subsequent tasks can add features on top of a working baseline.

The app lives in a **separate repository** from ACP core (`agent-context-protocol-visualizer`). ACP core tracks the milestone in its own `progress.yaml`.

---

## Steps

### 1. Create the repository

Create a new GitHub repository: `agent-context-protocol-visualizer`
- Visibility: Public
- Description: "Browser-based dashboard for visualizing ACP progress.yaml files"
- License: MIT
- Initialize with README

### 2. Initialize TanStack Start project

```bash
npx create-tsrouter-app@latest . --framework=react --target=server --tailwind --git-init false
```

Or follow current TanStack Start docs for the recommended init command. The project must:
- Use React + TypeScript
- Target server (not static) — required for the server route that reads the filesystem
- Include Tailwind CSS
- Support Vite dev server (`npm run dev`)

### 3. Verify file structure matches architecture

Confirm these directories exist (create empty ones if missing):
- `app/routes/` — TanStack Start file-based routing
- `app/components/` — UI component stubs
- `app/lib/` — utility libraries
- `server/routes/api/` — server-side API routes

### 4. Add dependencies

```bash
npm install js-yaml @tanstack/react-table fuse.js
npm install --save-dev @types/js-yaml
```

### 5. Add a root layout stub

Create `app/routes/__root.tsx` with a minimal shell:
- HTML `<head>` with Tailwind base styles
- `<main>` wrapper with neutral gray background
- `<Outlet />` for child routes

### 6. Add a placeholder home route

Create `app/routes/index.tsx` that renders:
```
ACP Progress Visualizer — P0 MVP
Loading progress.yaml...
```

### 7. Verify dev server starts

```bash
npm run dev
```

Confirm the Vite dev server starts without errors and the placeholder renders at `http://localhost:3000` (or configured port).

### 8. Commit bootstrap

```bash
git add .
git commit -m "chore: bootstrap TanStack Start + Tailwind (M25 task-137)"
git push origin main
```

---

## Expected Output

### Files Created
- `agent-context-protocol-visualizer/` (new repository on GitHub)
- `package.json` — dependencies including js-yaml, @tanstack/react-table, fuse.js
- `app/routes/__root.tsx` — root layout shell
- `app/routes/index.tsx` — placeholder home route
- `app/components/.gitkeep` — component stubs directory
- `app/lib/.gitkeep` — lib directory
- `server/routes/api/.gitkeep` — server API directory

### Files Modified
- N/A (new repo)

---

## Verification

- [ ] Repository exists on GitHub as `agent-context-protocol-visualizer`
- [ ] `npm install` completes without errors
- [ ] `npm run dev` starts Vite dev server without errors
- [ ] Placeholder renders at localhost
- [ ] TypeScript type-checks without errors (`npm run typecheck` or `tsc --noEmit`)
- [ ] `js-yaml`, `@tanstack/react-table`, `fuse.js` in `package.json`
- [ ] Root layout and placeholder home route exist

---

## User-Observable Acceptance

- Opening `http://localhost:3000` (or configured port) in a browser shows a page with "ACP Progress Visualizer" text
- No errors in browser console
- `npm run dev` output shows "ready" or "listening" with no TypeScript errors
