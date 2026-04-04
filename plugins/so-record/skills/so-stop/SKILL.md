# So Stop — Finalize recording and produce cinematic video

## Usage

```
/so-stop
```

## Allowed tools

- `mcp__playwright__*`
- `Bash(so session *)`

## Instructions

1. Call `mcp__playwright__browser_close`
2. Run:

```bash
so session finalize ACTIVE_SESSION_ID
```

Report the output path.

## CRITICAL RULES

- **NEVER build compound Bash commands.** Only call `so` with subcommands.
