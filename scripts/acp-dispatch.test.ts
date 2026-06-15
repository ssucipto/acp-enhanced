import { describe, it, expect } from "vitest";
import { readFileSync, writeFileSync, mkdtempSync, mkdirSync, existsSync, rmSync } from "fs";
import { tmpdir } from "os";
import path from "path";
import {
  updateRoutingYml,
  getLastNSessions,
  getFilteredLessons,
  getSkillFile,
  estimateTokens,
  buildContext,
} from "./acp-dispatch.ts";

// ── updateRoutingYml (ported from node:test to vitest) ───────

const ROUTING_FIXTURE = `# Updated per session by dispatch script or manually
# DO NOT mix static and dynamic content in the same file

session:
  executor: copilot
  model: github-copilot
  persona: A

context_modes:
  current: light
  light:
    steps:
      - load_identity

command_suggestions:
  acp-status:
    - acp-update: "Refresh progress"
`;

describe("updateRoutingYml", () => {
  it("preserves context_modes and command_suggestions", () => {
    const dir = mkdtempSync(path.join(tmpdir(), "acp-routing-"));
    const routingPath = path.join(dir, "routing.yml");
    writeFileSync(routingPath, ROUTING_FIXTURE, "utf-8");

    updateRoutingYml("deepseek-v4-pro", "deepseek/deepseek-v4-pro", routingPath);

    const updated = readFileSync(routingPath, "utf-8");
    expect(updated).toMatch(/context_modes:/);
    expect(updated).toMatch(/command_suggestions:/);
    expect(updated).toMatch(/executor: deepseek-v4-pro/);
    expect(updated).toMatch(/model: deepseek\/deepseek-v4-pro/);
    expect(updated).toMatch(/persona: B/);
    expect(updated).not.toMatch(/executor: copilot/);
    rmSync(dir, { recursive: true, force: true });
  });

  it("throws when session block missing", () => {
    const dir = mkdtempSync(path.join(tmpdir(), "acp-routing-"));
    const routingPath = path.join(dir, "routing.yml");
    writeFileSync(routingPath, "context_modes:\n  current: light\n", "utf-8");

    expect(() => updateRoutingYml("x", "y", routingPath)).toThrow(
      /missing session: block/
    );
    rmSync(dir, { recursive: true, force: true });
  });
});

// ── getLastNSessions ─────────────────────────────────────────

describe("getLastNSessions", () => {
  const FIXTURE_SESSIONS = `- date: 2026-06-10
  executor: copilot
  tasks: [route-001]
  done: [a]
  key_fact: "First session"

- date: 2026-06-11
  executor: deepseek-v4-pro
  tasks: [route-002]
  done: [b]
  key_fact: "Second session"

- date: 2026-06-12
  executor: claude-sonnet
  tasks: [route-003]
  done: [c]
  key_fact: "Third session"

- date: 2026-06-13
  executor: copilot
  tasks: [route-004, route-005]
  done: [d, e]
  key_fact: "Fourth session"
`;

  it("returns empty string when content is missing", () => {
    const result = getLastNSessions(1, "");
    expect(result).toBe("");
  });

  it("returns last 1 entry", () => {
    const result = getLastNSessions(1, FIXTURE_SESSIONS);
    expect(result).toContain("Fourth session");
    expect(result).not.toContain("Third session");
  });

  it("returns last 2 entries", () => {
    const result = getLastNSessions(2, FIXTURE_SESSIONS);
    expect(result).toContain("Fourth session");
    expect(result).toContain("Third session");
    expect(result).not.toContain("Second session");
  });

  it("returns last 3 entries (default context load)", () => {
    const result = getLastNSessions(3, FIXTURE_SESSIONS);
    expect(result).toContain("Fourth session");
    expect(result).toContain("Third session");
    expect(result).toContain("Second session");
    expect(result).not.toContain("First session");
  });
});

// ── getFilteredLessons ────────────────────────────────────────

