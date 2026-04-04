#!/bin/bash
# Finalize a So recording session: find video, transcode, compute zoom, compose.
# Usage: so-finalize-session.sh <SESSION_ID>
set -e

SESSION_ID="${1:?Usage: so-finalize-session.sh <SESSION_ID>}"
SESSION_DIR="$HOME/.so/sessions/$SESSION_ID"
CLI="$HOME/.so/bin/so-engine-cli"

# Add ~/.so/bin to PATH so so-engine-cli can find ffmpeg/ffprobe
export PATH="$HOME/.so/bin:$PATH"

# Find most recent WebM
WEBM=$(ls -t playwright-videos/*.webm 2>/dev/null | head -1)
if [ -z "$WEBM" ]; then
  echo "Error: No WebM found in playwright-videos/" >&2
  exit 1
fi
echo "Video: $WEBM ($(du -h "$WEBM" | cut -f1))"

# Build finalize args
FINALIZE_ARGS="--video $WEBM --output $SESSION_DIR/output/"

if [ -f "$SESSION_DIR/events.jsonl" ] && [ -s "$SESSION_DIR/events.jsonl" ]; then
  FINALIZE_ARGS="$FINALIZE_ARGS --events $SESSION_DIR/events.jsonl"
fi

if [ -f "$SESSION_DIR/cursor.json" ] && [ -s "$SESSION_DIR/cursor.json" ]; then
  FINALIZE_ARGS="$FINALIZE_ARGS --cursor $SESSION_DIR/cursor.json"
  echo "Cursor data: $(wc -c < "$SESSION_DIR/cursor.json" | tr -d ' ') bytes"
fi

# Finalize (auto-transcodes WebM → MP4)
"$CLI" session finalize $FINALIZE_ARGS

# Compute zoom segments if cursor data produced a Tier 2 manifest
ZOOM_ARGS=""
MANIFEST="$SESSION_DIR/output/manifest.json"
if [ -f "$MANIFEST" ]; then
  HAS_CURSOR=$(python3 -c "import json; m=json.load(open('$MANIFEST')); print('yes' if m.get('cursor') else 'no')" 2>/dev/null || echo "no")
  if [ "$HAS_CURSOR" = "yes" ]; then
    ZOOM_FILE="$SESSION_DIR/output/zoom_segments.json"
    "$CLI" session zoom --manifest "$MANIFEST" --zoom-level 2.0 --output "$ZOOM_FILE"
    ZOOM_ARGS="--zoom-segments-file $ZOOM_FILE"
  fi
fi

# Cinematic composition — use native backend on macOS, ffmpeg fallback elsewhere
NATIVE_CLI="$HOME/.so/bin/native-export-cli"
if [ "$(uname -s)" = "Darwin" ] && [ -f "$NATIVE_CLI" ]; then
  "$NATIVE_CLI" export \
    -i "$SESSION_DIR/output/session.mp4" \
    -o "$SESSION_DIR/output/cinematic.mp4" \
    --bg-type color --bg-color "#0f0f23" \
    --padding 0.06 --corner-radius 16 --shadow \
    --codec h264 --quality high \
    $ZOOM_ARGS
else
  # Future: so-compose-ffmpeg for Linux/Windows
  echo "Error: native-export-cli not found. Run /so-setup to install." >&2
  exit 1
fi

# Clean up consumed WebM
rm -f "$WEBM"

# Open and report
open "$SESSION_DIR/output/cinematic.mp4" 2>/dev/null || true
du -h "$SESSION_DIR/output/cinematic.mp4"
