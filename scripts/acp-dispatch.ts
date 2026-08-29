import OpenAI from "openai";
import matter from "gray-matter";
import yaml from "js-yaml";
import {
  readFileSync,
  appendFileSync,
  existsSync,
  writeFileSync,
} from "fs";
import path from "path";

// ============================================================
// ACP Enhanced — Dispatch Script
// Usage: npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/task-NNN.md
// ============================================================

const OPENROUTER_BASE = "https://openrouter.ai/api/v1";
const AGENT_DIR = "agent";

// ── Model Configuration ─────────────────────────────────────
const MODEL_MAP: Record<string, { model: string; inputCost: number; outputCost: number }> = {
  "claude-sonnet":    { model: "anthropic/claude-sonnet-4-5",    inputCost: 3.00,  outputCost: 15.00 },
  "deepseek-v4-flash":{ model: "deepseek/deepseek-v4-flash",     inputCost: 0.14,  outputCost: 0.28  },
  "deepseek-v4-pro":  { model: "deepseek/deepseek-v4-pro",       inputCost: 0.435, outputCost: 0.87  },
  "gemini-flash":     { model: "google/gemini-2.0-flash-exp",    inputCost: 0.075, outputCost: 0.30  },
  "local-script":     { model: "",                               inputCost: 0,     outputCost: 0     },
};

// ── Helpers ──────────────────────────────────────────────────
function readAgent(relPath: string): string {
  const full = path.join(AGENT_DIR, relPath);
  if (!existsSync(full)) return "";
  return readFileSync(full, "utf-8");
}

export function getLastNSessions(n: number, content?: string): string {
  const raw = content ?? readAgent("memory/sessions.md");
  if (!raw) return "";
  const entries = raw.split("\n- date:").filter(Boolean);
  return entries
    .slice(-n)
    .map((e) => (e.startsWith("- date:") ? e : "- date:" + e))
    .join("\n");
}

export function getFilteredLessons(taskType: string, content?: string): string {
  const raw = content ?? readAgent("memory/lessons.md");
  if (!raw) return "";
  const entries = raw.split("\n- date:").filter(Boolean);
  const relevant = entries.filter(
    (e) =>
      // Skip archived lessons (see lessons.md schema comment)
      !e.includes("status: archived") &&
      (
        e.includes(`task_type: ${taskType}`) ||
        e.includes("task_type: all") ||
        e.includes("priority: high")
      )
  );
  return relevant
    .slice(-5)
    .map((e) => (e.startsWith("- date:") ? e : "- date:" + e))
    .join("\n");
}

function extractSection(filePath: string, sectionId: string): string {
  const full = path.join(AGENT_DIR, filePath);
  if (!existsSync(full)) return "";
  const content = readFileSync(full, "utf-8");
  // XML tag extraction
  const xmlMatch = content.match(
    new RegExp(`<${sectionId}[^>]*>([\\s\\S]*?)<\\/${sectionId}>`, "i")
  );
  if (xmlMatch) return `<${sectionId}>${xmlMatch[1]}</${sectionId}>`;
  // Markdown section extraction (## heading)
  const lines = content.split("\n");
  let inSection = false;
  const result: string[] = [];
  for (const line of lines) {
    if (line.match(new RegExp(`^##.*${sectionId}`, "i"))) {
      inSection = true;
      result.push(line);
      continue;
    }
    if (inSection && line.startsWith("## ")) break;
    if (inSection) result.push(line);
  }
  return result.join("\n").slice(0, 3000); // cap section size
}

export function getSkillFile(taskType: string): string {
  const commandTypes = ["command-doc-write", "command-doc-update"];
  const scriptTypes = ["bash-script-create", "bash-script-fix", "bash-script-refactor", "preference-system", "bug-fix-simple", "bug-fix-complex"];
  const schemaTypes = ["yaml-schema"];
  const testTypes = ["e2e-test-write", "test-run"];
  const tsTypes = ["typescript-feature"];
  const crosscutTypes = [
    "wiki-update", "memory-write", "changelog-update", "progress-update",
    "adr-write", "audit-run", "milestone-create", "route-create",
    "upstream-parity-check", "documentation-sync", "crosscut",
  ];
  if (commandTypes.includes(taskType)) return "skills/commands.md";
  if (scriptTypes.includes(taskType)) return "skills/scripts.md";
  if (schemaTypes.includes(taskType)) return "skills/schemas.md";
  if (testTypes.includes(taskType)) return "skills/testing.md";
  if (tsTypes.includes(taskType)) return "skills/typescript.md";
  if (crosscutTypes.includes(taskType)) return "skills/crosscut.md";
  return "skills/crosscut.md";
}

