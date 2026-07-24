# CodeRabbit Local Summary

- `scripts`: 2 findings (`major`: 2).
- `agent/scripts`: 2 findings (`major`: 1, `minor`: 1).
- `e2e`: no review findings recorded because the chunk is `blocked`. Blocked by CodeRabbit rate limiting (27 minutes wait), which exceeded the requested 10-minute per-review cap.
- `.github/workflows`: no review findings recorded because the chunk is `blocked`. Blocked: the explicit workflows retry produced no output before the requested 12-minute total wait budget expired, so no fallback run was started.

## Top Findings

- `scripts` | `major` | `scripts/acp-validate.ts`: In @scripts/acp-validate.ts at line 1070, Update the SCHEMAS_DIR initialization in scripts/acp-validate.ts so relative ACP_SCHEMAS_DIR overrides are resolved through repoPath() from the repository root, while absolute overrides remain unchanged. Preserve the existing default repoPath("agent", "schemas") behavior when the environment variable is unset.
- `scripts` | `major` | `scripts/acp-validate.ts`: In @scripts/acp-validate.ts around lines 1105 - 1113, Update resolveOriginGithubRepo and its downstream GitHub API call to avoid shell interpolation: restrict parsed origin URLs to approved GitHub hostnames and validate the owner/repository segments before use. Replace the execSync invocation at the GitHub API call site with execFileSync("gh", ["api", endpoint], …), passing arguments directly rather than through a shell.
- `agent/scripts` | `major` | `agent/scripts/acp.project-update.sh`: In @agent/scripts/acp.project-update.sh around lines 206 - 208, Move the current_tags assignment using yaml_query from before the ADD_TAGS loop into the loop body so it runs before processing each tag. Ensure each iteration reads the updated project registry after the previous mutation, preventing duplicate tags keys when multiple tags are added.
- `agent/scripts` | `minor` | `agent/scripts/acp.post-milestone-sweep.sh`: In @agent/scripts/acp.post-milestone-sweep.sh around lines 145 - 148, Update the gate 5 failure branch in the TOKEN_FAILS check to explicitly report when TOTAL_TOKENS exceeds TOTAL_MAX, even if TOKEN_FAILS is zero. Preserve the existing per-file failure count and limit details, while including the total-budget violation in the fail_gate message.

## Incomplete Chunks

- `e2e`: Blocked by CodeRabbit rate limiting (27 minutes wait), which exceeded the requested 10-minute per-review cap.
- `.github/workflows`: Blocked: the explicit workflows retry produced no output before the requested 12-minute total wait budget expired, so no fallback run was started.
