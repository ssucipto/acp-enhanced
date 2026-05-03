import matter from "gray-matter";
import yaml from "js-yaml";
import { readFileSync, existsSync } from "fs";
import path from "path";

// ============================================================
// ACP Enhanced — Task Validator
// Usage: npx ts-node scripts/acp-validate.ts agent/routing/tasks/task-NNN.md
// Exits 0 if valid, exits 1 with errors if not.
// ============================================================

const AGENT_DIR = ".agent";
const TAXONOMY_PATH = path.join(AGENT_DIR, "routing", "taxonomy.yml");
const CONFIG_PATH = path.join(AGENT_DIR, "routing", "config.yml");

const REQUIRED_FIELDS = [
  "id",
  "title",
  "task_type",
  "executor",
  "complexity",
  "tokens_est",
  "created",
];

const VALID_COMPLEXITIES = ["low", "medium", "high"];

function loadYaml<T>(filePath: string): T | null {
  if (!existsSync(filePath)) return null;
  return yaml.load(readFileSync(filePath, "utf-8")) as T;
}

function validateTaskFile(taskFilePath: string): string[] {
  const errors: string[] = [];

  if (!existsSync(taskFilePath)) {
    return [`File not found: ${taskFilePath}`];
  }

  const raw = readFileSync(taskFilePath, "utf-8");
  const { data: meta } = matter(raw);

  // ── Required fields ──────────────────────────────────────
  for (const field of REQUIRED_FIELDS) {
    if (meta[field] === undefined || meta[field] === null || meta[field] === "") {
      errors.push(`Missing required field: ${field}`);
    }
  }

  // ── id format ────────────────────────────────────────────
  if (meta.id && !/^task-\d{3,}$/.test(String(meta.id))) {
    errors.push(`Invalid id format: "${meta.id}" — expected "task-NNN" (e.g. task-001)`);
  }

  // ── created date ─────────────────────────────────────────
  if (meta.created && !/^\d{4}-\d{2}-\d{2}$/.test(String(meta.created))) {
    errors.push(`Invalid created date: "${meta.created}" — expected YYYY-MM-DD`);
  }

  // ── complexity ────────────────────────────────────────────
  if (meta.complexity && !VALID_COMPLEXITIES.includes(meta.complexity)) {
    errors.push(
      `Invalid complexity: "${meta.complexity}" — expected one of: ${VALID_COMPLEXITIES.join(", ")}`
    );
  }

  // ── tokens_est ───────────────────────────────────────────
  if (meta.tokens_est !== undefined && typeof meta.tokens_est !== "number") {
    errors.push(`tokens_est must be a number, got: ${typeof meta.tokens_est}`);
  }

  // ── task_type must exist in taxonomy ────────────────────
  if (meta.task_type) {
    const taxonomy = loadYaml<any>(TAXONOMY_PATH);
    if (taxonomy) {
      const knownTypes = Object.keys(taxonomy.task_types ?? {});
      if (!knownTypes.includes(meta.task_type)) {
        errors.push(
          `Unknown task_type: "${meta.task_type}" — known types: ${knownTypes.join(", ")}`
        );
      }
    } else {
      errors.push(`Cannot load taxonomy at ${TAXONOMY_PATH} — cannot validate task_type`);
    }
  }

  // ── executor must be a valid model name ──────────────────
  if (meta.executor && meta.executor !== "local-script") {
    const config = loadYaml<any>(CONFIG_PATH);
    if (config) {
      const knownModels = Object.keys(config.models ?? {});
      if (!knownModels.includes(meta.executor)) {
        errors.push(
          `Unknown executor: "${meta.executor}" — known models: ${knownModels.join(", ")}`
        );
      }
    } else {
      errors.push(`Cannot load config at ${CONFIG_PATH} — cannot validate executor`);
    }
  }

  return errors;
}

// ── Main ───────────────────────────────────────────────────
const args = process.argv.slice(2);
if (args.length === 0) {
  console.error("Usage: ts-node acp-validate.ts <task-file.md> [task-file-2.md ...]");
  process.exit(1);
}

let overallFailed = false;

for (const taskFile of args) {
  const errors = validateTaskFile(taskFile);
  if (errors.length === 0) {
    console.log(`✓ ${taskFile}`);
  } else {
    overallFailed = true;
    console.error(`✗ ${taskFile}`);
    for (const err of errors) {
      console.error(`  - ${err}`);
    }
  }
}

process.exit(overallFailed ? 1 : 0);
