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
- `Bash(${CLAUDE_PLUGIN_ROOT}/scripts/so-init-session.sh, ${CLAUDE_PLUGIN_ROOT}/scripts/so-finalize-session.sh, ${CLAUDE_PLUGIN_ROOT}/scripts/so-finalize-session.sh *)`
- `Write`

## Instructions

### Step 1: Initialize session

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/so-init-session.sh
```

If this prints "ERROR", tell the user to run `/so-setup` and stop.

Otherwise it prints a SESSION_ID (e.g. `20260402-104847`). Remember it.

### Step 2: Execute

**If args provided:** Use Playwright MCP tools to do the task. Navigate, click, fill — whatever is needed.

**If no args:** Say "Recording. Use `/so-stop` when done."

### Step 3: Retrieve cursor data

**THIS STEP IS MANDATORY. Do NOT skip it.**

Before closing the browser:

1. Call `mcp__playwright__browser_console_messages` with level "info" and all: true
2. From the response, extract all lines containing `[SO_CURSOR]`
3. Parse the JSON object after each `[SO_CURSOR]` prefix
4. Collect into an array and use Write tool to save as `~/.so/sessions/SESSION_ID/cursor.json`
5. If no `[SO_CURSOR]` lines found, skip saving

### Step 4: Finalize

1. Call `mcp__playwright__browser_close`
2. Run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/so-finalize-session.sh SESSION_ID
```

Replace SESSION_ID with the actual ID from step 1.

Report the video path and file size.

## CRITICAL RULES

- **NEVER build compound Bash commands.** Only call the scripts above.
- **NEVER call `browser_start_video` or `browser_stop_video`.** Video recording is automatic.
- **ALWAYS retrieve cursor data (Step 3) before closing the browser (Step 4).**
- **Do not mention "recording" during Playwright work.**
