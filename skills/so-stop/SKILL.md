# So Stop — Finalize recording and produce cinematic video

Stop the current So recording session and produce a cinematic video.

## Usage

```
/so-stop
```

## Allowed tools

- `mcp__playwright__*`
- `Bash(${CLAUDE_PLUGIN_ROOT}/scripts/so-finalize-session.sh, ${CLAUDE_PLUGIN_ROOT}/scripts/so-finalize-session.sh *, ls *)`
- `Read`
- `Write`

## Instructions

Run these steps in order. Do NOT skip any step.

### Step 1: Find session ID

```bash
ls -t ~/.so/sessions/ | head -1
```

### Step 2: Retrieve cursor data (MANDATORY)

1. Call `mcp__playwright__browser_console_messages` with level "info" and all: true
2. Find all lines containing `[SO_CURSOR]`
3. Extract JSON after prefix, collect into array
4. Write to `~/.so/sessions/SESSION_ID/cursor.json`

### Step 3: Close browser

Call `mcp__playwright__browser_close`

### Step 4: Finalize

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/so-finalize-session.sh SESSION_ID
```

Report video path and file size.

## CRITICAL RULES

- **Step 2 MUST happen BEFORE Step 3.** Console messages are lost after browser close.
- **NEVER build compound Bash commands.**
