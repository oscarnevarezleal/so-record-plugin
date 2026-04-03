#!/bin/bash
# So Record hook — captures Playwright interaction events.
# Called by Claude Code on every PreToolUse/PostToolUse.
# Non-Playwright tools are filtered by the CLI (silent no-op).

SESSION_ID=$(cat "$HOME/.so/active-session" 2>/dev/null)
[ -z "$SESSION_ID" ] && exit 0

CLI="$HOME/.so/bin/so-engine-cli"
[ ! -f "$CLI" ] && exit 0

exec "$CLI" session append --log "$HOME/.so/sessions/$SESSION_ID/events.jsonl"
