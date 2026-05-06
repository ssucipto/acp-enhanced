import matter from "gray-matter";
import yaml from "js-yaml";
import { readFileSync, existsSync, readdirSync } from "fs";
import path from "path";

// ── Shared types ─────────────────────────────────────────────
interface ValidationError {
  file: string;
  line: number;
  message: string;
  severity: "error" | "warning";
}

// ── Placeholder detection ─────────────────────────────────────
const COMMANDS_DIR = path.join("agent", "commands");

function validatePlaceholders(filePath: string): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(filePath)) return errors;

  const lines = readFileSync(filePath, "utf8").split("\n");
  let inCodeBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track fenced code blocks
    if (/^```/.test(line)) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    // Only check lines 3 and 4 (0-indexed: 2 and 3)
    if (i === 2 || i === 3) {
      const placeholderPattern = /\{[A-Za-z_][A-Za-z0-9_]*\}/g;
      const matches = line.match(placeholderPattern);
      if (matches) {
        for (const match of matches) {
          errors.push({
            file: filePath,
            line: i + 1,
            message: `Unresolved placeholder: ${match}`,
            severity: "error",
          });
        }
      }
    }
  }

  return errors;
}

function runPlaceholderScan(): void {
  if (!existsSync(COMMANDS_DIR)) {
    console.log(`Placeholder check: ${COMMANDS_DIR} not found — skipped`);
    return;
  }

  const commandFiles = readdirSync(COMMANDS_DIR)
    .filter((f) => f.endsWith(".md") && !f.endsWith(".template.md"))
    .map((f) => path.join(COMMANDS_DIR, f));

  let totalErrors = 0;
  const allErrors: ValidationError[] = [];

  for (const file of commandFiles) {
    const errs = validatePlaceholders(file);
    allErrors.push(...errs);
    totalErrors += errs.length;
  }

  if (totalErrors === 0) {
    console.log(
      `Placeholder check: ${commandFiles.length} files checked, 0 errors found ✓`
    );
  } else {
    console.error(
      `Placeholder check: ${commandFiles.length} files checked, ${totalErrors} errors found`
    );
    for (const err of allErrors) {
      console.error(`  ✗ ${err.file}:${err.line} — ${err.message}`);
    }
    process.exitCode = 1;
  }
}

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
  // No args: run placeholder scan across all command files
  runPlaceholderScan();
  process.exit(process.exitCode ?? 0);
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
