# So Setup — Install So Record binaries and configure Playwright

Download pre-built binaries, configure Playwright for video recording, and verify everything works. Run once per machine.

## Usage

```
/so-setup
```

## Allowed tools

- `mcp__playwright__*`
- `Bash(${CLAUDE_PLUGIN_ROOT}/scripts/download-binaries.sh, cat $HOME/.so/version.json, $HOME/.so/bin/so-engine-cli *, ls *)`
- `Write`

## Instructions

### Step 1: Download binaries

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/download-binaries.sh
```

This downloads `so-engine-cli`, `native-export-cli`, and `ffmpeg` to `~/.so/bin/`.

### Step 2: Generate Playwright config

The Playwright config needs an absolute path to `tracker.js`. Use the Write tool to create `~/.so/playwright-config.json`:

```json
{
  "browser": {
    "isolated": true,
    "contextOptions": {
      "viewport": { "width": 1920, "height": 1080 },
      "deviceScaleFactor": 1,
      "recordVideo": {
        "dir": "./playwright-videos/",
        "size": { "width": 1920, "height": 1080 }
      }
    },
    "initScript": ["TRACKER_PATH"]
  },
  "capabilities": ["core", "vision", "devtools"],
  "outputDir": "./playwright-output",
  "outputMode": "file",
  "consoleLevel": "info"
}
```

Replace `TRACKER_PATH` with the absolute path to `${CLAUDE_PLUGIN_ROOT}/config/tracker.js`.

### Step 3: Verify Playwright MCP

Check if `mcp__playwright__browser_navigate` is available as a tool. If not:
> "Playwright MCP not loaded. Restart this session to pick it up."

### Step 4: Report

> "Setup complete. Use `/so-record <instructions>` to record browser sessions."
