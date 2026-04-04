#!/bin/bash
# Download So Record binaries for the current platform.
# Fetches pre-built binaries from GitHub Releases.
set -e

SO_DIR="$HOME/.so"
BIN_DIR="$SO_DIR/bin"
REPO="oscarnevarezleal/screen-recorder"
FFMPEG_BASE_URL="https://github.com/eugeneware/ffmpeg-static/releases/latest/download"

mkdir -p "$BIN_DIR"

# Detect platform
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  PLATFORM="darwin-arm64" ;;
      x86_64) PLATFORM="darwin-x64" ;;
      *)      echo "Error: Unsupported macOS architecture: $ARCH" >&2; exit 1 ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64) PLATFORM="linux-x64" ;;
      *)      echo "Error: Unsupported Linux architecture: $ARCH" >&2; exit 1 ;;
    esac
    ;;
  *)
    echo "Error: Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

echo "Platform: $PLATFORM"

# Get latest release version (uses gh CLI for auth with private repos)
echo "Checking latest release..."
if command -v gh &>/dev/null; then
  LATEST=$(gh release list --repo "$REPO" --limit 10 2>/dev/null | grep "^cli-v" | head -1 | awk '{print $3}')
else
  LATEST=$(curl -sL "https://api.github.com/repos/$REPO/releases" | \
    python3 -c "import sys,json; releases=json.load(sys.stdin); cli=[r for r in releases if r['tag_name'].startswith('cli-v')]; print(cli[0]['tag_name'] if cli else '')" 2>/dev/null)
fi

if [ -z "$LATEST" ]; then
  echo "No cli-v* releases found. Using development binaries." >&2
  echo "Build from source: cargo build -p so-engine --features cli --release" >&2
  exit 1
fi

echo "Latest: $LATEST"

# Check if already installed
INSTALLED_VERSION=$(python3 -c "import json; print(json.load(open('$SO_DIR/version.json'))['version'])" 2>/dev/null || echo "none")
if [ "$INSTALLED_VERSION" = "$LATEST" ]; then
  echo "Already up to date ($LATEST)"
  exit 0
fi

# Download release tarball
TARBALL="so-record-${PLATFORM}.tar.gz"
echo "Downloading $TARBALL from $LATEST..."

TMPDIR=$(mktemp -d)
if command -v gh &>/dev/null; then
  gh release download "$LATEST" --repo "$REPO" --pattern "$TARBALL" --dir "$TMPDIR" 2>/dev/null
else
  DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST/$TARBALL"
  curl -sL "$DOWNLOAD_URL" -o "$TMPDIR/$TARBALL"
fi

if [ ! -s "$TMPDIR/$TARBALL" ]; then
  echo "Error: Download failed or empty file" >&2
  rm -rf "$TMPDIR"
  exit 1
fi

# Extract
echo "Extracting to $BIN_DIR..."
tar -xzf "$TMPDIR/$TARBALL" -C "$BIN_DIR"
chmod +x "$BIN_DIR/so" "$BIN_DIR/so-engine-cli" "$BIN_DIR/native-export-cli" 2>/dev/null || true
rm -rf "$TMPDIR"

# Download ffmpeg if missing
if [ ! -f "$BIN_DIR/ffmpeg" ]; then
  echo "Downloading ffmpeg..."
  case "$PLATFORM" in
    darwin-arm64)  FFMPEG_TARGET="darwin-arm64" ;;
    darwin-x64)    FFMPEG_TARGET="darwin-x64" ;;
    linux-x64)     FFMPEG_TARGET="linux-x64" ;;
  esac
  curl -sL "$FFMPEG_BASE_URL/ffmpeg-$FFMPEG_TARGET" -o "$BIN_DIR/ffmpeg"
  chmod +x "$BIN_DIR/ffmpeg"

  # Also get ffprobe
  curl -sL "$FFMPEG_BASE_URL/ffprobe-$FFMPEG_TARGET" -o "$BIN_DIR/ffprobe"
  chmod +x "$BIN_DIR/ffprobe"
fi

# Write version file
cat > "$SO_DIR/version.json" << EOF
{
  "version": "$LATEST",
  "platform": "$PLATFORM",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "bin_dir": "$BIN_DIR"
}
EOF

# Generate Playwright config with absolute tracker.js path
# Write into the plugin's config directory (where mcp-servers.json references it)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
TRACKER_PATH="$(cd "$CONFIG_DIR" && pwd)/tracker.js"

cat > "$CONFIG_DIR/playwright-config.json" << PEOF
{
  "browser": {
    "isolated": true,
    "contextOptions": {
      "viewport": { "width": 1920, "height": 1080 },
      "deviceScaleFactor": 1,
      "recordVideo": {
        "dir": "./playwright-videos/",
        "size": { "width": 1920, "height": 1080 }
      }
    },
    "initScript": ["$TRACKER_PATH"]
  },
  "capabilities": ["core", "vision", "devtools"],
  "outputDir": "./playwright-output",
  "outputMode": "file",
  "consoleLevel": "info"
}
PEOF

echo "Installed $LATEST for $PLATFORM"
echo "  so-engine-cli:      $BIN_DIR/so-engine-cli"
echo "  native-export-cli:  $BIN_DIR/native-export-cli"
echo "  ffmpeg:             $BIN_DIR/ffmpeg"
echo "  playwright-config:  $CONFIG_DIR/playwright-config.json"
echo "  tracker.js:         $TRACKER_PATH"
