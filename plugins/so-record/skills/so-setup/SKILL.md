# So Setup — Install So Record

Download binaries and configure Playwright for video recording. Run once per machine.

## Usage

```
/so-setup
```

## Allowed tools

- `mcp__playwright__*`
- `Bash(${CLAUDE_PLUGIN_ROOT}/scripts/download-binaries.sh)`

## Instructions

### Step 1: Run setup

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/download-binaries.sh
```

This downloads binaries to `~/.so/bin/` and generates `~/.so/playwright-config.json` with the cursor tracker configured.

### Step 2: Verify Playwright MCP

Check if `mcp__playwright__browser_navigate` is available. If not:
> "Restart this session to load Playwright MCP, then use `/so-record`."

If available:
> "Setup complete. Use `/so-record <instructions>` to record browser sessions."
