# So Record — Usage Guide

## Install

```bash
git clone https://github.com/oscarnevarezleal/so-record-plugin ~/.claude/plugins/repos/so-record
```

Restart Claude Code to load the plugin.

## First-Time Setup

```
/so-setup
```

Downloads `so-engine-cli`, `native-export-cli`, and `ffmpeg` to `~/.so/bin/`. Generates Playwright config with video recording enabled. Run once per machine.

## Recording a Session

### One-shot (recommended)

Give instructions and get a video back:

```
/so-record Navigate to stripe.com and explore the pricing page
/so-record Go to github.com/anthropics/claude-code, star the repo, browse issues
/so-record Open docs.anthropic.com, search for "tool use", click the first result
```

Claude opens the browser, executes the task, captures cursor data, closes the browser, and produces a cinematic video. No other commands needed.

### Interactive

Start recording, browse manually, stop when ready:

```
/so-record
```

Claude opens the browser and waits. Ask it to navigate, click, fill forms — whatever you need. When done:

```
/so-stop
```

## Output

Videos are saved to:

```
~/.so/sessions/<session-id>/output/cinematic.mp4
```

The video opens automatically after finalization.

## What Gets Captured

| Data | Source | Used For |
|------|--------|----------|
| Browser video | Playwright `recordVideo` (VP8/WebM, auto-transcoded to H.264/MP4) | The raw footage |
| Interaction events | Claude Code hooks (navigations, clicks, fills) | Segment boundaries |
| Cursor positions | Injected tracker script via `console.log` | Auto-zoom to click targets |

## Cinematic Treatment

Every video gets:
- Dark background (`#0f0f23`)
- 6% padding
- 16px rounded corners
- Drop shadow
- Auto-zoom to click locations (when cursor data is available)

## Session Files

```
~/.so/
├── bin/                        # Downloaded binaries
│   ├── so-engine-cli
│   ├── native-export-cli
│   └── ffmpeg
├── active-session              # Current session marker (for hooks)
├── version.json                # Installed binary version
└── sessions/
    └── 20260402-104847/        # One directory per session
        ├── events.jsonl        # Hook-captured interaction events
        ├── cursor.json         # Cursor tracking data from browser
        └── output/
            ├── session.mp4     # Transcoded source video
            ├── manifest.json   # CaptureManifest for the pipeline
            ├── zoom_segments.json  # Computed zoom targets
            └── cinematic.mp4   # Final polished video
```

## Requirements

- macOS (Apple Silicon)
- Claude Code
- Node.js (for Playwright MCP: `npx @playwright/mcp`)

## Troubleshooting

**"Run `/so-setup` first"** — Binaries aren't installed. Run `/so-setup`.

**No video produced** — The browser must close before the WebM file is finalized. Ensure `/so-stop` or the auto-finalize step ran.

**Viewport looks zoomed in** — Check that `deviceScaleFactor: 1` is in the Playwright config at `~/.so/playwright-config.json`.

**No cursor data** — The skill needs to call `browser_console_messages` before `browser_close`. If using `/so-stop`, it handles this automatically. If the session ended via `/so-record` auto-finalize, cursor retrieval depends on Claude following the skill instructions.

**"No cli-v* releases found"** — The download script can't find a release. Check https://github.com/oscarnevarezleal/screen-recorder/releases for available versions, or build from source:

```bash
cd /path/to/screen-recorder
cargo build -p so-engine --features cli --bin so-engine-cli --release
cargo build -p recorder-macos --bin native-export-cli --release
cp target/release/so-engine-cli target/release/native-export-cli ~/.so/bin/
```