export function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

/** Frontmatter fields dispatch reads. Extra keys from gray-matter are ignored. */
export interface TaskMeta {
  id?: string;
  task_type?: string;
  executor?: string;
}

interface TaxonomyTaskDef {
  context_required?: string[];
}

interface TaxonomyFile {
  task_types?: Record<string, TaxonomyTaskDef>;
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function loadTaxonomy(): TaxonomyFile {
  const loaded: unknown = yaml.load(readAgent("routing/taxonomy.yml"));
  if (!isPlainObject(loaded)) return {};
  const rawTypes = loaded.task_types;
  if (!isPlainObject(rawTypes)) return {};
  const task_types: Record<string, TaxonomyTaskDef> = {};
  for (const [key, val] of Object.entries(rawTypes)) {
    if (!isPlainObject(val)) continue;
    const cr = val.context_required;
    task_types[key] = {
      context_required: Array.isArray(cr)
        ? cr.filter((item): item is string => typeof item === "string")
        : undefined,
    };
  }
  return { task_types };
}

export function toTaskMeta(data: unknown): TaskMeta {
  if (!isPlainObject(data)) return {};
  const meta: TaskMeta = {};
  if (typeof data.id === "string") meta.id = data.id;
  if (typeof data.task_type === "string") meta.task_type = data.task_type;
  if (typeof data.executor === "string") meta.executor = data.executor;
  return meta;
}

// ── Context Assembly (cache-optimised) ───────────────────────
export function buildContext(
  meta: TaskMeta,
  taskContent: string
): { system: string; user: string } {
  // STATIC SYSTEM PREFIX — identical bytes = cache hit
  const layer1 = [
    readAgent("core/identity.yml"),
    readAgent("core/constraints.yml"),
    readAgent("core/routing.yml"),
    readAgent(getSkillFile(meta.task_type ?? "crosscut")),
  ]
    .filter(Boolean)
    .join("\n\n");

  // DYNAMIC USER MESSAGE — fresh every call
  const taxonomy = loadTaxonomy();
  const taskDef = taxonomy.task_types?.[meta.task_type ?? ""] ?? {};
  const contextRequired: string[] = taskDef.context_required ?? [];

  const dynamicParts: string[] = [
    getLastNSessions(3),
    getFilteredLessons(meta.task_type ?? ""),
    taskContent,
  ];

  for (const ref of contextRequired) {
    if (ref === "active-task-only") continue;
    if (ref.includes("#")) {
      const [file, section] = ref.split("#");
      dynamicParts.push(extractSection(file, section));
    } else {
      const content = readAgent(ref);
      dynamicParts.push(content.slice(0, 4000)); // cap wiki files
    }
  }

  // Budget enforcement
  const user = dynamicParts.filter(Boolean).join("\n\n---\n\n");
  const totalTokens = estimateTokens(layer1) + estimateTokens(user);
  const budget = 6500;

  if (totalTokens > budget) {
    console.warn(
      `[ACP] ⚠ Context budget exceeded: ~${totalTokens} tokens (limit: ${budget}). Pruning wiki content.`
    );
    // Return trimmed version — drop wiki sections from dynamic parts
    const trimmedUser = [
      getLastNSessions(2),
      getFilteredLessons(meta.task_type ?? ""),
      taskContent,
    ]
      .filter(Boolean)
      .join("\n\n---\n\n");
    return { system: layer1, user: trimmedUser };
  }

  return { system: layer1, user };
}

// ── Ledger Logging ────────────────────────────────────────────
function appendLedger(
  meta: TaskMeta,
  inputTokens: number,
  outputTokens: number,
  costUsd: number
): void {
  const date = new Date().toISOString().slice(0, 10);
  const row =
    `| ${date} | ${meta.id ?? "?"} | ${meta.task_type ?? "?"} | ` +
    `${meta.executor ?? "?"} | ${inputTokens} | ${outputTokens} | ` +
    `$${costUsd.toFixed(4)} | |\n`;
  appendFileSync(path.join(AGENT_DIR, "routing/ledger.md"), row);
}

// ── Update core/routing.yml with session executor ─────────────
export function updateRoutingYml(
  executor: string,
  modelId: string,
  routingPath?: string
): void {
  const filePath =
    routingPath ?? path.join(AGENT_DIR, "core", "routing.yml");
  const original = readFileSync(filePath, "utf-8");
  const newSession =
    `session:\n  executor: ${executor}\n  model: ${modelId}\n  persona: B\n`;
  const sessionRe = /^session:\r?\n(?:  .*(?:\r?\n|$))*/m;
  if (!sessionRe.test(original)) {
    throw new Error(`[ACP] routing.yml missing session: block (${filePath})`);
  }
  const updated = original.replace(sessionRe, newSession);
  writeFileSync(filePath, updated, "utf-8");
}

// ── Main ──────────────────────────────────────────────────────
async function dispatch(taskPath: string) {
  if (!existsSync(taskPath)) {
    console.error(`[ACP] Task file not found: ${taskPath}`);
    process.exit(1);
  }

  const parsed = matter(readFileSync(taskPath, "utf-8"));
  const meta = toTaskMeta(parsed.data);
  const taskContent = parsed.content;
  const executor: string = meta.executor ?? "claude-sonnet";

  if (executor === "local-script") {
    console.log("[ACP] Local task — no API dispatch needed. Run your script manually.");
    return;
  }

  const apiKey = process.env.OPENROUTER_API_KEY?.trim();
  if (!apiKey) {
    console.error(
      "[ACP] OPENROUTER_API_KEY is not set. Export it or use Persona A (copilot). See scripts/QUICKSTART.md."
    );
    process.exit(1);
  }

  const modelConfig = MODEL_MAP[executor] ?? MODEL_MAP["claude-sonnet"];
  console.log(`[ACP] Dispatching ${meta.id} → ${executor} (${modelConfig.model})`);

  // Read project identity for OpenRouter attribution headers
  const identity = (yaml.load(readAgent("core/identity.yml")) ?? {}) as Record<string, unknown>;
  const repoField = (identity.repo as string) ?? "ssucipto/acp-enhanced";
  const repoUrl = (identity.homepage as string) ??
    (repoField.startsWith("http") ? repoField : `https://${repoField}`);
  const projectName = (identity.project as string) ?? "ACP Enhanced";

  const prompt = buildContext(meta, taskContent);
  const systemTokens = estimateTokens(prompt.system);
  const userTokens = estimateTokens(prompt.user);
  console.log(
    `[ACP] Context: ~${systemTokens} system (cached) + ~${userTokens} user tokens`
  );

  const client = new OpenAI({
    baseURL: OPENROUTER_BASE,
    apiKey,
    defaultHeaders: {
      "HTTP-Referer": repoUrl,
      "X-Title": projectName,
    },
  });

  const start = Date.now();
  let output = "";
  let inputTokens = 0;
  let outputTokens = 0;

  // SIGINT handler: flush partial ledger row, do NOT update routing.yml
  const sigintHandler = () => {
    process.stderr.write("\n[dispatch] Interrupted — flushing partial ledger row\n");
    appendLedger(meta, 0, 0, 0);
    process.exit(130);
  };
  process.on("SIGINT", sigintHandler);

  try {
    const stream = await client.chat.completions.create({
      model: modelConfig.model,
      messages: [
        { role: "system", content: prompt.system },
        { role: "user",   content: prompt.user },
      ],
      temperature: 0.0,
      stream: true,
      stream_options: { include_usage: true },
    });

    for await (const chunk of stream) {
      const delta = chunk.choices?.[0]?.delta?.content ?? "";
      process.stdout.write(delta);
      output += delta;
      if (chunk.usage) {
        inputTokens = chunk.usage.prompt_tokens ?? 0;
        outputTokens = chunk.usage.completion_tokens ?? 0;
      }
    }
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`\n[ACP] API error: ${msg}`);
    process.exit(1);
  }

  const elapsed = Date.now() - start;
  const costInput = (inputTokens * modelConfig.inputCost) / 1_000_000;
  const costOutput = (outputTokens * modelConfig.outputCost) / 1_000_000;
  const totalCost = costInput + costOutput;

  process.off("SIGINT", sigintHandler);

  appendLedger(meta, inputTokens, outputTokens, totalCost);
  updateRoutingYml(executor, modelConfig.model);

  console.log(`\n\n[ACP] ✓ Done in ${elapsed}ms`);
  console.log(
    `[ACP] Tokens: ${inputTokens} in / ${outputTokens} out | Cost: $${totalCost.toFixed(4)}`
  );
  console.log(`[ACP] Ledger updated: agent/routing/ledger.md`);
}

// ── CLI entry (skip when imported by tests) ───────────────────
function isDirectExecution(): boolean {
  const entry = process.argv[1] ?? "";
  return entry.replace(/\\/g, "/").endsWith("acp-dispatch.ts");
}

if (isDirectExecution()) {
  const taskArg = process.argv[2];
  if (!taskArg) {
    console.error(
      "Usage: npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/task-NNN.md"
    );
    process.exit(1);
  }
  dispatch(taskArg);
}
