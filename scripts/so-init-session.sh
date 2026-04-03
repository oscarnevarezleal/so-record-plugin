#!/bin/bash
# Initialize a new So recording session.
# Creates session directory and writes active session marker.
# Prints the session ID to stdout.
SESSION_ID=$(date +%Y%m%d-%H%M%S)
mkdir -p "$HOME/.so/sessions/$SESSION_ID"
echo "$SESSION_ID" > "$HOME/.so/active-session"
echo "$SESSION_ID"
