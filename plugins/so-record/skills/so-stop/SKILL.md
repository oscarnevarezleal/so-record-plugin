# So Stop — Finalize recording and produce cinematic video

## Usage

```
/so-stop
```

## Allowed tools

- `mcp__playwright__*`
- `Bash($HOME/.so/bin/so *)`

## Instructions

1. Call `mcp__playwright__browser_close`
2. Run:

```bash
$HOME/.so/bin/so session finalize ACTIVE_SESSION_ID
```

The `so` binary reads cursor data from console logs automatically, transcodes, computes zoom, composes, and opens the video. Report the output path.

## CRITICAL RULES

- **NEVER build compound Bash commands.** Only call `$HOME/.so/bin/so`.
