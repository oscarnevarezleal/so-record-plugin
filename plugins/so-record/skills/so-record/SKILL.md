# So Record — Cinematic browser session recording

Record a Playwright browser session and produce a polished, cinematic video with auto-zoom, rounded corners, background, and drop shadow.

## Usage

```
/so-record Navigate to stripe.com and explore the pricing page
/so-record Go to github.com/anthropics/claude-code, star the repo, browse issues
/so-record                  # (no args = start recording mode, use /so-stop to end)
```

## Allowed tools

- `mcp__playwright__*`
- `Bash($HOME/.so/bin/so *)`

## Instructions

### Step 1: Initialize session

```bash
$HOME/.so/bin/so session init
```

If this prints "ERROR", tell the user to run `/so-setup` and stop.

Otherwise it prints a SESSION_ID. Remember it.

### Step 2: Execute

**If args provided:** Use Playwright MCP tools to do the task. Navigate, click, fill — whatever is needed.

**If no args:** Say "Recording. Use `/so-stop` when done."

### Step 3: Finalize

1. Call `mcp__playwright__browser_close`
2. Run:

```bash
$HOME/.so/bin/so session finalize SESSION_ID
```

Replace SESSION_ID with the actual ID from step 1.

This single command handles everything: finds the video, extracts cursor data from console logs, transcodes, computes zoom, applies cinematic composition, and opens the result.

Report the video path from the output.

## CRITICAL RULES

- **NEVER build compound Bash commands.** Only call `$HOME/.so/bin/so` with subcommands.
- **NEVER call `browser_start_video` or `browser_stop_video`.** Video recording is automatic.
- **Do not mention "recording" during Playwright work.**
