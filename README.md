# So Record — Claude Code Plugin

Record Playwright browser sessions as cinematic videos with auto-zoom, rounded corners, and polished composition. Works with any Claude Code project that uses Playwright MCP.

## Install

```bash
git clone https://github.com/oscarnevarezleal/so-record-plugin ~/.claude/plugins/repos/so-record
```

Then restart Claude Code and run `/so-setup` to download binaries.

## Usage

```
/so-setup                    # one-time: downloads binaries, configures Playwright
/so-record <instructions>    # record a browser session
/so-stop                     # finalize and produce cinematic video
```

### Examples

```
/so-record Navigate to stripe.com and explore the pricing page
/so-record Go to github.com/anthropics/claude-code, click on issues, browse a few
/so-record Open docs.anthropic.com, search for "tool use", read the first result
```

## What It Does

1. **Records** the Playwright browser session as video (VP8/WebM via Playwright's `recordVideo`)
2. **Tracks** mouse movements, clicks, and scrolls via an injected cursor tracker
3. **Captures** interaction events (navigations, clicks, fills) from Claude Code hooks
4. **Transcodes** WebM to H.264/MP4 for AVFoundation compatibility
5. **Computes** auto-zoom segments from click clusters
6. **Composes** the final video with rounded corners, dark background, padding, drop shadow, and auto-zoom

## Output

Videos are saved to `~/.so/sessions/<session-id>/output/cinematic.mp4`.

## Requirements

- macOS (arm64 or x86_64)
- Claude Code with Playwright MCP
- Node.js (for `npx @playwright/mcp`)

## Architecture

The plugin is a thin orchestration layer. Heavy lifting is done by two Rust binaries:

- **so-engine-cli** — session management, manifest production, zoom computation
- **native-export-cli** — cinematic composition via AVFoundation

Both are downloaded automatically by `/so-setup` from GitHub Releases.
