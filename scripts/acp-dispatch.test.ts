import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync, writeFileSync, mkdtempSync } from "fs";
import { tmpdir } from "os";
import path from "path";
import { updateRoutingYml } from "./acp-dispatch.ts";

const FIXTURE = `# Updated per session by dispatch script or manually
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

test("updateRoutingYml preserves context_modes and command_suggestions", () => {
  const dir = mkdtempSync(path.join(tmpdir(), "acp-routing-"));
  const routingPath = path.join(dir, "routing.yml");
  writeFileSync(routingPath, FIXTURE, "utf-8");

  updateRoutingYml("deepseek-v4-pro", "deepseek/deepseek-v4-pro", routingPath);

  const updated = readFileSync(routingPath, "utf-8");
  assert.match(updated, /context_modes:/);
  assert.match(updated, /command_suggestions:/);
  assert.match(updated, /executor: deepseek-v4-pro/);
  assert.match(updated, /model: deepseek\/deepseek-v4-pro/);
  assert.match(updated, /persona: B/);
  assert.doesNotMatch(updated, /executor: copilot/);
});

test("updateRoutingYml throws when session block missing", () => {
  const dir = mkdtempSync(path.join(tmpdir(), "acp-routing-"));
  const routingPath = path.join(dir, "routing.yml");
  writeFileSync(routingPath, "context_modes:\n  current: light\n", "utf-8");

  assert.throws(
    () => updateRoutingYml("x", "y", routingPath),
    /missing session: block/
  );
});
