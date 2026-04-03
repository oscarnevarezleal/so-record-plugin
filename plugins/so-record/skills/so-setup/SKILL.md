# So Setup — Install So Record

Download binaries, configure Playwright MCP, and set up video recording. Run once per project.

## Usage

```
/so-setup
```

## Allowed tools

- `mcp__playwright__*`
- `Bash(${CLAUDE_PLUGIN_ROOT}/scripts/download-binaries.sh)`
- `Write`
- `Read`

## Instructions

### Step 1: Download binaries

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/download-binaries.sh
```

### Step 2: Add Playwright MCP to this project

Check if `.mcp.json` exists in the current directory. If it does, read it. If it already has a `playwright` entry, skip this step.

Otherwise, use the Write tool to create or update `.mcp.json` in the current working directory with the Playwright MCP server. The config path must be the absolute path printed by the download script (look for `playwright-config:` in the output).

Example `.mcp.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--config", "/absolute/path/to/playwright-config.json"]
    }
  }
}
```

Use the actual path from the download script output for the `--config` value.

### Step 3: Report

If Playwright MCP tools are available:
> "Setup complete. Use `/so-record <instructions>` to record browser sessions."

If not:
> "Setup complete. Restart this session to load Playwright MCP, then use `/so-record`."
