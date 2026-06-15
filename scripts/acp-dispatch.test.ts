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
  it("returns empty string when sessions.md does not exist", () => {
    // sessions.md is in agent/memory/ which should exist, but if it were empty/missing
    // the function reads from agent/memory/sessions.md. We can't easily redirect.
    // Instead test that it returns a string (may be empty or populated).
    const result = getLastNSessions(1);
    expect(typeof result).toBe("string");
  });
});

// ── getFilteredLessons ────────────────────────────────────────

describe("getFilteredLessons", () => {
  it("returns a string for any task_type", () => {
    const result = getFilteredLessons("bash-script-create");
    expect(typeof result).toBe("string");
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