describe("getFilteredLessons", () => {
  const FIXTURE_LESSONS = `- date: 2026-06-10
  task_type: bash-script-create
  priority: normal
  mistake: "Used set -e without trap"
  correction: "Always trap errors with set -e"

- date: 2026-06-11
  task_type: bash-script-create
  priority: high
  mistake: "Forgot pipefail"
  correction: "Always use set -euo pipefail"

- date: 2026-06-12
  task_type: typescript-feature
  priority: normal
  mistake: "Type issue"
  correction: "Fix types"

- date: 2026-06-13
  task_type: all
  priority: normal
  mistake: "Context window overflow"
  correction: "Write at moment of discovery"

- date: 2026-06-14
  task_type: bash-script-create
  priority: normal
  status: archived
  mistake: "Fixed and archived"
  correction: "No longer relevant"

- date: 2026-06-15
  task_type: e2e-test-write
  priority: high
  mistake: "CRLF issue"
  correction: "Convert line endings"

- date: 2026-06-16
  task_type: bash-script-create
  priority: normal
  mistake: "Sixth bash lesson"
  correction: "This should test the cap of 5"

- date: 2026-06-17
  task_type: bash-script-create
  priority: normal
  mistake: "Seventh bash lesson"
  correction: "Beyond the cap of 5"
`;

  it("filters by exact task_type match", () => {
    const result = getFilteredLessons("bash-script-create", FIXTURE_LESSONS);
    // 4 bash-script-create + 1 "all" + 1 high = 6 relevant → capped at 5
    // Oldest (2026-06-10 "Always trap errors") is dropped by the cap
    expect(result).toContain("Always use set -euo pipefail");
    expect(result).toContain("Sixth bash lesson");
    // Oldest entry dropped by the 5-entry cap
    expect(result).not.toContain("Always trap errors");
    // Typescript-feature entry not matched (normal priority, different task_type)
    expect(result).not.toContain("Type issue");
  });

  it("returns empty string for unmatched task_type", () => {
    const result = getFilteredLessons("nonexistent-type", FIXTURE_LESSONS);
    // Only "all" type and "priority: high" should match
    expect(result).toContain("Context window overflow"); // task_type: all
    expect(result).toContain("CRLF issue"); // priority: high
    expect(result).not.toContain("Type issue"); // typescript-feature, normal
  });

  it("skips archived entries", () => {
    const result = getFilteredLessons("bash-script-create", FIXTURE_LESSONS);
    expect(result).not.toContain("status: archived");
    expect(result).not.toContain("Fixed and archived");
  });

  it("includes priority: high entries regardless of task_type", () => {
    const result = getFilteredLessons("e2e-test-write", FIXTURE_LESSONS);
    expect(result).toContain("CRLF issue"); // priority: high, different task_type
    expect(result).toContain("Context window overflow"); // task_type: all
  });

  it("caps at 5 entries", () => {
    const result = getFilteredLessons("bash-script-create", FIXTURE_LESSONS);
    // 6 relevant entries (4 bash + 1 all + 1 high) → cap at 5
    // The oldest (2026-06-10 "Always trap errors") is dropped
    const entryCount = (result.match(/- date:/g) || []).length;
    expect(entryCount).toBe(5);
    expect(result).not.toContain("Always trap errors"); // oldest, dropped by cap
  });
});

// ── getSkillFile ──────────────────────────────────────────────

describe("getSkillFile", () => {
  it("maps command-doc-write to commands.md", () => {
    expect(getSkillFile("command-doc-write")).toBe("skills/commands.md");
  });

  it("maps bash-script-create to scripts.md", () => {
    expect(getSkillFile("bash-script-create")).toBe("skills/scripts.md");
  });

  it("maps yaml-schema to schemas.md", () => {
    expect(getSkillFile("yaml-schema")).toBe("skills/schemas.md");
  });

  it("maps e2e-test-write to testing.md", () => {
    expect(getSkillFile("e2e-test-write")).toBe("skills/testing.md");
  });

  it("maps typescript-feature to typescript.md", () => {
    expect(getSkillFile("typescript-feature")).toBe("skills/typescript.md");
  });

  it("maps wiki-update to crosscut.md", () => {
    expect(getSkillFile("wiki-update")).toBe("skills/crosscut.md");
  });

  it("maps unknown type to crosscut.md (fallback)", () => {
    expect(getSkillFile("nonexistent-type")).toBe("skills/crosscut.md");
  });
});

// ── estimateTokens ────────────────────────────────────────────

describe("estimateTokens", () => {
  it("estimates ~1 token per 4 chars", () => {
    expect(estimateTokens("abcd")).toBe(1);
    expect(estimateTokens("abcdefgh")).toBe(2);
    expect(estimateTokens("abc")).toBe(1);
  });

  it("returns 0 for empty string", () => {
    expect(estimateTokens("")).toBe(0);
  });
});

// ── buildContext (budget enforcement) ─────────────────────────

describe("buildContext", () => {
  it("returns system and user keys", () => {
    const meta = { task_type: "bash-script-create" };
    const result = buildContext(meta, "Fake task content for testing.");
    expect(result).toHaveProperty("system");
    expect(result).toHaveProperty("user");
    expect(typeof result.system).toBe("string");
    expect(typeof result.user).toBe("string");
  });

  it("trims wiki content when budget exceeded", () => {
    // Create a large task content to force budget overflow (6500 tokens = ~26000 chars)
    const largeContent = "x".repeat(30000);
    const meta = { task_type: "bash-script-create" };
    const result = buildContext(meta, largeContent);
    expect(result).toHaveProperty("system");
    expect(result).toHaveProperty("user");
    // The trimmed version should have fewer sessions (2 vs 3) and the task content
    expect(typeof result.user).toBe("string");
  });
});
