# Task 139: Server Route + File Watcher (Auto-Refresh)

<!-- @acp.meta.task
topic: server, route, file, watcher, auto-refresh
description: Task 139: Server Route + File Watcher (Auto-Refresh)
milestone: M25
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M25 — ACP Progress Visualizer (P0 MVP)  
**Task ID**: task-139  
**Priority**: P0  
**Estimated Hours**: 2–3h  
**Design Reference**: [ACP Progress Visualizer](../../design/visualizer.requirements.md)  
**Depends On**: task-138 (YAML Parser + Data Model)

---

## Objective

Implement the TanStack Start server route that reads `progress.yaml` from the local filesystem and serves the parsed data as JSON, plus a file watcher that pushes auto-refresh events to the browser via Server-Sent Events (SSE) when the file changes.

---

## Context

The dashboard needs a server-side data source because browser JavaScript cannot read arbitrary filesystem paths. A TanStack Start server route handles the filesystem read. The file watcher enables "live dashboard" behaviour — when the user runs `@acp.proceed` and progress.yaml updates, the dashboard refreshes without a manual browser reload.

---

## Steps

### 1. Create the server route `server/routes/api/progress.ts`

```typescript
import { createAPIFileRoute } from '@tanstack/start/api';
import { readFileSync } from 'node:fs';
import { parseProgressYaml } from '../../../app/lib/yaml-loader';

const DEFAULT_PATH = process.env.PROGRESS_YAML_PATH ?? 'agent/progress.yaml';

export const APIRoute = createAPIFileRoute('/api/progress')({
  GET: ({ request }) => {
    const url = new URL(request.url);
    const filePath = url.searchParams.get('path') ?? DEFAULT_PATH;

    try {
      const raw = readFileSync(filePath, 'utf-8');
      const data = parseProgressYaml(raw);
      return Response.json(data);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      return Response.json({ error: message }, { status: 500 });
    }
  },
});
```

- The `path` query parameter allows pointing at any `progress.yaml` (defaults to `agent/progress.yaml` relative to CWD)
- Returns `{ error }` JSON with HTTP 500 on failure

### 2. Create the SSE route `server/routes/api/watch.ts`

```typescript
import { createAPIFileRoute } from '@tanstack/start/api';
import { watch } from 'node:fs';

const DEFAULT_PATH = process.env.PROGRESS_YAML_PATH ?? 'agent/progress.yaml';

export const APIRoute = createAPIFileRoute('/api/watch')({
  GET: ({ request }) => {
    const url = new URL(request.url);
    const filePath = url.searchParams.get('path') ?? DEFAULT_PATH;

    const stream = new ReadableStream({
      start(controller) {
        const watcher = watch(filePath, () => {
          controller.enqueue(`data: changed\n\n`);
        });
        request.signal.addEventListener('abort', () => {
          watcher.close();
          controller.close();
        });
      },
    });

    return new Response(stream, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
      },
    });
  },
});
```

### 3. Create `app/lib/data-source.ts` — client-side data fetching hook

```typescript
import { useEffect, useState } from 'react';
import type { ProgressData } from './types';

export function useProgressData(path?: string) {
  const [data, setData] = useState<ProgressData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const url = path ? `/api/progress?path=${encodeURIComponent(path)}` : '/api/progress';

  const load = async () => {
    try {
      setLoading(true);
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = await res.json();
      setData(json);
      setError(null);
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    // SSE auto-refresh
    const watchUrl = path ? `/api/watch?path=${encodeURIComponent(path)}` : '/api/watch';
    const source = new EventSource(watchUrl);
    source.onmessage = () => load();
    return () => source.close();
  }, [path]);

  return { data, error, loading, reload: load };
}
```

### 4. Update `app/routes/index.tsx` to use the hook

Replace the placeholder with:
```tsx
import { useProgressData } from '../lib/data-source';

export default function Home() {
  const { data, error, loading } = useProgressData();
  if (loading) return <p className="p-4 text-gray-500">Loading progress.yaml…</p>;
  if (error) return <p className="p-4 text-red-500">Error: {error}</p>;
  return (
    <pre className="p-4 text-xs font-mono text-gray-800 overflow-auto">
      {JSON.stringify(data, null, 2)}
    </pre>
  );
}
```

This is a temporary raw JSON display — task-143 will replace it with the polished dashboard shell.

### 5. Test the route manually

```bash
npm run dev
curl http://localhost:3000/api/progress
```

Confirm JSON response matches the parsed structure from task-138 types.

---

## Expected Output

### Files Created
- `server/routes/api/progress.ts` — server route serving parsed progress.yaml JSON
- `server/routes/api/watch.ts` — SSE server route for file change events
- `app/lib/data-source.ts` — `useProgressData` React hook

### Files Modified
- `app/routes/index.tsx` — updated to fetch and display live data

---

## Verification

- [ ] `GET /api/progress` returns valid JSON matching `ProgressData` interface
- [ ] `GET /api/progress?path=<custom-path>` loads a different progress.yaml
- [ ] `GET /api/progress` returns `{ error }` with HTTP 500 for missing/invalid file
- [ ] `GET /api/watch` streams `data: changed` events when `progress.yaml` is edited
- [ ] Browser auto-refreshes dashboard within 1s of file change (manual test)
- [ ] `useProgressData` hook returns `{ data, error, loading }` correctly
- [ ] `index.tsx` renders raw JSON from live server route (no hardcoded data)

---

## User-Observable Acceptance

- Running `npm run dev`, opening `localhost`, and seeing the raw JSON of this project's `progress.yaml` rendered in the browser
- Editing `agent/progress.yaml` (e.g., adding a space) and watching the browser page refresh automatically within ~1 second
