#!/bin/bash
# Initialize a new So recording session.
# Checks setup, creates session directory, writes active session marker.
# Exits with error if binaries aren't installed.

if [ ! -f "$HOME/.so/bin/so-engine-cli" ]; then
  echo "ERROR: So Record not set up. Run /so-setup first." >&2
  exit 1
fi

SESSION_ID=$(date +%Y%m%d-%H%M%S)
mkdir -p "$HOME/.so/sessions/$SESSION_ID"
echo "$SESSION_ID" > "$HOME/.so/active-session"
echo "$SESSION_ID"
