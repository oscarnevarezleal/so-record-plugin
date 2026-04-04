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

Otherwise, use the Write tool to create or update `.mcp.json` with the Playwright MCP server. Use the `playwright-config:` path from the download script output.

Example `.mcp.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--config", "/path/from/download/output/playwright-config.json"]
    }
  }
}
```

### Step 3: Add so to PATH

Tell the user to add `~/.so/bin` to their PATH if not already there:

> Add to your shell profile (`~/.zshrc` or `~/.bashrc`):
> ```
> export PATH="$HOME/.so/bin:$PATH"
> ```
> Then restart your terminal and Claude Code.

### Step 4: Report

> "Setup complete. Restart this session to load Playwright MCP, then use `/so-record`."
